import { Image } from 'expo-image';
import * as WebBrowser from 'expo-web-browser';
import { Lexer, type Token, type Tokens } from 'marked';
import { Info, Lightbulb, TriangleAlert } from 'lucide-react-native';
import { Fragment, memo, useMemo, type ReactNode } from 'react';
import { ScrollView, StyleSheet, Text as RNText, View, type TextStyle } from 'react-native';

import { Text } from '@/components/ui/Text';
import { useTheme, type Theme } from '@/theme/ThemeProvider';

import { CodeBlock } from './CodeBlock';

/**
 * Markdown → native components with editorial typography. Supports headings, rich
 * inline text, lists (nested), tables, fenced code, images and GitHub-style callouts
 * (> [!NOTE] / [!TIP] / [!WARNING]). Raw HTML is shown as code, never executed.
 */
function decode(s: string) {
  return s.replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&quot;/g, '"').replace(/&#39;/g, "'");
}

function Inline({ tokens, theme, base }: { tokens: Token[]; theme: Theme; base?: TextStyle }): ReactNode {
  return tokens.map((tk, i) => {
    switch (tk.type) {
      case 'strong':
        return (
          <RNText key={i} style={[base, { fontFamily: theme.fonts.semibold, color: theme.colors.text }]}>
            <Inline tokens={(tk as Tokens.Strong).tokens} theme={theme} base={{ ...base, fontFamily: theme.fonts.semibold }} />
          </RNText>
        );
      case 'em':
        return (
          <RNText key={i} style={[base, { fontStyle: 'italic' }]}>
            <Inline tokens={(tk as Tokens.Em).tokens} theme={theme} base={{ ...base, fontStyle: 'italic' }} />
          </RNText>
        );
      case 'del':
        return (
          <RNText key={i} style={[base, { textDecorationLine: 'line-through' }]}>
            <Inline tokens={(tk as Tokens.Del).tokens} theme={theme} base={base} />
          </RNText>
        );
      case 'codespan':
        return (
          <RNText key={i} style={{ fontFamily: theme.fonts.mono, fontSize: (base?.fontSize ?? 16) * 0.88, color: theme.colors.accent, backgroundColor: theme.colors.accentSoft }}>
            {` ${decode((tk as Tokens.Codespan).text)} `}
          </RNText>
        );
      case 'link': {
        const link = tk as Tokens.Link;
        return (
          <RNText key={i} accessibilityRole="link" onPress={() => /^https?:\/\//.test(link.href) && WebBrowser.openBrowserAsync(link.href)} style={[base, { color: theme.colors.accent, textDecorationLine: 'underline' }]}>
            <Inline tokens={link.tokens} theme={theme} base={{ ...base, color: theme.colors.accent }} />
          </RNText>
        );
      }
      case 'br':
        return <RNText key={i}>{'\n'}</RNText>;
      case 'text':
      case 'escape': {
        const text = tk as Tokens.Text;
        if (text.tokens?.length) return <Inline key={i} tokens={text.tokens} theme={theme} base={base} />;
        return <Fragment key={i}>{decode(text.text)}</Fragment>;
      }
      default:
        return <Fragment key={i}>{'raw' in tk ? decode(String(tk.raw)) : ''}</Fragment>;
    }
  });
}

const calloutMeta = (theme: Theme) =>
  ({
    NOTE: { icon: Info, color: theme.colors.info, bg: theme.colors.infoSoft },
    TIP: { icon: Lightbulb, color: theme.colors.success, bg: theme.colors.successSoft },
    WARNING: { icon: TriangleAlert, color: theme.colors.warning, bg: theme.colors.warningSoft },
    IMPORTANT: { icon: Info, color: theme.colors.accent, bg: theme.colors.accentSoft },
  }) as const;

function Block({ token, theme, depth = 0 }: { token: Token; theme: Theme; depth?: number }): ReactNode {
  const body: TextStyle = { ...theme.typography.body, fontSize: 17, lineHeight: 28, color: theme.colors.text };
  switch (token.type) {
    case 'heading': {
      const h = token as Tokens.Heading;
      const style = h.depth <= 1 ? theme.typography.title1 : h.depth === 2 ? theme.typography.title2 : theme.typography.title3;
      return (
        <RNText accessibilityRole="header" style={[style, { color: theme.colors.text, marginTop: h.depth <= 2 ? 14 : 8 }]}>
          <Inline tokens={h.tokens} theme={theme} base={style} />
        </RNText>
      );
    }
    case 'paragraph': {
      const p = token as Tokens.Paragraph;
      const img = p.tokens.length === 1 && p.tokens[0].type === 'image' ? (p.tokens[0] as Tokens.Image) : null;
      if (img && /^https:\/\//.test(img.href)) {
        return (
          <View style={{ gap: 6 }}>
            <Image source={{ uri: img.href }} style={{ width: '100%', aspectRatio: 16 / 9, borderRadius: theme.radii.md, backgroundColor: theme.colors.surfaceHigh }} contentFit="cover" accessibilityLabel={img.text} />
            {img.text ? (
              <Text variant="footnote" tone="tertiary" align="center">
                {img.text}
              </Text>
            ) : null}
          </View>
        );
      }
      return (
        <RNText selectable style={body}>
          <Inline tokens={p.tokens} theme={theme} base={body} />
        </RNText>
      );
    }
    case 'list': {
      const l = token as Tokens.List;
      const start = typeof l.start === 'number' ? l.start : 1;
      return (
        <View style={{ gap: 10, paddingLeft: depth ? 14 : 2 }}>
          {l.items.map((item, i) => (
            <View key={i} style={{ flexDirection: 'row', gap: 12 }}>
              {l.ordered ? (
                <View style={[styles.number, { backgroundColor: theme.colors.accentSoft }]}>
                  <Text variant="caption" tone="accent">
                    {start + i}
                  </Text>
                </View>
              ) : (
                <View style={[styles.bullet, { backgroundColor: theme.colors.accent }]} />
              )}
              <View style={{ flex: 1, gap: 8 }}>
                {item.tokens.map((child, k) =>
                  child.type === 'text' ? (
                    <RNText key={k} selectable style={body}>
                      <Inline tokens={(child as Tokens.Text).tokens ?? [child]} theme={theme} base={body} />
                    </RNText>
                  ) : (
                    <Block key={k} token={child} theme={theme} depth={depth + 1} />
                  ),
                )}
              </View>
            </View>
          ))}
        </View>
      );
    }
    case 'code': {
      const c = token as Tokens.Code;
      return <CodeBlock code={c.text} lang={c.lang ?? ''} />;
    }
    case 'html':
      return <CodeBlock code={(token as Tokens.HTML).text} lang="html" />;
    case 'blockquote': {
      const q = token as Tokens.Blockquote;
      const match = /^\s*\[!(NOTE|TIP|WARNING|IMPORTANT)\]\s*/i.exec(q.text);
      if (match) {
        const meta = calloutMeta(theme)[match[1].toUpperCase() as keyof ReturnType<typeof calloutMeta>];
        const inner = new Lexer().lex(q.text.replace(match[0], ''));
        const Icon = meta.icon;
        return (
          <View style={[styles.callout, { backgroundColor: meta.bg, borderRadius: theme.radii.md, borderColor: meta.color }]} accessibilityRole="summary">
            <Icon size={18} color={meta.color} style={{ marginTop: 4 }} />
            <View style={{ flex: 1, gap: 10 }}>
              {inner.map((tk, i) => (
                <Block key={i} token={tk} theme={theme} depth={depth + 1} />
              ))}
            </View>
          </View>
        );
      }
      return (
        <View style={[styles.quote, { borderColor: theme.colors.accent }]}>
          {q.tokens.map((tk, i) => (
            <Block key={i} token={tk} theme={theme} depth={depth + 1} />
          ))}
        </View>
      );
    }
    case 'table': {
      const tb = token as Tokens.Table;
      const cellStyle: TextStyle = { ...theme.typography.callout, color: theme.colors.text };
      return (
        <ScrollView horizontal showsHorizontalScrollIndicator={false}>
          <View style={[styles.table, { borderColor: theme.colors.border, borderRadius: theme.radii.md }]}>
            <View style={[styles.tr, { backgroundColor: theme.colors.surfaceHigh }]}>
              {tb.header.map((h, i) => (
                <View key={i} style={styles.td}>
                  <RNText style={[cellStyle, { fontFamily: theme.fonts.semibold }]}>
                    <Inline tokens={h.tokens} theme={theme} base={{ ...cellStyle, fontFamily: theme.fonts.semibold }} />
                  </RNText>
                </View>
              ))}
            </View>
            {tb.rows.map((row, r) => (
              <View key={r} style={[styles.tr, { borderTopWidth: StyleSheet.hairlineWidth, borderColor: theme.colors.border }]}>
                {row.map((cell, i) => (
                  <View key={i} style={styles.td}>
                    <RNText selectable style={cellStyle}>
                      <Inline tokens={cell.tokens} theme={theme} base={cellStyle} />
                    </RNText>
                  </View>
                ))}
              </View>
            ))}
          </View>
        </ScrollView>
      );
    }
    case 'hr':
      return <View style={{ height: StyleSheet.hairlineWidth, backgroundColor: theme.colors.borderStrong, marginVertical: 8 }} />;
    case 'space':
      return null;
    default:
      return 'text' in token ? (
        <RNText selectable style={body}>
          {decode(String((token as Tokens.Text).text))}
        </RNText>
      ) : null;
  }
}

export const Markdown = memo(function Markdown({ source }: { source: string }) {
  const theme = useTheme();
  const tokens = useMemo(() => new Lexer({ gfm: true }).lex(source), [source]);
  return (
    <View style={{ gap: 16 }}>
      {tokens.map((tk, i) => (
        <Block key={i} token={tk} theme={theme} />
      ))}
    </View>
  );
});

/** Single-line/inline markdown (quiz prompts and answers). */
export function InlineMarkdown({ source, style }: { source: string; style?: TextStyle }) {
  const theme = useTheme();
  const tokens = useMemo(() => {
    const block = new Lexer({ gfm: true }).lex(source);
    return block.flatMap((b) => ('tokens' in b && b.tokens ? (b.tokens as Token[]) : [b]));
  }, [source]);
  const base: TextStyle = { ...theme.typography.body, color: theme.colors.text, ...style };
  return (
    <RNText style={base}>
      <Inline tokens={tokens} theme={theme} base={base} />
    </RNText>
  );
}

const styles = StyleSheet.create({
  bullet: { width: 6, height: 6, borderRadius: 3, marginTop: 11 },
  number: { width: 24, height: 24, borderRadius: 12, alignItems: 'center', justifyContent: 'center', marginTop: 2 },
  callout: { flexDirection: 'row', gap: 12, padding: 16, borderLeftWidth: 3 },
  quote: { borderLeftWidth: 3, paddingLeft: 14, gap: 10 },
  table: { borderWidth: StyleSheet.hairlineWidth, overflow: 'hidden' },
  tr: { flexDirection: 'row' },
  td: { width: 170, paddingHorizontal: 12, paddingVertical: 10 },
});
