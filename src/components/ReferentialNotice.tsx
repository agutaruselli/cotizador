import { es } from '../i18n/es';

// RF-10: aviso de cotización referencial, con el mismo tamaño de letra que el resto.
export function ReferentialNotice() {
  return (
    <aside
      aria-labelledby="referential-notice-title"
      className="rounded-lg border border-amber-300 bg-amber-50 p-4 text-amber-950"
    >
      <h2 id="referential-notice-title" className="font-semibold">
        {es.referentialNotice.title}
      </h2>
      <p className="mt-1">{es.referentialNotice.body}</p>
    </aside>
  );
}
