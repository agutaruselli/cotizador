# CLAUDE.md

Guía para trabajar en este repositorio. Léela completa antes de escribir código y mantenela actualizada cuando cambie una decisión.

## 1. Qué es este proyecto

Plataforma web para que personas que quieren vender su auto usado reciban una **cotización estimada** de una automotora socia. El cliente completa una solicitud con datos y fotos del vehículo, la automotora pone un valor, y el cliente ve un **rango** sujeto a revisión presencial en la automotora.

Este repositorio es el **MVP de un piloto con UNA sola automotora**. Lo que se busca medir:

1. Qué porcentaje de quienes empiezan el formulario lo envían completo (12 fotos incluidas).
2. Cuánto tarda la automotora en cotizar y qué porcentaje cotiza.
3. Cuántos clientes cotizados aceptan y llegan a la visita.
4. Cuánto se desvía el valor final de la oferta inicial.

Todo lo que no ayude a medir esto queda fuera o se simplifica. **Ante la duda, construí lo más simple.**

## 2. Documentos de referencia

Exportalos a `docs/` en Markdown y tratalos como la fuente de verdad:

- `docs/requerimientos-funcionales.md`: 38 requerimientos funcionales (RF-01 a RF-38). Es el documento completo de la visión final.
- `docs/alcance-mvp.md`: qué RF entran tal cual, cuáles simplificados y cuáles se posponen. **Si hay conflicto entre ambos, manda el alcance del MVP.**

Al referirte a una funcionalidad, usá siempre su número de RF (por ejemplo, "RF-05") en commits, pruebas y comentarios.

## 3. Stack y restricciones

**Regla principal: no usar servicios ni herramientas pagas.** Si una dependencia o servicio requiere pagar, parar y preguntar antes de integrarla.

- **Frontend:** React + Vite + TypeScript (modo estricto) + Tailwind CSS. SPA, sin SSR. Mobile-first.
- **Hosting del frontend:** Cloudflare Pages (estático). No usar Vercel Hobby (no permite uso comercial) ni Next.js sobre Cloudflare Workers gratuito (límite de tamaño).
- **Backend:** Supabase (Postgres, Auth, Storage, Edge Functions, pg_cron) en el plan gratuito.
- **Correos:** Resend (plan gratuito). Se llama desde Edge Functions, nunca desde el navegador.
- **Anti-spam:** Cloudflare Turnstile.
- **Validación:** Zod para formularios y para payloads de Edge Functions.
- **Pruebas:** Vitest para lógica y componentes, Playwright para el flujo completo (formulario y panel).
- **CI:** GitHub Actions (lint, tipos, pruebas, build).

### Límites del plan gratuito que condicionan el diseño

- **Storage 1 GB:** las fotos se comprimen en el navegador (lado mayor ~1600 px, calidad ~0,8, objetivo ~300 KB por foto) antes de subirlas. Borrar fotos de solicitudes cerradas o vencidas tras el plazo configurado (propuesta: 60 días).
- **Base de datos 500 MB:** no guardar binarios en la base. Solo rutas de Storage.
- **Correos 100/día y 3.000/mes:** presupuesto de ~8 correos por solicitud. No agregar correos nuevos sin revisar el presupuesto. Todos los correos pasan por una única función `sendEmail` con registro en la tabla `email_log`.
- **Pausa por inactividad de Supabase (7 días):** hay un ping programado semanal. No quitarlo.
- **Sin respaldos diarios:** hay un volcado semanal con GitHub Actions. No quitarlo.

## 4. Estructura del repositorio

```
/
├── CLAUDE.md
├── docs/                      # requerimientos y alcance exportados
├── src/
│   ├── app/                   # rutas y layout
│   ├── features/
│   │   ├── request-form/      # formulario del cliente (RF-01 a RF-13)
│   │   ├── client-tracking/   # seguimiento por enlace privado (RF-13, RF-24, RF-25, RF-26, RF-28)
│   │   └── dealer-panel/      # panel de la automotora (RF-33 a RF-36, RF-22, RF-26, RF-27, RF-38)
│   ├── components/            # componentes compartidos
│   ├── lib/                   # cliente Supabase, utilidades, validaciones
│   └── i18n/es.ts             # todos los textos visibles (español)
├── supabase/
│   ├── migrations/            # toda la estructura de base de datos, en SQL
│   ├── functions/             # Edge Functions (correos, recordatorios, verificación)
│   └── seed.sql               # automotora, sucursales y catálogo de ejemplo
├── e2e/                       # pruebas Playwright
└── .github/workflows/
```

## 5. Comandos

Mantener actualizados. Detalle de configuración en `README.md`.

```
npm install
npm run dev              # servidor de desarrollo (http://localhost:5173)
npm run build            # typecheck + build de producción
npm run lint             # ESLint (typescript-eslint strict)
npm run typecheck        # tsc -b
npm run test             # Vitest
npm run test:db          # pgTAP (supabase/tests), requiere Supabase local
npm run test:e2e         # Playwright en emulación móvil, requiere Supabase local con seed
npx supabase start       # Supabase local (requiere Docker)
npx supabase db reset    # reaplica migraciones y seed en local
npx supabase migration new <nombre>
```

- TypeScript está fijado en `~6.0`: typescript-eslint todavía no soporta la 7.
- Las migraciones se aplican a la nube solo con el workflow manual `db-push.yml`.

## 6. Convenciones de código

- **Idioma:** código, nombres de tablas y columnas, y commits en **inglés**. Textos visibles para el usuario en **español**, siempre desde `src/i18n/es.ts`, nunca escritos en los componentes.
- TypeScript estricto, sin `any`. Validar con Zod en los bordes (formularios, Edge Functions).
- Componentes pequeños, sin librerías de UI pesadas. Accesibilidad básica: etiquetas en los campos, foco visible, contraste suficiente, botones táctiles de al menos 44 px.
- Toda la estructura de base de datos vive en `supabase/migrations/`. Nunca cambiar la base a mano.
- Commits pequeños con mensaje claro, referenciando el RF cuando aplique.
- Nada de secretos en el repositorio. Mantener `.env.example` actualizado.

## 7. Seguridad y privacidad (no negociable)

- **Row Level Security activada en todas las tablas**, sin excepciones. Escribir pruebas que verifiquen que un usuario no puede leer datos ajenos.
- La clave `service_role` de Supabase **nunca** llega al navegador. Solo se usa en Edge Functions.
- **El cliente no tiene cuenta.** Accede a su solicitud por un enlace con token aleatorio de al menos 128 bits. En la base se guarda solo el hash del token. El token nunca se escribe en logs.
- Las fotos van a un bucket **privado** y se sirven con URLs firmadas de corta duración.
- No registrar datos personales (nombre, correo, teléfono) en logs ni en mensajes de error.
- Límites por correo e IP y Turnstile en el inicio del formulario (RF-18 simplificado).
- El consentimiento (RF-11) se guarda con fecha y versión del texto aceptado.

## 8. Reglas de negocio clave

- **Aviso de cotización referencial (RF-10):** debe mostrarse en el formulario, en la confirmación, en los correos y junto al rango en el seguimiento. Sin letra chica. Texto centralizado en `i18n`.
- **Rango al cliente (RF-24):** desde `oferta × (1 − tolerancia)` hasta `oferta`. La tolerancia sale de la tabla de configuración (valor inicial 5%), nunca fija en el código.
- **Moneda:** todos los montos (oferta, rango, valor final) son en **dólares estadounidenses (USD)**, que es como comercializa la automotora del piloto. Guardar igual la moneda como campo (`currency`, por defecto `USD`) y formatear los montos desde una única función de `lib/`, para no fijar la moneda en los componentes.
- **Sucursal:** la automotora del piloto tiene **una sola sucursal**. No construir selector de sucursal: la dirección, horarios y contacto de la visita salen de esa única sucursal.
- **Oferta (RF-22):** la pone la automotora. Valor único en USD, con vigencia y observaciones. Se puede corregir mientras el cliente no haya aceptado, y cada cambio queda como una nueva versión.
- **Resultado (RF-27):** si el valor final baja más que la tolerancia, exigir motivo de una lista y una foto de respaldo.
- **Fotos (RF-04, RF-05):** 12 obligatorias, 8 exteriores (frente, trasera, lateral izquierdo, lateral derecho y cuatro esquinas) y 4 interiores (tablero con el cuentakilómetros encendido, asientos delanteros, asientos traseros y baúl). Validación solo en el navegador: formato, resolución mínima, peso, nitidez, brillo y duplicadas. No se envía hasta completar las 12.
- **Estados de la solicitud (RF-34):** `received`, `info_requested`, `quoted`, `client_interested`, `visit_scheduled`, `inspection_done`, `closed_purchased`, `closed_no_deal`, `expired`. Además existe `draft` (borrador, RF-09 y embudo de RF-38), que la automotora nunca ve. Todo cambio de estado se registra en `status_events` con fecha y usuario, mediante un trigger.
- **Enlace privado (RF-09, RF-13):** un solo token por solicitud, que sirve para retomar el borrador y para el seguimiento. Va en el fragmento de la URL (`/seguimiento#<token>`), para que no llegue a logs ni al Referer, y se consulta por POST con `get_request_by_token`.
- **Zona horaria:** la de la automotora, en `dealers.timezone` (piloto: `America/Montevideo`).
- **Verificación de correo (RF-11):** se hace al inicio del formulario con código de 6 dígitos. Desde ahí se guarda el borrador automáticamente (RF-09, vigencia de 30 días).
- **Plazo de cotización:** la automotora se comprometió a cotizar **el mismo día si la solicitud se envía por la mañana, y la mañana siguiente si se envía por la tarde**.
  - Al enviarse la solicitud, calcular y guardar `quote_due_at` a partir de la hora de envío, la zona horaria de la automotora y los parámetros de `settings`: hora de corte entre mañana y tarde (a confirmar, propuesta 12:00), hora límite de la mañana siguiente, días hábiles y feriados. Toda esa lógica vive en una única función pura de `lib/`, con pruebas para los casos borde (justo en el corte, fin de semana, feriado).
  - Mostrar al cliente el plazo estimado ("hoy" o "mañana por la mañana") en la confirmación, en el correo y en el seguimiento.
  - Un job de `pg_cron` revisa cada 15 minutos las solicitudes en estado `received` cuyo `quote_due_at` ya pasó y que no tienen recordatorio enviado. Envía un único correo de recordatorio a la automotora y al administrador y marca `overdue_notified_at`. No se le envían más correos por la misma solicitud.
  - Guardar si la cotización salió dentro del plazo, para la métrica de cumplimiento (RF-38).
- **Métricas (RF-38):** los eventos necesarios para el embudo (iniciada, correo verificado, fotos completas, enviada, cotizada, aceptada, visita, resultado) se registran desde el corte 2. No depender de herramientas externas de analítica.

## 9. Modelo de datos

La fuente de verdad son las migraciones en `supabase/migrations/`.

**Creadas en el corte 1:**

- `dealers`: incluye `timezone`.
- `branches`: un solo registro en el piloto, pero se mantiene la tabla para poder sumar sucursales.
- `profiles`: solo personal, con rol `dealer_user` o `admin` y `dealer_id`. Los clientes que verifican su correo por OTP no tienen perfil.
- `settings`: una sola fila tipada con tolerancia, vigencias, retención de fotos, plazo de cotización, días hábiles y elegibilidad.
- `holidays`
- `vehicle_catalog`: marca y modelo.
- `requests`: datos del cliente, vehículo, mantenimiento, condición, neumáticos, estado, consentimiento, vencimiento del borrador, `quote_due_at` y `overdue_notified_at`.
- `request_tokens`: solo el hash SHA-256 del token, en una tabla aparte con RLS y sin políticas, inaccesible desde la API.
- `photos`: solicitud, ángulo, ruta y hash.
- `offers`: valor, moneda, vigencia, sucursal y versión.
- `status_events`

**Llegan en su corte:** `visit_slots`, `inspection_results`, `internal_notes` y `email_log`.

**Modelo de acceso (RLS):**

- `anon` solo lee configuración y catálogo, y su solicitud por `get_request_by_token`.
- El cliente (autenticado sin perfil) solo ve y edita los campos de formulario de su borrador.
- `dealer_user` ve las solicitudes enviadas de su automotora.
- `admin` lee todo.
- Los cambios de estado, token y plazos se hacen solo con funciones `security definer`.
- Las funciones auxiliares viven en el esquema `private`, que no se expone en la API.

## 10. Fuera de alcance del MVP (no construir)

Si una tarea parece requerir alguna de estas cosas, parar y preguntar:

- Ronda de ofertas, varias automotoras, selección de mejor oferta y filtros de notificación (RF-19, RF-20 completo, RF-23).
- Valor de mercado, extracción de precios de la web y valor de compra sugerido (RF-15).
- Publicación automática y revisión por excepción, tasador (RF-14).
- Protección de identidad y desenfoque de patentes (RF-21).
- Cumplimiento de automotoras y suspensión (RF-31).
- Comisiones, cobros, pagos y facturación (RF-37).
- Cuentas de usuario final, compra de autos por usuarios finales (prevista para una versión 2).
- Detección de vehículo o ángulo con IA en las fotos.
- Mensajería entre cliente y automotora.

## 11. Forma de trabajo

- Trabajar por **cortes verticales**, en este orden: (1) base del proyecto, (2) formulario del cliente, (3) panel de la automotora, (4) cotización y aceptación, (5) visita y resultado, (6) métricas y cierre. Detalle en `docs/alcance-mvp.md`.
- Antes de cada corte, proponer un plan breve y esperar confirmación.
- Cada funcionalidad termina con pruebas y una verificación manual en un celular (o emulación móvil).
- Si un requerimiento es ambiguo, preguntar en vez de suponer. Si una decisión cambia el alcance, actualizar este archivo y `docs/alcance-mvp.md`.
- No agregar dependencias sin justificarlo. Preferir la plataforma del navegador y las funciones de Supabase antes que librerías nuevas.
- Antes del lanzamiento, revisar los límites vigentes de los planes gratuitos de Supabase, Cloudflare y Resend, porque cambian con frecuencia.
