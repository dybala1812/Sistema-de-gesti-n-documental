"use client";

import { Send, ShieldCheck } from "lucide-react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useState, type FormEvent } from "react";
import { Progreso } from "@/components/publico/progreso";
import { Aparecer } from "@/components/ui/aparecer";
import { Aviso } from "@/components/ui/bloques";
import { Boton, BotonEnlace } from "@/components/ui/boton";
import { AreaTexto, Campo, Entrada, Seleccion } from "@/components/ui/campos";
import { notificar } from "@/components/ui/notificaciones";
import { ZonaArchivos } from "@/components/ui/zona-archivos";
import { PROGRAMAS, TRAMITES_PORTAL } from "@/lib/datos-demo";
import { soloDigitos } from "@/lib/utils";

type Errores = Partial<Record<"nombre" | "cedula" | "correo" | "descripcion" | "datos", string>>;

function validar(f: FormData): Errores {
  const e: Errores = {};
  if (!String(f.get("nombre") ?? "").trim()) e.nombre = "Escribe tu nombre completo.";
  const cedula = soloDigitos(String(f.get("cedula") ?? ""));
  if (cedula.length < 6 || cedula.length > 10) e.cedula = "La cédula debe tener entre 6 y 10 dígitos.";
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(String(f.get("correo") ?? ""))) e.correo = "Escribe un correo válido: ahí llegará la respuesta.";
  if (String(f.get("descripcion") ?? "").trim().length < 20) e.descripcion = "Explica tu solicitud con al menos 20 caracteres.";
  if (!f.get("datos")) e.datos = "Debes aceptar el tratamiento de datos para radicar.";
  return e;
}

export default function NuevaSolicitud() {
  const router = useRouter();
  const [errores, setErrores] = useState<Errores>({});
  const [enviando, setEnviando] = useState(false);

  async function enviar(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const datos = new FormData(e.currentTarget);
    const encontrados = validar(datos);
    setErrores(encontrados);
    if (Object.keys(encontrados).length) {
      notificar.error("Revisa el formulario", "Hay campos por corregir.");
      return;
    }

    setEnviando(true);
    // Simulación de POST /api/v1/radicados: el consecutivo lo asigna el backend.
    const radicar = new Promise<string>((ok) => setTimeout(() => ok("2026-CR-01488"), 1100));
    const numero = await notificar.promesa(radicar, {
      loading: { title: "Radicando tu solicitud…" },
      success: (n) => ({ title: "Solicitud radicada", description: `Número ${n}` }),
      error: { title: "No se pudo radicar", description: "Intenta de nuevo en unos minutos." },
    });
    const tipo = String(datos.get("tipo") ?? "");
    router.push(`/radicar/confirmacion?n=${encodeURIComponent(numero)}&t=${encodeURIComponent(tipo)}`);
  }

  return (
    <div className="mx-auto max-w-[720px] px-4 pt-10 pb-18 sm:px-6">
      <Progreso paso={2} />
      <h1 className="mb-6 font-display text-3xl font-extrabold tracking-tight text-marca">Nueva solicitud</h1>

      <Aparecer>
        <form onSubmit={enviar} noValidate className="border border-borde bg-fondo px-5 py-7 sm:px-8">
          <fieldset className="mb-6">
            <legend className="mb-4 font-display text-[11px] font-bold tracking-[0.12em] text-tinta-suave uppercase">
              Tu trámite
            </legend>
            <Campo etiqueta="Tipo de trámite" htmlFor="tipo">
              <Seleccion id="tipo" name="tipo" opciones={TRAMITES_PORTAL} />
            </Campo>
          </fieldset>

          <fieldset data-aparecer className="mb-6 grid gap-5 sm:grid-cols-2">
            <legend className="mb-4 font-display text-[11px] font-bold tracking-[0.12em] text-tinta-suave uppercase">
              Tus datos
            </legend>
            <Campo etiqueta="Nombre completo" htmlFor="nombre" error={errores.nombre}>
              <Entrada id="nombre" name="nombre" autoComplete="name" aria-invalid={!!errores.nombre} />
            </Campo>
            <Campo etiqueta="Cédula" htmlFor="cedula" error={errores.cedula}>
              <Entrada id="cedula" name="cedula" inputMode="numeric" autoComplete="off" aria-invalid={!!errores.cedula} />
            </Campo>
            <Campo etiqueta="Programa o carrera" htmlFor="programa" className="sm:col-span-2">
              <Seleccion id="programa" name="programa" opciones={[...PROGRAMAS, "No aplica / externo"]} />
            </Campo>
            <Campo
              etiqueta="Correo de contacto para la respuesta"
              htmlFor="correo"
              error={errores.correo}
              ayuda="La respuesta llega solo por correo."
              className="sm:col-span-2"
            >
              <Entrada id="correo" name="correo" type="email" autoComplete="email" aria-invalid={!!errores.correo} />
            </Campo>
          </fieldset>

          <fieldset data-aparecer className="mb-6 flex flex-col gap-5">
            <legend className="mb-4 font-display text-[11px] font-bold tracking-[0.12em] text-tinta-suave uppercase">
              Tu solicitud
            </legend>
            <Campo etiqueta="Descripción de la solicitud" htmlFor="descripcion" error={errores.descripcion}>
              <AreaTexto
                id="descripcion"
                name="descripcion"
                placeholder="Explica brevemente qué solicitas"
                aria-invalid={!!errores.descripcion}
              />
            </Campo>
            <ZonaArchivos etiqueta="Documentos adjuntos" />
          </fieldset>

          <div data-aparecer className="mb-7 border border-borde bg-fondo-alt p-4">
            <label className="flex cursor-pointer gap-3 text-[13px] leading-relaxed text-tinta">
              <input type="checkbox" name="datos" className="mt-1 size-4 shrink-0 accent-marca" aria-invalid={!!errores.datos} />
              <span>
                Autorizo a la universidad a tratar mis datos personales (nombre, cédula y correo) para gestionar esta
                solicitud, conforme a la Ley 1581 de 2012 y al aviso de privacidad.
              </span>
            </label>
            {errores.datos && (
              <p role="alert" className="mt-2 text-[11px] font-medium text-peligro">
                {errores.datos}
              </p>
            )}
          </div>

          <Aviso icono={ShieldCheck} className="mb-7">
            Aquí irá la verificación anti-abuso (CAPTCHA). El proveedor está pendiente de decisión (D-11).
          </Aviso>

          <div className="flex flex-wrap gap-2.5">
            <Boton type="submit" tamano="lg" className="flex-1" disabled={enviando}>
              <Send aria-hidden />
              {enviando ? "Enviando…" : "Enviar solicitud"}
            </Boton>
            <BotonEnlace href="/" variante="secundario" tamano="lg">
              Cancelar
            </BotonEnlace>
          </div>
        </form>
      </Aparecer>

      <p className="mt-5 text-xs text-tinta-suave">
        ¿Ya radicaste?{" "}
        <Link href="/mis-tramites" className="font-semibold text-marca hover:underline">
          Consulta el estado de tu trámite
        </Link>
        .
      </p>
    </div>
  );
}
