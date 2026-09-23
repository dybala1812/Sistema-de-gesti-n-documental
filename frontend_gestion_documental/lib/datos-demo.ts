/**
 * Datos de demostración tomados de la maquetación de interfaz v1.0.
 * Se reemplazan por llamadas a la API (/api/v1/...) cuando exista el backend.
 */
import type {
  Alerta,
  EventoTrazabilidad,
  Expediente,
  Radicado,
  RegistroAuditoria,
  Rol,
  TipoTramite,
  Usuario,
} from "./tipos";

export const UNIVERSIDAD = "Universidad Autónoma del Cauca";

export const TRAMITES_PORTAL = [
  "Reingreso",
  "Reintegro de dinero",
  "Homologación",
  "Trabajo de grado",
  "Tutela",
  "Otro",
];

export const PROGRAMAS = [
  "Ingeniería de Sistemas",
  "Ingeniería Ambiental",
  "Ingeniería Industrial",
  "Derecho",
  "Contaduría Pública",
  "Administración de Empresas",
  "Psicología",
  "Enfermería",
  "Fisioterapia",
  "Comunicación Social",
];

export const DEPENDENCIAS = [
  "Facultad de Ingeniería",
  "Registro Académico",
  "Financiera",
  "Rectoría",
  "Bienestar",
  "Biblioteca",
  "Talento Humano",
  "Secretaría General",
];

export const TIPOS_CONSECUTIVO = [
  "Comunicación recibida",
  "Comunicación enviada",
  "Circular",
  "Resolución",
  "Convenio",
];

export const TIPOS_ELEMENTO = ["Revista", "Factura", "Paquete", "Documento sin firma"];

export const RADICADOS: Radicado[] = [
  {
    id: "2026-CR-01487",
    numero: "2026-CR-01487",
    tipoTramite: "Homologación",
    solicitante: "Laura C. Chicangana",
    cedula: "1061784220",
    dependencia: "Facultad de Ingeniería",
    estado: "En trámite",
    fecha: "1 sep 2026",
    diasRestantes: 6,
    semaforo: "amarillo",
    requiereComite: false,
    adjunto: { nombre: "solicitud-homologacion.pdf", tamano: "2,4 MB" },
  },
  {
    id: "2026-CR-01486",
    numero: "2026-CR-01486",
    tipoTramite: "Reingreso",
    solicitante: "Juan S. Muñoz",
    cedula: "1002456789",
    dependencia: "Registro Académico",
    estado: "Radicado",
    fecha: "1 sep 2026",
    diasRestantes: 14,
    semaforo: "verde",
    requiereComite: false,
  },
  {
    id: "2026-CR-01483",
    numero: "2026-CR-01483",
    tipoTramite: "Trabajo de grado",
    solicitante: "Andrés F. Muñoz",
    cedula: "1007452118",
    dependencia: "Facultad de Ingeniería",
    estado: "En comité",
    fecha: "29 ago 2026",
    diasRestantes: 4,
    semaforo: "naranja",
    requiereComite: true,
  },
  {
    id: "2026-CR-01481",
    numero: "2026-CR-01481",
    tipoTramite: "Homologación",
    solicitante: "Sebastián Rojas",
    cedula: "1061332907",
    dependencia: "Facultad de Ingeniería",
    estado: "Pendiente",
    fecha: "31 ago 2026",
    diasRestantes: 11,
    semaforo: "verde",
    requiereComite: false,
  },
  {
    id: "2026-CR-01479",
    numero: "2026-CR-01479",
    tipoTramite: "Reintegro de dinero",
    solicitante: "Paola Bolaños",
    cedula: "34567123",
    dependencia: "Financiera",
    estado: "Vencido",
    fecha: "25 ago 2026",
    diasRestantes: -7,
    semaforo: "rojo",
    requiereComite: false,
  },
  {
    id: "2026-CR-01474",
    numero: "2026-CR-01474",
    tipoTramite: "Tutela",
    solicitante: "Juzgado 3° Popayán",
    cedula: "891500319",
    dependencia: "Rectoría",
    estado: "Respondido",
    fecha: "22 ago 2026",
    diasRestantes: null,
    semaforo: "verde",
    requiereComite: false,
  },
  {
    id: "2026-CR-01470",
    numero: "2026-CR-01470",
    tipoTramite: "Otro",
    solicitante: "Ana M. Cerón",
    cedula: "25283746",
    dependencia: "Bienestar",
    estado: "Anulado",
    fecha: "20 ago 2026",
    diasRestantes: null,
    semaforo: "verde",
    requiereComite: false,
  },
  {
    id: "2026-CR-01455",
    numero: "2026-CR-01455",
    tipoTramite: "Trabajo de grado",
    solicitante: "Andrés F. Muñoz",
    cedula: "1007452118",
    dependencia: "Facultad de Ingeniería",
    estado: "En revisión",
    fecha: "20 ago 2026",
    diasRestantes: 4,
    semaforo: "naranja",
    requiereComite: true,
  },
  {
    id: "2026-CR-01442",
    numero: "2026-CR-01442",
    tipoTramite: "Reingreso",
    solicitante: "Valeria Astudillo",
    cedula: "1061998877",
    dependencia: "Registro Académico",
    estado: "Vencido",
    fecha: "12 ago 2026",
    diasRestantes: -3,
    semaforo: "rojo",
    requiereComite: false,
  },
  {
    id: "2026-CR-01430",
    numero: "2026-CR-01430",
    tipoTramite: "Homologación",
    solicitante: "Miguel Ángel Ruiz",
    cedula: "1061445566",
    dependencia: "Facultad de Ingeniería",
    estado: "Por verificar",
    fecha: "10 ago 2026",
    diasRestantes: 2,
    semaforo: "naranja",
    requiereComite: false,
  },
];

export const HISTORIAL_PERSONA: Record<string, { nombre: string; radicados: Radicado[] }> = {
  "1061784220": {
    nombre: "Laura Camila Chicangana",
    radicados: [
      RADICADOS[0],
      {
        ...RADICADOS[1],
        id: "2025-CR-00932",
        numero: "2025-CR-00932",
        estado: "Respondido",
        fecha: "14 feb 2025",
        diasRestantes: null,
      },
      {
        ...RADICADOS[4],
        id: "2024-CR-00610",
        numero: "2024-CR-00610",
        estado: "Respondido",
        fecha: "3 oct 2024",
        diasRestantes: null,
      },
    ],
  },
};

export const TRAZABILIDAD: EventoTrazabilidad[] = [
  { estado: "Radicado", autor: "Portal público · Laura C. Chicangana", cuando: "1 sep 2026 · 10:24 a. m.", hecho: true },
  { estado: "Asignado a dependencia", autor: "Marcela Ordóñez · Recepción", cuando: "1 sep 2026 · 10:31 a. m.", hecho: true },
  { estado: "En trámite", autor: "Carlos A. Zúñiga · Facultad de Ingeniería", cuando: "2 sep 2026 · 08:15 a. m.", hecho: true },
  { estado: "Respondido", autor: "Pendiente", cuando: "—", hecho: false },
];

export const ALERTAS: Alerta[] = [
  { radicadoId: "2026-CR-01442", numero: "2026-CR-01442", tipoTramite: "Reingreso", dependencia: "Registro Académico", plazo: "Vence hoy", grupo: "hoy", esperaComite: false },
  { radicadoId: "2026-CR-01487", numero: "2026-CR-01487", tipoTramite: "Homologación", dependencia: "Facultad de Ingeniería", plazo: "Quedan 3 días", grupo: "semana", esperaComite: false },
  { radicadoId: "2026-CR-01455", numero: "2026-CR-01455", tipoTramite: "Trabajo de grado", dependencia: "Facultad de Ingeniería", plazo: "Quedan 4 días", grupo: "semana", esperaComite: true },
  { radicadoId: "2026-CR-01479", numero: "2026-CR-01479", tipoTramite: "Reintegro de dinero", dependencia: "Financiera", plazo: "7 días de retraso", grupo: "vencido", esperaComite: false },
];

export const POR_CLASIFICAR = [
  { numero: "2026-CR-01474", tipo: "Tutela", dependencia: "Rectoría", cerrado: "28 ago 2026", estado: "Por clasificar" as const },
  { numero: "2026-CR-01430", tipo: "Homologación", dependencia: "Facultad de Ingeniería", cerrado: "26 ago 2026", estado: "Por clasificar" as const },
  { numero: "2026-CR-01412", tipo: "Reingreso", dependencia: "Registro Académico", cerrado: "21 ago 2026", estado: "Por clasificar" as const },
  { numero: "2026-CR-01398", tipo: "Reintegro de dinero", dependencia: "Financiera", cerrado: "19 ago 2026", estado: "Por clasificar" as const },
  { numero: "2026-CR-01377", tipo: "Convenio", dependencia: "Rectoría", cerrado: "15 ago 2026", estado: "Clasificado" as const },
];

export const EXPEDIENTES: Expediente[] = [
  { codigo: "EXP-2026-0114", serie: "Acciones constitucionales / Tutelas", titular: "Rectoría", documentos: 7, actualizado: "28 ago 2026" },
  { codigo: "EXP-2026-0098", serie: "Historias académicas / Homologaciones", titular: "Laura C. Chicangana", documentos: 4, actualizado: "26 ago 2026" },
  { codigo: "EXP-2025-0771", serie: "Convenios / Interinstitucionales", titular: "Rectoría", documentos: 12, actualizado: "15 ago 2026" },
  { codigo: "EXP-2025-0640", serie: "Financieros / Reintegros", titular: "Financiera", documentos: 3, actualizado: "19 ago 2026" },
];

export const SERIES_TRD = [
  "Acciones constitucionales",
  "Historias académicas",
  "Convenios",
  "Financieros",
];

export const USUARIOS: Usuario[] = [
  { nombre: "Marcela Ordóñez", dependencia: "Recepción", rol: "Recepción / Ventanilla", estado: "Activo" },
  { nombre: "Carlos A. Zúñiga", dependencia: "Facultad de Ingeniería", rol: "Dependencia", estado: "Activo" },
  { nombre: "Diana Paz", dependencia: "Archivo Central", rol: "Archivo Central", estado: "Activo" },
  { nombre: "Hernán Velasco", dependencia: "Financiera", rol: "Dependencia", estado: "Deshabilitado" },
  { nombre: "Soporte TIC", dependencia: "TIC", rol: "Administrador", estado: "Activo" },
];

export const TIPOS_TRAMITE: TipoTramite[] = [
  { nombre: "Reingreso", plazoDiasHabiles: 8, requiereComite: false },
  { nombre: "Reintegro de dinero", plazoDiasHabiles: 15, requiereComite: false },
  { nombre: "Homologación", plazoDiasHabiles: 15, requiereComite: false },
  { nombre: "Trabajo de grado", plazoDiasHabiles: 15, requiereComite: true },
  { nombre: "Tutela", plazoDiasHabiles: 2, requiereComite: false },
  { nombre: "Otro", plazoDiasHabiles: 15, requiereComite: false },
];

export const AUDITORIA: RegistroAuditoria[] = [
  { cuando: "1 sep 2026 · 10:24", usuario: "Marcela Ordóñez", accion: "Radicación", detalle: "Creó 2026-CR-01487" },
  { cuando: "1 sep 2026 · 09:12", usuario: "Soporte TIC", accion: "Usuario", detalle: "Deshabilitó a Hernán Velasco" },
  { cuando: "31 ago 2026 · 16:40", usuario: "Carlos A. Zúñiga", accion: "Respuesta", detalle: "Respondió 2026-CR-01430" },
  { cuando: "31 ago 2026 · 14:05", usuario: "Marcela Ordóñez", accion: "Anulación", detalle: "Anuló 2026-CR-01470" },
  { cuando: "30 ago 2026 · 11:31", usuario: "Soporte TIC", accion: "Configuración", detalle: "Cambió plazo de “Tutela” a 2 días" },
];

/** Una dependencia solo ve sus alertas; en la demo es Facultad de Ingeniería. */
export function alertasDelRol(rol: Rol) {
  return rol === "dependencia" ? ALERTAS.filter((a) => a.dependencia === "Facultad de Ingeniería") : ALERTAS;
}

export function buscarRadicado(id: string) {
  return RADICADOS.find((r) => r.id === id);
}
