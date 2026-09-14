import 'package:xml/xml.dart';
import '../../../domain/entities/nfce/nfce_invoice.dart';
import '../../../domain/entities/nfce/nfce_qr_payload.dart';
import '../../../domain/entities/nfce/nfce_raw_item.dart';
import '../../../domain/exceptions/nfce_exception.dart';

class NfceXmlParser {
  const NfceXmlParser();

  static final _xmlStart = RegExp(
    r'^\s*<(\?xml|nfeProc|NFe)\b',
    caseSensitive: false,
  );
  static const _noGtin = 'SEM GTIN';

  static bool canParse(String content) => _xmlStart.hasMatch(content);

  NfceInvoice parse(String xml, NfceQrPayload payload) {
    final document = _parseDocument(xml);
    _throwIfSefazError(document);

    final infNFe = _firstElement(document, 'infNFe');
    if (infNFe == null) {
      throw const NfceParseException(message: 'XML sem dados da nota');
    }

    final items = _extractItems(infNFe);
    if (items.isEmpty) {
      throw const NfceParseException(message: 'Nenhum item encontrado');
    }

    return NfceInvoice(
      chave: _extractChave(infNFe) ?? payload.chave,
      issuedAt: _extractIssuedAt(infNFe) ?? DateTime.now(),
      emitenteNome: _extractEmitenteNome(infNFe) ?? 'Estabelecimento',
      emitenteCnpj: _extractEmitenteCnpj(infNFe) ?? '',
      uf: _extractUf(infNFe) ?? payload.uf,
      items: items,
    );
  }

  XmlDocument _parseDocument(String xml) {
    try {
      return XmlDocument.parse(xml);
    } on XmlException catch (e) {
      throw NfceParseException(
        message: 'XML inválido do SEFAZ',
        snippet: e.message,
      );
    }
  }

  void _throwIfSefazError(XmlDocument document) {
    final erro = _textOf(_firstElement(document, 'erro'));
    if (erro != null) throw NfceParseException(message: erro);
  }

  List<NfceRawItem> _extractItems(XmlElement infNFe) {
    return infNFe
        .findElements('det')
        .map(_detToItem)
        .whereType<NfceRawItem>()
        .toList();
  }

  NfceRawItem? _detToItem(XmlElement det) {
    final prod = det.findElements('prod').firstOrNull;
    if (prod == null) return null;
    final name = _childText(prod, 'xProd');
    final quantity = _parseDecimal(_childText(prod, 'qCom'));
    if (name == null || quantity == null) return null;
    return NfceRawItem(
      rawName: name,
      quantity: quantity,
      unitRaw: _childText(prod, 'uCom') ?? 'UN',
      code: _extractCode(prod),
      unitPrice: _parseDecimal(_childText(prod, 'vUnCom')),
    );
  }

  String? _extractCode(XmlElement prod) {
    final ean = _childText(prod, 'cEAN');
    if (ean != null && ean.toUpperCase() != _noGtin) return ean;
    return _childText(prod, 'cProd');
  }

  String? _extractChave(XmlElement infNFe) {
    final id = infNFe.getAttribute('Id');
    if (id == null) return null;
    final digits = id.replaceAll(RegExp(r'\D'), '');
    return digits.length == 44 ? digits : null;
  }

  DateTime? _extractIssuedAt(XmlElement infNFe) {
    final ide = infNFe.findElements('ide').firstOrNull;
    if (ide == null) return null;
    final raw = _childText(ide, 'dhEmi') ?? _childText(ide, 'dEmi');
    if (raw == null) return null;
    return DateTime.tryParse(raw)?.toLocal();
  }

  String? _extractEmitenteNome(XmlElement infNFe) {
    final emit = infNFe.findElements('emit').firstOrNull;
    if (emit == null) return null;
    return _childText(emit, 'xFant') ?? _childText(emit, 'xNome');
  }

  String? _extractEmitenteCnpj(XmlElement infNFe) {
    final emit = infNFe.findElements('emit').firstOrNull;
    if (emit == null) return null;
    final raw = _childText(emit, 'CNPJ');
    if (raw == null) return null;
    return _formatCnpj(raw.replaceAll(RegExp(r'\D'), ''));
  }

  String? _extractUf(XmlElement infNFe) {
    final emit = infNFe.findElements('emit').firstOrNull;
    final enderEmit = emit?.findElements('enderEmit').firstOrNull;
    if (enderEmit == null) return null;
    return _childText(enderEmit, 'UF')?.toUpperCase();
  }

  String _formatCnpj(String digits) {
    if (digits.length != 14) return digits;
    return '${digits.substring(0, 2)}.${digits.substring(2, 5)}.'
        '${digits.substring(5, 8)}/${digits.substring(8, 12)}-${digits.substring(12)}';
  }

  double? _parseDecimal(String? raw) =>
      raw == null ? null : double.tryParse(raw.replaceAll(',', '.'));

  XmlElement? _firstElement(XmlNode node, String name) =>
      node.findAllElements(name).firstOrNull;

  String? _childText(XmlElement parent, String name) =>
      _textOf(parent.findElements(name).firstOrNull);

  String? _textOf(XmlElement? element) {
    final text = element?.innerText.trim();
    return text == null || text.isEmpty ? null : text;
  }
}
