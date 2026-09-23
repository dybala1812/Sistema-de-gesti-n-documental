"use client";

import { ChevronRight, Users } from "lucide-react";
import Link from "next/link";
import { EncabezadoPantalla } from "@/components/panel/marco-panel";
import { useRolDemo } from "@/components/panel/sesion-demo";
import { Aparecer } from "@/components/ui/aparecer";
import { alertasDelRol } from "@/lib/datos-demo";
import type { Alerta } from "@/lib/tipos";
import { cn } from "@/lib/utils";

const GRUPOS: { id: Alerta["grupo"]; etiqueta: string; punto: string; borde: string; texto: string }[] = [
  { id: "vencido", etiqueta: "Vencido", punto: "bg-peligro", borde: "border-l-peligro", texto: "text-peligro" },
  { id: "hoy", etiqueta: "Vence hoy", punto: "bg-acento", borde: "border-l-acento", texto: "text-acento-texto" },
  { id: "semana", etiqueta: "Vence esta semana", punto: "bg-info", borde: "border-l-info", texto: "text-info" },
];

export default function Alertas() {
  const rol = useRolDemo();
  const alertas = alertasDelRol(rol);

  return (
    <>
      <EncabezadoPantalla
        titulo="Alertas de vencimiento"
        objetivo="Qué radicados están por vencer o ya vencieron, agrupados por urgencia."
      />
      <Aparecer className="flex max-w-[940px] flex-col gap-6">
        {GRUPOS.map((g) => {
          const items = alertas.filter((a) => a.grupo === g.id);
          if (!items.length) return null;
          return (
            <section key={g.id} data-aparecer aria-labelledby={`grupo-${g.id}`}>
              <h2 id={`grupo-${g.id}`} className="mb-2.5 flex items-center gap-2.5">
                <span aria-hidden className={cn("size-2.5", g.punto)} />
                <span className="font-display text-[13px] font-semibold">{g.etiqueta}</span>
                <span className="text-xs text-tinta-suave">
                  {items.length} radicado{items.length > 1 ? "s" : ""}
                </span>
              </h2>
              <ul className="flex flex-col gap-2">
                {items.map((a) => (
                  <li key={a.numero}>
                    <Link
                      href={`/panel/radicados/${a.radicadoId}`}
                      className={cn(
                        "group flex flex-wrap items-center gap-x-4 gap-y-2 border border-l-[3px] border-borde bg-fondo px-4 py-3.5 transition-shadow hover:shadow-flotante",
                        g.borde,
                      )}
                    >
                      <span className="w-[140px] shrink-0 font-display text-sm font-bold text-tinta tabular-nums">{a.numero}</span>
                      <span className="min-w-0 flex-1 text-[13px] text-tinta">
                        {a.tipoTramite}
                        <span className="text-tinta-suave"> · {a.dependencia}</span>
                      </span>
                      {a.esperaComite && (
                        <span className="inline-flex items-center gap-1.5 bg-violet-100 px-2.5 py-1 text-[11px] font-bold whitespace-nowrap text-violet-800">
                          <Users className="size-3" aria-hidden />
                          Espera de comité
                        </span>
                      )}
                      <span className={cn("shrink-0 font-display text-xs font-bold", g.texto)}>{a.plazo}</span>
                      <ChevronRight className="size-4 text-tinta-suave transition-transform group-hover:translate-x-0.5" aria-hidden />
                    </Link>
                  </li>
                ))}
              </ul>
            </section>
          );
        })}
      </Aparecer>
    </>
  );
}
