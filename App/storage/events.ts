import { SavedPageChangeEvent } from '@/storage/types';

type SavedPageListener = (event: SavedPageChangeEvent) => void;

const listeners = new Set<SavedPageListener>();

export function subscribeToSavedPages(listener: SavedPageListener) {
  listeners.add(listener);
  return () => {
    listeners.delete(listener);
  };
}

export function emitSavedPagesEvent(event: SavedPageChangeEvent) {
  listeners.forEach((listener) => {
    try {
      listener(event);
    } catch (error) {
      console.error('Error notifying saved pages listener', error);
    }
  });
}


