# Requerimientos funcionales – Plataforma de cotización y compra de vehículos usados

Sep 30, 2026 · @Taru

## Contexto, objetivo y actores

La plataforma permite que cualquier persona que quiera vender su auto usado reciba una cotización estimada, y que ese auto termine en una automotora socia que lo compra para revenderlo. El cliente solicita la cotización sin crear cuenta; las automotoras compiten por el vehículo y la plataforma le muestra al cliente la mejor oferta.

El enfoque es masivo: gama baja y media, con el mínimo de pasos para el cliente y revisión humana solo por excepción. Los vehículos de alta gama, que se negocian directamente, quedan fuera.

**Flujo de punta a punta**

1. El cliente completa la solicitud con datos, fotos, mantenimiento, condición y neumáticos, y verifica su contacto.
2. El sistema valida la solicitud y, si pasa los controles, la publica automáticamente a las automotoras. El tasador revisa solo los casos marcados.
3. Las automotoras ofertan durante una ventana corta (24 horas por defecto).
4. El sistema elige la mejor oferta y le muestra al cliente un rango estimado, sujeto a revisión presencial.
5. El cliente acepta avanzar; se comparten sus datos de contacto con la automotora ganadora.
6. Cliente y automotora coordinan la visita; la automotora registra el resultado y el cliente lo confirma.
7. Si la compra se concreta, la plataforma registra la operación para el estado de cuenta de la automotora.

**Actores**

| Actor | Qué hace en el sistema |
| --- | --- |
| Cliente (sin cuenta) | Solicita la cotización, sigue su estado por enlace privado, acepta una oferta y confirma el resultado |
| Tasador | Revisa los casos marcados por el sistema y valida ofertas en caso de alerta |
| Coordinador de socios | Gestiona automotoras, cumplimiento y reasignaciones |
| Administrador | Configura reglas, comisiones, elegibilidad y usuarios |
| Usuario de automotora | Ve solicitudes publicadas, ofrece, coordina la visita y registra el resultado |

**Convenciones.** Cada requerimiento se redacta como "El sistema deberá..." y lleva prioridad entre paréntesis (alta, media, baja). Los requerimientos no funcionales (rendimiento, seguridad, accesibilidad) se definen en una etapa posterior. La numeración de este documento es la definitiva y reemplaza a la de las versiones intermedias.

## Módulo 1: Solicitud del cliente

El cliente completa una solicitud sin crear cuenta, principalmente desde el celular, en un formulario pensado para no abandonarlo a mitad de camino.

**RF-01 Elegibilidad del vehículo (alta)** El administrador podrá configurar qué vehículos acepta la plataforma: valor máximo estimado, antigüedad máxima y marcas o segmentos excluidos. Si el vehículo queda fuera, el sistema deberá informarlo al usuario al inicio del formulario, con un mensaje claro, antes de pedirle las fotos.

**RF-02 Datos de contacto (alta)** El sistema deberá solicitar nombre, teléfono y correo del usuario.

**RF-03 Datos del vehículo (alta)** El sistema deberá requerir marca, modelo, versión, año y kilómetros.

- Marca, modelo y versión se seleccionan de un catálogo dependiente: al elegir la marca se filtran los modelos, y al elegir el modelo, las versiones.
- El año y los kilómetros se validan (rango lógico, solo números).

**RF-04 Carga de fotos obligatorias (alta)** El sistema deberá pedir una foto por cada ángulo, con una guía visual de cómo tomarla.

- Exterior: frente, trasera, lateral izquierdo, lateral derecho y las cuatro esquinas (vistas 3/4).
- Interior: tablero con el cuentakilómetros encendido, asientos delanteros, asientos traseros y baúl.
- No se podrá enviar la solicitud hasta completar todas las fotos obligatorias.

**RF-05 Validación de fotos (alta)** El sistema deberá validar cada foto al subirla y avisar de inmediato si no cumple.

- Formato (JPG, PNG, HEIC), resolución mínima y peso máximo.
- Que la imagen no esté borrosa ni demasiado oscura.
- Que se trate de un vehículo y que corresponda razonablemente al ángulo solicitado.
- Que no se repita la misma foto en distintos ángulos.
- El usuario podrá reemplazar una foto antes de enviar.

**RF-06 Historial de mantenimiento (alta)** El sistema deberá preguntar por el mantenimiento realizado hasta la fecha:

- Si fue atendido en servicio oficial (sí / no / mixto).
- Si cuenta con documentación que lo respalde (sí / no), con opción de adjuntar facturas o libreta de servicio.
- Fecha y kilometraje del último service.

**RF-07 Condición general (alta)** El sistema deberá registrar la condición general según el cliente (excelente, buena, regular, mala), junto con:

- Si tiene fallas conocidas, con un campo para describirlas.
- Si presenta consumo o pérdida de aceite, refrigerante o líquido de frenos (selección múltiple y observaciones).

**RF-08 Neumáticos (media)** El sistema deberá preguntar por el estado de los neumáticos (nuevos, buen estado, desgaste medio, desgaste alto) y su edad (año de fabricación o tiempo de uso). Opcionalmente se podrá subir una foto de la banda de rodamiento.

**RF-09 Guardado de borrador (media)** Sin cuenta, el sistema deberá guardar el borrador asociado al correo del usuario y enviarle un enlace único para retomarlo desde cualquier dispositivo. El borrador se conservará un tiempo limitado (por ejemplo, 30 días).

**RF-10 Aviso de cotización referencial (alta)** El sistema deberá dejar claro al usuario que la cotización es un rango estimado del valor que pagaría una automotora, sujeto a revisión presencial, y que el valor final puede variar según el estado real del vehículo. El aviso deberá aparecer:

- En el formulario, antes de comenzar.
- En la pantalla de confirmación y el correo de recepción (RF-13).
- En el correo de cotización y en la página de seguimiento, junto al rango, sin letra chica ni enlaces ocultos.
- Opcionalmente, como casilla de aceptación al enviar la solicitud.

**RF-11 Verificación de contacto y consentimiento (media)** El sistema deberá verificar el correo (o el teléfono) antes de enviar la solicitud, para evitar solicitudes falsas y asegurar que la cotización llegue. También deberá pedir aceptación expresa, con enlace a la política de privacidad, indicando que:

- Los datos del vehículo y las fotos se compartirán con todas las automotoras integradas.
- Los datos de contacto se compartirán solo con la automotora cuya oferta el cliente acepte.

**RF-12 Resumen y envío (alta)** El sistema deberá mostrar un resumen de los datos y las fotos antes de enviar, y permitir corregir cualquier sección.

**RF-13 Confirmación y seguimiento (media)** Al enviar, el sistema deberá generar un número de solicitud, mostrar una confirmación y enviar un correo al usuario con un enlace privado de seguimiento (sin login), donde podrá ver el estado de la solicitud y la cotización cuando esté lista.

## Módulo 2: Revisión y publicación

Con volumen masivo, la publicación es automática cuando la solicitud pasa los controles. El tasador trabaja por excepción y no es un paso obligatorio en cada solicitud.

**RF-14 Revisión por excepción y publicación automática (alta)** El sistema deberá publicar la solicitud a las automotoras sin intervención humana cuando cumpla todas las validaciones: datos completos, fotos válidas (RF-05), contacto verificado y valores dentro de lo esperado según RF-15. Deberá derivar al tasador solo los casos marcados:

- Fotos dudosas o inconsistentes.
- Datos que no coinciden con el mercado (por ejemplo, un kilometraje improbable).
- Vehículos cercanos al límite de elegibilidad (RF-01).
- Ofertas muy alejadas del valor de compra sugerido (RF-15).

**RF-15 Valor de mercado y valor de compra sugerido (media)** Al recibir una solicitud, el sistema deberá consultar en el momento los avisos web de vehículos similares (misma marca y modelo y, en lo posible, versión, año y rango de kilómetros) y calcular un valor de mercado.

- Se usará una medida robusta (mediana o promedio sin valores atípicos) y un mínimo de avisos comparables. Si no se alcanza, el sistema lo indicará y permitirá al tasador ingresar una referencia manual.
- Se guardará la fuente, la fecha y hora, la cantidad de avisos usados y la moneda, con conversión si hay precios en distintas monedas.
- El sistema restará el margen de una automotora para obtener el **valor de compra sugerido**. El margen será configurable por el administrador (porcentaje o monto fijo), con posibilidad de definirlo por marca, segmento o automotora. Podrá descontarse también un costo estimado de reacondicionamiento según la condición declarada.
- Es una referencia interna: sirve para validar solicitudes (RF-14) y para alertar si una oferta se aleja mucho del valor sugerido, por arriba o por abajo. Mercado, margen y valor sugerido nunca se muestran al cliente ni a las automotoras, y se guardan en la solicitud con el margen aplicado en ese momento.

**RF-16 Revisión de fotos (media)** El tasador podrá marcar una foto como no aceptable y solicitar su reemplazo. El sistema notificará al usuario con el enlace para subir la nueva.

**RF-17 Solicitud de información adicional (media)** El tasador podrá pedir al usuario datos o fotos extra desde el sistema. La respuesta quedará asociada a la misma solicitud.

**RF-18 Control de abuso (media)** El sistema deberá limitar la cantidad de solicitudes por correo, teléfono y dispositivo en un período, detectar fotos repetidas entre solicitudes y permitir el bloqueo manual de usuarios abusivos. Su objetivo es proteger a las automotoras de solicitudes basura.

## Módulo 3: Ronda de ofertas

Todas las automotoras integradas pueden ver cada solicitud publicada y ofertar. El cliente ve solo la mejor oferta, y su identidad se mantiene anónima hasta que acepta.

**RF-19 Publicación a automotoras (alta)** Al pasar las validaciones (RF-14), el sistema deberá publicar la solicitud a todas las automotoras activas, con una ventana de tiempo configurable (24 horas por defecto).

- La automotora ve el resumen del vehículo, las fotos, el historial, la condición declarada y el tiempo restante.
- No ve datos de contacto del cliente, valor de mercado ni ofertas de otras automotoras.
- Si al cerrar la ronda no hay ofertas, el sistema informará de inmediato al cliente, sin intervención del tasador, y le ofrecerá volver a intentarlo más adelante.

**RF-20 Filtros y notificaciones configurables (alta)** Todas las automotoras pueden ver todas las solicitudes, pero solo reciben aviso de las que les interesan. Cada una podrá configurar marcas, rango de año, rango de valor y zona, y elegir cómo enterarse: aviso inmediato, resumen diario o solo desde el panel.

**RF-21 Protección de identidad (alta)** El sistema deberá desenfocar automáticamente las patentes en las fotos mostradas a las automotoras, y bloquear el intercambio de datos de contacto en los mensajes hasta la adjudicación (RF-25). Toda comunicación pasa por la plataforma.

**RF-22 Carga de oferta (alta)** La automotora ingresará un valor único, con vigencia, sucursal donde se hará la revisión y observaciones.

- Podrá subir su oferta mientras la ronda esté abierta, pero no bajarla.
- Deberá aceptar que la oferta está sujeta a revisión presencial y a la tolerancia estándar de RF-24.
- Las ofertas quedan cerradas al vencer la ventana, salvo que el administrador la extienda.

**RF-23 Selección de la mejor oferta (alta)** El sistema deberá ordenar las ofertas y marcar automáticamente como ganadora la de mayor valor. En empate o valores muy cercanos, desempatará por el indicador de cumplimiento de la automotora (RF-31), sin mostrárselo al cliente.

- El tasador interviene solo ante alertas (RF-14), por ejemplo una oferta fuera de parámetros. Podrá descartarla o pedir aclaraciones, dejando registro del motivo.

**RF-24 Cotización al cliente (alta)** El sistema mostrará al cliente, en su enlace de seguimiento y por correo, un rango: desde la oferta ganadora menos la tolerancia estándar hasta la oferta ganadora.

- La tolerancia (por ejemplo, 5%) la define el administrador y es igual para todos.
- El rango irá siempre acompañado del aviso de RF-10.
- Si llega una oferta mejor mientras la ronda sigue abierta, la cotización se actualiza y se notifica al cliente. Se conserva el historial de versiones.
- El cliente verá la información de la revisión presencial: automotora, sucursal, dirección, horarios, contacto y documentación a llevar.

**RF-25 Aceptación del cliente y adjudicación (alta)** El cliente podrá manifestar su interés en avanzar con la oferta mostrada. Al hacerlo:

- Se comparten sus datos de contacto con la automotora ganadora.
- Las demás automotoras reciben aviso de que la solicitud fue adjudicada o cerrada, sin detalles de la oferta ganadora.
- Si el cliente no responde, o la automotora ganadora no cumple, el sistema podrá pasar a la siguiente mejor oferta mientras siga vigente.

## Módulo 4: Visita y resultado

Después de la adjudicación, el proceso se acota a una sola automotora y termina con el resultado registrado por ambas partes.

**RF-26 Coordinación de la revisión presencial (alta)** La automotora adjudicada propondrá horarios y el cliente confirmará desde su enlace de seguimiento. El sistema enviará recordatorios a ambos.

**RF-27 Resultado de la revisión (alta)** Tras la visita, la automotora registrará el resultado en un formulario corto: si el auto fue revisado, el valor final ofrecido y el resultado (compra concretada, rechazada por el cliente o rechazada por la automotora).

- Si el valor final baja más que la tolerancia estándar respecto de la oferta, deberá elegir un motivo de una lista corta (daño no declarado, kilometraje distinto, documentación, otro) y subir una foto de respaldo. Dentro de la tolerancia no se pide nada.
- Cuando no hay compra, el motivo es obligatorio.
- Hasta registrar el resultado, la automotora no accede a nuevas rondas. Recibirá recordatorios.

**RF-28 Confirmación del cliente (alta)** Tras la visita, el sistema enviará al cliente una consulta de un clic para confirmar si la venta se concretó y con qué automotora. Si coincide con lo informado por la automotora, la operación se cierra. Si difiere, pasa a revisión manual del coordinador. Sirve para medir calidad y desvíos.

## Módulo 5: Automotoras socias

Las automotoras son socias de la plataforma y deben poder ofertar con el menor esfuerzo posible.

**RF-29 Registro de automotoras (alta)** El administrador podrá crear y editar automotoras: razón social, sucursales con dirección y horarios, contactos, marcas o segmentos de interés, zona de cobertura, modelo de cobro (RF-37) y estado (activa o suspendida).

**RF-30 Usuarios de automotora (alta)** Cada automotora tendrá usuarios propios, con acceso a las solicitudes publicadas, sus propias ofertas y las solicitudes que le fueron adjudicadas. Las automotoras activas ven todas las solicitudes publicadas (RF-19), y su panel respeta los filtros de RF-20.

**RF-31 Cumplimiento de automotoras (media)** El sistema calculará por automotora el desvío promedio entre oferta y valor final, la cantidad de bajas fuera de tolerancia, el tiempo de respuesta y los resultados sin registrar.

- Alertará al coordinador al superar umbrales configurables (por ejemplo, 3 bajas fuera de tolerancia en 10 operaciones).
- El coordinador podrá advertir o suspender a la automotora (RF-29). No hay penalidades automáticas.

## Módulo 6: Administración interna

El panel del equipo interno concentra la supervisión de solicitudes, la gestión de socios y la configuración de reglas.

**RF-32 Acceso y roles (alta)** El sistema deberá permitir el inicio de sesión del personal con los roles tasador, coordinador de socios y administrador. Las automotoras acceden con sus propios usuarios (RF-30), con permisos limitados a sus solicitudes.

**RF-33 Bandeja de solicitudes (alta)** El sistema deberá listar las solicitudes con número, fecha, vehículo, estado y responsable, con filtros por estado, marca, modelo y fecha, y búsqueda por número o datos de contacto. Deberá destacar las solicitudes con alertas pendientes de revisión (RF-14).

**RF-34 Estados de la solicitud (alta)** El sistema deberá manejar este ciclo de vida:

1. Recibida
2. En revisión (solo si hay alerta)
3. Información adicional requerida
4. Publicada a automotoras (ronda abierta)
5. Cotizada (mejor oferta informada al cliente)
6. Cliente interesado (adjudicada)
7. Visita coordinada
8. Revisión presencial realizada
9. Cerrada, compra concretada
10. Cerrada, sin acuerdo (incluye sin ofertas)
11. Vencida

Cada cambio de estado quedará registrado con fecha y usuario, sea del equipo interno, de la automotora o del sistema.

**RF-35 Detalle de la solicitud (alta)** El sistema deberá mostrar al personal todos los datos del vehículo, el historial de mantenimiento, la condición declarada, la galería de fotos por ángulo (visor ampliable y descarga), las ofertas recibidas, la referencia de mercado (RF-15) y el historial de estados.

**RF-36 Comunicación, notas y trazabilidad (media)** Las notas internas (visibles solo para el personal) y los mensajes con las automotoras quedarán asociados a la solicitud. La auditoría cubrirá toda la operación: publicación, ofertas, cambios de oferta, selección, adjudicación, resultado y decisiones del tasador con su motivo.

## Módulo 7: Comisiones y reportes

El cliente no paga nada. Ver solicitudes y ofertar es gratis para la automotora, que paga solo cuando el cliente acepta su oferta. La facturación y el cobro se hacen fuera del sistema en esta versión.

**RF-37 Comisiones y estado de cuenta (media)** El administrador podrá configurar, por automotora, el modelo de cobro y el monto.

- Modelos admitidos: por adjudicación, por compra concretada o plan mensual. El evento que genera el cargo es configurable (adjudicación, visita realizada o compra concretada). Al inicio se usa la adjudicación.
- Al inicio se aplica un fee fijo único por adjudicación, igual para todos los vehículos. El sistema debe admitir porcentaje y tramos por valor si los datos de las primeras operaciones lo justifican.
- Se acreditará automáticamente el cargo cuando la visita no se realice por causa del cliente (ausencia o cancelación). Si no se realiza por causa de la automotora, el cargo se mantiene.
- El sistema generará un estado de cuenta mensual exportable por automotora, con cargos, créditos y total.
- El sistema registrará el valor de cada operación (oferta y valor final) para poder evaluar tramos más adelante.

**RF-38 Reportes (baja)** El sistema deberá mostrar, por período, por automotora y por marca cuando aplique:

- Solicitudes recibidas, por estado y por marca, y solicitudes fuera de alcance (RF-01).
- Porcentaje de solicitudes publicadas automáticamente contra las que requirieron revisión (RF-14).
- Porcentaje de solicitudes sin ofertas, que distingue un problema de oferta (pocas automotoras) de uno de calidad (solicitudes flojas).
- Cantidad de ofertas por solicitud, diferencia entre la mejor y la peor oferta, y tiempo de respuesta por automotora.
- Comparación entre la oferta ganadora, el valor de compra sugerido (RF-15) y el valor final tras la visita, y desvío promedio por automotora.
- Embudo: cotizadas, clientes interesados, visitas realizadas y compras concretadas.
- Operaciones cerradas y comisión generada, y tiempo promedio de respuesta del sistema al cliente.

## Parámetros configurables

Estos valores no deben quedar fijos en el código: el administrador los ajusta según los datos de las primeras operaciones. Los valores iniciales son propuestas para validar.

| Parámetro | Valor inicial propuesto | Requerimiento |
| --- | --- | --- |
| Ventana de la ronda de ofertas | 24 horas | RF-19 |
| Tolerancia estándar entre oferta y valor final | 5% | RF-24, RF-27 |
| Umbral de incumplimiento de una automotora | 3 bajas fuera de tolerancia en 10 operaciones | RF-31 |
| Conservación del borrador | 30 días | RF-09 |
| Margen de la automotora descontado del valor de mercado | Por definir (porcentaje o monto, por marca, segmento o automotora) | RF-15 |
| Fee por adjudicación | Por definir (monto fijo único) | RF-37 |
| Vehículos elegibles (valor máximo, antigüedad, marcas excluidas) | Por definir | RF-01 |
| Mínimo de avisos comparables para el valor de mercado | Por definir | RF-15 |
| Límite de solicitudes por correo, teléfono y dispositivo | Por definir | RF-18 |

## Fuera de alcance y riesgos a cuidar

**Fuera de alcance en esta versión**

- Cuentas de usuario final e historial de solicitudes por cuenta.
- Cotización automática sin revisión humana cuando hay alertas, y cotización basada únicamente en precios de mercado.
- Pasarela de pagos, suscripciones y facturación integrada (el estado de cuenta es exportable y se factura por fuera).
- Penalidades económicas automáticas, depósitos o garantías de oferta.
- Tolerancias distintas por oferta o negociadas caso a caso.
- Comprobantes de compraventa obligatorios por operación.
- Tramos de fee por valor y canal separado para autos de alta gama. Se evaluarán con datos reales.
- Plan mensual para automotoras: el sistema lo admite (RF-37), pero no se construye en el lanzamiento.

**Riesgos a cuidar**

- **Obtención de precios de mercado:** las condiciones de uso de los portales suelen restringir la extracción automática de datos. Conviene usar una API o un proveedor de datos autorizado, o validar el tema con asesoría legal antes de construir RF-15.
- **Expectativa del cliente:** el rango se basa en lo que pagaría una automotora, no en el precio de mercado, y el cliente puede notar la diferencia con los avisos que ve en la web. El aviso de RF-10 debe decirlo con claridad.
- **Ofertas que no se cumplen:** el riesgo es ofrecer alto para ganar la ronda y bajar el valor en la visita. Se controla con ofertas que solo suben, tolerancia fija, motivo y foto cuando se baja más (RF-27) e indicador de cumplimiento con suspensión (RF-31).
- **Elusión:** una automotora podría cerrar la compra sin registrarla. Se mitiga con el bloqueo de nuevas rondas hasta registrar el resultado (RF-27), la confirmación de un clic del cliente (RF-28), el cobro al adjudicar y el contrato con los socios.
- **Datos personales y fuga de contacto:** el cliente es anónimo hasta que acepta, las patentes se desenfocan y los mensajes no admiten datos de contacto (RF-21). Falta validar el consentimiento y el tratamiento de datos con asesoría legal según la normativa local.
- **Saturación de automotoras:** con volumen masivo, demasiados avisos o solicitudes basura las hace abandonar. Lo controlan RF-18, RF-20 y la publicación automática de RF-14.

## Decisiones pendientes y equivalencia de numeración

**Decisiones abiertas**

- **Volumen esperado:** solicitudes por mes y cantidad de automotoras en el primer año. Define cuánto automatizar desde el lanzamiento (RF-14, RF-23) y cuánto dejar manual al principio.
- **Fuente del valor de mercado (RF-15):** proveedor o API autorizada, o extracción propia con validación legal.
- **Valores iniciales de los parámetros** marcados "Por definir": margen de la automotora, fee por adjudicación, vehículos elegibles, mínimo de avisos comparables y límites anti-abuso.
- **Qué ve el cliente:** se asumió que ve solo la mejor oferta (RF-24). Mostrar todas las ofertas para elegir por ubicación o cercanía agregaría un paso y cambiaría RF-23 y RF-25.
- **Canal de verificación (RF-11):** correo, teléfono o ambos.
- **Contrato con automotoras:** cláusulas de fee, reporte de resultados y suspensión, que respaldan RF-27, RF-31 y RF-37.

**Equivalencia con la numeración de las versiones intermedias**

| Anterior | Nueva | Tema |
| --- | --- | --- |
| RF-01 | RF-02 | Datos de contacto |
| RF-02 | RF-03 | Datos del vehículo |
| RF-03 | RF-04 | Fotos obligatorias |
| RF-04 | RF-05 | Validación de fotos |
| RF-05 | RF-06 | Mantenimiento |
| RF-06 | RF-07 | Condición general |
| RF-07 | RF-08 | Neumáticos |
| RF-08 | RF-09 | Borrador |
| RF-09 | RF-12 | Resumen y envío |
| RF-10 | RF-13 | Confirmación y seguimiento |
| RF-11 | RF-11 | Verificación y consentimiento |
| RF-12 | RF-32 | Acceso y roles |
| RF-13 | RF-33 | Bandeja de solicitudes |
| RF-14 | RF-34 | Estados |
| RF-15 | RF-35 | Detalle de la solicitud |
| RF-16 | RF-16 | Revisión de fotos |
| RF-17 | RF-17 | Información adicional |
| RF-18 | RF-24 | Cotización al cliente |
| RF-19, RF-32 | RF-36 | Notas y trazabilidad |
| RF-20 | RF-38 | Reportes |
| RF-21 | RF-10 | Aviso de cotización referencial |
| RF-22 | RF-15 | Valor de mercado y valor sugerido |
| RF-23 | RF-24 | Información de la revisión presencial (integrada) |
| RF-24 | RF-29 | Registro de automotoras |
| RF-25 | RF-30 | Usuarios de automotora |
| RF-26 | RF-19 | Publicación a automotoras |
| RF-27 | RF-22 | Carga de oferta |
| RF-28 | RF-23 | Selección de la mejor oferta |
| RF-29 | RF-25 | Aceptación y adjudicación |
| RF-30 | RF-26 | Coordinación de la visita |
| RF-31 | RF-27 | Resultado de la revisión |
| RF-33 | RF-31 | Cumplimiento de automotoras |
| RF-34 | RF-28 | Confirmación del cliente |
| RF-35 | RF-21 | Protección de identidad |
| RF-36 | RF-37 | Comisiones y estado de cuenta |
| RF-37 | RF-01 | Elegibilidad del vehículo |
| RF-38 | RF-14 | Revisión por excepción |
| RF-39 | RF-20 | Filtros y notificaciones |
| RF-40 | RF-18 | Control de abuso |
