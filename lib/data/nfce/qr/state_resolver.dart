import '../../../core/constants/nfce_supported_states.dart';

class NfceStateResolver {
  NfceStateResolver._();

  static const _hostFragments = <String, String>{
    'sefazac': 'AC',
    'sefazal': 'AL',
    'sefazam': 'AM',
    'sefazap': 'AP',
    'sefazba': 'BA',
    'sefazce': 'CE',
    'sefazdf': 'DF',
    'sefazes': 'ES',
    'sefazgo': 'GO',
    'sefazma': 'MA',
    'sefazmg': 'MG',
    'sefazms': 'MS',
    'sefazmt': 'MT',
    'sefazpa': 'PA',
    'sefazpb': 'PB',
    'sefazpe': 'PE',
    'sefazpi': 'PI',
    'sefazpr': 'PR',
    'sefazrj': 'RJ',
    'sefazrn': 'RN',
    'sefazro': 'RO',
    'sefazrr': 'RR',
    'sefazrs': 'RS',
    'sefazsc': 'SC',
    'sefazse': 'SE',
    'sefazsp': 'SP',
    'sefazto': 'TO',
    'fazenda.ac.gov': 'AC',
    'fazenda.al.gov': 'AL',
    'fazenda.am.gov': 'AM',
    'fazenda.ap.gov': 'AP',
    'fazenda.ba.gov': 'BA',
    'fazenda.ce.gov': 'CE',
    'fazenda.df.gov': 'DF',
    'fazenda.es.gov': 'ES',
    'fazenda.go.gov': 'GO',
    'fazenda.ma.gov': 'MA',
    'fazenda.mg.gov': 'MG',
    'fazenda.ms.gov': 'MS',
    'fazenda.mt.gov': 'MT',
    'fazenda.pa.gov': 'PA',
    'fazenda.pb.gov': 'PB',
    'fazenda.pe.gov': 'PE',
    'fazenda.pi.gov': 'PI',
    'fazenda.pr.gov': 'PR',
    'fazenda.rj.gov': 'RJ',
    'fazenda.rn.gov': 'RN',
    'fazenda.ro.gov': 'RO',
    'fazenda.rr.gov': 'RR',
    'fazenda.rs.gov': 'RS',
    'fazenda.sc.gov': 'SC',
    'fazenda.se.gov': 'SE',
    'fazenda.sp.gov': 'SP',
    'fazenda.to.gov': 'TO',
  };

  static String? resolve({required String rawUrl, required String chave}) {
    final fromHost = _resolveFromHost(rawUrl);
    if (fromHost != null) return fromHost;
    return _resolveFromChave(chave);
  }

  static String? _resolveFromHost(String rawUrl) {
    final lower = rawUrl.toLowerCase();
    for (final entry in _hostFragments.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return null;
  }

  static String? _resolveFromChave(String chave) {
    if (chave.length < 2) return null;
    final code = chave.substring(0, 2);
    return nfceUfByIbgeCode[code];
  }
}
