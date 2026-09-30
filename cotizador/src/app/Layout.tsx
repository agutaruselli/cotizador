import { Link, Outlet } from 'react-router';
import { es } from '../i18n/es';

export function Layout() {
  return (
    <div className="min-h-dvh bg-white text-slate-900">
      <a
        href="#main"
        className="sr-only focus:not-sr-only focus:absolute focus:m-2 focus:rounded focus:bg-white focus:p-2"
      >
        {es.app.skipToContent}
      </a>
      <header className="border-b border-slate-200">
        <div className="mx-auto flex max-w-2xl items-center px-4 py-3">
          <Link to="/" className="inline-flex min-h-11 items-center font-semibold">
            {es.app.name}
          </Link>
        </div>
      </header>
      <main id="main" className="mx-auto max-w-2xl px-4 py-6">
        <Outlet />
      </main>
    </div>
  );
}
