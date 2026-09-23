"use client";

import gsap from "gsap";
import { CheckCircle2 } from "lucide-react";
import { useLayoutEffect, useRef } from "react";

export function SelloExito() {
  const nodo = useRef<HTMLSpanElement>(null);

  useLayoutEffect(() => {
    if (!nodo.current || window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;
    const tween = gsap.from(nodo.current, { scale: 0.4, opacity: 0, duration: 0.7, ease: "back.out(2.2)" });
    return () => {
      tween.revert();
    };
  }, []);

  return (
    <span ref={nodo} className="mb-4 inline-grid size-12 place-items-center bg-exito-claro text-exito">
      <CheckCircle2 className="size-7" aria-hidden />
    </span>
  );
}
