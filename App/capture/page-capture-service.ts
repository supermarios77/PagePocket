import * as FileSystem from 'expo-file-system/legacy';

import {
  getSavedPageById,
  transitionSavedPage,
  updateSavedPage,
} from '@/storage/saved-page-repository';

const PAGES_DIRECTORY = `${FileSystem.documentDirectory ?? ''}saved-pages`;

let isProcessing = false;
const queue: number[] = [];

async function ensurePagesDirectory() {
  if (!PAGES_DIRECTORY) {
    throw new Error('FileSystem document directory unavailable');
  }

  const info = await FileSystem.getInfoAsync(PAGES_DIRECTORY);
  if (!info.exists) {
    await FileSystem.makeDirectoryAsync(PAGES_DIRECTORY, { intermediates: true });
  }
}

function extractTitle(html: string): string | null {
  const match = html.match(/<title>([^<]*)<\/title>/i);
  if (!match) {
    return null;
  }
  return match[1].trim() || null;
}

async function processQueue() {
  if (isProcessing) {
    return;
  }
  isProcessing = true;

  while (queue.length > 0) {
    const nextPageId = queue.shift();
    if (typeof nextPageId !== 'number') {
      continue;
    }

    try {
      await downloadPage(nextPageId);
    } catch (error) {
      console.error(`Failed to capture page ${nextPageId}`, error);
    }
  }

  isProcessing = false;
}

async function downloadPage(pageId: number) {
  const savedPage = await getSavedPageById(pageId);
  if (!savedPage) {
    return;
  }

  await transitionSavedPage(pageId, 'downloading');

  try {
    await ensurePagesDirectory();

    const response = await fetch(savedPage.url);
    if (!response.ok) {
      throw new Error(`Unexpected status code ${response.status}`);
    }

    const html = await response.text();
    const fileUri = `${PAGES_DIRECTORY}/${pageId}.html`;

    await FileSystem.writeAsStringAsync(fileUri, html, {
      encoding: FileSystem.EncodingType.UTF8,
    });

    const title = savedPage.title ?? extractTitle(html);
    const contentType = response.headers.get('content-type');
    const contentLengthHeader = response.headers.get('content-length');
    const contentLength = contentLengthHeader ? Number(contentLengthHeader) : null;

    await updateSavedPage(pageId, {
      status: 'ready',
      fileUri,
      title,
      contentType,
      contentLength,
      lastError: null,
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    await transitionSavedPage(pageId, 'error', message);
    console.warn(`Failed to capture page ${pageId}: ${message}`);
  }
}

export function queueSavedPageCapture(pageId: number) {
  queue.push(pageId);
  void processQueue();
}


