import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import '../../../domain/entities/nfce/nfce_invoice.dart';
import '../../../domain/entities/nfce/nfce_qr_payload.dart';
import '../../../domain/entities/nfce/nfce_raw_item.dart';
import '../../../domain/exceptions/nfce_exception.dart';
import 'helpers/dom_extractors.dart';
import 'nfce_parser.dart';

class PbNfceParser implements NfceParser {
  const PbNfceParser();

  @override
  String get uf => 'PB';

  @override
  NfceInvoice parse(String html, NfceQrPayload payload) {
    final document = html_parser.parse(html);
    final root = document.documentElement ?? document.body;
    if (root == null) {
      throw const NfceParseException(message: 'HTML vazio do SEFAZ-PB');
    }
    final items = _extractItems(root);
    if (items.isEmpty) {
      throw NfceParseException(
        message: 'Nenhum item encontrado',
        snippet: root.outerHtml.substring(
          0,
          root.outerHtml.length.clamp(0, 200),
        ),
      );
    }
    return NfceInvoice(
      chave: payload.chave,
      issuedAt: _extractIssuedAt(root) ?? DateTime.now(),
      emitenteNome: _extractEmitente(root) ?? 'Estabelecimento',
      emitenteCnpj: _extractCnpj(root) ?? '',
      uf: 'PB',
      items: items,
    );
  }

  String? _extractEmitente(Element root) {
    final byClass = DomExtractors.textOfFirst(root, '.txtTopo');
    if (byClass != null) return DomExtractors.stripWhitespace(byClass);
    return DomExtractors.textOfFirst(root, '#u20');
  }

  String? _extractCnpj(Element root) {
    final match = RegExp(
      r'\d{2}\.\d{3}\.\d{3}/\d{4}-\d{2}',
    ).firstMatch(root.text);
    return match?.group(0);
  }

  DateTime? _extractIssuedAt(Element root) {
    final match = RegExp(
      r'Emiss[ãa]o[^<]*?(\d{2}/\d{2}/\d{4}(?:\s+\d{2}:\d{2}(?::\d{2})?)?)',
      caseSensitive: false,
    ).firstMatch(root.text);
    if (match == null) return null;
    return DomExtractors.parseBrDateTime(match.group(1)!);
  }

  List<NfceRawItem> _extractItems(Element root) {
    final rows = root.querySelectorAll('#tabResult tr');
    return rows.map(_rowToItem).whereType<NfceRawItem>().toList();
  }

  NfceRawItem? _rowToItem(Element row) {
    final name = _extractName(row);
    if (name == null) return null;
    final text = row.text;
    final qty = _extractField(text, r'Qtde\.?\s*[:]\s*([\d.,]+)');
    final unit = _extractField(text, r'UN\s*[:]\s*([A-Za-zÀ-ú]+)');
    final unitPrice = _extractField(text, r'Vl\.?\s*Unit\.?\s*[:]\s*([\d.,]+)');
    final code = _extractField(text, r'C[óo]digo\s*[:]\s*(\d+)');
    if (qty == null) return null;
    return NfceRawItem(
      rawName: name,
      quantity: DomExtractors.parseBrDecimal(qty),
      unitRaw: unit ?? 'UN',
      code: code,
      unitPrice: unitPrice == null
          ? null
          : DomExtractors.parseBrDecimal(unitPrice),
    );
  }

  String? _extractName(Element row) {
    final nameSpan =
        row.querySelector('.txtTit2') ?? row.querySelector('.txtTit');
    if (nameSpan == null) return null;
    final cleaned = DomExtractors.stripWhitespace(nameSpan.text);
    return cleaned.isEmpty ? null : cleaned;
  }

  String? _extractField(String text, String pattern) {
    return RegExp(
      pattern,
      caseSensitive: false,
    ).firstMatch(text)?.group(1)?.trim();
  }
}
