// Todos los textos visibles para el usuario. Nunca escribir textos en los componentes.
export const es = {
  app: {
    name: 'Cotizador',
    skipToContent: 'Saltar al contenido',
  },
  // RF-10: aviso de cotización referencial. Se muestra en formulario, confirmación,
  // correos y seguimiento, sin letra chica.
  referentialNotice: {
    title: 'La cotización es referencial',
    body: 'Te vamos a mostrar un rango estimado de lo que pagaría la automotora por tu vehículo. No es el precio de venta de mercado ni una oferta de compra cerrada: el valor final se define en una revisión presencial en la automotora y puede variar según el estado real del vehículo.',
  },
  home: {
    title: 'Vendé tu auto usado',
    lead: 'Completá los datos y las fotos de tu vehículo y recibí una cotización estimada de una automotora.',
    comingSoon: 'El formulario va a estar disponible pronto.',
  },
  notFound: {
    title: 'Página no encontrada',
    backHome: 'Volver al inicio',
  },
  // RF-34
  requestStatus: {
    draft: 'Borrador',
    received: 'Recibida',
    info_requested: 'Información adicional requerida',
    quoted: 'Cotizada',
    client_interested: 'Cliente interesado',
    visit_scheduled: 'Visita coordinada',
    inspection_done: 'Revisión realizada',
    closed_purchased: 'Cerrada (compra)',
    closed_no_deal: 'Cerrada (sin acuerdo)',
    expired: 'Vencida',
  },
  // RF-13
  tracking: {
    title: 'Seguimiento de tu solicitud',
    loading: 'Cargando tu solicitud…',
    requestNumber: 'Solicitud N.º',
    status: 'Estado',
    notFoundTitle: 'No encontramos tu solicitud',
    notFoundBody: 'Revisá que el enlace esté completo, tal como lo recibiste por correo.',
    errorTitle: 'No pudimos cargar tu solicitud',
    errorBody: 'Probá de nuevo en unos minutos.',
  },
  // RF-32
  panel: {
    loginTitle: 'Ingreso de la automotora',
    email: 'Correo',
    password: 'Contraseña',
    signIn: 'Ingresar',
    signingIn: 'Ingresando…',
    signOut: 'Salir',
    invalidCredentials: 'El correo o la contraseña no son correctos.',
    notStaff: 'Tu usuario no tiene acceso al panel.',
    loading: 'Cargando…',
    requestsTitle: 'Solicitudes',
    noRequests: 'Todavía no hay solicitudes.',
    loadError: 'No pudimos cargar las solicitudes.',
    columnNumber: 'N.º',
    columnStatus: 'Estado',
    columnSubmitted: 'Enviada',
  },
} as const;
