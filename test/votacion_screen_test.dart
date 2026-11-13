import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vota_dolores_hidalgo/main.dart';

void telefono(WidgetTester tester, Size tamano) {
  tester.view.devicePixelRatio = 2;
  tester.view.physicalSize = tamano * 2;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('al votar, la barra llega a 100% y desaparecen los botones', (tester) async {
    telefono(tester, const Size(412, 891));
    await tester.pumpWidget(const VotaDoloresApp());
    expect(find.text('Votar por esta opción'), findsNWidgets(4));

    await tester.tap(find.text('Votar por esta opción').first);
    await tester.pump(const Duration(milliseconds: 300));
    // a media animacion el porcentaje todavia va creciendo
    final aMedias = tester.widget<Text>(find.textContaining('%').first).data!;
    expect(aMedias, isNot('100%'));
    await tester.pumpAndSettle();

    expect(find.text('100%'), findsOneWidget);
    expect(find.text('0%'), findsNWidgets(3));
    expect(find.text('Votar por esta opción'), findsNothing);
  });

  testWidgets('despues de votar, el dialogo anuncia al ganador', (tester) async {
    telefono(tester, const Size(412, 891));
    await tester.pumpWidget(const VotaDoloresApp());
    await tester.tap(find.text('Votar por esta opción').at(1));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ver resultado del plebiscito'));
    await tester.pumpAndSettle();

    expect(find.textContaining('La opción ganadora es:'), findsOneWidget);
    expect(find.textContaining('Nueva Biblioteca Digital'), findsNWidgets(2));
  });

  testWidgets('sin votos, el dialogo no anuncia un empate', (tester) async {
    telefono(tester, const Size(412, 891));
    await tester.pumpWidget(const VotaDoloresApp());

    await tester.tap(find.text('Ver resultado del plebiscito'));
    await tester.pumpAndSettle();

    expect(find.textContaining('empate'), findsNothing);
    expect(find.text('Todavía no hay votos.'), findsOneWidget);
  });

  testWidgets('en un telefono chico (360x640) no hay desbordes', (tester) async {
    telefono(tester, const Size(360, 640));
    await tester.pumpWidget(const VotaDoloresApp());
    await tester.tap(find.text('Votar por esta opción').first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Ver resultado del plebiscito'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver resultado del plebiscito'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Cerrar'), findsOneWidget);
  });
}
