import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:estacionamento/models/model.dart';
import 'package:estacionamento/services/service_local.dart';

ParkingSpot vaga(String n, String placa, String apto, String bloco) =>
    ParkingSpot(
      parkingSpotNumber: n,
      licensePlateCar: placa,
      brandCar: 'Honda',
      modelCar: 'Civic',
      colorCar: 'Preto',
      responsibleName: 'Aluno Teste',
      apartment: apto,
      block: bloco,
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('cadastra, lista, atualiza e exclui', () async {
    final s = ParkingSpotService();
    final criada = await s.cadastrar(vaga('A101', 'tst1a23', '101', 'T'));
    expect(criada.id, isNotNull);
    expect(criada.registrationDate, isNotNull);
    expect(criada.licensePlateCar, 'TST1A23');
    expect((await s.listar()).length, 1);

    final up = await s.atualizar(criada.id!, vaga('A101', 'TST1A23', '101', 'T'));
    expect(up.id, criada.id);
    expect(up.registrationDate, criada.registrationDate);

    await s.excluir(criada.id!);
    expect(await s.listar(), isEmpty);
  });

  test('bloqueia duplicados de vaga, placa e apto+bloco', () async {
    final s = ParkingSpotService();
    await s.cadastrar(vaga('A101', 'AAA1111', '101', 'T'));
    expect(() => s.cadastrar(vaga('A101', 'BBB2222', '102', 'T')), throwsException);
    expect(() => s.cadastrar(vaga('A102', 'AAA1111', '102', 'T')), throwsException);
    expect(() => s.cadastrar(vaga('A102', 'BBB2222', '101', 'T')), throwsException);
  });

  test('paginação e ordenação', () async {
    final s = ParkingSpotService();
    await s.cadastrar(vaga('B2', 'P000002', '2', 'T'));
    await s.cadastrar(vaga('A1', 'P000001', '1', 'T'));
    await s.cadastrar(vaga('C3', 'P000003', '3', 'T'));
    final p = await s.listarPaginado(page: 0, size: 2);
    expect(p.map((e) => e.parkingSpotNumber), ['A1', 'B2']);
    final d = await s.listarPaginado(sort: 'parkingSpotNumber,desc');
    expect(d.first.parkingSpotNumber, 'C3');
  });
}
