import { useEffect, useState } from 'react';
import { Navigate, Outlet } from 'react-router';
import { es } from '../../i18n/es';
import { fetchIsStaff, signOut } from './api';
import { useSession } from './useSession';

type Access = 'staff' | 'denied';

// RF-32: only dealer users and admins reach the panel routes.
export function RequireStaff() {
  const session = useSession();
  const userId = session.status === 'ready' ? session.session?.user.id : undefined;
  const [access, setAccess] = useState<{ userId: string; value: Access } | null>(null);

  useEffect(() => {
    if (!userId) return;
    let cancelled = false;
    fetchIsStaff(userId)
      .then((isStaff) => {
        if (!cancelled) setAccess({ userId, value: isStaff ? 'staff' : 'denied' });
      })
      .catch(() => {
        if (!cancelled) setAccess({ userId, value: 'denied' });
      });
    return () => {
      cancelled = true;
    };
  }, [userId]);

  if (session.status === 'loading') return <p role="status">{es.panel.loading}</p>;
  if (!userId) return <Navigate to="/panel/ingresar" replace />;

  const current = access?.userId === userId ? access.value : 'checking';
  if (current === 'checking') return <p role="status">{es.panel.loading}</p>;
  if (current === 'denied') {
    return (
      <div role="alert" className="space-y-4">
        <p>{es.panel.notStaff}</p>
        <button
          type="button"
          onClick={() => void signOut()}
          className="min-h-11 rounded-md border border-slate-300 px-4"
        >
          {es.panel.signOut}
        </button>
      </div>
    );
  }
  return <Outlet />;
}
