import 'package:get/get.dart';

import '../models/model.dart';
import '../services/service.dart';

class ParkingSpotController extends GetxController {
  final ParkingSpotService _service = ParkingSpotService();

  final RxList<ParkingSpot> vagas = <ParkingSpot>[].obs;
  final RxBool carregando = false.obs;
  final RxBool salvando = false.obs;
  final RxnString erro = RxnString();

  final RxnString ordenacao = RxnString();

  @override
  void onInit() {
    super.onInit();
    carregar();
  }

  String _msg(Object e) => e.toString().replaceFirst('Exception: ', '');

  Future<void> carregar() async {
    carregando.value = true;
    erro.value = null;
    try {
      final lista = ordenacao.value == null
          ? await _service.listar()
          : await _service.listarPaginado(
              size: 1000, sort: ordenacao.value!);
      vagas.assignAll(lista);
    } catch (e) {
      erro.value = _msg(e);
    } finally {
      carregando.value = false;
    }
  }

  Future<void> ordenar(String? sort) async {
    ordenacao.value = sort;
    await carregar();
  }

  Future<String?> salvar(ParkingSpot vaga, {String? idEdicao}) async {
    salvando.value = true;
    try {
      if (idEdicao == null) {
        await _service.cadastrar(vaga);
      } else {
        await _service.atualizar(idEdicao, vaga);
      }
      await carregar();
      return null;
    } catch (e) {
      return _msg(e);
    } finally {
      salvando.value = false;
    }
  }

  Future<String?> excluir(String id) async {
    try {
      await _service.excluir(id);
      vagas.removeWhere((v) => v.id == id);
      return null;
    } catch (e) {
      return _msg(e);
    }
  }
}
