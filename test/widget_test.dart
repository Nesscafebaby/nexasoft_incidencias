import 'package:flutter_test/flutter_test.dart';
import 'package:nexasoft_incidencias/model/incidencia.dart';

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
}