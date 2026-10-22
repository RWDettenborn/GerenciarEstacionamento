import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/model.dart';

class ParkingSpotService {
  static const String _chave = 'parking_spots';

  Map<String, dynamic> _paraMapa(ParkingSpot v) => {
        'id': v.id,
        'registrationDate': v.registrationDate,
        ...v.toJson(),
      };

  Future<List<ParkingSpot>> _ler() async {
    final prefs = await SharedPreferences.getInstance();
    final texto = prefs.getString(_chave);
    if (texto == null || texto.isEmpty) return [];
    final dados = jsonDecode(texto) as List<dynamic>;
    return dados
        .map((e) => ParkingSpot.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _gravar(List<ParkingSpot> vagas) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _chave, jsonEncode(vagas.map(_paraMapa).toList()));
  }

  String _novoUuid() {
    final r = Random.secure();
    final b = List<int>.generate(16, (_) => r.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-'
        '${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
  }

  bool _igual(String a, String b) =>
      a.trim().toLowerCase() == b.trim().toLowerCase();

  void _validar(ParkingSpot nova, List<ParkingSpot> existentes,
      {String? ignorarId}) {
    if (nova.parkingSpotNumber.trim().isEmpty ||
        nova.licensePlateCar.trim().isEmpty ||
        nova.brandCar.trim().isEmpty ||
        nova.modelCar.trim().isEmpty ||
        nova.colorCar.trim().isEmpty ||
        nova.responsibleName.trim().isEmpty ||
        nova.apartment.trim().isEmpty ||
        nova.block.trim().isEmpty) {
      throw Exception('Preencha todos os campos.');
    }
    if (nova.parkingSpotNumber.trim().length > 10) {
      throw Exception('O número da vaga deve ter no máximo 10 caracteres.');
    }
    if (nova.licensePlateCar.trim().length > 7) {
      throw Exception('A placa deve ter no máximo 7 caracteres.');
    }
    for (final v in existentes) {
      if (v.id == ignorarId) continue;
      if (_igual(v.parkingSpotNumber, nova.parkingSpotNumber)) {
        throw Exception('Parking Spot is already in use!');
      }
      if (_igual(v.licensePlateCar, nova.licensePlateCar)) {
        throw Exception('License Plate Car is already in use!');
      }
      if (_igual(v.apartment, nova.apartment) && _igual(v.block, nova.block)) {
        throw Exception(
            'Parking Spot already registered for this apartment/block!');
      }
    }
  }

  ParkingSpot _limpa(ParkingSpot v, {String? id, String? data}) => ParkingSpot(
        id: id,
        registrationDate: data,
        parkingSpotNumber: v.parkingSpotNumber.trim(),
        licensePlateCar: v.licensePlateCar.trim().toUpperCase(),
        brandCar: v.brandCar.trim(),
        modelCar: v.modelCar.trim(),
        colorCar: v.colorCar.trim(),
        responsibleName: v.responsibleName.trim(),
        apartment: v.apartment.trim(),
        block: v.block.trim(),
      );

  Future<List<ParkingSpot>> listar() async => _ler();

  Future<ParkingSpot> cadastrar(ParkingSpot vaga) async {
    final vagas = await _ler();
    _validar(vaga, vagas);
    final criada = _limpa(vaga,
        id: _novoUuid(), data: DateTime.now().toUtc().toIso8601String());
    vagas.add(criada);
    await _gravar(vagas);
    return criada;
  }

  Future<ParkingSpot> buscarPorId(String id) async {
    final vagas = await _ler();
    for (final v in vagas) {
      if (v.id == id) return v;
    }
    throw Exception('Parking Spot not found.');
  }

  Future<ParkingSpot> atualizar(String id, ParkingSpot vaga) async {
    final vagas = await _ler();
    final i = vagas.indexWhere((v) => v.id == id);
    if (i < 0) throw Exception('Parking Spot not found.');
    _validar(vaga, vagas, ignorarId: id);
    final atualizada =
        _limpa(vaga, id: id, data: vagas[i].registrationDate);
    vagas[i] = atualizada;
    await _gravar(vagas);
    return atualizada;
  }

  Future<String> excluir(String id) async {
    final vagas = await _ler();
    final antes = vagas.length;
    vagas.removeWhere((v) => v.id == id);
    if (vagas.length == antes) throw Exception('Parking Spot not found.');
    await _gravar(vagas);
    return 'Parking Spot deleted successfully.';
  }

  Future<List<ParkingSpot>> listarPaginado({
    int page = 0,
    int size = 5,
    String sort = 'parkingSpotNumber,asc',
  }) async {
    final vagas = await _ler();
    final partes = sort.split(',');
    final campo = partes.first;
    final desc = partes.length > 1 && partes[1].toLowerCase() == 'desc';

    String chave(ParkingSpot v) {
      switch (campo) {
        case 'licensePlateCar':
          return v.licensePlateCar;
        case 'responsibleName':
          return v.responsibleName;
        case 'brandCar':
          return v.brandCar;
        case 'modelCar':
          return v.modelCar;
        case 'colorCar':
          return v.colorCar;
        case 'apartment':
          return v.apartment;
        case 'block':
          return v.block;
        case 'registrationDate':
          return v.registrationDate ?? '';
        default:
          return v.parkingSpotNumber;
      }
    }

    vagas.sort((a, b) {
      final c = chave(a).toLowerCase().compareTo(chave(b).toLowerCase());
      return desc ? -c : c;
    });

    final inicio = page * size;
    if (inicio >= vagas.length) return [];
    final fim = min(inicio + size, vagas.length);
    return vagas.sublist(inicio, fim);
  }
}
