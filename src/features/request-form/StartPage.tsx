import { ReferentialNotice } from '../../components/ReferentialNotice';
import { es } from '../../i18n/es';

// Portada provisoria del formulario (RF-01 a RF-13 llegan en el corte 2).
export function StartPage() {
  return (
    <div className="space-y-6">
      <header className="space-y-2">
        <h1 className="text-2xl font-bold">{es.home.title}</h1>
        <p>{es.home.lead}</p>
      </header>
      <ReferentialNotice />
      <p className="text-slate-700">{es.home.comingSoon}</p>
    </div>
  );
}
