const initialSchema = `
  CREATE TABLE IF NOT EXISTS migrations (
    id INTEGER PRIMARY KEY
  );

  CREATE TABLE IF NOT EXISTS saved_pages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    url TEXT NOT NULL,
    title TEXT,
    summary TEXT,
    status TEXT NOT NULL,
    file_uri TEXT,
    preview_image_uri TEXT,
    content_type TEXT,
    content_length INTEGER,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    last_error TEXT
  );

  CREATE INDEX IF NOT EXISTS idx_saved_pages_status ON saved_pages(status);
  CREATE INDEX IF NOT EXISTS idx_saved_pages_created_at ON saved_pages(created_at DESC);
`;

export const MIGRATIONS: readonly string[] = [initialSchema];


