import { cn } from "@/lib/utils";
import type { EstadoVisible, Semaforo } from "@/lib/tipos";

const COLORES_ESTADO: Record<EstadoVisible, string> = {
  Radicado: "bg-info-claro text-info",
  "En trámite": "bg-acento/20 text-acento-texto",
  "En revisión": "bg-acento/20 text-acento-texto",
  "En comité": "bg-violet-100 text-violet-800",
  "Por verificar": "bg-info-claro text-info",
  Respondido: "bg-exito-claro text-exito",
  Vencido: "bg-peligro-claro text-peligro",
  Anulado: "bg-fondo-sutil text-tinta-suave line-through",
  Pendiente: "bg-info-claro text-info",
  Activo: "bg-exito-claro text-exito",
  Deshabilitado: "bg-fondo-sutil text-tinta-suave",
  "Por clasificar": "bg-acento/20 text-acento-texto",
  Clasificado: "bg-exito-claro text-exito",
};

export function InsigniaEstado({ estado, className }: { estado: EstadoVisible; className?: string }) {
  return (
    <span
      className={cn(
        "inline-block whitespace-nowrap px-2.5 py-1 text-[11px] font-bold",
        COLORES_ESTADO[estado],
        className,
      )}
    >
      {estado}
    </span>
  );
}

const SEMAFORO: Record<Semaforo, { clase: string; texto: string }> = {
  verde: { clase: "bg-exito", texto: "Al día" },
  amarillo: { clase: "bg-acento", texto: "En curso" },
  naranja: { clase: "bg-orange-500", texto: "Próximo a vencer" },
  rojo: { clase: "bg-peligro", texto: "Vencido" },
};

/** El color nunca va solo: siempre lo acompaña el texto. */
export function IndicadorSemaforo({ semaforo, detalle }: { semaforo: Semaforo; detalle?: string }) {
  const { clase, texto } = SEMAFORO[semaforo];
  return (
    <span className="inline-flex items-center gap-2 whitespace-nowrap text-xs text-tinta">
      <span aria-hidden className={cn("size-2.5", clase)} />
      {detalle ?? texto}
    </span>
  );
}
