import { Pressable, ScrollView, StyleSheet, View } from 'react-native';

import { useRouter } from 'expo-router';

import { ThemedText } from '@/components/themed-text';
import { ThemedView } from '@/components/themed-view';
import { Colors } from '@/constants/theme';
import { useColorScheme } from '@/hooks/use-color-scheme';

export default function LibraryScreen() {
  const router = useRouter();
  const colorScheme = useColorScheme();
  const theme = Colors[colorScheme ?? 'light'];

  return (
    <ThemedView style={styles.container}>
      <ScrollView contentContainerStyle={styles.content}>
        <View style={styles.header}>
          <ThemedText type="title">Library</ThemedText>
          <ThemedText type="default">
            Capture articles, docs, and reference pages so they stay accessible wherever you are.
          </ThemedText>
        </View>

        <ThemedView
          lightColor={theme.surface}
          darkColor={theme.surface}
          style={styles.emptyState}>
          <ThemedText type="subtitle">No pages yet</ThemedText>
          <ThemedText type="default">
            Save something to see it here. PagePocket keeps a clean copy of each page offline.
          </ThemedText>
          <Pressable
            onPress={() => router.push('/capture')}
            style={[styles.primaryButton, { backgroundColor: theme.tint }]}>
            <ThemedText type="defaultSemiBold" style={{ color: theme.background }}>
              Add your first page
            </ThemedText>
          </Pressable>
        </ThemedView>

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
