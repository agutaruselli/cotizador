import { useState, type SubmitEvent } from 'react';
import { Navigate, useNavigate } from 'react-router';
import { es } from '../../i18n/es';
import { signIn } from './api';
import { useSession } from './useSession';

function textField(form: FormData, name: string): string {
  const value = form.get(name);
  return typeof value === 'string' ? value : '';
}

// RF-32: dealer staff and admin sign in with email and password.
export function LoginPage() {
  const session = useSession();
  const navigate = useNavigate();
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  if (session.status === 'ready' && session.session) return <Navigate to="/panel" replace />;

  async function handleSubmit(event: SubmitEvent<HTMLFormElement>) {
    event.preventDefault();
    const form = new FormData(event.currentTarget);
    setSubmitting(true);
    setError(null);
    try {
      const result = await signIn(textField(form, 'email'), textField(form, 'password'));
      if (result === 'ok') {
        void navigate('/panel', { replace: true });
        return;
      }
      setError(es.panel.invalidCredentials);
    } catch {
      setError(es.panel.loadError);
    }
    setSubmitting(false);
  }

  return (
    <div className="mx-auto max-w-sm space-y-6">
      <h1 className="text-2xl font-bold">{es.panel.loginTitle}</h1>
      <form onSubmit={(event) => void handleSubmit(event)} className="space-y-4" noValidate>
        <div className="space-y-1">
          <label htmlFor="email" className="block font-medium">
            {es.panel.email}
          </label>
          <input
            id="email"
            name="email"
            type="email"
            autoComplete="username"
            required
            className="min-h-11 w-full rounded-md border border-slate-400 px-3"
          />
        </div>
        <div className="space-y-1">
          <label htmlFor="password" className="block font-medium">
            {es.panel.password}
          </label>
          <input
            id="password"
            name="password"
            type="password"
            autoComplete="current-password"
            required
            className="min-h-11 w-full rounded-md border border-slate-400 px-3"
          />
        </div>
        {error && (
          <p role="alert" className="text-red-700">
            {error}
          </p>
        )}
        <button
          type="submit"
          disabled={submitting}
          className="min-h-11 w-full rounded-md bg-blue-700 px-4 font-semibold text-white disabled:opacity-60"
        >
          {submitting ? es.panel.signingIn : es.panel.signIn}
        </button>
      </form>
    </div>
  );
}
