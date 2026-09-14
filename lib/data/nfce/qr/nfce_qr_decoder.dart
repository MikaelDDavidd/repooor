import '../../../domain/entities/nfce/nfce_qr_payload.dart';
import '../../../domain/exceptions/nfce_exception.dart';
import 'state_resolver.dart';

class NfceQrDecoder {
  NfceQrDecoder._();

  static final _keyRegex = RegExp(r'(\d{44})');

  static NfceQrPayload decode(String rawText) {
    final trimmed = rawText.trim();
    if (trimmed.isEmpty) {
      throw const NfceInvalidQrException('QR Code vazio');
    }
    if (!_looksLikeUrl(trimmed)) {
      throw const NfceInvalidQrException('QR não é uma URL de NFC-e');
    }

    final chave = _extractChave(trimmed);
    if (chave == null) {
      throw const NfceInvalidQrException(
        'Chave de acesso de 44 dígitos não encontrada',
      );
    }

    final uf = NfceStateResolver.resolve(rawUrl: trimmed, chave: chave);
    if (uf == null) {
      throw const NfceInvalidQrException('Estado emissor não identificado');
    }

    final params = _extractParams(trimmed);
    return NfceQrPayload(
      chave: chave,
      uf: uf,
      rawUrl: trimmed,
      tpAmb: params['tpAmb'],
      versao: params['nVersao'] ?? params['versao'],
    );
  }

  static bool _looksLikeUrl(String text) {
    final lower = text.toLowerCase();
    return lower.startsWith('http://') || lower.startsWith('https://');
  }

  static String? _extractChave(String text) {
    final match = _keyRegex.firstMatch(text);
    return match?.group(1);
  }

  static Map<String, String> _extractParams(String url) {
    final result = <String, String>{};
    final uri = Uri.tryParse(url);
    if (uri == null) return result;
    result.addAll(uri.queryParameters);

    final pParam = uri.queryParameters['p'];
    if (pParam != null && pParam.contains('|')) {
      final parts = pParam.split('|');
      if (parts.length >= 2) result['nVersao'] = parts[1];
      if (parts.length >= 3) result['tpAmb'] = parts[2];
    }
    return result;
  }
}
