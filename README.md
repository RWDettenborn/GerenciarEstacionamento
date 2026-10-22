# estacionamento

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Estacionamento (Parking Spot)

App Flutter + GetX que consome a API REST `https://parking-spot-pmfd.onrender.com`
(collection Postman "Parking Spot"). Fluxo: API > Service > Model > Controller > Tela.

- CRUD completo: listar, cadastrar, consultar por ID, atualizar (PUT) e excluir (DELETE)
- Listagem ordenada via `/parking-spot/order` (menu de ordenação)
- Valores de vaga, placa e apartamento+bloco devem ser únicos (validação do backend)
- Rodar: `flutter pub get && flutter run`


## Versão local (sem API)

O sistema não depende mais da API do Postman. `lib/services/service.dart` reproduz
as 6 operações e as regras do backend (UUID, data de cadastro, unicidade de vaga,
placa e apartamento+bloco) salvando os dados no aparelho com `shared_preferences`.
O service antigo (HTTP) ficou guardado em `lib/services/service_api.dart` apenas para consulta.
