enum AppUnit {
  kg('kg'),
  g('g'),
  l('L'),
  ml('ml'),
  un('un'),
  pack('pacote'),
  box('caixa'),
  can('lata');

  const AppUnit(this.label);
  final String label;
}
