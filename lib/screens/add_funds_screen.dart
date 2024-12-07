// lib/screens/add_funds_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:walletapp/models/notifications.dart';
import 'package:walletapp/models/transaction_model.dart';
import 'package:walletapp/models/user_model.dart';
import 'package:walletapp/services/database_helper.dart';

class AddFundsScreen extends StatefulWidget {
  final UserModel user;

  const AddFundsScreen({super.key, required this.user});

  @override
  State<AddFundsScreen> createState() => _AddFundsScreenState();
}

class _AddFundsScreenState extends State<AddFundsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _isLoading = false;

  Future<void> _addFunds() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text);
      final db = DatabaseHelper.instance;

      // Créer la transaction
      final transaction = TransactionModel(
        id: 0,
        userId: widget.user.id!,
        type: TransactionType.deposit,
        amount: amount,
        description: 'Ajout de fonds',
        date: DateTime.now(),
        status: TransactionStatus.completed,
        recipientId: null,
        billReference: null,
      );

      // Mettre à jour le solde de l'utilisateur
      final newBalance = widget.user.balance + amount;
      await db.updateUserBalance(widget.user.id!, newBalance);

      // Enregistrer la transaction
      await db.createTransaction(transaction);

      // Créer une notification
      await db.createNotification(WalletNotification(
        id: 0,
        userId: widget.user.id!,
        title: 'Fonds ajoutés',
        message:
            'Vous avez ajouté ${amount.toStringAsFixed(2)}€ à votre compte',
        date: DateTime.now(),
        type: NotificationType.transaction,
        isRead: false,
      ));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fonds ajoutés avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(
            context, true); // true indique que les fonds ont été ajoutés
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
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ajouter des fonds',
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
              Text(
                'Montant à ajouter',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixText: '€ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'Entrez le montant',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un montant';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null) {
                    return 'Montant invalide';
                  }
                  if (amount <= 0) {
                    return 'Le montant doit être supérieur à 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _addFunds,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                        'Ajouter les fonds',
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
