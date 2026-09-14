enum NfceFetchFailureReason { network, timeout, httpError, sefazUnavailable }

sealed class NfceException implements Exception {
  const NfceException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class NfceInvalidQrException extends NfceException {
  const NfceInvalidQrException([super.message = 'QR Code inválido']);
}

class NfceUnsupportedStateException extends NfceException {
  const NfceUnsupportedStateException({required this.uf, String? message})
    : super(message ?? 'Estado $uf ainda não suportado');

  final String uf;
}

class NfceFetchException extends NfceException {
  const NfceFetchException({required this.reason, String? message})
    : super(message ?? 'Falha ao buscar nota');

  final NfceFetchFailureReason reason;
}

class NfceParseException extends NfceException {
  const NfceParseException({String? message, this.snippet})
    : super(message ?? 'Não conseguimos ler a nota');

  final String? snippet;
}

class NfceImportException extends NfceException {
  const NfceImportException([super.message = 'Falha ao importar a compra']);
}

class CameraPermissionDeniedException extends NfceException {
  const CameraPermissionDeniedException({
    required this.permanent,
    String? message,
  }) : super(message ?? 'Permissão de câmera negada');

  final bool permanent;
}
