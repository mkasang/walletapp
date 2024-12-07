import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:walletapp/models/transaction_model.dart';
import 'package:walletapp/models/user_model.dart';
import '../services/database_helper.dart';
import '../utils/constants.dart';

class BillPaymentScreen extends StatefulWidget {
  final UserModel user;

  const BillPaymentScreen({super.key, required this.user});

  @override
  State<BillPaymentScreen> createState() => _BillPaymentScreenState();
}

class _BillPaymentScreenState extends State<BillPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _referenceController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedBillType = 'Électricité';
  bool _isLoading = false;

  final List<String> _billTypes = [
    'Électricité',
    'Eau',
    'Internet',
    'Téléphone',
    'Autre',
  ];

  Future<void> _payBill() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final amount = double.parse(_amountController.text);
        if (amount > widget.user.balance) {
          throw Exception('Solde insuffisant');
        }

        final transaction = TransactionModel(
          userId: widget.user.id!,
          type: TransactionType.payment,
          amount: amount,
          description: 'Paiement $_selectedBillType',
          date: DateTime.now(),
          billReference: _referenceController.text,
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
          'Paiement de factures',
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
              // Solde disponible
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

              // Type de facture
              DropdownButtonFormField<String>(
                value: _selectedBillType,
                decoration: InputDecoration(
                  labelText: 'Type de facture',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.receipt_long),
                ),
                items: _billTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBillType = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Référence de la facture
              TextFormField(
                controller: _referenceController,
                decoration: InputDecoration(
                  labelText: 'Référence de la facture',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.numbers),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la référence de la facture';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Montant
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

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _payBill,
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
                        'Payer la facture',
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
