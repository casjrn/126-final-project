class QuickSelectItem {
  String id;          // Unique ID to help when editing or deleting
  String name;        // e.g., "Trike Fare"
  double price;       // e.g., 15.00
  String category;    // e.g., "Transportation"
  String iconName;    // To determine which icon to show (e.g., 'tricycle', 'bus', 'food')

  QuickSelectItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.iconName,
  });
}