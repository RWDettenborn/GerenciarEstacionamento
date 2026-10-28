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


## Fonte de dados: API do Postman

`lib/services/service.dart` consome a API da collection Postman
(`https://parking-spot-pmfd.onrender.com`). A versão que salva os dados no aparelho
(`shared_preferences`) está em `lib/services/service_local.dart`: para usá-la,
troque os nomes dos dois arquivos (ou o import no controller).
Obs.: no Chrome (Flutter Web) a API pode ser bloqueada por CORS; prefira Windows ou Android.
