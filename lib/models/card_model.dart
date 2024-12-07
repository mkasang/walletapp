class WalletCard {
  final int? id;
  final int userId;
  final String cardNumber;
  final String cardHolderName;
  final String expiryDate;
  final String cvv;

  WalletCard({
    this.id,
    required this.userId,
    required this.cardNumber,
    required this.cardHolderName,
    required this.expiryDate,
    required this.cvv,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'card_number': cardNumber,
      'card_holder_name': cardHolderName,
      'expiry_date': expiryDate,
      'cvv': cvv,
    };
  }

  factory WalletCard.fromMap(Map<String, dynamic> map) {
    return WalletCard(
      id: map['id'],
      userId: map['user_id'],
      cardNumber: map['card_number'],
      cardHolderName: map['card_holder_name'],
      expiryDate: map['expiry_date'],
      cvv: map['cvv'],
    );
  }
}
