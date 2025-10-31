import { useCallback, useMemo, useState } from 'react';
import { Alert, Pressable, ScrollView, StyleSheet, View } from 'react-native';

import { useFocusEffect } from '@react-navigation/native';
import { useRouter } from 'expo-router';

import { ThemedText } from '@/components/themed-text';
import { ThemedView } from '@/components/themed-view';
import { Colors } from '@/constants/theme';
import { useColorScheme } from '@/hooks/use-color-scheme';
import {
  deleteSavedPage,
  listSavedPages,
  SavedPage,
  subscribeToSavedPages,
} from '@/storage';
import { queueSavedPageCapture } from '@/capture/page-capture-service';

function useStatusLabel(page: SavedPage, tintColor: string) {
  return useMemo(() => {
    switch (page.status) {
      case 'ready':
        return { label: 'Ready to read offline', color: tintColor };
      case 'queued':
        return { label: 'Queued for download', color: '#F59E0B' };
      case 'downloading':
        return { label: 'Downloading…', color: '#2563EB' };
      case 'error':
        return { label: page.lastError ?? 'Needs attention', color: '#DC2626' };
      case 'archived':
      default:
        return { label: 'Archived', color: '#9CA3AF' };
    }
  }, [page, tintColor]);
}

function LibraryListItem({
  page,
  colorScheme,
}: {
  page: SavedPage;
  colorScheme: 'light' | 'dark';
}) {
  const router = useRouter();
  const theme = Colors[colorScheme];
  const status = useStatusLabel(page, theme.tint);

  const onOpen = useCallback(() => {
    if (!page.fileUri) {
      Alert.alert('Still preparing', 'We are still downloading this page.');
      return;
    }

    router.push({
      pathname: '/reader',
      params: { pageId: String(page.id) },
    });
  }, [page, router]);

  const onDelete = useCallback(() => {
    Alert.alert('Remove page', 'Delete this saved page from your library?', [
      {
        text: 'Cancel',
        style: 'cancel',
      },
      {
        text: 'Delete',
        style: 'destructive',
        onPress: async () => {
          try {
            await deleteSavedPage(page.id);
          } catch (error) {
            console.error('Failed to delete saved page', error);
            Alert.alert('Could not delete page');
          }
        },
      },
    ]);
  }, [page.id]);

  return (
    <ThemedView
      style={[
        styles.listItem,
        {
          borderBottomColor:
            colorScheme === 'dark' ? 'rgba(255,255,255,0.12)' : 'rgba(0,0,0,0.08)',
        },
      ]}
      lightColor="transparent"
      darkColor="transparent">
      <ThemedText type="defaultSemiBold">{page.title?.trim() || page.url}</ThemedText>
      <View style={styles.statusRow}>
        <ThemedText type="default" style={{ color: status.color }}>
          {status.label}
        </ThemedText>
        <ThemedText type="default" style={{ color: theme.muted }}>
          {new Date(page.updatedAt).toLocaleString()}
        </ThemedText>
      </View>
      <View style={styles.buttonRow}>
        <Pressable
          onPress={onOpen}
          style={styles.actionButton}
          hitSlop={10}
          disabled={!page.fileUri}>
          <ThemedText type="link" style={{ opacity: page.fileUri ? 1 : 0.4 }}>
            Open
          </ThemedText>
        </Pressable>
        <Pressable
          onPress={() => queueSavedPageCapture(page.id)}
          style={styles.actionButton}
          hitSlop={10}
          disabled={page.status === 'downloading'}>
          <ThemedText type="link" style={{ opacity: page.status === 'downloading' ? 0.4 : 1 }}>
            Retry
          </ThemedText>
        </Pressable>
        <Pressable onPress={onDelete} style={styles.actionButton} hitSlop={10}>
          <ThemedText type="link" style={{ color: '#DC2626' }}>
            Delete
          </ThemedText>
        </Pressable>
      </View>
    </ThemedView>
  );
}

export default function LibraryScreen() {
  const router = useRouter();
  const colorScheme = useColorScheme();
  const theme = Colors[colorScheme ?? 'light'];
  const [pages, setPages] = useState<SavedPage[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  const loadPages = useCallback(async () => {
    setIsLoading(true);
    try {
      const savedPages = await listSavedPages();
      setPages(savedPages);
    } catch (error) {
      console.error('Failed to load saved pages', error);
    } finally {
      setIsLoading(false);
    }
  }, []);

  useFocusEffect(
    useCallback(() => {
      void loadPages();
      const unsubscribe = subscribeToSavedPages(() => {
        void loadPages();
      });
      return () => {
        unsubscribe();
      };
    }, [loadPages])
  );

  return (
    <ThemedView style={styles.container}>
      <ScrollView contentContainerStyle={styles.content}>
        <View style={styles.header}>
          <ThemedText type="title">Library</ThemedText>
          <ThemedText type="default">
            Capture articles, docs, and reference pages so they stay accessible wherever you are.
          </ThemedText>
        </View>

        {pages.length === 0 && !isLoading ? (
          <ThemedView
            lightColor={theme.surface}
            darkColor={theme.surface}
            style={styles.emptyState}
            testID="empty-library">
            <ThemedText type="subtitle">No pages yet</ThemedText>
            <ThemedText type="default">
              Save something to see it here. PagePocket keeps a clean copy of each page offline.
            </ThemedText>
            <Pressable
              onPress={() => router.push('/capture')}
              style={[styles.primaryButton, { backgroundColor: theme.tint }]}
              testID="add-first-page">
              <ThemedText type="defaultSemiBold" style={{ color: theme.background }}>
                Add your first page
              </ThemedText>
            </Pressable>
          </ThemedView>
        ) : (
          <ThemedView
            lightColor={theme.surface}
            darkColor={theme.surface}
            style={styles.listContainer}
            testID="library-list">
            <View style={styles.listHeader}>
              <ThemedText type="subtitle">Saved pages</ThemedText>
              <Pressable onPress={loadPages} style={styles.refreshButton} hitSlop={10}>
                <ThemedText type="link">Refresh</ThemedText>
              </Pressable>
            </View>
            {isLoading ? (
              <ThemedText type="default" style={{ color: theme.muted }}>
                Loading your library…
              </ThemedText>
            ) : (
              pages.map((page) => (
                <LibraryListItem key={page.id} page={page} colorScheme={colorScheme ?? 'light'} />
              ))
            )}
          </ThemedView>
        )}

        <ThemedView
          lightColor={theme.surface}
          darkColor={theme.surface}
          style={styles.nextSteps}>
          <ThemedText type="subtitle">Up next</ThemedText>
          <ThemedText type="default">
            We will bring in your reading queue, expose filters, and let you refresh pages on demand.
          </ThemedText>
        </ThemedView>
      </ScrollView>
    </ThemedView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  content: {
    padding: 24,
    gap: 24,
  },
  header: {
    gap: 12,
  },
  emptyState: {
    gap: 16,
    padding: 20,
    borderRadius: 16,
  },
  listContainer: {
    gap: 16,
    padding: 20,
    borderRadius: 16,
  },
  listHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  listItem: {
    paddingVertical: 8,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: 'transparent',
    gap: 4,
  },
  statusRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    gap: 8,
  },
  buttonRow: {
    flexDirection: 'row',
    gap: 12,
  },
  actionButton: {
    paddingVertical: 8,
  },
  refreshButton: {
    paddingVertical: 4,
    paddingHorizontal: 4,
  },
  nextSteps: {
    gap: 12,
    padding: 16,
    borderRadius: 12,
  },
  primaryButton: {
    borderRadius: 12,
    paddingVertical: 14,
    alignItems: 'center',
  },
});
