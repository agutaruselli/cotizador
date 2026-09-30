import type { Session } from '@supabase/supabase-js';
import { useEffect, useState } from 'react';
import { getSession, onSessionChange } from './api';

export type SessionState = { status: 'loading' } | { status: 'ready'; session: Session | null };

export function useSession(): SessionState {
  const [state, setState] = useState<SessionState>({ status: 'loading' });

  useEffect(() => {
    let cancelled = false;
    void getSession().then((session) => {
      if (!cancelled) setState({ status: 'ready', session });
    });
    const unsubscribe = onSessionChange((session) => {
      if (!cancelled) setState({ status: 'ready', session });
    });
    return () => {
      cancelled = true;
      unsubscribe();
    };
  }, []);

  return state;
}
