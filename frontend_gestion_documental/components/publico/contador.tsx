"use client";

import gsap from "gsap";
import { useEffect, useRef } from "react";

/**
 * Cifra que cuenta desde cero al aparecer. El valor final ya está en el HTML y es el
 * que leen los lectores de pantalla; la animación es solo visual.
 */
export function Contador({ valor, sufijo = "" }: { valor: number; sufijo?: string }) {
  const nodo = useRef<HTMLSpanElement>(null);

  useEffect(() => {
    const el = nodo.current;
    if (!el || window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;
    const estado = { n: 0 };
    const tween = gsap.to(estado, {
      n: valor,
      duration: 1.2,
      ease: "power2.out",
      onUpdate: () => {
        el.textContent = `${Math.round(estado.n)}${sufijo}`;
      },
    });
    return () => {
      tween.kill();
      el.textContent = `${valor}${sufijo}`;
    };
  }, [valor, sufijo]);

  return (
    <>
      <span ref={nodo} aria-hidden className="tabular-nums">
        {valor}
        {sufijo}
      </span>
      <span className="sr-only">
        {valor}
        {sufijo}
      </span>
    </>
  );
}
