import { router, useLocalSearchParams } from 'expo-router';
import { MessageCircle, Send, X } from 'lucide-react-native';
import { useState } from 'react';
import { KeyboardAvoidingView, Platform, ScrollView, StyleSheet, TextInput, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { Aurora } from '@/components/brand/Aurora';
import { Markdown } from '@/components/lesson/Markdown';
import { EmptyState, IconButton } from '@/components/ui/layout';
import { Badge, Card } from '@/components/ui/primitives';
import { Text } from '@/components/ui/Text';
import { useSettings } from '@/data/hooks';
import { askAssistant, type ChatMessage } from '@/lib/assistant';
import { isDemoMode } from '@/lib/env';
import { useI18n } from '@/i18n';
import { useTheme } from '@/theme/ThemeProvider';

/**
 * Learning assistant. The UI and transport are complete; the feature activates only when
 * an administrator enables it AND the `assistant` edge function has a provider key.
 * Until then the screen says so plainly and sends nothing.
 */
export default function Assistant() {
  const t = useTheme();
  const { t: tr } = useI18n();
  const insets = useSafeAreaInsets();
  const { lessonId } = useLocalSearchParams<{ lessonId?: string }>();
  const settings = useSettings();
  const enabled = !isDemoMode && !!settings.data?.assistant?.enabled;
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [input, setInput] = useState('');
  const [busy, setBusy] = useState(false);

  const send = async () => {
    const text = input.trim();
    if (!text || !enabled) return;
    const next: ChatMessage[] = [...messages, { role: 'user', content: text }];
    setMessages(next);
    setInput('');
    setBusy(true);
    try {
      const reply = await askAssistant(next, lessonId);
      setMessages([...next, { role: 'assistant', content: reply }]);
    } catch {
      setMessages([...next, { role: 'assistant', content: tr('assistant.error') }]);
    } finally {
      setBusy(false);
    }
  };

  return (
    <KeyboardAvoidingView style={{ flex: 1, backgroundColor: t.colors.background }} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
      <Aurora hue={160} intensity={0.4} />
      <View style={[styles.top, { paddingTop: Platform.OS === 'ios' ? 16 : insets.top + 8 }]}>
        <Text variant="title3" style={{ flex: 1 }}>
          {tr('assistant.title')}
        </Text>
        {!enabled && <Badge label={tr('assistant.notConnected')} tone="warning" />}
        <IconButton icon={X} label={tr('common.close')} onPress={() => router.back()} />
      </View>
      <ScrollView contentContainerStyle={{ padding: 20, gap: 12, flexGrow: 1 }}>
        {!enabled ? (
          <EmptyState icon={MessageCircle} title={tr('assistant.notConnected')} body={tr('assistant.notConnectedBody')} />
        ) : (
          messages.map((m, i) => (
            <Card key={i} style={[{ maxWidth: '88%' }, m.role === 'user' ? { alignSelf: 'flex-end', backgroundColor: t.colors.accentSoft, borderColor: 'transparent' } : { alignSelf: 'flex-start' }]}>
              {m.role === 'assistant' ? <Markdown source={m.content} /> : <Text variant="callout">{m.content}</Text>}
            </Card>
          ))
        )}
      </ScrollView>
      <View style={[styles.inputBar, { paddingBottom: insets.bottom + 10, borderTopColor: t.colors.border }]}>
        {enabled && (
          <Text variant="caption" tone="tertiary" align="center">
            {tr('assistant.disclaimer')}
          </Text>
        )}
        <View style={[styles.input, { backgroundColor: t.colors.surface, borderColor: t.colors.border, borderRadius: t.radii.xl, opacity: enabled ? 1 : 0.5 }]}>
          <TextInput
            value={input}
            onChangeText={setInput}
            editable={enabled && !busy}
            placeholder={tr('assistant.placeholder')}
            placeholderTextColor={t.colors.textTertiary}
            style={[t.typography.body, { flex: 1, color: t.colors.text, maxHeight: 120, outlineStyle: 'none' as never }]}
            multiline
            accessibilityLabel={tr('assistant.placeholder')}
          />
          <IconButton icon={Send} size={38} label={tr('assistant.send')} active onPress={send} />
        </View>
      </View>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  top: { flexDirection: 'row', alignItems: 'center', gap: 10, paddingHorizontal: 20, paddingBottom: 8 },
  inputBar: { paddingHorizontal: 16, paddingTop: 10, gap: 8, borderTopWidth: StyleSheet.hairlineWidth },
  input: { flexDirection: 'row', alignItems: 'flex-end', gap: 8, paddingLeft: 16, paddingRight: 6, paddingVertical: 6, borderWidth: StyleSheet.hairlineWidth },
});
