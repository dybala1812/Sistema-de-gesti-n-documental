"use client";

import { CalendarClock, FileX, Mail, Search } from "lucide-react";
import { useState, type FormEvent } from "react";
import { Aparecer } from "@/components/ui/aparecer";
import { Aviso, EstadoVacio } from "@/components/ui/bloques";
import { Boton, BotonEnlace } from "@/components/ui/boton";
import { Campo, Entrada } from "@/components/ui/campos";
import { IndicadorSemaforo } from "@/components/ui/insignia";
import { RADICADOS } from "@/lib/datos-demo";
import type { EstadoVisible, Radicado } from "@/lib/tipos";
import { soloDigitos } from "@/lib/utils";

/** Texto para el ciudadano: no expone estados ni responsables internos (HU-018). */
const TEXTO_CIUDADANO: Partial<Record<EstadoVisible, string>> = {
  Radicado: "Recibimos tu solicitud y la estamos asignando a la dependencia responsable.",
  Pendiente: "Tu solicitud fue asignada y está en cola para revisión.",
  "En trámite": "Tu solicitud está siendo revisada por la dependencia.",
  "En revisión": "Estamos revisando que tu solicitud cumpla los requisitos.",
  "En comité": "Tu solicitud espera la decisión del comité.",
  "Por verificar": "Tu solicitud está siendo revisada por la dependencia.",
  Respondido: "La respuesta fue enviada al correo que registraste.",
  Vencido: "Tu solicitud superó el plazo. La dependencia fue notificada para responder.",
  Anulado: "Esta solicitud fue anulada. Si crees que es un error, comunícate con Recepción.",
};

type Resultado = { tipo: "vacio" } | { tipo: "no-encontrado" } | { tipo: "ok"; radicado: Radicado };

export default function MisTramites() {
  const [numero, setNumero] = useState("");
  const [cedula, setCedula] = useState("");
  const [error, setError] = useState("");
  const [resultado, setResultado] = useState<Resultado>({ tipo: "vacio" });

  function consultar(e: FormEvent) {
    e.preventDefault();
    if (!numero.trim() || !cedula.trim()) {
      setError("Escribe el número de radicado y tu cédula.");
      return;
    }
    setError("");
    // Simulación de la consulta pública: ambos datos deben coincidir.
    const r = RADICADOS.find(
      (x) => x.numero.toUpperCase() === numero.trim().toUpperCase() && x.cedula === soloDigitos(cedula),
    );
    setResultado(r ? { tipo: "ok", radicado: r } : { tipo: "no-encontrado" });
  }

  return (
    <div className="mx-auto max-w-[900px] px-4 pt-10 pb-18 sm:px-6">
      <h1 className="mb-2.5 font-display text-3xl font-extrabold tracking-tight text-marca">Mis trámites</h1>
      <p className="mb-6 max-w-[620px] text-sm leading-relaxed text-pretty text-tinta-suave">
        Consulta el estado de una solicitud con su número de radicado y tu cédula. La respuesta sigue llegando a tu correo;
        esta pantalla es solo de lectura.
      </p>

      <form onSubmit={consultar} noValidate className="mb-6 border border-borde bg-fondo px-5 py-5 sm:px-6">
        <div className="grid gap-4 sm:grid-cols-[1fr_1fr_auto] sm:items-end">
          <Campo etiqueta="Número de radicado" htmlFor="numero">
            <Entrada id="numero" placeholder="p. ej. 2026-CR-01487" value={numero} onChange={(e) => setNumero(e.target.value)} />
          </Campo>
          <Campo etiqueta="Número de cédula" htmlFor="cedula-consulta">
            <Entrada
              id="cedula-consulta"
              inputMode="numeric"
              placeholder="p. ej. 1.061.784.220"
              value={cedula}
              onChange={(e) => setCedula(e.target.value)}
            />
          </Campo>
          <Boton type="submit" tamano="lg">
            <Search aria-hidden />
            Consultar
          </Boton>
        </div>
        {error && (
          <p role="alert" className="mt-3 text-xs font-medium text-peligro">
            {error}
          </p>
        )}
        <p className="mt-3 text-[11.5px] text-tinta-suave">Prueba en la demo: 2026-CR-01487 con 1061784220.</p>
      </form>

      <div aria-live="polite">
        {resultado.tipo === "vacio" && (
          <EstadoVacio
            punteado
            icono={Search}
            titulo="Escribe tus datos para consultar"
            descripcion="Verás el estado, el semáforo de plazo y la fecha límite de tu solicitud."
          />
        )}

        {resultado.tipo === "no-encontrado" && (
          <EstadoVacio
            icono={FileX}
            titulo="No encontramos una solicitud con esos datos"
            descripcion="Revisa el número de radicado y la cédula, o radica una nueva solicitud."
          />
        )}

        {resultado.tipo === "ok" && (
          <Aparecer key={resultado.radicado.id} className="border border-borde bg-fondo">
            <div data-aparecer className="flex flex-wrap items-center gap-3 border-b border-borde px-6 py-5">
              <span className="font-display text-xl font-extrabold text-marca tabular-nums">{resultado.radicado.numero}</span>
              <span className="text-[13px] text-tinta-suave">{resultado.radicado.tipoTramite}</span>
              <span className="ml-auto">
                <IndicadorSemaforo semaforo={resultado.radicado.semaforo} />
              </span>
            </div>
            <div data-aparecer className="px-6 py-5">
              <p className="mb-4 text-[15px] leading-relaxed text-tinta">
                {TEXTO_CIUDADANO[resultado.radicado.estado] ?? "Tu solicitud está en proceso."}
              </p>
              <p className="flex items-center gap-2 text-[13px] text-tinta-suave">
                <CalendarClock className="size-4" aria-hidden />
                Radicado el {resultado.radicado.fecha}
                {resultado.radicado.diasRestantes !== null && resultado.radicado.diasRestantes >= 0 &&
                  ` · quedan ${resultado.radicado.diasRestantes} días hábiles`}
              </p>
            </div>
          </Aparecer>
        )}
      </div>

      <Aviso icono={Mail} className="mt-7 items-center">
        <div className="flex flex-wrap items-center gap-3">
          <span className="flex-1">Cuando la dependencia responda, recibirás el documento en tu correo.</span>
          <BotonEnlace href="/radicar" tamano="sm">
            Radicar otra solicitud
          </BotonEnlace>
        </div>
      </Aviso>
    </div>
  );
}
