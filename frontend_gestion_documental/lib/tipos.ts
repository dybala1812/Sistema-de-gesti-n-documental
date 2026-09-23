export type Rol = "recepcion" | "dependencia" | "archivo_central" | "administrador";

/** Estados tal como se muestran en pantalla (maquetación v1.0). */
export type EstadoVisible =
  | "Radicado"
  | "En trámite"
  | "En revisión"
  | "En comité"
  | "Por verificar"
  | "Respondido"
  | "Vencido"
  | "Anulado"
  | "Pendiente"
  | "Activo"
  | "Deshabilitado"
  | "Por clasificar"
  | "Clasificado";

export type Semaforo = "verde" | "amarillo" | "naranja" | "rojo";

export type TipoConsecutivo =
  | "Comunicación recibida"
  | "Comunicación enviada"
  | "Circular"
  | "Resolución"
  | "Convenio";

export interface Radicado {
  id: string;
  numero: string;
  tipoTramite: string;
  solicitante: string;
  cedula: string;
  dependencia: string;
  estado: EstadoVisible;
  fecha: string;
  diasRestantes: number | null;
  semaforo: Semaforo;
  requiereComite: boolean;
  adjunto?: { nombre: string; tamano: string };
}

export interface EventoTrazabilidad {
  estado: string;
  autor: string;
  cuando: string;
  hecho: boolean;
}

export interface Alerta {
  radicadoId: string;
  numero: string;
  tipoTramite: string;
  dependencia: string;
  plazo: string;
  grupo: "hoy" | "semana" | "vencido";
  esperaComite: boolean;
}

export interface Usuario {
  nombre: string;
  dependencia: string;
  rol: string;
  estado: EstadoVisible;
}

export interface TipoTramite {
  nombre: string;
  plazoDiasHabiles: number;
  requiereComite: boolean;
}

export interface Expediente {
  codigo: string;
  serie: string;
  titular: string;
  documentos: number;
  actualizado: string;
}

export interface RegistroAuditoria {
  cuando: string;
  usuario: string;
  accion: string;
  detalle: string;
}
