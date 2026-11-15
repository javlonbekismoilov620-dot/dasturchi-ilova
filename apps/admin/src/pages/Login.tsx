import { useState } from 'react';

import { Button, Field, Input } from '../components/ui';
import { useAuth } from '../lib/auth';
import { configured, supabase } from '../lib/supabase';

export function Login() {
  const { session, isStaff, signOut } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  if (session && !isStaff) {
    return (
      <div className="login">
        <div className="card stack">
          <img src="/mark.svg" alt="" width={44} />
          <h1 className="display" style={{ fontSize: 32 }}>
            No access
          </h1>
          <p className="muted">
            {session.user.email} doesn’t have an instructor, editor or admin role. Ask an administrator to grant access.
          </p>
          <Button onClick={signOut}>Sign out</Button>
        </div>
      </div>
    );
  }

  return (
    <div className="login">
      <form
        className="card stack"
        onSubmit={async (e) => {
          e.preventDefault();
          setBusy(true);
          setError(null);
          const { error } = await supabase.auth.signInWithPassword({ email: email.trim(), password });
          if (error) setError(error.message);
          setBusy(false);
        }}>
        <img src="/mark.svg" alt="" width={44} />
        <div>
          <h1 className="display" style={{ fontSize: 34 }}>
            Mahorat Studio
          </h1>
          <p className="muted" style={{ margin: '4px 0 0' }}>
            Content and operations for the Mahorat learning platform.
          </p>
        </div>
        {!configured && <p className="badge danger">VITE_SUPABASE_URL / VITE_SUPABASE_ANON_KEY are not set.</p>}
        <Field label="Email">
          <Input type="email" autoComplete="email" required value={email} onChange={(e) => setEmail(e.target.value)} data-testid="login-email" />
        </Field>
        <Field label="Password" error={error}>
          <Input type="password" autoComplete="current-password" required value={password} onChange={(e) => setPassword(e.target.value)} data-testid="login-password" />
        </Field>
        <Button variant="primary" type="submit" loading={busy} data-testid="login-submit">
          Sign in
        </Button>
      </form>
    </div>
  );
}
