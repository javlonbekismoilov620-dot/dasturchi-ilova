import * as Clipboard from 'expo-clipboard';
import { Check, Copy } from 'lucide-react-native';
import { useState } from 'react';
import { ScrollView, StyleSheet, Text as RNText, View } from 'react-native';

import { PressableScale } from '@/components/ui/PressableScale';
import { Text } from '@/components/ui/Text';
import { haptics } from '@/lib/haptics';
import { useI18n } from '@/i18n';
import { useTheme } from '@/theme/ThemeProvider';

/**
 * Lightweight syntax highlighter (no native deps) covering the languages used in
 * beginner material: HTML, CSS, JavaScript/TypeScript, Python, Bash, C-family.
 */
type Kind = 'plain' | 'keyword' | 'string' | 'comment' | 'number' | 'tag' | 'attr' | 'fn' | 'punct';

const palette: Record<Kind, string> = {
  plain: '#E7E3DA',
  keyword: '#C9A0FF',
  string: '#9FDB9A',
  comment: '#6E7380',
  number: '#F2B880',
  tag: '#7DB8FF',
  attr: '#F0CF8A',
  fn: '#86D4E8',
  punct: '#9AA0AC',
};

const KEYWORDS = new Set(
  'def return if elif else for while in not and or import from as class pass break continue try except finally with lambda yield None True False print const let var function new this typeof instanceof async await export default extends interface type public private protected static void int float double char bool string include using namespace struct echo cd ls sudo'.split(' '),
);

function tokenize(code: string, lang: string): { text: string; kind: Kind }[] {
  const out: { text: string; kind: Kind }[] = [];
  const isMarkup = /^(html|xml|svg|vue)$/i.test(lang);
  const hashComments = /^(python|py|bash|sh|shell|zsh|text|yaml|toml)$/i.test(lang);
  const re = isMarkup
    ? /(<!--[\s\S]*?-->)|(<\/?[A-Za-z!][\w-]*)|(\s[\w-:]+)(?==)|("[^"]*"|'[^']*')|(\/?>)|([^<"'\s>]+|\s+|.)/g
    : new RegExp(
        [
          hashComments ? '(#[^\\n]*)' : '(\\/\\/[^\\n]*|\\/\\*[\\s\\S]*?\\*\\/)',
          '("(?:\\\\.|[^"\\\\])*"|\'(?:\\\\.|[^\'\\\\])*\'|`(?:\\\\.|[^`\\\\])*`)',
          '(\\b\\d+(?:\\.\\d+)?\\b)',
          '([A-Za-z_][\\w]*)(?=\\s*\\()',
          '([A-Za-z_][\\w]*)',
          '([{}()\\[\\];,.:=+\\-*/<>!&|%^~?]+)',
          '(\\s+|.)',
        ].join('|'),
        'g',
      );
  let m: RegExpExecArray | null;
  while ((m = re.exec(code))) {
    if (isMarkup) {
      const [, comment, tag, attr, str, close, rest] = m;
      if (comment) out.push({ text: comment, kind: 'comment' });
      else if (tag) out.push({ text: tag, kind: 'tag' });
      else if (attr) out.push({ text: attr, kind: 'attr' });
      else if (str) out.push({ text: str, kind: 'string' });
      else if (close) out.push({ text: close, kind: 'tag' });
      else out.push({ text: rest ?? m[0], kind: 'plain' });
    } else {
      const [, comment, str, num, fn, word, punct] = m;
      if (comment) out.push({ text: comment, kind: 'comment' });
      else if (str) out.push({ text: str, kind: 'string' });
      else if (num) out.push({ text: num, kind: 'number' });
      else if (fn) out.push({ text: fn, kind: KEYWORDS.has(fn) ? 'keyword' : 'fn' });
      else if (word) out.push({ text: word, kind: KEYWORDS.has(word) ? 'keyword' : 'plain' });
      else if (punct) out.push({ text: punct, kind: 'punct' });
      else out.push({ text: m[0], kind: 'plain' });
    }
  }
  return out;
}

export function CodeBlock({ code, lang = '' }: { code: string; lang?: string }) {
  const t = useTheme();
  const { t: tr } = useI18n();
  const [copied, setCopied] = useState(false);
  const tokens = tokenize(code.replace(/\n$/, ''), lang);
  const label = lang && lang !== 'text' ? lang.toUpperCase() : '';

  return (
    <View style={[styles.block, { backgroundColor: t.colors.codeBackground, borderRadius: t.radii.md, borderColor: t.isDark ? t.colors.border : 'transparent' }]}>
      <View style={styles.header}>
        <View style={styles.dots}>
          {['#FF6B6B', '#F3B65A', '#5FD39B'].map((c) => (
            <View key={c} style={[styles.dot, { backgroundColor: c, opacity: 0.75 }]} />
          ))}
        </View>
        <Text variant="caption" color="#8A8F9A" style={{ flex: 1, textAlign: 'center' }}>
          {label}
        </Text>
        <PressableScale
          haptic={false}
          hitSlop={10}
          accessibilityLabel={copied ? tr('common.copied') : tr('common.copy')}
          onPress={async () => {
            await Clipboard.setStringAsync(code);
            haptics.success();
            setCopied(true);
            setTimeout(() => setCopied(false), 1600);
          }}
          style={styles.copy}>
          {copied ? <Check size={14} color="#5FD39B" /> : <Copy size={14} color="#8A8F9A" />}
          <Text variant="caption" color={copied ? '#5FD39B' : '#8A8F9A'}>
            {copied ? tr('common.copied') : tr('common.copy')}
          </Text>
        </PressableScale>
      </View>
      <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={{ paddingHorizontal: 16, paddingBottom: 16 }}>
        <RNText selectable style={[t.typography.mono, { color: palette.plain }]}>
          {tokens.map((tk, i) => (
            <RNText key={i} style={{ color: palette[tk.kind], fontStyle: tk.kind === 'comment' ? 'italic' : 'normal' }}>
              {tk.text}
            </RNText>
          ))}
        </RNText>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  block: { overflow: 'hidden', borderWidth: StyleSheet.hairlineWidth },
  header: { flexDirection: 'row', alignItems: 'center', paddingHorizontal: 14, paddingVertical: 10 },
  dots: { flexDirection: 'row', gap: 6, width: 70 },
  dot: { width: 9, height: 9, borderRadius: 5 },
  copy: { flexDirection: 'row', alignItems: 'center', gap: 4, width: 70, justifyContent: 'flex-end' },
});
