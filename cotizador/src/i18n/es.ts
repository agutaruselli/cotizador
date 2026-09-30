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
} as const;
