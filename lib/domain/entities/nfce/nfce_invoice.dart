import 'nfce_raw_item.dart';

class NfceInvoice {
  const NfceInvoice({
    required this.chave,
    required this.issuedAt,
    required this.emitenteNome,
    required this.emitenteCnpj,
    required this.uf,
    required this.items,
  });

  final String chave;
  final DateTime issuedAt;
  final String emitenteNome;
  final String emitenteCnpj;
  final String uf;
  final List<NfceRawItem> items;

  double? get totalPrice {
    final priced = items.where((i) => i.unitPrice != null);
    if (priced.isEmpty) return null;
    return priced.fold<double>(0, (sum, i) => sum + i.totalPrice!);
  }
}
