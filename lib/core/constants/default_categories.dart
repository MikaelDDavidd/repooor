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
  DefaultCategory(
    name: 'Carnes',
    icon: Icons.set_meal,
    color: Color(0xFFC0392B),
  ),
  DefaultCategory(
    name: 'Laticínios',
    icon: Icons.egg_alt,
    color: Color(0xFFF39C12),
  ),
  DefaultCategory(
    name: 'Padaria',
    icon: Icons.bakery_dining,
    color: Color(0xFFD4A574),
  ),
  DefaultCategory(
    name: 'Café da Manhã',
    icon: Icons.free_breakfast,
    color: Color(0xFFF4A261),
  ),
  DefaultCategory(name: 'Doces', icon: Icons.cookie, color: Color(0xFFE91E63)),
  DefaultCategory(
    name: 'Snacks',
    icon: Icons.fastfood,
    color: Color(0xFFFF5722),
  ),
  DefaultCategory(
    name: 'Massas',
    icon: Icons.dinner_dining,
    color: Color(0xFFFF9800),
  ),
  DefaultCategory(
    name: 'Farinhas',
    icon: Icons.grain,
    color: Color(0xFFD4A76A),
  ),
  DefaultCategory(name: 'Grãos', icon: Icons.grass, color: Color(0xFFE67E22)),
  DefaultCategory(
    name: 'Mercearia',
    icon: Icons.inventory_2,
    color: Color(0xFFE8A838),
  ),
  DefaultCategory(name: 'Temperos', icon: Icons.spa, color: Color(0xFF8D6E63)),
  DefaultCategory(
    name: 'Bebidas',
    icon: Icons.local_drink,
    color: Color(0xFF3498DB),
  ),
  DefaultCategory(
    name: 'Congelados',
    icon: Icons.ac_unit,
    color: Color(0xFF2980B9),
  ),
  DefaultCategory(
    name: 'Limpeza',
    icon: Icons.cleaning_services,
    color: Color(0xFF9B59B6),
  ),
  DefaultCategory(
    name: 'Higiene',
    icon: Icons.sanitizer,
    color: Color(0xFF1ABC9C),
  ),
  DefaultCategory(name: 'Pet', icon: Icons.pets, color: Color(0xFF8ECAE6)),
  DefaultCategory(
    name: 'Bebê',
    icon: Icons.child_care,
    color: Color(0xFFA8DADC),
  ),
  DefaultCategory(
    name: 'Outros',
    icon: Icons.category,
    color: Color(0xFF95A5A6),
  ),
];
