import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vota_dolores_hidalgo/main.dart';

/// Guarda lo que la app dibujo realmente en evidencias/capturas.
Future<void> capturar(WidgetTester tester, String nombre) async {
  final vista = tester.binding.renderViews.first;
  final capa = vista.debugLayer! as OffsetLayer;
  final imagen = await capa.toImage(vista.paintBounds);
  final bytes = await imagen.toByteData(format: ui.ImageByteFormat.png);
  final archivo = File('evidencias/capturas/$nombre.png');
  await archivo.parent.create(recursive: true);
  await archivo.writeAsBytes(bytes!.buffer.asUint8List());
  // ignore: avoid_print
  print('CAPTURA evidencias/capturas/$nombre.png');
}

/// Corre la app REAL en Linux a tamano de telefono y la usa como un vecino.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('vecino: consulta, vota y ve el resultado', (tester) async {
    tester.view.devicePixelRatio = 2;
    tester.view.physicalSize = const Size(824, 1782); // 412x891
    addTearDown(tester.view.reset);

    runApp(const VotaDoloresApp());
    await tester.pumpAndSettle();
    expect(find.text('0%'), findsNWidgets(4));
    await capturar(tester, '01_inicio_sin_votos');

    // Antes de votar: no hay ganador ni empate.
    await tester.tap(find.text('Ver resultado del plebiscito'));
    await tester.pumpAndSettle();
    expect(find.text('Todavía no hay votos.'), findsOneWidget);
    await capturar(tester, '02_resultado_sin_votos');
    await tester.tap(find.text('Cerrar'));
    await tester.pumpAndSettle();

    // Vota por la biblioteca y captura la barra a media animacion.
    await tester.tap(find.text('Votar por esta opción').at(1));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 180));
    await capturar(tester, '03_barra_animandose');
    await tester.pumpAndSettle();
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('Votar por esta opción'), findsNothing);
    await capturar(tester, '04_voto_registrado');

    // Revela al ganador: primero a media animacion elastica, luego completo.
    await tester.tap(find.text('Ver resultado del plebiscito'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    await capturar(tester, '05_ganador_animandose');
    await tester.pumpAndSettle();
    expect(find.textContaining('La opción ganadora es:'), findsOneWidget);
    await capturar(tester, '06_ganador');
  });
}
