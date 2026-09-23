"use client";

import { FileText, UploadCloud, X } from "lucide-react";
import { useId, useRef, useState, type DragEvent } from "react";
import { cn } from "@/lib/utils";
import { notificar } from "./notificaciones";

const TIPOS_PERMITIDOS = ["application/pdf", "image/png", "image/jpeg"];
const LIMITE_BYTES = 100 * 1024 * 1024;

function formatoTamano(bytes: number) {
  if (bytes < 1024 * 1024) return `${Math.max(1, Math.round(bytes / 1024))} KB`;
  return `${(bytes / (1024 * 1024)).toFixed(1).replace(".", ",")} MB`;
}

/**
 * La validación aquí es solo para guiar al usuario; el backend vuelve a validar
 * tipo (por contenido) y tamaño.
 */
export function ZonaArchivos({
  etiqueta,
  multiple = true,
  ayuda = "PDF o imagen · hasta 100 MB por envío",
}: {
  etiqueta: string;
  multiple?: boolean;
  ayuda?: string;
}) {
  const id = useId();
  const entrada = useRef<HTMLInputElement>(null);
  const [archivos, setArchivos] = useState<File[]>([]);
  const [arrastrando, setArrastrando] = useState(false);

  function agregar(lista: FileList | null) {
    if (!lista) return;
    const nuevos = Array.from(lista);
    const rechazados = nuevos.filter((f) => !TIPOS_PERMITIDOS.includes(f.type));
    const validos = nuevos.filter((f) => TIPOS_PERMITIDOS.includes(f.type));
    const total = [...(multiple ? archivos : []), ...validos];
    const peso = total.reduce((s, f) => s + f.size, 0);

    if (rechazados.length) {
      notificar.error("Formato no permitido", `${rechazados.map((f) => f.name).join(", ")}: solo PDF o imagen.`);
    }
    if (peso > LIMITE_BYTES) {
      notificar.error("Archivos demasiado grandes", "El envío supera los 100 MB permitidos.");
      return;
    }
    setArchivos(multiple ? total : validos.slice(0, 1));
  }

  function soltar(e: DragEvent) {
    e.preventDefault();
    setArrastrando(false);
    agregar(e.dataTransfer.files);
  }

  return (
    <div>
      <span className="mb-2 block font-display text-xs font-semibold text-tinta">{etiqueta}</span>
      <button
        type="button"
        onClick={() => entrada.current?.click()}
        onDragOver={(e) => {
          e.preventDefault();
          setArrastrando(true);
        }}
        onDragLeave={() => setArrastrando(false)}
        onDrop={soltar}
        aria-describedby={`${id}-ayuda`}
        className={cn(
          "flex w-full flex-col items-center gap-2 border-[1.5px] border-dashed border-borde-campo bg-fondo-alt px-6 py-6 text-center text-[13px] text-tinta-suave transition-colors",
          arrastrando && "border-info bg-info-claro",
        )}
      >
        <UploadCloud className="size-6" aria-hidden />
        <span>
          Arrastra archivos o <span className="font-semibold text-info underline">selecciónalos</span>
        </span>
      </button>
      <input
        ref={entrada}
        id={id}
        type="file"
        accept=".pdf,image/png,image/jpeg"
        multiple={multiple}
        className="sr-only"
        onChange={(e) => agregar(e.target.files)}
      />
      <p id={`${id}-ayuda`} className="mt-1.5 text-[11px] text-tinta-suave">
        {ayuda}
      </p>
      {archivos.length > 0 && (
        <ul className="mt-3 divide-y divide-borde border border-borde">
          {archivos.map((f, i) => (
            <li key={`${f.name}-${i}`} className="flex items-center gap-3 px-3 py-2.5 text-[13px]">
              <FileText className="size-4 shrink-0 text-tinta-suave" aria-hidden />
              <span className="min-w-0 flex-1 truncate">{f.name}</span>
              <span className="text-xs text-tinta-suave">{formatoTamano(f.size)}</span>
              <button
                type="button"
                aria-label={`Quitar ${f.name}`}
                onClick={() => setArchivos((a) => a.filter((_, j) => j !== i))}
                className="p-1 text-tinta-suave hover:text-peligro"
              >
                <X className="size-4" />
              </button>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
