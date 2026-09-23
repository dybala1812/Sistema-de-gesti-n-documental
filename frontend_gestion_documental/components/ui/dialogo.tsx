"use client";

import * as Dialog from "@radix-ui/react-dialog";
import { X } from "lucide-react";
import { useState, type ReactNode } from "react";
import { Boton } from "./boton";
import { AreaTexto, Campo } from "./campos";

/**
 * Confirmación para acciones que no se deshacen (anular, deshabilitar, reasignar).
 * Con `pedirMotivo`, el motivo es obligatorio y queda en la trazabilidad.
 */
export function DialogoConfirmar({
  disparador,
  titulo,
  descripcion,
  textoConfirmar,
  peligroso = false,
  pedirMotivo = false,
  alConfirmar,
  children,
}: {
  disparador: ReactNode;
  titulo: string;
  descripcion: string;
  textoConfirmar: string;
  peligroso?: boolean;
  pedirMotivo?: boolean;
  alConfirmar: (motivo: string) => void;
  children?: ReactNode;
}) {
  const [abierto, setAbierto] = useState(false);
  const [motivo, setMotivo] = useState("");
  const [error, setError] = useState("");

  function confirmar() {
    if (pedirMotivo && !motivo.trim()) {
      setError("Escribe el motivo para continuar.");
      return;
    }
    alConfirmar(motivo.trim());
    setAbierto(false);
    setMotivo("");
    setError("");
  }

  return (
    <Dialog.Root open={abierto} onOpenChange={setAbierto}>
      <Dialog.Trigger asChild>{disparador}</Dialog.Trigger>
      <Dialog.Portal>
        <Dialog.Overlay className="fixed inset-0 z-40 bg-tinta-profunda/40 data-[state=open]:animate-[aparecer_150ms_ease-out]" />
        <Dialog.Content className="fixed top-1/2 left-1/2 z-50 w-[calc(100vw-32px)] max-w-md -translate-x-1/2 -translate-y-1/2 border border-borde bg-fondo p-6 shadow-flotante data-[state=open]:animate-[emerger_180ms_ease-out]">
          <div className="mb-2 flex items-start gap-3">
            <Dialog.Title className="flex-1 font-display text-lg font-bold text-marca">{titulo}</Dialog.Title>
            <Dialog.Close aria-label="Cerrar" className="p-1 text-tinta-suave hover:text-tinta">
              <X className="size-4" />
            </Dialog.Close>
          </div>
          <Dialog.Description className="mb-5 text-[13px] leading-relaxed text-tinta-suave">{descripcion}</Dialog.Description>
          {children}
          {pedirMotivo && (
            <Campo etiqueta="Motivo" htmlFor="motivo-dialogo" error={error} className="mb-5">
              <AreaTexto
                id="motivo-dialogo"
                rows={3}
                value={motivo}
                onChange={(e) => setMotivo(e.target.value)}
                aria-invalid={!!error}
                aria-describedby={error ? "motivo-dialogo-error" : undefined}
              />
            </Campo>
          )}
          <div className="flex flex-wrap gap-2">
            <Boton variante={peligroso ? "peligro" : "primario"} onClick={confirmar}>
              {textoConfirmar}
            </Boton>
            <Dialog.Close asChild>
              <Boton variante="secundario">Cancelar</Boton>
            </Dialog.Close>
          </div>
        </Dialog.Content>
      </Dialog.Portal>
    </Dialog.Root>
  );
}
