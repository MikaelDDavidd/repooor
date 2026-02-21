import 'package:flutter/material.dart';

class DefaultCategory {
  const DefaultCategory({
    required this.name,
    required this.icon,
    required this.color,
  });

  final String name;
  final IconData icon;
  final Color color;
}

const defaultCategories = [
  DefaultCategory(name: 'Frutas', icon: Icons.apple, color: Color(0xFFE74C3C)),
  DefaultCategory(name: 'Verduras', icon: Icons.eco, color: Color(0xFF27AE60)),
  DefaultCategory(name: 'Carnes', icon: Icons.set_meal, color: Color(0xFFC0392B)),
  DefaultCategory(name: 'Laticínios', icon: Icons.egg_alt, color: Color(0xFFF39C12)),
  DefaultCategory(name: 'Bebidas', icon: Icons.local_drink, color: Color(0xFF3498DB)),
  DefaultCategory(name: 'Limpeza', icon: Icons.cleaning_services, color: Color(0xFF9B59B6)),
  DefaultCategory(name: 'Higiene', icon: Icons.sanitizer, color: Color(0xFF1ABC9C)),
  DefaultCategory(name: 'Grãos', icon: Icons.grain, color: Color(0xFFE67E22)),
  DefaultCategory(name: 'Congelados', icon: Icons.ac_unit, color: Color(0xFF2980B9)),
  DefaultCategory(name: 'Outros', icon: Icons.category, color: Color(0xFF95A5A6)),
];
