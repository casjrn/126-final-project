class UserData {
  final String email;
  final String password;
  final String username;

  final int cashBalance;
  final int targetSavings;

  UserData({
    required this.email,
    required this.password,
    required this.username,

    this.cashBalance = 0,
    required this.targetSavings, 
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData (
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      username: json['username'] ?? '',
      
      cashBalance: json['physical money on hand'] ?? 0,
      targetSavings: json['target savings'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'username': username,

      'cash_balance': cashBalance,
      'target_savings': targetSavings,
    };
  }

}