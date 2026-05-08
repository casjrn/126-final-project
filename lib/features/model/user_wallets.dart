class UserWallets{
    final String name;
    final double balance;
    final String type; // e.g., "Bank Account", "Credit Card", "Cash"
    
    UserWallets({
        required this.name,
        required this.balance,
        required this.type,
    });
}