import { Loader2, Upload, X } from 'lucide-react';
import { createContext, useCallback, useContext, useRef, useState, type ButtonHTMLAttributes, type InputHTMLAttributes, type ReactNode, type SelectHTMLAttributes, type TextareaHTMLAttributes } from 'react';

import type { Status } from '../lib/format';
import { supabase } from '../lib/supabase';

// Buttons --------------------------------------------------------------------
type BtnProps = ButtonHTMLAttributes<HTMLButtonElement> & { variant?: 'primary' | 'ghost' | 'outline' | 'danger'; size?: 'sm'; icon?: ReactNode; loading?: boolean };
export function Button({ variant, size, icon, loading, children, className, disabled, ...rest }: BtnProps) {
  return (
    <button {...rest} disabled={disabled || loading} className={['btn', variant, size, !children && 'icon', className].filter(Boolean).join(' ')}>
      {loading ? <Loader2 className="spin-icon" style={{ animation: 'spin .8s linear infinite' }} /> : icon}
      {children}
    </button>
  );
}

/** Two-step destructive action: first click arms, second click confirms. */
export function ConfirmButton({ onConfirm, label = 'Delete', confirmLabel = 'Click to confirm', size = 'sm' }: { onConfirm: () => void | Promise<void>; label?: string; confirmLabel?: string; size?: 'sm' }) {
  const [armed, setArmed] = useState(false);
  const timer = useRef<number | undefined>(undefined);
  return (
    <Button
      variant="danger"
      size={size}
      onClick={async (e) => {
        e.stopPropagation();
        if (!armed) {
          setArmed(true);
          timer.current = window.setTimeout(() => setArmed(false), 3000);
          return;
        }
        window.clearTimeout(timer.current);
        setArmed(false);
        await onConfirm();
      }}>
      {armed ? confirmLabel : label}
    </Button>
  );
}

// Form fields -----------------------------------------------------------------
export function Field({ label, hint, error, children }: { label: string; hint?: string; error?: string | null; children: ReactNode }) {
  return (
    <label className="field">
      <span>{label}</span>
      {children}
      {error ? <em className="err">{error}</em> : hint ? <em className="hint">{hint}</em> : null}
    </label>
  );
}
export const Input = (p: InputHTMLAttributes<HTMLInputElement>) => <input {...p} className={['input', p.className].filter(Boolean).join(' ')} />;
export const Textarea = ({ code, ...p }: TextareaHTMLAttributes<HTMLTextAreaElement> & { code?: boolean }) => <textarea {...p} className={['textarea', code && 'code', p.className].filter(Boolean).join(' ')} />;
export const Select = (p: SelectHTMLAttributes<HTMLSelectElement>) => <select {...p} className={['select', p.className].filter(Boolean).join(' ')} />;

export function Switch({ checked, onChange, label }: { checked: boolean; onChange: (v: boolean) => void; label: string }) {
  return (
    <label className="row" style={{ cursor: 'pointer', justifyContent: 'space-between' }}>
      <span>{label}</span>
      <span className="switch">
        <input type="checkbox" checked={checked} onChange={(e) => onChange(e.target.checked)} aria-label={label} />
        <span />
      </span>
    </label>
  );
}

/** Edits a text[] column (learning outcomes, prerequisites, tags). */
export function ListEditor({ value, onChange, placeholder }: { value: string[]; onChange: (v: string[]) => void; placeholder: string }) {
  const [draft, setDraft] = useState('');
  const add = () => {
    const v = draft.trim();
    if (v && !value.includes(v)) onChange([...value, v]);
    setDraft('');
  };
  return (
    <div className="stack" style={{ gap: 8 }}>
      <div className="row">
        <Input value={draft} placeholder={placeholder} onChange={(e) => setDraft(e.target.value)} onKeyDown={(e) => e.key === 'Enter' && (e.preventDefault(), add())} />
        <Button type="button" onClick={add}>
          Add
        </Button>
      </div>
      {value.length > 0 && (
        <div className="pill-list">
          {value.map((v) => (
            <span key={v} className="pill">
              {v}
              <button type="button" aria-label={`Remove ${v}`} onClick={() => onChange(value.filter((x) => x !== v))}>
                ×
              </button>
            </span>
          ))}
        </div>
      )}
    </div>
  );
}

// Feedback ------------------------------------------------------------------------
export const Spinner = () => <div className="spinner" role="status" aria-label="Loading" />;
export const Loading = () => (
  <div className="center">
    <Spinner />
  </div>
);
export function Empty({ title, body, action }: { title: string; body?: string; action?: ReactNode }) {
  return (
    <div className="empty">
      <strong style={{ color: 'var(--text)' }}>{title}</strong>
      {body && <span>{body}</span>}
      {action}
    </div>
  );
}

const statusTone: Record<string, string> = { draft: '', in_review: 'warning', published: 'success', archived: 'danger', submitted: 'info', approved: 'success', changes_requested: 'warning' };
export function StatusBadge({ status }: { status: Status | string }) {
  return (
    <span className={`badge ${statusTone[status] ?? ''}`}>
      <span className="dot" />
      {status.replace('_', ' ')}
    </span>
  );
}
export const Badge = ({ tone = '', children }: { tone?: string; children: ReactNode }) => <span className={`badge ${tone}`}>{children}</span>;

export function Modal({ title, onClose, children, footer, wide }: { title: string; onClose: () => void; children: ReactNode; footer?: ReactNode; wide?: boolean }) {
  return (
    <div className="backdrop" onMouseDown={(e) => e.target === e.currentTarget && onClose()} role="presentation">
      <div className={`modal ${wide ? 'wide' : ''}`} role="dialog" aria-modal="true" aria-label={title}>
        <div className="modal-head">
          <h3 style={{ fontSize: 18 }}>{title}</h3>
          <Button variant="ghost" size="sm" icon={<X />} onClick={onClose} aria-label="Close" />
        </div>
        {children}
        {footer && <div className="modal-foot">{footer}</div>}
      </div>
    </div>
  );
}

export function Tabs<T extends string>({ value, onChange, tabs }: { value: T; onChange: (v: T) => void; tabs: { value: T; label: string }[] }) {
  return (
    <div className="tabs" role="tablist">
      {tabs.map((t) => (
        <button key={t.value} role="tab" aria-selected={value === t.value} className={`tab ${value === t.value ? 'active' : ''}`} onClick={() => onChange(t.value)}>
          {t.label}
        </button>
      ))}
    </div>
  );
}

// Toasts --------------------------------------------------------------------------
type Toast = { id: number; kind: 'success' | 'error' | 'info'; text: string };
const ToastCtx = createContext<(kind: Toast['kind'], text: string) => void>(() => {});
export function ToastProvider({ children }: { children: ReactNode }) {
  const [items, setItems] = useState<Toast[]>([]);
  const push = useCallback((kind: Toast['kind'], text: string) => {
    const id = Date.now() + Math.random();
    setItems((s) => [...s.slice(-3), { id, kind, text }]);
    setTimeout(() => setItems((s) => s.filter((t) => t.id !== id)), 4200);
  }, []);
  return (
    <ToastCtx.Provider value={push}>
      {children}
      <div className="toasts" aria-live="polite">
        {items.map((t) => (
          <div key={t.id} className={`toast ${t.kind}`} role={t.kind === 'error' ? 'alert' : 'status'}>
            {t.text}
          </div>
        ))}
      </div>
    </ToastCtx.Provider>
  );
}
export const useToast = () => useContext(ToastCtx);

// Upload ---------------------------------------------------------------------------
export function UploadButton({ bucket, path, accept, onUploaded, label = 'Upload file', upsert = true }: { bucket: string; path: (file: File) => string; accept?: string; onUploaded: (path: string, file: File) => void | Promise<void>; label?: string; upsert?: boolean }) {
  const ref = useRef<HTMLInputElement>(null);
  const [busy, setBusy] = useState(false);
  const toast = useToast();
  return (
    <>
      <input
        ref={ref}
        type="file"
        accept={accept}
        hidden
        onChange={async (e) => {
          const file = e.target.files?.[0];
          e.target.value = '';
          if (!file) return;
          setBusy(true);
          try {
            const p = path(file);
            const { error } = await supabase.storage.from(bucket).upload(p, file, { upsert, contentType: file.type || undefined });
            if (error) throw error;
            await onUploaded(p, file);
            toast('success', `Uploaded ${file.name}`);
          } catch (err) {
            toast('error', err instanceof Error ? err.message : String(err));
          } finally {
            setBusy(false);
          }
        }}
      />
      <Button type="button" icon={<Upload />} loading={busy} onClick={() => ref.current?.click()}>
        {label}
      </Button>
    </>
  );
}

export const safeFileName = (name: string) => name.replace(/[^A-Za-z0-9._-]+/g, '_').slice(-80);
