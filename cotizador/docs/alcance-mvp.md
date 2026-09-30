# Alcance del MVP – Piloto con automotora socia

Sep 30, 2026 · @Taru

## Objetivo e hipótesis del piloto

El MVP es un piloto con una sola automotora socia, y su objetivo es medir si el modelo funciona antes de construir la ronda de ofertas entre varias automotoras. El valor lo pone la propia automotora, sin tasador de la plataforma ni valor de mercado automático.

El piloto debe responder cuatro preguntas:

1. **Completan el formulario:** ¿qué porcentaje de las personas que empiezan una solicitud la envía, con 12 fotos y todos los datos?
2. **La automotora responde:** ¿cuánto tarda en cotizar y qué porcentaje de solicitudes cotiza?
3. **El cliente avanza:** ¿cuántos clientes cotizados aceptan y llegan a la visita?
4. **La oferta se sostiene:** ¿cuánto se desvía el valor final de la oferta inicial?

Todo lo que no ayude a responder estas preguntas queda fuera o se simplifica. Los números de referencia se toman del documento de requerimientos funcionales, cuya numeración (RF-01 a RF-38) se mantiene.

## Flujo del piloto

El flujo es lineal y más corto que el definitivo, porque no hay ronda de ofertas ni tasador intermedio.

1. El cliente entra al formulario, ve el aviso de cotización referencial y verifica su correo con un código de 6 dígitos. Desde ese momento se guarda un borrador y se le envía el enlace para retomarlo.
2. Completa datos del vehículo, 12 fotos, mantenimiento, condición y neumáticos, acepta el consentimiento y envía.
3. La solicitud queda en estado "Recibida", la automotora recibe un correo inmediato y el cliente ve el plazo estimado de cotización: el mismo día si envió por la mañana, o la mañana siguiente si envió por la tarde. Sus datos de contacto son visibles para la automotora desde este paso.
4. La automotora revisa la solicitud en su panel. Si falta algo, pide información adicional o el reemplazo de una foto; el cliente responde desde su enlace.
5. La automotora carga su valor (único) en dólares, con vigencia y observaciones. El cliente recibe un correo y ve en su enlace un rango: el valor menos la tolerancia estándar hasta el valor, con el aviso de revisión presencial.
6. El cliente presiona "Quiero avanzar". La automotora propone horarios y el cliente confirma uno.
7. Tras la visita, la automotora registra el resultado y el valor final. El cliente recibe una consulta de un clic para confirmar si la venta se concretó.

## Entran tal cual (11 RF)

Estos requerimientos se construyen como están definidos en el documento de requerimientos funcionales.

| RF | Requerimiento | Nota para el MVP |
| --- | --- | --- |
| RF-02 | Datos de contacto | Nombre, teléfono y correo |
| RF-04 | Fotos obligatorias | 12 fotos: 8 exteriores y 4 interiores, con guía visual de cada ángulo |
| RF-06 | Historial de mantenimiento | Servicio oficial, documentación, fecha y kilometraje del último service |
| RF-07 | Condición general | Fallas conocidas y pérdidas o consumo de líquidos |
| RF-08 | Neumáticos | Estado y edad, con foto opcional |
| RF-10 | Aviso de cotización referencial | En formulario, confirmación, correos y seguimiento, sin letra chica |
| RF-12 | Resumen y envío | Con corrección por sección |
| RF-13 | Confirmación y seguimiento | Número de solicitud, enlace privado sin login y plazo estimado de cotización |
| RF-24 | Cotización al cliente | Rango desde (valor − tolerancia) hasta el valor, más información de la visita |
| RF-26 | Coordinación de la visita | La automotora propone horarios, el cliente confirma, recordatorios por correo |
| RF-33 | Bandeja de solicitudes | Filtros por estado y fecha, búsqueda por número o contacto |

## Entran simplificados (20 RF)

Se construyen, pero con recortes que reducen el esfuerzo sin perder lo que el piloto necesita medir. RF-25 se suma a la lista de núcleo porque RF-26 depende de que el cliente acepte avanzar.

| RF | Requerimiento | Qué se recorta o cambia en el MVP |
| --- | --- | --- |
| RF-01 | Elegibilidad del vehículo | Solo antigüedad máxima y marcas excluidas, guardadas en una tabla de configuración. Sin valor máximo, porque no hay referencia de mercado |
| RF-03 | Datos del vehículo | Marca y modelo desde un catálogo cargado con la lista que entregue la automotora. La versión es texto libre con sugerencias |
| RF-05 | Validación de fotos | Solo en el navegador: formato, resolución mínima, peso, nitidez, brillo y foto repetida. Sin detección de vehículo ni de ángulo con IA |
| RF-09 | Guardado de borrador | Se guarda automáticamente tras verificar el correo, con enlace para retomar. Vigencia de 30 días |
| RF-11 | Verificación y consentimiento | Solo correo, con código de 6 dígitos al inicio del formulario. El consentimiento indica que los datos se comparten con la automotora socia |
| RF-16 | Revisión de fotos | Se fusiona con RF-17 |
| RF-17 | Información adicional | Una sola acción de la automotora: pedir datos o reemplazo de fotos. El cliente responde desde su enlace |
| RF-18 | Control de abuso | Verificación de correo, captcha gratuito y límite de solicitudes por correo e IP. Sin detección de fotos repetidas entre solicitudes |
| RF-20 | Filtros y notificaciones | Un correo inmediato a la automotora por cada solicitud nueva, y un recordatorio a la automotora y al administrador si vence el plazo de cotización. Sin filtros ni resúmenes |
| RF-22 | Carga de oferta | Valor único en dólares (USD) con vigencia y observaciones. Sin selector de sucursal, porque la automotora tiene una sola. Se permite corregirlo con historial de versiones mientras el cliente no haya aceptado |
| RF-25 | Aceptación del cliente | Botón "Quiero avanzar" en el seguimiento. No hay otras automotoras a las que avisar |
| RF-27 | Resultado de la revisión | Formulario corto con valor final y resultado. Si baja más que la tolerancia, motivo de lista y foto. Sin bloqueo de nuevas rondas |
| RF-28 | Confirmación del cliente | Un correo con dos botones tras la visita, para medir el resultado real |
| RF-29 | Registro de automotoras | Una sola automotora con una sola sucursal, cargadas a mano en la base de datos. Sin pantalla de administración |
| RF-30 | Usuarios de automotora | Entre uno y tres usuarios creados a mano |
| RF-32 | Acceso y roles | Dos roles: usuario de automotora y administrador de la plataforma. No hay tasador |
| RF-34 | Estados de la solicitud | Recibida, información adicional requerida, cotizada, cliente interesado, visita coordinada, revisión realizada, cerrada (compra), cerrada (sin acuerdo) y vencida |
| RF-35 | Detalle de la solicitud | Datos, galería por ángulo con visor ampliable, ofertas e historial de estados. Sin referencia de mercado ni descarga conjunta |
| RF-36 | Notas y trazabilidad | Notas internas e historial de estados con fecha y usuario. Sin mensajería entre partes |
| RF-38 | Reportes | Una pantalla con las métricas del piloto (ver la sección de medición) y exportación a CSV |

## Postergados (7 RF)

No se construyen en el piloto. Se reactivan al sumar más automotoras o cuando el volumen lo justifique.

| RF | Requerimiento | Por qué se posterga | Qué lo reactiva |
| --- | --- | --- | --- |
| RF-14 | Revisión por excepción y publicación automática | No hay tasador, y la automotora revisa todas las solicitudes | Volumen que sature a la automotora |
| RF-15 | Valor de mercado y valor de compra sugerido | Requiere resolver la fuente de datos y el tema legal de los portales. El valor lo pone la automotora | Necesidad de validar ofertas o de incorporar un tasador |
| RF-19 | Publicación a automotoras | Con un solo socio, la solicitud es visible apenas se envía | Segunda automotora |
| RF-21 | Protección de identidad | Sin competencia entre socios no hay riesgo de fuga de contacto | Segunda automotora |
| RF-23 | Selección de la mejor oferta | Hay un solo oferente | Segunda automotora |
| RF-31 | Cumplimiento de automotoras | Con un socio, el control se hace conversando, apoyado por las métricas del piloto | Segunda automotora |
| RF-37 | Comisiones y estado de cuenta | El acuerdo comercial se maneja fuera del sistema | Definir el modelo de cobro tras el piloto |

El MVP igual registra el valor de cada oferta, el valor final y la fecha de adjudicación, para poder definir el fee y los tramos con datos reales.

## Stack tecnológico (sin herramientas pagas)

El stack elegido es una aplicación web de una sola página (React + Vite) alojada como sitio estático, con Supabase como backend completo. Su único gasto previsto es un dominio propio, necesario para enviar correos con buena entrega.

| Capa | Herramienta | Costo | Nota |
| --- | --- | --- | --- |
| Frontend | React, Vite, TypeScript y Tailwind CSS | Gratis | Diseño mobile-first, porque las fotos se toman desde el celular |
| Hosting del frontend | Cloudflare Pages (sitio estático) | Gratis | Sin servidor propio. Ver la nota sobre Vercel más abajo |
| Base de datos, autenticación, archivos y lógica | Supabase (Postgres con seguridad por filas, Auth, Storage y Edge Functions) | Gratis | 500 MB de base, 1 GB de archivos, 5 GB de transferencia mensual |
| Acceso de clientes | Supabase Auth con código de 6 dígitos por correo | Gratis | El cliente no crea contraseña ni cuenta visible |
| Acceso de la automotora y el administrador | Supabase Auth con correo y contraseña | Gratis | Usuarios creados a mano |
| Correos | Resend | Gratis | 3.000 correos al mes y 100 al día. Requiere un dominio propio verificado |
| Anti-spam | Cloudflare Turnstile | Gratis | Captcha sin fricción en el inicio del formulario |
| Tareas programadas | Supabase (pg\_cron y Edge Functions) | Gratis | Recordatorios de visita, vencimiento de solicitudes y limpieza de fotos |
| Procesamiento de fotos | En el navegador del cliente | Gratis | Compresión a unos 1600 px, chequeo de nitidez y brillo, y hash para detectar duplicados |
| Código y pruebas | GitHub y GitHub Actions | Gratis | Incluye un respaldo semanal de la base |

**Por qué una aplicación estática y no Next.js.** El plan gratuito de Vercel (Hobby) se limita al [uso personal no comercial](https://vercel.com/docs/limits/fair-use-guidelines), y un piloto con una automotora socia es comercial. Next.js en el plan gratuito de Cloudflare tiene un [límite de 3 MiB por Worker](https://opennext.js.org/cloudflare/troubleshooting) que es fácil de superar. Como la app es privada y no necesita posicionamiento en buscadores, una SPA con Supabase evita ambos problemas.

**Capacidad estimada del plan gratuito.** Son estimaciones mías, para validar en el piloto:

- **Fotos:** 12 fotos comprimidas a unos 300 KB son cerca de 3,6 MB por solicitud. Con 1 GB de archivos entran unas 270 solicitudes. Conviene borrar las fotos de solicitudes cerradas o vencidas pasados unos 60 días.
- **Correos:** cada solicitud genera unos 8 correos (código, enlace de borrador, confirmación, aviso a la automotora, cotización, horarios, recordatorio y confirmación posterior). Con [100 al día y 3.000 al mes](https://resend.com/docs/knowledge-base/account-quotas-and-limits), alcanza para unas 12 solicitudes diarias o 375 mensuales.

**Límites a tener presentes.**

- Los proyectos gratuitos de Supabase se pausan tras 7 días sin actividad, y el primer acceso posterior puede tardar entre 10 y 30 segundos. Durante el piloto se evita con un ping programado semanal. Los detalles están en esta [guía de límites](https://www.ssdnodes.com/learn/is-supabase-free-cloud-vs-self-hosted), verificada el 10 de septiembre de 2026.
- El plan gratuito de Supabase no incluye respaldos diarios, por eso se programa un volcado semanal de la base.
- El primer gasto probable sería el plan Pro de Supabase (25 dólares al mes), por almacenamiento, respaldos o la pausa. Los límites cambian con frecuencia: conviene revisarlos en las páginas oficiales antes del lanzamiento.

## Plan de construcción y medición del piloto

Se construye por cortes verticales, en este orden, empezando por lo más riesgoso: el formulario con fotos. Cada corte termina con algo que se puede usar y probar de punta a punta.

1. **Base del proyecto:** repositorio, proyecto en Supabase, esquema de datos (solicitudes, vehículos, fotos, ofertas, eventos de estado, automotora, sucursales, usuarios y configuración), seguridad por filas, acceso por enlace privado con token y despliegue automático en Cloudflare Pages.
2. **Formulario del cliente (RF-01 a RF-13):** verificación de correo, datos del vehículo, 12 fotos con guía, validación y compresión, mantenimiento, condición y neumáticos, borrador con enlace, resumen, envío y correos de confirmación.
3. **Panel de la automotora (RF-33, RF-35, RF-17, RF-34, RF-36):** ingreso, bandeja con filtros, detalle con galería, pedido de información adicional con respuesta del cliente, estados y notas.
4. **Cotización y aceptación (RF-22, RF-24, RF-25):** carga del valor por la automotora, rango y aviso en el seguimiento del cliente, y botón "Quiero avanzar".
5. **Visita y resultado (RF-26, RF-27, RF-28):** horarios propuestos, confirmación del cliente, recordatorios, registro del resultado y confirmación de un clic.
6. **Métricas y cierre (RF-38):** pantalla de métricas con exportación a CSV, limpieza de fotos, respaldo semanal, pruebas en celulares reales y un ensayo completo con la automotora antes de abrirlo al público.

**Medición del piloto.** El sistema debe registrar, sin herramientas externas, lo necesario para responder las cuatro preguntas del inicio:

- **Embudo del formulario:** solicitudes iniciadas, con correo verificado, con fotos completas y enviadas. El abandono por paso indica dónde se pierde la gente.
- **Fricción de fotos:** cuántas fotos rechaza la validación y cuántos reintentos hacen los usuarios.
- **Respuesta de la automotora:** tiempo hasta la primera cotización, porcentaje de solicitudes cotizadas y porcentaje cotizado dentro del plazo comprometido.
- **Avance del cliente:** cotizadas que aceptan, visitas realizadas y compras concretadas.
- **Calidad de la oferta:** desvío entre la oferta inicial y el valor final, y cantidad de bajas fuera de la tolerancia.

Las metas de cada indicador se definen con la automotora antes de empezar, para saber qué resultado justifica pasar a la versión con varias automotoras.

## Antes de construir: datos y decisiones pendientes

Estos puntos no bloquean el arranque técnico, pero sí el corte 2 en adelante. Conviene resolverlos durante las primeras semanas.

**A pedirle a la automotora**

- Lista de marcas y modelos (y versiones, si la tiene) que compra, para cargar el catálogo de RF-03.
- Marcas excluidas y antigüedad máxima aceptada, para RF-01.
- Dirección, horarios, contacto y documentación que el cliente debe llevar a su única sucursal, donde se harán las revisiones.
- Quiénes usarán el panel (entre uno y tres correos) y quién cotiza.
- Plazo de cotización: lo acordado es el mismo día si la solicitud llega por la mañana y la mañana siguiente si llega por la tarde. Falta confirmar la hora que separa mañana de tarde, el horario de atención y cómo se cuentan los fines de semana y feriados.
- Conformidad con la tolerancia estándar de 5% entre oferta y valor final, o el porcentaje que prefieran.
- Razón social y textos legales para el consentimiento de RF-11.

**A decidir por ustedes**

- Nombre de la plataforma, logo y dominio propio (también para el correo de envío).
- Moneda de la cotización: dólares (USD), ya definida. El sistema la guarda como campo, por si más adelante se suman otras monedas.
- Vigencia de la oferta de la automotora (por ejemplo, 7 días) y plazo para que el cliente acepte antes de pasar a "Vencida".
- Retención de fotos tras cerrar o vencer una solicitud (propuesta: 60 días).
- Quién será el administrador de la plataforma, con acceso a la base de datos.
- Acuerdo comercial del piloto con la automotora (fee o gratuito), que se maneja fuera del sistema.

**A validar con asesoría legal.** El texto del consentimiento y el tratamiento de datos personales y fotos según la normativa local, antes de abrir el formulario al público.
