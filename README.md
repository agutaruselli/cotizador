# Cotizador

MVP del piloto de cotización de autos usados con una automotora socia. Antes de trabajar en el código, leé [CLAUDE.md](CLAUDE.md) y [docs/alcance-mvp.md](docs/alcance-mvp.md).

## Requisitos

- Node.js 22.12 o superior (se usa la 24).
- Docker Desktop, para Supabase local y las pruebas de base de datos.

## Desarrollo local

```bash
npm install
npx supabase start          # levanta Supabase local, aplica migraciones y seed
npx supabase status -o env  # muestra la URL y la clave anon locales
```

Creá un archivo `.env.local` con los valores locales (tiene prioridad sobre `.env`):

```bash
VITE_SUPABASE_URL=http://127.0.0.1:54321
VITE_SUPABASE_ANON_KEY=<ANON_KEY de supabase status>
```

Después, `npm run dev` y abrí http://localhost:5173.

Datos del seed (solo en local):

- Panel: `dealer@example.com` o `admin@example.com`, con la contraseña `local-dev-password`.
- Seguimiento: http://localhost:5173/seguimiento#demo-local-token-00000000000000000000000000

## Pruebas

| Comando | Qué prueba |
| --- | --- |
| `npm run lint` y `npm run typecheck` | ESLint y TypeScript estricto |
| `npm test` | Vitest: lógica y componentes |
| `npm run test:db` | pgTAP: RLS, token y estados, contra Supabase local |
| `npm run test:e2e` | Playwright en emulación móvil, contra Supabase local con el seed |

Para Playwright, la primera vez instalá el navegador con `npx playwright install chromium`. Las variables `VITE_SUPABASE_*` tienen que apuntar a Supabase local (con `.env.local`).

## Base de datos

- Toda la estructura está en `supabase/migrations/`. Nunca cambiar la base a mano.
- Nueva migración: `npx supabase migration new <nombre>`, y después `npx supabase db reset` para aplicarla en local.
- En la nube se aplica con el workflow manual **Deploy database migrations** de GitHub Actions. Nunca sube el seed.

## Configuración de los servicios (una sola vez)

### Supabase (proyecto en la nube)

1. En **Authentication → URL Configuration**, poné como Site URL la URL de Cloudflare Pages.
2. En **Authentication → Providers → Email**: activá el código de 6 dígitos y mínimo de 12 caracteres para contraseñas.
3. Los usuarios de la automotora y el administrador se crean a mano en **Authentication → Users**, y después se les agrega su fila en `profiles` desde el SQL Editor.

### Cloudflare Pages

1. **Workers & Pages → Create → Pages → Connect to Git**, y elegí el repositorio `cotizador`.
2. Framework preset: *None*. Build command: `npm run build`. Output directory: `dist`.
3. Variables de entorno (Production y Preview): `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY` y `NODE_VERSION=24`.

Cada push a `main` despliega a producción. Las demás ramas generan una URL de preview.

### Secretos de GitHub Actions

En **Settings → Secrets and variables → Actions**:

| Secreto | Para qué | Dónde se obtiene |
| --- | --- | --- |
| `SUPABASE_URL` | Ping semanal | Supabase → Project Settings → API |
| `SUPABASE_ANON_KEY` | Ping semanal | Supabase → Project Settings → API |
| `SUPABASE_ACCESS_TOKEN` | Aplicar migraciones | Supabase → Account → Access Tokens |
| `SUPABASE_DB_PASSWORD` | Aplicar migraciones | La contraseña de la base elegida al crear el proyecto |
| `SUPABASE_PROJECT_REF` | Aplicar migraciones | El identificador del proyecto, en su URL |
