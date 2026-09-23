import {
  BellRing,
  FilePlus,
  FolderInput,
  FolderSearch,
  FolderTree,
  Inbox,
  MailCheck,
  Package,
  ScanLine,
  ScrollText,
  Search,
  SlidersHorizontal,
  UserCog,
  type LucideIcon,
} from "lucide-react";
import type { Rol } from "./tipos";

export interface ItemMenu {
  href: string;
  etiqueta: string;
  descripcion: string;
  icono: LucideIcon;
}

export interface GrupoMenu {
  titulo?: string;
  items: ItemMenu[];
}

const BUSCAR_CEDULA: ItemMenu = {
  href: "/panel/personas",
  etiqueta: "Buscar por cédula",
  descripcion: "Historial documental completo de una persona.",
  icono: Search,
};

const ALERTAS: ItemMenu = {
  href: "/panel/alertas",
  etiqueta: "Alertas de vencimiento",
  descripcion: "Radicados que vencen hoy, esta semana o ya vencieron.",
  icono: BellRing,
};

const ARCHIVO: GrupoMenu = {
  titulo: "Archivo Central",
  items: [
    {
      href: "/panel/archivo/digitalizar",
      etiqueta: "Digitalizar documentos físicos",
      descripcion: "Subir escaneos y registrar dónde está el original.",
      icono: ScanLine,
    },
    {
      href: "/panel/archivo/por-clasificar",
      etiqueta: "Documentos por clasificar",
      descripcion: "Respondidos o cerrados que faltan por archivar.",
      icono: FolderInput,
    },
    {
      href: "/panel/archivo/clasificar",
      etiqueta: "Clasificación de expediente",
      descripcion: "Aplicar serie y subserie de la TRD a un documento.",
      icono: FolderTree,
    },
    {
      href: "/panel/archivo/expedientes",
      etiqueta: "Consulta de expedientes",
      descripcion: "Buscar expedientes por persona, dependencia o serie.",
      icono: FolderSearch,
    },
  ],
};

/** Matriz de permisos por rol (maquetación §2.2). Es ergonomía: la API vuelve a comprobar. */
export const MENUS: Record<Rol, GrupoMenu[]> = {
  recepcion: [
    {
      titulo: "Recepción",
      items: [
        {
          href: "/panel/radicados",
          etiqueta: "Bandeja de radicados",
          descripcion: "Todo lo que ha entrado y su estado, con filtros.",
          icono: Inbox,
        },
        {
          href: "/panel/radicados/nuevo",
          etiqueta: "Nueva radicación",
          descripcion: "Radicar correspondencia que llega a ventanilla.",
          icono: FilePlus,
        },
        {
          href: "/panel/sin-consecutivo",
          etiqueta: "Registro sin consecutivo",
          descripcion: "Constancia de revistas, facturas y paquetes.",
          icono: Package,
        },
        {
          href: "/panel/verificacion",
          etiqueta: "Respuestas por verificar",
          descripcion: "Revisar respuestas antes de notificar al solicitante.",
          icono: MailCheck,
        },
        ALERTAS,
        BUSCAR_CEDULA,
      ],
    },
    ARCHIVO,
  ],
  dependencia: [
    {
      titulo: "Dependencia",
      items: [
        {
          href: "/panel/asignados",
          etiqueta: "Radicados asignados",
          descripcion: "Bandeja de trabajo ordenada por fecha límite. Desde aquí se responde y se lleva el comité.",
          icono: Inbox,
        },
        ALERTAS,
      ],
    },
  ],
  archivo_central: [{ titulo: "Archivo Central", items: [...ARCHIVO.items, BUSCAR_CEDULA] }],
  administrador: [
    {
      titulo: "Administración",
      items: [
        {
          href: "/panel/admin/usuarios",
          etiqueta: "Gestión de usuarios",
          descripcion: "Crear, editar rol y deshabilitar usuarios.",
          icono: UserCog,
        },
        {
          href: "/panel/admin/tramites",
          etiqueta: "Tipos de trámite y plazos",
          descripcion: "Plazo en días hábiles y si requiere comité.",
          icono: SlidersHorizontal,
        },
        {
          href: "/panel/admin/auditoria",
          etiqueta: "Panel de auditoría",
          descripcion: "Quién hizo qué y cuándo en el sistema.",
          icono: ScrollText,
        },
      ],
    },
  ],
};

export const ETIQUETA_ROL: Record<Rol, string> = {
  recepcion: "Recepción / Ventanilla",
  dependencia: "Dependencia",
  archivo_central: "Archivo Central",
  administrador: "Administrador / TIC",
};

export const USUARIO_DEMO: Record<Rol, { nombre: string; detalle: string }> = {
  recepcion: { nombre: "Marcela Ordóñez", detalle: "Recepción y Archivo Central" },
  dependencia: { nombre: "Carlos A. Zúñiga", detalle: "Facultad de Ingeniería" },
  archivo_central: { nombre: "Diana Paz", detalle: "Archivo Central" },
  administrador: { nombre: "Soporte TIC", detalle: "Administrador" },
};
