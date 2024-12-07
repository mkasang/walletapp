class UserModel {
  final int? id;
  final String username;
  final String email;
  final String password;
  double balance;

  UserModel({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    this.balance = 0.0,
  });

  // Convertir un User en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'balance': balance,
    };
  }

  // Créer un User à partir d'un Map de la base de données
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      balance: map['balance'],
    );
  }

  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? password,
    double? balance,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      balance: balance ?? this.balance,
    );
  }
}
