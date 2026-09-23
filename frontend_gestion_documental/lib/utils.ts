import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...clases: ClassValue[]) {
  return twMerge(clsx(clases));
}

/**
 * Copia al portapapeles. Si la API moderna no está permitida (navegadores embebidos,
 * http sin localhost), usa el método clásico con una selección temporal.
 */
export async function copiarTexto(texto: string): Promise<boolean> {
  try {
    await navigator.clipboard.writeText(texto);
    return true;
  } catch {
    const area = document.createElement("textarea");
    area.value = texto;
    area.setAttribute("readonly", "");
    area.style.position = "fixed";
    area.style.opacity = "0";
    document.body.appendChild(area);
    area.select();
    try {
      // execCommand está obsoleto, pero es el único respaldo cuando la API moderna está bloqueada.
      return document.execCommand("copy");
    } catch {
      return false;
    } finally {
      area.remove();
    }
  }
}

export function soloDigitos(valor: string) {
  return valor.replace(/\D/g, "");
}
