import '../data/almacen_local.dart';
import '../model/incidencia.dart';

class GestorIncidencias {
  final AlmacenLocal datos = AlmacenLocal();
  List<Incidencia> incidencias = [];

  Future<void> iniciar() async {
    incidencias = await datos.leer();
  }

  // FEAT-002: aplica texto, estado y prioridad a la vez.
  // 'Todos' y 'Todas' significan sin filtro. Con texto vacío devuelve
  // los registros que cumplen los filtros activos.
  static List<Incidencia> filtrar(
    List<Incidencia> lista, {
    String texto = '',
    String estado = 'Todos',
    String prioridad = 'Todas',
  }) {
    final q = texto.trim().toLowerCase();
    return lista.where((x) {
      final coincideTexto = q.isEmpty ||
          x.titulo.toLowerCase().contains(q) ||
          x.descripcion.toLowerCase().contains(q);
      final coincideEstado = estado == 'Todos' || x.estado == estado;
      final coincidePrioridad =
          prioridad == 'Todas' || x.prioridad == prioridad;
      return coincideTexto && coincideEstado && coincidePrioridad;
    }).toList();
  }

  List<Incidencia> buscar(
    String texto, {
    String estado = 'Todos',
    String prioridad = 'Todas',
  }) {
    return filtrar(incidencias,
        texto: texto, estado: estado, prioridad: prioridad);
  }

  Incidencia? porId(String id) {
    for (var x in incidencias) {
      if (x.id == id) return x;
    }
    return null;
  }

  // BUG-003: siempre cuenta desde la lista actual
  int contar(String estado) {
    return incidencias.where((x) => x.estado == estado).length;
  }

  // BUG-001: guarda el cambio
  Future<void> cambiarEstado(String id, String estado) async {
    for (var i = 0; i < incidencias.length; i++) {
      if (incidencias[i].id == id) {
        incidencias[i].estado = estado;
        break;
      }
    }
    await datos.guardar(incidencias);
  }

  // FEAT-001
  Future<void> cambiarPrioridad(String id, String prioridad) async {
    final item = porId(id);
    if (item == null) return;
    item.prioridad = Incidencia.normalizarPrioridad(prioridad);
    await datos.guardar(incidencias);
  }

  Future<void> crear(String titulo, String descripcion, String cliente,
      String categoria,
      {String prioridad = 'Media'}) async {
    final nuevo = Incidencia(
      id: 'INC-${DateTime.now().microsecondsSinceEpoch}',
      titulo: titulo,
      descripcion: descripcion,
      cliente: cliente,
      categoria: categoria,
      estado: 'Pendiente',
      fecha: DateTime.now().toIso8601String().split('T').first,
      prioridad: Incidencia.normalizarPrioridad(prioridad),
    );
    incidencias.insert(0, nuevo);
    await datos.guardar(incidencias);
  }

  Future<void> reiniciarDemo() async {
    await datos.restaurarDatosDeEjemplo();
    await iniciar();
  }
}