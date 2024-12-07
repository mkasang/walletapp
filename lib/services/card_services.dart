import 'dart:math';

class CardService {
  static String generateCardNumber() {
    final random = Random();
    const prefix = '4242'; // Préfixe fixe pour les cartes
    String cardNumber = prefix;

    // Générer les 12 chiffres restants
    for (int i = 0; i < 12; i++) {
      cardNumber += random.nextInt(10).toString();
    }

    return cardNumber;
  }

  static String generateCVV() {
    final random = Random();
    String cvv = '';
    for (int i = 0; i < 3; i++) {
      cvv += random.nextInt(10).toString();
    }
    return cvv;
  }

  static String generateExpiryDate() {
    final now = DateTime.now();
    final expiryYear = now.year + 4; // Validité de 4 ans
    final month = now.month.toString().padLeft(2, '0');
    return '$month/${expiryYear.toString().substring(2)}';
  }
}
