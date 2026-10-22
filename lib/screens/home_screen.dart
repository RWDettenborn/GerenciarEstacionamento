import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/controller.dart';
import '../models/model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ParkingSpotController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Registro de Vagas do Edificio Gran Lider'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Ordenar',
            onSelected: (v) => c.ordenar(v == 'padrao' ? null : v),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'padrao', child: Text('Padrão da API')),
              PopupMenuItem(
                  value: 'parkingSpotNumber,asc', child: Text('Vaga (A-Z)')),
              PopupMenuItem(
                  value: 'parkingSpotNumber,desc', child: Text('Vaga (Z-A)')),
              PopupMenuItem(
                  value: 'responsibleName,asc',
                  child: Text('Responsável (A-Z)')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: c.carregar,
          ),
        ],
      ),
      body: Obx(() {
        if (c.carregando.value && c.vagas.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('Carregando...'),
              ],
            ),
          );
        }
        if (c.erro.value != null && c.vagas.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(c.erro.value!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: c.carregar,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: c.carregar,
          child: c.vagas.isEmpty
              ? ListView(children: const [
                  SizedBox(height: 200),
                  Center(child: Text('Nenhuma vaga cadastrada.')),
                ])
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: c.vagas.length,
                  itemBuilder: (_, i) => _VagaTile(vaga: c.vagas[i]),
                ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(context),
        icon: const Icon(Icons.add),
        label: const Text('Nova vaga'),
      ),
    );
  }
}

class _VagaTile extends StatelessWidget {
  final ParkingSpot vaga;
  const _VagaTile({required this.vaga});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ParkingSpotController>();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(child: Text(vaga.parkingSpotNumber)),
        title: Text('${vaga.brandCar} ${vaga.modelCar} • ${vaga.colorCar}'),
        subtitle: Text(
            'Placa ${vaga.licensePlateCar}\n${vaga.responsibleName} — Apto ${vaga.apartment}, Bloco ${vaga.block}'),
        isThreeLine: true,
        onTap: () => _abrirFormulario(context, vaga: vaga),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          tooltip: 'Excluir',
          onPressed: () async {
            final ok = await Get.dialog<bool>(
              AlertDialog(
                title: const Text('Excluir vaga'),
                content: Text(
                    'Deseja excluir a vaga ${vaga.parkingSpotNumber} (${vaga.licensePlateCar})?'),
                actions: [
                  TextButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text('Cancelar')),
                  FilledButton(
                      onPressed: () => Get.back(result: true),
                      child: const Text('Excluir')),
                ],
              ),
            );
            if (ok == true && vaga.id != null) {
              final erro = await c.excluir(vaga.id!);
              Get.snackbar(erro == null ? 'Sucesso' : 'Erro',
                  erro ?? 'Vaga excluída.',
                  snackPosition: SnackPosition.BOTTOM);
            }
          },
        ),
      ),
    );
  }
}

void _abrirFormulario(BuildContext context, {ParkingSpot? vaga}) {
  final c = Get.find<ParkingSpotController>();
  final formKey = GlobalKey<FormState>();
  final numero = TextEditingController(text: vaga?.parkingSpotNumber);
  final placa = TextEditingController(text: vaga?.licensePlateCar);
  final marca = TextEditingController(text: vaga?.brandCar);
  final modelo = TextEditingController(text: vaga?.modelCar);
  final cor = TextEditingController(text: vaga?.colorCar);
  final responsavel = TextEditingController(text: vaga?.responsibleName);
  final apto = TextEditingController(text: vaga?.apartment);
  final bloco = TextEditingController(text: vaga?.block);

  String? obrigatorio(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null;

  Widget campo(String rotulo, TextEditingController ctrl,
      {int? max, bool caixaAlta = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        maxLength: max,
        textCapitalization:
            caixaAlta ? TextCapitalization.characters : TextCapitalization.none,
        decoration: InputDecoration(
            labelText: rotulo, border: const OutlineInputBorder()),
        validator: obrigatorio,
      ),
    );
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(vaga == null ? 'Nova vaga' : 'Editar vaga',
                  style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              campo('Número da vaga', numero, max: 10),
              campo('Placa', placa, max: 7, caixaAlta: true),
              campo('Marca', marca),
              campo('Modelo', modelo),
              campo('Cor', cor),
              campo('Nome do responsável', responsavel),
              campo('Apartamento', apto),
              campo('Bloco', bloco),
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: c.salvando.value
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              final nova = ParkingSpot(
                                parkingSpotNumber: numero.text.trim(),
                                licensePlateCar:
                                    placa.text.trim().toUpperCase(),
                                brandCar: marca.text.trim(),
                                modelCar: modelo.text.trim(),
                                colorCar: cor.text.trim(),
                                responsibleName: responsavel.text.trim(),
                                apartment: apto.text.trim(),
                                block: bloco.text.trim(),
                              );
                              final erro =
                                  await c.salvar(nova, idEdicao: vaga?.id);
                              if (erro == null) {
                                Get.back();
                                Get.snackbar('Sucesso',
                                    vaga == null
                                        ? 'Vaga cadastrada.'
                                        : 'Vaga atualizada.',
                                    snackPosition: SnackPosition.BOTTOM);
                              } else {
                                Get.snackbar('Erro', erro,
                                    snackPosition: SnackPosition.BOTTOM);
                              }
                            },
                      child: c.salvando.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(vaga == null ? 'Cadastrar' : 'Salvar'),
                    ),
                  )),
            ],
          ),
        ),
      ),
    ),
  );
}
