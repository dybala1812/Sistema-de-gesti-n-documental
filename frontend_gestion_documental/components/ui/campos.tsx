import type { ComponentProps, ReactNode } from "react";
import { cn } from "@/lib/utils";

const baseControl =
  "w-full border border-borde-campo bg-fondo px-3.5 py-3 text-sm text-tinta placeholder:text-tinta-suave read-only:border-borde read-only:bg-fondo-sutil read-only:text-tinta-suave focus-visible:border-info";

export function Campo({
  etiqueta,
  htmlFor,
  ayuda,
  error,
  className,
  children,
}: {
  etiqueta: string;
  htmlFor: string;
  ayuda?: string;
  error?: string;
  className?: string;
  children: ReactNode;
}) {
  return (
    <div className={className}>
      <label htmlFor={htmlFor} className="mb-2 block font-display text-xs font-semibold text-tinta">
        {etiqueta}
      </label>
      {children}
      {error ? (
        <p id={`${htmlFor}-error`} role="alert" className="mt-1.5 text-[11px] font-medium text-peligro">
          {error}
        </p>
      ) : ayuda ? (
        <p id={`${htmlFor}-ayuda`} className="mt-1.5 text-[11px] text-tinta-suave">
          {ayuda}
        </p>
      ) : null}
    </div>
  );
}

export function Entrada({ className, ...props }: ComponentProps<"input">) {
  return <input className={cn(baseControl, className)} {...props} />;
}

export function Seleccion({
  opciones,
  className,
  ...props
}: ComponentProps<"select"> & { opciones: readonly string[] }) {
  return (
    <select className={cn(baseControl, "cursor-pointer", className)} {...props}>
      {opciones.map((o) => (
        <option key={o}>{o}</option>
      ))}
    </select>
  );
}

export function AreaTexto({ className, rows = 4, ...props }: ComponentProps<"textarea">) {
  return <textarea rows={rows} className={cn(baseControl, "resize-y", className)} {...props} />;
}
