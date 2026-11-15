import { Check, Languages, Save } from 'lucide-react';
import { useState } from 'react';

import { errMsg } from '../lib/format';
import { supabase } from '../lib/supabase';
import { CONTENT_LOCALES, isFilled, targetLocales, translationStatus, type Locale, type TrField, type TrRow, type Translations } from '../lib/translations';
import { Badge, Button, Field, Input, ListEditor, Textarea, useToast } from './ui';

/**
 * Editing per-locale overlays stored in each content row's `translations` column.
 * The original (base-language) text is shown next to every field so editors translate
 * from the source. Saving only touches `translations`, so IDs, progress and quiz
 * attempts are never affected.
 */
export function LocalePicker({ value, onChange, baseLanguage }: { value: Locale; onChange: (l: Locale) => void; baseLanguage: string }) {
  return (
    <div className="row" style={{ gap: 8, flexWrap: 'wrap' }} role="radiogroup" aria-label="Translation language">
      <Languages size={16} />
      <span className="muted small">Source: {CONTENT_LOCALES.find((l) => l.code === baseLanguage)?.label ?? baseLanguage}. Translate into:</span>
      {targetLocales(baseLanguage).map((l) => (
        <Button key={l.code} size="sm" variant={value === l.code ? 'primary' : 'ghost'} onClick={() => onChange(l.code)} aria-checked={value === l.code} role="radio" data-testid={`locale-${l.code}`}>
          {l.label}
        </Button>
      ))}
    </div>
  );
}

type EditorProps = {
  table: string;
  idColumn?: string;
  row: TrRow;
  fields: TrField[];
  locale: Locale;
  title?: string;
  onSaved?: () => void;
};

export function TranslationEditor(props: EditorProps) {
  const { row, idColumn = 'id', locale } = props;
  // Remount (fresh draft) when the row, the locale or the saved translation changes.
  return <TranslationForm key={`${String(row[idColumn])}:${locale}:${JSON.stringify(row.translations?.[locale] ?? {})}`} {...props} />;
}

function TranslationForm({ table, idColumn = 'id', row, fields, locale, title, onSaved }: EditorProps) {
  const toast = useToast();
  const initial = (row.translations?.[locale] ?? {}) as Record<string, unknown>;
  const [draft, setDraft] = useState<Record<string, unknown>>(initial);
  const [saving, setSaving] = useState(false);

  const dirty = JSON.stringify(draft) !== JSON.stringify(initial);
  const status = translationStatus({ ...row, translations: { ...row.translations, [locale]: draft } }, fields, locale);

  const save = async () => {
    setSaving(true);
    // Keep only non-empty values so “not translated” stays distinguishable from “empty”.
    const cleaned = Object.fromEntries(
      Object.entries(draft)
        .map(([k, v]) => [k, Array.isArray(v) ? v.map((x) => String(x).trim()).filter(Boolean) : typeof v === 'string' ? v.trim() : v])
        .filter(([, v]) => isFilled(v)),
    );
    const next: Translations = { ...(row.translations ?? {}) };
    if (Object.keys(cleaned).length) next[locale] = cleaned;
    else delete next[locale];
    const { error } = await supabase.from(table).update({ translations: next }).eq(idColumn, row[idColumn] as string);
    setSaving(false);
    if (error) return toast('error', errMsg(error));
    toast('success', 'Translation saved');
    onSaved?.();
  };

  return (
    <div className="card stack" data-testid={`tr-${table}`}>
      <div className="row" style={{ justifyContent: 'space-between' }}>
        <h3 style={{ margin: 0 }}>{title ?? String(row.title ?? '')}</h3>
        <Badge tone={status.complete ? 'success' : 'warning'}>
          {status.complete ? <Check size={12} /> : null} {status.done}/{status.total} translated
        </Badge>
      </div>
      {fields.map((f) => {
        const base = row[f.key];
        if (!isFilled(base)) return null;
        const value = draft[f.key];
        const set = (v: unknown) => setDraft((d) => ({ ...d, [f.key]: v }));
        return (
          <Field key={f.key} label={f.label}>
            <div className="stack" style={{ gap: 6 }}>
              <div className="muted small" style={{ whiteSpace: 'pre-wrap', maxHeight: f.kind === 'markdown' ? 160 : undefined, overflow: 'auto' }}>
                {Array.isArray(base) ? base.map((b) => `• ${b}`).join('\n') : String(base)}
              </div>
              {f.kind === 'list' ? (
                <ListEditor value={Array.isArray(value) ? (value as string[]) : []} onChange={set} placeholder="Add a translated item and press Enter" />
              ) : f.kind === 'markdown' ? (
                <Textarea value={typeof value === 'string' ? value : ''} onChange={(e) => set(e.target.value)} rows={Math.min(24, Math.max(4, String(base).split('\n').length + 2))} code />
              ) : (
                <Input value={typeof value === 'string' ? value : ''} onChange={(e) => set(e.target.value)} data-testid={`tr-${table}-${f.key}`} />
              )}
            </div>
          </Field>
        );
      })}
      <div className="row" style={{ justifyContent: 'flex-end' }}>
        <Button variant="primary" icon={<Save />} disabled={!dirty} loading={saving} onClick={save} data-testid={`tr-save-${table}`}>
          Save translation
        </Button>
      </div>
    </div>
  );
}
