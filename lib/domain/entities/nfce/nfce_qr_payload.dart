class NfceQrPayload {
  const NfceQrPayload({
    required this.chave,
    required this.uf,
    required this.rawUrl,
    this.tpAmb,
    this.versao,
  });

  final String chave;
  final String uf;
  final String rawUrl;
  final String? tpAmb;
  final String? versao;
}
