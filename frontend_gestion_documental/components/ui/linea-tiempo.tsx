import { GitCommitVertical } from "lucide-react";
import type { EventoTrazabilidad } from "@/lib/tipos";
import { cn } from "@/lib/utils";

export function LineaTiempo({ eventos }: { eventos: EventoTrazabilidad[] }) {
  return (
    <section aria-labelledby="titulo-trazabilidad" className="bg-fondo-sutil px-7 py-6">
      <h2
        id="titulo-trazabilidad"
        className="mb-5 flex items-center gap-2 font-display text-[11px] font-bold uppercase tracking-[0.11em] text-tinta-suave"
      >
        <GitCommitVertical className="size-3.5" aria-hidden />
        Línea de tiempo de trazabilidad
      </h2>
      <ol>
        {eventos.map((e, i) => (
          <li key={`${e.estado}-${i}`} className="grid grid-cols-[12px_1fr] gap-3.5">
            <div className="flex flex-col items-center">
              <span
                aria-hidden
                className={cn("size-[11px] shrink-0 border-2", e.hecho ? "border-acento bg-acento" : "border-tinta/30")}
              />
              {i < eventos.length - 1 && <span aria-hidden className="my-1 w-px flex-1 bg-tinta/20" />}
            </div>
            <div className="pb-5">
              <p className="font-display text-[13px] font-semibold text-tinta">
                {e.estado}
                {!e.hecho && <span className="sr-only"> (pendiente)</span>}
              </p>
              <p className="mt-0.5 text-xs text-tinta-suave">{e.autor}</p>
              <p className="mt-0.5 text-[11px] text-tinta-suave">{e.cuando}</p>
            </div>
          </li>
        ))}
      </ol>
    </section>
  );
}
