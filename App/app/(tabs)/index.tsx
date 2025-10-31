import { useCallback, useState } from 'react';
import { Pressable, ScrollView, StyleSheet, View } from 'react-native';

import { useFocusEffect } from '@react-navigation/native';
import { useRouter } from 'expo-router';

import { ThemedText } from '@/components/themed-text';
import { ThemedView } from '@/components/themed-view';
import { Colors } from '@/constants/theme';
import { useColorScheme } from '@/hooks/use-color-scheme';
import { listSavedPages, SavedPage, subscribeToSavedPages } from '@/storage';

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
            <ThemedText type="subtitle">Saved pages</ThemedText>
            {isLoading ? (
              <ThemedText type="default" style={{ color: theme.muted }}>
                Loading your library…
              </ThemedText>
            ) : (
              pages.map((page) => (
                <ThemedView
                  key={page.id}
                  style={[
                    styles.listItem,
                    {
                      borderBottomColor:
                        colorScheme === 'dark' ? 'rgba(255,255,255,0.12)' : 'rgba(0,0,0,0.08)',
                    },
                  ]}>
                  <ThemedText type="defaultSemiBold">
                    {page.title?.trim() || page.url}
                  </ThemedText>
                  <ThemedText type="default" style={{ color: theme.muted }}>
                    {page.status === 'ready'
                      ? 'Ready to read offline'
                      : page.status === 'queued'
                        ? 'Queued for download'
                        : page.status === 'downloading'
                          ? 'Downloading…'
                          : page.status === 'error'
                            ? page.lastError ?? 'Needs attention'
                            : 'Archived'}
                  </ThemedText>
                </ThemedView>
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
  listItem: {
    paddingVertical: 8,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: 'transparent',
    gap: 4,
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
