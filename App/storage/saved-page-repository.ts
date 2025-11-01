import * as FileSystem from 'expo-file-system/legacy';

import { getDatabase } from '@/storage/database';
import { emitSavedPagesEvent } from '@/storage/events';
import {
  SavedPage,
  SavedPageChangeEvent,
  SavedPageCreateInput,
  SavedPageRecord,
  SavedPageStatus,
  SavedPageUpdateInput,
} from '@/storage/types';

function toDomain(record: SavedPageRecord): SavedPage {
  return {
    id: record.id,
    url: record.url,
    title: record.title,
    summary: record.summary,
    status: record.status,
    fileUri: record.file_uri,
    previewImageUri: record.preview_image_uri,
    contentType: record.content_type,
    contentLength: record.content_length,
    createdAt: record.created_at,
    updatedAt: record.updated_at,
    lastError: record.last_error,
  };
}

function nowISO() {
  return new Date().toISOString();
}

async function notify(event: SavedPageChangeEvent) {
  emitSavedPagesEvent(event);
}

async function deleteFileIfExists(fileUri: string | null) {
  if (!fileUri) {
    return;
  }

  try {
    const info = await FileSystem.getInfoAsync(fileUri);
    if (info.exists) {
      await FileSystem.deleteAsync(fileUri, { idempotent: true });
    }
  } catch (error) {
    console.warn('Failed to remove saved page file', fileUri, error);
  }
}

export async function listSavedPages(): Promise<SavedPage[]> {
  const db = await getDatabase();
  const rows = await db.getAllAsync<SavedPageRecord>(
    'SELECT * FROM saved_pages ORDER BY created_at DESC'
  );
  return rows.map(toDomain);
}

export async function getSavedPageById(id: number): Promise<SavedPage | null> {
  const db = await getDatabase();
  const row = await db.getFirstAsync<SavedPageRecord>('SELECT * FROM saved_pages WHERE id = ?', id);
  return row ? toDomain(row) : null;
}

export async function getSavedPageByUrl(url: string): Promise<SavedPage | null> {
  const db = await getDatabase();
  const row = await db.getFirstAsync<SavedPageRecord>('SELECT * FROM saved_pages WHERE url = ?', url);
  return row ? toDomain(row) : null;
}

export async function createSavedPage(input: SavedPageCreateInput): Promise<SavedPage> {
  const db = await getDatabase();
  const existingWithUrl = await getSavedPageByUrl(input.url);

  if (existingWithUrl) {
    throw new Error('Page already saved');
  }

  const createdAt = nowISO();
  const updatedAt = createdAt;
  const status: SavedPageStatus = input.status ?? 'queued';

  const result = await db.runAsync(
    `INSERT INTO saved_pages (
      url,
      title,
      summary,
      status,
      file_uri,
      preview_image_uri,
      content_type,
      content_length,
      created_at,
      updated_at,
      last_error
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
      .replace(/\s+/g, ' ')
      .trim(),
    input.url,
    input.title ?? null,
    input.summary ?? null,
    status,
    input.fileUri ?? null,
    input.previewImageUri ?? null,
    input.contentType ?? null,
    input.contentLength ?? null,
    createdAt,
    updatedAt,
    input.lastError ?? null
  );

  const savedPage = await getSavedPageById(result.lastInsertRowId);
  if (!savedPage) {
    throw new Error('Failed to fetch saved page after insertion');
  }

  await notify({ type: 'created', pageId: savedPage.id });
  return savedPage;
}

export async function updateSavedPage(id: number, updates: SavedPageUpdateInput): Promise<SavedPage> {
  const db = await getDatabase();
  const existing = await getSavedPageById(id);

  if (!existing) {
    throw new Error(`Saved page ${id} not found`);
  }

  const merged = {
    ...existing,
    ...updates,
  };

  const updatedAt = nowISO();

  await db.runAsync(
    `UPDATE saved_pages
     SET title = ?,
         summary = ?,
         status = ?,
         file_uri = ?,
         preview_image_uri = ?,
         content_type = ?,
         content_length = ?,
         last_error = ?,
         updated_at = ?
     WHERE id = ?`,
    merged.title ?? null,
    merged.summary ?? null,
    merged.status,
    merged.fileUri ?? null,
    merged.previewImageUri ?? null,
    merged.contentType ?? null,
    merged.contentLength ?? null,
    merged.lastError ?? null,
    updatedAt,
    id
  );

  const savedPage = await getSavedPageById(id);
  if (!savedPage) {
    throw new Error('Saved page disappeared after update');
  }

  await notify({ type: 'updated', pageId: id });
  return savedPage;
}

export async function transitionSavedPage(id: number, status: SavedPageStatus, lastError?: string) {
  return updateSavedPage(id, {
    status,
    lastError: lastError ?? null,
  });
}

export async function deleteSavedPage(id: number): Promise<void> {
  const db = await getDatabase();
  const existing = await getSavedPageById(id);

  await db.runAsync('DELETE FROM saved_pages WHERE id = ?', id);
  await deleteFileIfExists(existing?.fileUri ?? null);
  await notify({ type: 'deleted', pageId: id });
}

export async function clearSavedPages(): Promise<void> {
  const db = await getDatabase();
  const pages = await listSavedPages();
  await db.runAsync('DELETE FROM saved_pages');
  await Promise.all(pages.map((page) => deleteFileIfExists(page.fileUri)));
  await notify({ type: 'deleted', pageId: -1 });
}


