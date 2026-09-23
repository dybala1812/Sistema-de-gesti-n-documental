"use client";

import gsap from "gsap";
import { useLayoutEffect, useRef, type ElementType, type ReactNode } from "react";

/**
 * Entrada suave de los hijos marcados con [data-aparecer] (o del bloque entero si no hay).
 * Si el usuario pidió reducir el movimiento, no anima.
 */
export function Aparecer({
  children,
  className,
  retardo = 0,
  como = "div",
}: {
  children: ReactNode;
  className?: string;
  retardo?: number;
  como?: "div" | "tbody" | "ul" | "ol" | "section";
}) {
  const raiz = useRef<HTMLElement>(null);

  useLayoutEffect(() => {
    const nodo = raiz.current;
    if (!nodo || window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;
    const ctx = gsap.context(() => {
      const objetivos = nodo.querySelectorAll("[data-aparecer]");
      gsap.from(objetivos.length ? objetivos : nodo, {
        y: 14,
        opacity: 0,
        duration: 0.45,
        ease: "power2.out",
        stagger: 0.05,
        delay: retardo,
        clearProps: "transform,opacity",
      });
    }, nodo);
    return () => ctx.revert();
  }, [retardo]);

  const Etiqueta = como as ElementType;
  return (
    <Etiqueta ref={raiz} className={className}>
      {children}
    </Etiqueta>
  );
}
