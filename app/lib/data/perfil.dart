import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Avatares prontos (ilustrações 3D) que a pessoa pode escolher.
const avataresProntos = [
  'assets/avatares/avatar-1.png',
  'assets/avatares/avatar-2.png',
  'assets/avatares/avatar-3.png',
  'assets/avatares/avatar-4.png',
];

/// De onde vem a foto do perfil.
enum OrigemFoto { camera, galeria }

/// A câmera foi negada nos Ajustes do celular.
class CameraNegada implements Exception {}

/// Foto ou avatar do perfil. Versão simulada (sem backend): fica só na
/// memória do app.
class PerfilRepo extends ChangeNotifier {
  PerfilRepo() {
    restaurar();
  }

  /// Avatar pronto escolhido (caminho do asset).
  String? avatar;

  /// Foto tirada ou escolhida da galeria, já recortada.
  Uint8List? foto;

  /// Permissão de câmera no celular (para simular "Câmera desativada").
  bool cameraPermitida = true;

  /// Abre a câmera ou a galeria e devolve a imagem (ou null se cancelar).
  /// Troque nos testes para não abrir o seletor de verdade.
  Future<Uint8List?> Function(OrigemFoto origem) escolherImagem =
      _escolherComImagePicker;

  bool get temImagem => avatar != null || foto != null;

  void restaurar() {
    avatar = avataresProntos.first;
    foto = null;
    cameraPermitida = true;
    escolherImagem = _escolherComImagePicker;
    notifyListeners();
  }

  void usarAvatar(String caminho) {
    avatar = caminho;
    foto = null;
    notifyListeners();
  }

  void usarFoto(Uint8List bytes) {
    foto = bytes;
    avatar = null;
    notifyListeners();
  }

  void remover() {
    avatar = null;
    foto = null;
    notifyListeners();
  }

  /// Pede a imagem; lança [CameraNegada] se a câmera estiver bloqueada.
  Future<Uint8List?> pedirImagem(OrigemFoto origem) async {
    if (origem == OrigemFoto.camera && !cameraPermitida) throw CameraNegada();
    return escolherImagem(origem);
  }
}

Future<Uint8List?> _escolherComImagePicker(OrigemFoto origem) async {
  try {
    final arquivo = await ImagePicker().pickImage(
      source: origem == OrigemFoto.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      preferredCameraDevice: CameraDevice.front,
      maxWidth: 1200,
    );
    return await arquivo?.readAsBytes();
  } on Exception catch (e) {
    // iOS/Android: permissão negada pela pessoa.
    if (origem == OrigemFoto.camera && '$e'.contains('access_denied')) {
      throw CameraNegada();
    }
    rethrow;
  }
}

/// Instância única usada pelo app enquanto não há backend.
final perfil = PerfilRepo();
