import { useCallback, useState } from 'react';
import { Alert, KeyboardAvoidingView, Platform, ScrollView, StyleSheet, TextInput, View } from 'react-native';

import { Link } from 'expo-router';

import { ThemedText } from '@/components/themed-text';
import { ThemedView } from '@/components/themed-view';
import { Colors } from '@/constants/theme';
import { useColorScheme } from '@/hooks/use-color-scheme';
import { createSavedPage } from '@/storage';
import { queueSavedPageCapture } from '@/capture/page-capture-service';

export default function CaptureScreen() {
  const colorScheme = useColorScheme();
  const theme = Colors[colorScheme ?? 'light'];
  const [url, setUrl] = useState('');
  const [isSaving, setIsSaving] = useState(false);

  const onSubmit = useCallback(async () => {
    if (!url.trim()) {
      Alert.alert('Enter a link', 'Paste the address of the page you want to keep offline.');
      return;
    }

    setIsSaving(true);
    try {
      const normalizedUrl = url.trim();
      const savedPage = await createSavedPage({ url: normalizedUrl });
      queueSavedPageCapture(savedPage.id);
      setUrl('');
      Alert.alert('Saved to library', 'We will download the page contents shortly.');
    } catch (error) {
      console.error('Failed to queue page for saving', error);
      Alert.alert('Could not save', error instanceof Error ? error.message : 'Please try again later.');
    } finally {
      setIsSaving(false);
    }
  }, [url]);

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.select({ ios: 'padding', android: 'height' })}>
      <ScrollView contentContainerStyle={styles.content} keyboardShouldPersistTaps="handled">
        <ThemedView style={styles.header}>
          <ThemedText type="title">Add a page</ThemedText>
          <ThemedText type="default">
            Paste any article or resource link to keep a clean copy available offline.
          </ThemedText>
        </ThemedView>

        <View style={styles.fieldGroup}>
          <ThemedText type="subtitle">Page URL</ThemedText>
          <TextInput
            value={url}
            onChangeText={setUrl}
            placeholder="https://example.com/article"
            autoCapitalize="none"
            autoCorrect={false}
            keyboardType="url"
            returnKeyType="done"
            onSubmitEditing={onSubmit}
            placeholderTextColor={theme.muted + '99'}
            editable={!isSaving}
            style={[
              styles.input,
              {
                backgroundColor: theme.surface,
                color: theme.text,
                borderColor: theme.border,
              },
            ]}
          />
        </View>

        <ThemedView
          style={[
            styles.helper,
            {
              backgroundColor: theme.surface,
              borderColor: theme.border,
            },
          ]}>
          <ThemedText type="defaultSemiBold">Queue download</ThemedText>
          <ThemedText type="default">
            PagePocket saves the link now and fetches the article in the background so it stays
            available offline.
          </ThemedText>
          <ThemedText type="default" style={{ color: theme.muted }}>
            {isSaving ? 'Adding to library…' : 'Tap return on your keyboard to save the link.'}
          </ThemedText>
        </ThemedView>

        <View style={styles.linksRow}>
          <Link href="/" style={styles.link}>
            <ThemedText type="link">View library</ThemedText>
          </Link>
          <Link href="/modal" style={styles.link}>
            <ThemedText type="link">Settings</ThemedText>
          </Link>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
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
  fieldGroup: {
    gap: 12,
  },
  input: {
    borderRadius: 12,
    borderWidth: 1,
    paddingHorizontal: 16,
    paddingVertical: Platform.select({ ios: 16, android: 12 }),
    fontSize: 16,
  },
  helper: {
    gap: 8,
    borderRadius: 12,
    padding: 16,
    borderWidth: 1,
  },
  linksRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  link: {
    paddingVertical: 8,
  },
});

