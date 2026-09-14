import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../domain/exceptions/nfce_exception.dart';

class NfceRemoteDs {
  NfceRemoteDs({http.Client? client, Duration? timeout})
    : _client = client ?? http.Client(),
      _timeout = timeout ?? const Duration(seconds: 15);

  final http.Client _client;
  final Duration _timeout;

  static const _userAgent =
      'Repooor/1.0 (NFC-e consumer; Flutter; +https://github.com/repooor)';

  Future<String> fetchHtml(String url) async {
    try {
      final response = await _client
          .get(Uri.parse(url), headers: const {'User-Agent': _userAgent})
          .timeout(_timeout);
      if (response.statusCode >= 500) {
        throw const NfceFetchException(
          reason: NfceFetchFailureReason.sefazUnavailable,
        );
      }
      if (response.statusCode != 200) {
        throw const NfceFetchException(
          reason: NfceFetchFailureReason.httpError,
        );
      }
      return response.body;
    } on TimeoutException {
      throw const NfceFetchException(reason: NfceFetchFailureReason.timeout);
    } on SocketException {
      throw const NfceFetchException(reason: NfceFetchFailureReason.network);
    } on http.ClientException {
      throw const NfceFetchException(reason: NfceFetchFailureReason.network);
    }
  }
}
