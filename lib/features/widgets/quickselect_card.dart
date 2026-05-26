//unfinished, needs assets

import 'package:flutter/material.dart';
/*import 'package:flutter/gestures.dart';
import 'package:upesov/theme/upesov_theme.dart';
import 'package:upesov/features/pages/dashboard.dart';
import 'package:upesov/features/pages/wallets.dart';
import 'package:upesov/features/pages/budget.dart';
import 'package:upesov/features/pages/manage.dart';*/
import 'package:upesov/features/model/quick_select.dart';

class QuickSelectCard extends StatelessWidget {
  final QuickSelectItem item;
  final VoidCallback onTap;

  const QuickSelectCard({
    super.key, 
    required this.item, 
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: ListTile(
        leading: Icon(_getIcon(item.iconName), color: Colors.teal),
        title: Text(item.name, style: const TextStyle(fontSize: 14)),
        trailing: Text(
          '₱${item.price.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onTap: onTap,
      ),
    );
  }

  // Helper method to map your string data to actual Flutter icons
  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'transit': return Icons.directions_bus;
      case 'food': return Icons.restaurant;
      case 'school': return Icons.edit;
      default: return Icons.monetization_on;
    }
  }
}