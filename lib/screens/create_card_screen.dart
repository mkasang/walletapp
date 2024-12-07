// lib/screens/create_card_screen.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:walletapp/models/card_model.dart';
import 'package:walletapp/models/user_model.dart';
import 'package:walletapp/services/database_helper.dart';

class CreateCardScreen extends StatefulWidget {
  final UserModel user;

  const CreateCardScreen({super.key, required this.user});

  @override
  State<CreateCardScreen> createState() => _CreateCardScreenState();
}

class _CreateCardScreenState extends State<CreateCardScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _generatedCardNumber = '';
  String _generatedCVV = '';
  String _expiryDate = '';

  @override
  void initState() {
    super.initState();
    _generateCardDetails();
  }

  void _generateCardDetails() {
    // Générer un numéro de carte aléatoire
    final cardNumber = List.generate(
            16,
            (index) =>
                (index % 4 == 0 ? ' ' : '') + (Random().nextInt(10)).toString())
        .join();
    final cvv = List.generate(3, (index) => Random().nextInt(10)).join();

    // Date d'expiration (3 ans à partir de maintenant)
    final expiry = DateTime.now().add(const Duration(days: 1095));
    final expiryDate =
        '${expiry.month.toString().padLeft(2, '0')}/${expiry.year.toString().substring(2)}';

    setState(() {
      _generatedCardNumber = cardNumber.trim();
      _generatedCVV = cvv;
      _expiryDate = expiryDate;
    });
  }

  Future<void> _createCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final card = WalletCard(
        id: 0,
        userId: widget.user.id!,
        cardNumber: _generatedCardNumber,
        cardHolderName: widget.user.username.toUpperCase(),
        expiryDate: _expiryDate,
        cvv: _generatedCVV,
      );

      await DatabaseHelper.instance.createCard(card);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Carte créée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Créer une carte',
          style: GoogleFonts.poppins(),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Aperçu de la carte
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue, Colors.blueAccent],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Carte virtuelle',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const Icon(
                          Icons.credit_card,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _generatedCardNumber.replaceAllMapped(
                        RegExp(r'.{4}'),
                        (match) => '${match.group(0)} ',
                      ),
                      style: GoogleFonts.sourceCodePro(
                        color: Colors.white,
                        fontSize: 22,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.user.username.toUpperCase(),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _expiryDate,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _createCard,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                        'Créer la carte',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
