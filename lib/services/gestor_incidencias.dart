import '../data/almacen_local.dart';
import '../model/incidencia.dart';

class GestorIncidencias {
  final AlmacenLocal datos = AlmacenLocal();
  List<Incidencia> incidencias = [];

  Future<void> iniciar() async {
    incidencias = await datos.leer();
  }

  // BUG-002: ignora mayúsculas, recorta espacios y busca en título y descripción
  List<Incidencia> buscar(String texto) {
    final q = texto.trim().toLowerCase();
    if (q.isEmpty) return incidencias;
    return incidencias
        .where((x) =>
            x.titulo.toLowerCase().contains(q) ||
            x.descripcion.toLowerCase().contains(q))
        .toList();
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

  // BUG-001: ahora guarda el cambio
  Future<void> cambiarEstado(String id, String estado) async {
    for (var i = 0; i < incidencias.length; i++) {
      if (incidencias[i].id == id) {
        incidencias[i].estado = estado;
        break;
      }
    }
    await datos.guardar(incidencias);
  }

  // FEAT-001: cambiar la prioridad y guardarla
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