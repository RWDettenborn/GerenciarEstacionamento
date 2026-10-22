import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/model.dart';

class ParkingSpotService {
  static const String baseUrl = 'https://parking-spot-pmfd.onrender.com';
  static const String _path = '/parking-spot';


  static const Duration _timeout = Duration(seconds: 60);

  static const Map<String, String> _headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: query);

  String _erro(http.Response r) {
    final corpo = utf8.decode(r.bodyBytes).trim();
    if (corpo.isEmpty) return 'Erro HTTP ${r.statusCode}';
    return 'Erro HTTP ${r.statusCode}: $corpo';
  }

  List<ParkingSpot> _lista(List<dynamic> dados) => dados
      .map((e) => ParkingSpot.fromJson(e as Map<String, dynamic>))
      .toList();

  Future<List<ParkingSpot>> listar() async {
    final r =
        await http.get(_uri(_path), headers: _headers).timeout(_timeout);
    if (r.statusCode != 200) throw Exception(_erro(r));
    return _lista(jsonDecode(utf8.decode(r.bodyBytes)) as List<dynamic>);
  }

  Future<ParkingSpot> cadastrar(ParkingSpot vaga) async {
    final r = await http
        .post(_uri(_path), headers: _headers, body: jsonEncode(vaga.toJson()))
        .timeout(_timeout);
    if (r.statusCode != 201 && r.statusCode != 200) throw Exception(_erro(r));
    return ParkingSpot.fromJson(
        jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>);
  }

  Future<ParkingSpot> buscarPorId(String id) async {
    final r =
        await http.get(_uri('$_path/$id'), headers: _headers).timeout(_timeout);
    if (r.statusCode != 200) throw Exception(_erro(r));
    return ParkingSpot.fromJson(
        jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>);
  }

  Future<ParkingSpot> atualizar(String id, ParkingSpot vaga) async {
    final r = await http
        .put(_uri('$_path/$id'),
            headers: _headers, body: jsonEncode(vaga.toJson()))
        .timeout(_timeout);
    if (r.statusCode != 200) throw Exception(_erro(r));
    return ParkingSpot.fromJson(
        jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>);
  }

  Future<String> excluir(String id) async {
    final r = await http
        .delete(_uri('$_path/$id'), headers: _headers)
        .timeout(_timeout);
    if (r.statusCode != 200) throw Exception(_erro(r));
    return utf8.decode(r.bodyBytes);
  }

  Future<List<ParkingSpot>> listarPaginado({
    int page = 0,
    int size = 5,
    String sort = 'parkingSpotNumber,asc',
  }) async {
    final r = await http.get(
      _uri('$_path/order', {
        'page': '$page',
        'size': '$size',
        'sort': sort,
      }),
      headers: _headers,
    ).timeout(_timeout);
    if (r.statusCode != 200) throw Exception(_erro(r));
    final mapa = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
    return _lista(mapa['content'] as List<dynamic>);
  }
}
