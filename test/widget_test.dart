import 'package:flutter_test/flutter_test.dart';
import 'package:nexasoft_incidencias/model/incidencia.dart';
import 'package:nexasoft_incidencias/services/gestor_incidencias.dart';

List<Incidencia> muestra() => [
      Incidencia(
        id: 'A', titulo: 'WiFi caído', descripcion: 'Sin red en recepción',
        cliente: 'c', categoria: 'Redes', estado: 'Pendiente',
        fecha: '2026-10-19', prioridad: 'Alta',
      ),
      Incidencia(
        id: 'B', titulo: 'Impresora lenta', descripcion: 'Tarda en imprimir',
        cliente: 'c', categoria: 'Hardware', estado: 'En proceso',
        fecha: '2026-10-19', prioridad: 'Media',
      ),
      Incidencia(
        id: 'C', titulo: 'Correo con error', descripcion: 'Falla la sincronización por WiFi',
        cliente: 'c', categoria: 'Software', estado: 'Pendiente',
        fecha: '2026-10-19', prioridad: 'Baja',
      ),
      Incidencia(
        id: 'D', titulo: 'Pantalla rota', descripcion: 'Monitor dañado',
        cliente: 'c', categoria: 'Hardware', estado: 'Resuelta',
        fecha: '2026-10-19', prioridad: 'Alta',
      ),
    ];

List<String> ids(List<Incidencia> lista) => lista.map((x) => x.id).toList();

void main() {
  test('Una incidencia antigua puede convertirse desde JSON', () {
    final registro = Incidencia.desdeJson({
      'id': 'INC-DEMO',
      'titulo': 'Prueba',
      'descripcion': 'Caso de ejemplo',
      'cliente': 'Cliente ficticio',
      'categoria': 'Redes',
      'estado': 'Pendiente',
      'fecha': '2026-10-12',
    });
    expect(registro.id, 'INC-DEMO');
    expect(registro.toJson()['estado'], 'Pendiente');
  });

  test('FEAT-001: registro antiguo sin prioridad usa Media', () {
    final registro = Incidencia.desdeJson({
      'id': 'INC-X',
      'titulo': 't',
      'descripcion': 'd',
      'cliente': 'c',
      'categoria': 'Redes',
      'estado': 'Pendiente',
      'fecha': '2026-10-16',
    });
    expect(registro.prioridad, 'Media');
  });

  test('FEAT-001: un valor inválido se normaliza a Media', () {
    expect(Incidencia.normalizarPrioridad('Urgente'), 'Media');
  });

  test('FEAT-001: toJson conserva Alta', () {
    final registro = Incidencia(
      id: 'INC-Y',
      titulo: 't',
      descripcion: 'd',
      cliente: 'c',
      categoria: 'Redes',
      estado: 'Pendiente',
      fecha: '2026-10-16',
      prioridad: 'Alta',
    );
    expect(registro.toJson()['prioridad'], 'Alta');
  });

  test('FEAT-002: sin filtros devuelve todos los registros', () {
    expect(GestorIncidencias.filtrar(muestra()).length, 4);
  });

  test('FEAT-002: estado y prioridad funcionan juntos', () {
    final r = GestorIncidencias.filtrar(muestra(),
        estado: 'Pendiente', prioridad: 'Alta');
    expect(ids(r), ['A']);
  });

  test('FEAT-002: texto, estado y prioridad se aplican a la vez', () {
    final soloTexto = GestorIncidencias.filtrar(muestra(), texto: 'wifi');
    expect(ids(soloTexto), ['A', 'C']);
    final combinado = GestorIncidencias.filtrar(muestra(),
        texto: 'wifi', estado: 'Pendiente', prioridad: 'Alta');
    expect(ids(combinado), ['A']);
  });

  test('FEAT-002: sin coincidencias devuelve una lista vacía', () {
    final r = GestorIncidencias.filtrar(muestra(),
        estado: 'Resuelta', prioridad: 'Baja');
    expect(r, isEmpty);
  });
}