"use client";

import { useSyncExternalStore } from "react";
import type { Rol } from "@/lib/tipos";

/*
  Sesión SOLO de demostración para recorrer la maquetación. Las cuentas y la contraseña
  viven en el navegador, así que NO es autenticación ni autorización: se reemplaza por
  POST /api/v1/auth/login y una cookie HttpOnly emitida por la API (RF-013).
*/
const CLAVE = "sgd-sesion-demo";
const EVENTO = "sgd-sesion-demo";

export const CLAVE_DEMO = "Demo2026*";

export const CUENTAS_DEMO: { correo: string; rol: Rol }[] = [
  { correo: "recepcion@uniautonoma.edu.co", rol: "recepcion" },
  { correo: "dependencia@uniautonoma.edu.co", rol: "dependencia" },
  { correo: "archivo@uniautonoma.edu.co", rol: "archivo_central" },
  { correo: "admin@uniautonoma.edu.co", rol: "administrador" },
];

/** "cargando" solo existe en el render del servidor y en la hidratación. */
export type EstadoSesion = Rol | "sin-sesion" | "cargando";

function leer(): EstadoSesion {
  try {
    const valor = window.sessionStorage.getItem(CLAVE);
    return CUENTAS_DEMO.some((c) => c.rol === valor) ? (valor as Rol) : "sin-sesion";
  } catch {
    return "sin-sesion";
  }
}

function suscribir(avisar: () => void) {
  window.addEventListener(EVENTO, avisar);
  return () => window.removeEventListener(EVENTO, avisar);
}

function escribir(valor: Rol | null) {
  try {
    if (valor) window.sessionStorage.setItem(CLAVE, valor);
    else window.sessionStorage.removeItem(CLAVE);
  } catch {
    // Sin almacenamiento (modo privado): la demo no podrá recordar la sesión.
  }
  window.dispatchEvent(new Event(EVENTO));
}

export function useSesionDemo(): EstadoSesion {
  return useSyncExternalStore(suscribir, leer, () => "cargando");
}

/** Para componentes que solo se muestran dentro del panel, donde ya hay sesión. */
export function useRolDemo(): Rol {
  const estado = useSesionDemo();
  return estado === "cargando" || estado === "sin-sesion" ? "recepcion" : estado;
}

/** Devuelve el rol si las credenciales coinciden con una cuenta de demostración. */
export function iniciarSesionDemo(correo: string, clave: string): Rol | null {
  const cuenta = CUENTAS_DEMO.find((c) => c.correo === correo.trim().toLowerCase());
  if (!cuenta || clave !== CLAVE_DEMO) return null;
  escribir(cuenta.rol);
  return cuenta.rol;
}

export function cerrarSesionDemo() {
  escribir(null);
}
