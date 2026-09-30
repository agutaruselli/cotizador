import { useEffect, useState } from 'react';
import { es } from '../../i18n/es';
import { formatDateTime } from '../../lib/format';
import { fetchRequests, signOut, type PanelRequest } from './api';

type State = { kind: 'loading' } | { kind: 'ready'; requests: PanelRequest[] } | { kind: 'error' };

// Minimal preview of the RF-33 inbox; filters and search arrive in slice 3.
export function PanelHomePage() {
  const [state, setState] = useState<State>({ kind: 'loading' });

  useEffect(() => {
    let cancelled = false;
    fetchRequests()
      .then((requests) => {
        if (!cancelled) setState({ kind: 'ready', requests });
      })
      .catch(() => {
        if (!cancelled) setState({ kind: 'error' });
      });
    return () => {
      cancelled = true;
    };
  }, []);

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between gap-4">
        <h1 className="text-2xl font-bold">{es.panel.requestsTitle}</h1>
        <button
          type="button"
          onClick={() => void signOut()}
          className="min-h-11 rounded-md border border-slate-300 px-4"
        >
          {es.panel.signOut}
        </button>
      </div>
      {state.kind === 'loading' && <p role="status">{es.panel.loading}</p>}
      {state.kind === 'error' && <p role="alert">{es.panel.loadError}</p>}
      {state.kind === 'ready' && state.requests.length === 0 && <p>{es.panel.noRequests}</p>}
      {state.kind === 'ready' && state.requests.length > 0 && (
        <table className="w-full text-left">
          <thead>
            <tr className="border-b border-slate-300">
              <th scope="col" className="py-2">
                {es.panel.columnNumber}
              </th>
              <th scope="col" className="py-2">
                {es.panel.columnStatus}
              </th>
              <th scope="col" className="py-2">
                {es.panel.columnSubmitted}
              </th>
            </tr>
          </thead>
          <tbody>
            {state.requests.map((request) => (
              <tr key={request.id} className="border-b border-slate-200">
                <td className="py-2">{request.request_number}</td>
                <td className="py-2">{es.requestStatus[request.status]}</td>
                <td className="py-2">
                  {request.submitted_at ? formatDateTime(request.submitted_at) : ''}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
}
