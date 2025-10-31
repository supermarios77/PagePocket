export type SavedPageStatus =
  | 'queued'
  | 'downloading'
  | 'ready'
  | 'error'
  | 'archived';

export type SavedPageRecord = {
  id: number;
  url: string;
  title: string | null;
  summary: string | null;
  status: SavedPageStatus;
  file_uri: string | null;
  preview_image_uri: string | null;
  content_type: string | null;
  content_length: number | null;
  created_at: string;
  updated_at: string;
  last_error: string | null;
};

export type SavedPage = {
  id: number;
  url: string;
  title: string | null;
  summary: string | null;
  status: SavedPageStatus;
  fileUri: string | null;
  previewImageUri: string | null;
  contentType: string | null;
  contentLength: number | null;
  createdAt: string;
  updatedAt: string;
  lastError: string | null;
};

export type SavedPageCreateInput = {
  url: string;
  title?: string | null;
  summary?: string | null;
  status?: SavedPageStatus;
  fileUri?: string | null;
  previewImageUri?: string | null;
  contentType?: string | null;
  contentLength?: number | null;
  lastError?: string | null;
};

export type SavedPageUpdateInput = Partial<
  Pick<
    SavedPage,
    | 'title'
    | 'summary'
    | 'status'
    | 'fileUri'
    | 'previewImageUri'
    | 'contentType'
    | 'contentLength'
    | 'lastError'
  >
>;

export type SavedPageChangeEvent =
  | { type: 'created'; pageId: number }
  | { type: 'updated'; pageId: number }
  | { type: 'deleted'; pageId: number };


