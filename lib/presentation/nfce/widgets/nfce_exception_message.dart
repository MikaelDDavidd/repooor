import '../../../domain/exceptions/nfce_exception.dart';

String nfceExceptionToUserMessage(NfceException e) {
  return switch (e) {
    NfceInvalidQrException() => e.message,
    NfceUnsupportedStateException() =>
      'NFC-e de ${e.uf} ainda não suportada. Crie a compra manualmente.',
    NfceFetchException() => switch (e.reason) {
      NfceFetchFailureReason.network => 'Sem conexão. Verifique sua internet.',
      NfceFetchFailureReason.timeout =>
        'O SEFAZ demorou para responder. Tente novamente.',
      NfceFetchFailureReason.httpError =>
        'O portal SEFAZ devolveu um erro. Tente novamente em instantes.',
      NfceFetchFailureReason.sefazUnavailable =>
        'Portal SEFAZ indisponível. Tente novamente mais tarde.',
    },
    NfceParseException() =>
      'Não conseguimos ler os itens dessa nota. Tente novamente ou crie manualmente.',
    NfceImportException() =>
      'Erro ao importar a compra. Os dados na tela foram preservados.',
    CameraPermissionDeniedException() =>
      'Permissão de câmera negada. Abra as configurações para liberar.',
  };
}
