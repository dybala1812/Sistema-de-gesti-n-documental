import { cva, type VariantProps } from "class-variance-authority";
import Link from "next/link";
import type { ComponentProps } from "react";
import { cn } from "@/lib/utils";

export const variantesBoton = cva(
  "inline-flex items-center gap-2 text-left font-medium transition-colors duration-150 disabled:pointer-events-none disabled:opacity-45 cursor-pointer [&_svg]:size-4 [&_svg]:shrink-0",
  {
    variants: {
      variante: {
        primario:
          "bg-acento font-display font-bold text-sobre-acento hover:bg-acento-hover active:bg-acento-oscuro",
        secundario:
          "border border-borde-campo bg-fondo text-tinta hover:bg-fondo-sutil active:bg-borde",
        contorno:
          "border border-info bg-fondo font-semibold text-info hover:bg-info-claro",
        fantasma:
          "border border-tinta/20 bg-transparent text-tinta-suave hover:bg-fondo-sutil hover:text-tinta",
        peligro:
          "border border-peligro bg-fondo font-semibold text-peligro hover:bg-peligro-claro",
      },
      tamano: {
        sm: "px-3 py-2 text-xs",
        md: "px-4 py-2.5 text-[13px]",
        lg: "px-5 py-3.5 text-sm",
      },
      ancho: {
        auto: "",
        completo: "w-full",
      },
    },
    defaultVariants: { variante: "primario", tamano: "md", ancho: "auto" },
  },
);

type PropsVariante = VariantProps<typeof variantesBoton>;

export function Boton({
  className,
  variante,
  tamano,
  ancho,
  type = "button",
  ...props
}: ComponentProps<"button"> & PropsVariante) {
  return (
    <button
      type={type}
      className={cn(variantesBoton({ variante, tamano, ancho }), className)}
      {...props}
    />
  );
}

export function BotonEnlace({
  className,
  variante,
  tamano,
  ancho,
  ...props
}: ComponentProps<typeof Link> & PropsVariante) {
  return (
    <Link className={cn(variantesBoton({ variante, tamano, ancho }), className)} {...props} />
  );
}
