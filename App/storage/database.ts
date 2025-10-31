import * as SQLite from 'expo-sqlite';

import { MIGRATIONS } from '@/storage/migrations';

let databasePromise: Promise<SQLite.SQLiteDatabase> | null = null;

async function applyMigrations(db: SQLite.SQLiteDatabase) {
  await db.execAsync('CREATE TABLE IF NOT EXISTS migrations (id INTEGER PRIMARY KEY)');

  const appliedMigrations = await db.getAllAsync<{ id: number }>(
    'SELECT id FROM migrations ORDER BY id ASC'
  );

  const appliedIds = new Set(appliedMigrations.map((row) => row.id));

  for (let migrationIndex = 0; migrationIndex < MIGRATIONS.length; migrationIndex += 1) {
    const migrationId = migrationIndex + 1;
    if (appliedIds.has(migrationId)) {
      continue;
    }

    await db.withTransactionAsync(async () => {
      await db.execAsync(MIGRATIONS[migrationIndex]);
      await db.runAsync('INSERT INTO migrations (id) VALUES (?)', migrationId);
    });
  }
}

export async function getDatabase() {
  if (!databasePromise) {
    databasePromise = (async () => {
      const db = await SQLite.openDatabaseAsync('pagepocket.db');

      await db.execAsync('PRAGMA journal_mode = WAL;');
      await db.execAsync('PRAGMA foreign_keys = ON;');

      await applyMigrations(db);

      return db;
    })();
  }

  return databasePromise;
}


