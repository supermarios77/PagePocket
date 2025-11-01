import { useCallback, useEffect, useMemo, useState } from 'react';
import { ActivityIndicator, Platform, Pressable, StyleSheet, View } from 'react-native';

import * as FileSystem from 'expo-file-system/legacy';
import { Stack, useLocalSearchParams } from 'expo-router';
import { WebView } from 'react-native-webview';

import { ThemedText } from '@/components/themed-text';
import { ThemedView } from '@/components/themed-view';
import { Colors } from '@/constants/theme';
import { useColorScheme } from '@/hooks/use-color-scheme';
import { getSavedPageById, SavedPage, subscribeToSavedPages } from '@/storage';

type ReaderState =
  | { status: 'loading' }
  | { status: 'error'; message: string }
  | { status: 'loaded'; page: SavedPage; contentUri: string | null };

export default function ReaderScreen() {
  const { pageId } = useLocalSearchParams<{ pageId?: string }>();
  const colorScheme = useColorScheme();
  const theme = Colors[colorScheme ?? 'light'];

  const numericId = useMemo(() => {
    if (!pageId) return null;
    const parsed = Number(pageId);
    return Number.isFinite(parsed) ? parsed : null;
  }, [pageId]);

  const [state, setState] = useState<ReaderState>({ status: 'loading' });

  const loadPage = useCallback(async () => {
    if (numericId == null) {
      setState({ status: 'error', message: 'Missing page identifier.' });
      return;
    }

    setState({ status: 'loading' });
    try {
      const page = await getSavedPageById(numericId);
      if (!page) {
        setState({ status: 'error', message: 'This page is no longer in your library.' });
        return;
      }

      if (!page.fileUri) {
        setState({
          status: 'error',
          message: 'Page is not downloaded yet. Retry download from your library.',
        });
        return;
      }

      let uri = page.fileUri;
      if (Platform.OS === 'android') {
        uri = await FileSystem.getContentUriAsync(page.fileUri);
      }

      setState({ status: 'loaded', page, contentUri: uri });
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Unable to open page.';
      setState({ status: 'error', message });
    }
  }, [numericId]);

  useEffect(() => {
    void loadPage();

    if (numericId == null) {
      return;
    }

    const unsubscribe = subscribeToSavedPages((event) => {
      if (event.pageId === numericId) {
        void loadPage();
      }
    });

    return unsubscribe;
  }, [loadPage, numericId]);

  const headerTitle = useMemo(() => {
    if (state.status === 'loaded') {
      return state.page.title?.trim() || state.page.url;
    }
    return 'Reader';
  }, [state]);

  return (
    <ThemedView style={{ flex: 1 }}>
      <Stack.Screen options={{ title: headerTitle, headerBackTitle: 'Back' }} />
      {state.status === 'loading' ? (
        <View style={styles.centered}>
          <ActivityIndicator size="large" color={theme.tint} />
          <ThemedText type="default" style={styles.message}>
            Loading saved page…
          </ThemedText>
        </View>
      ) : state.status === 'error' ? (
        <View style={styles.centered}>
          <ThemedText type="subtitle" style={{ textAlign: 'center' }}>
            Unable to open page
          </ThemedText>
          <ThemedText type="default" style={[styles.message, { textAlign: 'center' }]}
            lightColor={theme.muted}
            darkColor={theme.muted}>
            {state.message}
          </ThemedText>
          <PressableMessage onReload={loadPage} themeTint={theme.tint} />
        </View>
      ) : state.contentUri ? (
        <WebView
          source={{ uri: state.contentUri }}
          startInLoadingState
          allowFileAccess
          allowUniversalAccessFromFileURLs
          style={{ flex: 1 }}
        />
      ) : (
        <View style={styles.centered}>
          <ThemedText type="default" style={{ textAlign: 'center' }}>
            Missing content. Try downloading again from the library.
          </ThemedText>
        </View>
      )}
    </ThemedView>
  );
}

function PressableMessage({ onReload, themeTint }: { onReload: () => void; themeTint: string }) {
  return (
    <Pressable onPress={onReload} style={styles.retryContainer} hitSlop={10}>
      <ThemedText type="link" style={{ color: themeTint }}>
        Retry
      </ThemedText>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  centered: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 24,
    gap: 16,
  },
  message: {
    textAlign: 'center',
  },
  retryContainer: {
    paddingVertical: 8,
  },
});


