import { useEffect, useState } from 'react';
import { useLocation } from 'react-router';
import { ReferentialNotice } from '../../components/ReferentialNotice';
import { es } from '../../i18n/es';
import { fetchRequestByToken, type TrackedRequest } from './api';

type Result = { kind: 'found'; request: TrackedRequest } | { kind: 'not-found' } | { kind: 'error' };
type State = Result | { kind: 'loading' };

// RF-13: private tracking link without login. The token lives in the URL
// fragment so it never reaches server logs or the Referer header.
export function TrackingPage() {
  const { hash } = useLocation();
  const token = hash.replace(/^#/, '');
  const [loaded, setLoaded] = useState<{ token: string; result: Result } | null>(null);

  useEffect(() => {
    if (!token) return;
    let cancelled = false;
    const finish = (result: Result) => {
      if (!cancelled) setLoaded({ token, result });
    };
    fetchRequestByToken(token)
      .then((request) => {
        finish(request ? { kind: 'found', request } : { kind: 'not-found' });
      })
      .catch(() => {
        finish({ kind: 'error' });
      });
    return () => {
      cancelled = true;
    };
  }, [token]);

  let state: State;
  if (!token) state = { kind: 'not-found' };
  else if (loaded?.token === token) state = loaded.result;
  else state = { kind: 'loading' };

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">{es.tracking.title}</h1>
      <TrackingContent state={state} />
      <ReferentialNotice />
    </div>
  );
}

function TrackingContent({ state }: { state: State }) {
  switch (state.kind) {
    case 'loading':
      return <p role="status">{es.tracking.loading}</p>;
    case 'not-found':
      return (
        <div role="alert" className="space-y-1">
          <h2 className="font-semibold">{es.tracking.notFoundTitle}</h2>
          <p>{es.tracking.notFoundBody}</p>
        </div>
      );
    case 'error':
      return (
        <div role="alert" className="space-y-1">
          <h2 className="font-semibold">{es.tracking.errorTitle}</h2>
          <p>{es.tracking.errorBody}</p>
        </div>
      );
    case 'found':
      return (
        <dl className="grid grid-cols-[auto_1fr] gap-x-4 gap-y-2">
          <dt className="font-semibold">{es.tracking.requestNumber}</dt>
          <dd>{state.request.request_number}</dd>
          <dt className="font-semibold">{es.tracking.status}</dt>
          <dd>{es.requestStatus[state.request.status]}</dd>
        </dl>
      );
  }
}
