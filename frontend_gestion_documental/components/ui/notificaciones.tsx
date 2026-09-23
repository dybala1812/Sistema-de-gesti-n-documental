"use client";

import { sileo, Toaster } from "sileo";

/*
  Avisos arriba al centro y en el dorado de la marca. Sobre el dorado, título,
  descripción e icono van en tinta oscura (`sobre-acento`) para mantener el contraste;
  el tipo de aviso se distingue por el icono, no por el color.
*/
const ESTILOS_AVISO = {
  title: "text-sobre-acento! font-semibold!",
  description: "text-sobre-acento/80!",
  badge: "text-sobre-acento! bg-sobre-acento/10!",
  button: "text-sobre-acento! bg-sobre-acento/10!",
};

export function ProveedorNotificaciones() {
  return (
    <Toaster
      position="top-center"
      theme="light"
      offset={{ top: 16 }}
      options={{ fill: "#f4b400", styles: ESTILOS_AVISO }}
    />
  );
}

/** Punto único para las alertas emergentes, así se cambia la librería en un solo sitio. */
export const notificar = {
  exito: (titulo: string, descripcion?: string) => sileo.success({ title: titulo, description: descripcion }),
  error: (titulo: string, descripcion?: string) => sileo.error({ title: titulo, description: descripcion }),
  aviso: (titulo: string, descripcion?: string) => sileo.warning({ title: titulo, description: descripcion }),
  info: (titulo: string, descripcion?: string) => sileo.info({ title: titulo, description: descripcion }),
  promesa: sileo.promise,
};
