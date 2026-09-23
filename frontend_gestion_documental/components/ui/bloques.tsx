import type { LucideIcon } from "lucide-react";
import type { ReactNode } from "react";
import { cn } from "@/lib/utils";

export function Tarjeta({ className, children }: { className?: string; children: ReactNode }) {
  return <section className={cn("border border-borde bg-fondo", className)}>{children}</section>;
}

export function Antetitulo({ children, className }: { children: ReactNode; className?: string }) {
  return (
    <p className={cn("font-display text-[11px] font-bold uppercase tracking-[0.16em] text-acento-oscuro", className)}>
      {children}
    </p>
  );
}

type TonoAviso = "info" | "acento" | "peligro";

const TONOS: Record<TonoAviso, string> = {
  info: "border-info bg-fondo-sutil",
  acento: "border-acento bg-acento-claro",
  peligro: "border-peligro bg-peligro-claro",
};

export function Aviso({
  tono = "info",
  icono: Icono,
  children,
  className,
}: {
  tono?: TonoAviso;
  icono?: LucideIcon;
  children: ReactNode;
  className?: string;
}) {
  return (
    <div
      role={tono === "peligro" ? "alert" : "note"}
      className={cn("flex gap-3 border-l-2 px-4 py-3.5 text-[13px] leading-relaxed text-tinta", TONOS[tono], className)}
    >
      {Icono && <Icono className="mt-0.5 size-4 shrink-0" aria-hidden />}
      <div>{children}</div>
    </div>
  );
}

export function EstadoVacio({
  icono: Icono,
  titulo,
  descripcion,
  punteado = false,
}: {
  icono: LucideIcon;
  titulo: string;
  descripcion: string;
  punteado?: boolean;
}) {
  return (
    <div
      className={cn(
        "px-6 py-11 text-center",
        punteado ? "border border-dashed border-borde-campo bg-fondo-alt" : "border border-borde bg-fondo",
      )}
    >
      <Icono className="mx-auto size-6 text-slate-400" aria-hidden />
      <p className="mt-3 font-display text-[15px] font-semibold text-tinta">{titulo}</p>
      <p className="mt-1.5 text-[13px] text-tinta-suave">{descripcion}</p>
    </div>
  );
}

export function Dato({ etiqueta, children }: { etiqueta: string; children: ReactNode }) {
  return (
    <div>
      <dt className="mb-1 font-display text-[11px] font-semibold uppercase tracking-[0.09em] text-tinta-suave">
        {etiqueta}
      </dt>
      <dd className="text-[13px] text-tinta">{children}</dd>
    </div>
  );
}
