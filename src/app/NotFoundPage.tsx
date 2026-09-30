import { Link } from 'react-router';
import { es } from '../i18n/es';

export function NotFoundPage() {
  return (
    <div className="space-y-4">
      <h1 className="text-2xl font-bold">{es.notFound.title}</h1>
      <Link to="/" className="inline-flex min-h-11 items-center underline">
        {es.notFound.backHome}
      </Link>
    </div>
  );
}
