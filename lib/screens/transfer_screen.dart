import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:walletapp/models/transaction_model.dart';
import 'package:walletapp/models/user_model.dart';
import '../services/database_helper.dart';
import '../utils/constants.dart';

class TransferScreen extends StatefulWidget {
  final UserModel user;

  const TransferScreen({super.key, required this.user});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  Future<void> _makeTransfer() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final amount = double.parse(_amountController.text);
        if (amount > widget.user.balance) {
          throw Exception('Solde insuffisant');
        }

        // Créer la transaction
        final transaction = TransactionModel(
          userId: widget.user.id!,
          type: TransactionType.transfer,
          amount: amount,
          description: _descriptionController.text,
          date: DateTime.now(),
          recipientId: _recipientController.text,
        );

        await DatabaseHelper.instance.createTransaction(transaction);
        await DatabaseHelper.instance.updateUserBalance(
          widget.user.id!,
          widget.user.balance - amount,
        );

        if (!mounted) return;
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }

      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Transfert',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Solde actuel
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Solde disponible',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.user.balance.toStringAsFixed(2)} €',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Formulaire de transfert
              TextFormField(
                controller: _recipientController,
                decoration: InputDecoration(
                  labelText: 'Identifiant du destinataire',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer l\'identifiant du destinataire';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Montant',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.euro),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un montant';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Veuillez entrer un montant valide';
                  }
                  if (amount > widget.user.balance) {
                    return 'Solde insuffisant';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.description_outlined),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _makeTransfer,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Effectuer le transfert',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
