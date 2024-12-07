import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:walletapp/models/transaction_model.dart';
import 'package:walletapp/models/user_model.dart';
import '../services/database_helper.dart';
import '../utils/constants.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final UserModel user;

  const TransactionHistoryScreen({super.key, required this.user});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  late Future<List<TransactionModel>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _transactionsFuture =
        DatabaseHelper.instance.getUserTransactions(widget.user.id!);
  }

  String _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return '↓';
      case TransactionType.withdrawal:
        return '↑';
      case TransactionType.transfer:
        return '→';
      case TransactionType.payment:
        return '₿';
      default:
        return '•';
    }
  }

  Color _getTransactionColor(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return AppColors.success;
      case TransactionType.withdrawal:
        return AppColors.error;
      case TransactionType.transfer:
        return AppColors.primary;
      case TransactionType.payment:
        return AppColors.warning;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Historique',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<TransactionModel>>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erreur: ${snapshot.error}',
                style: GoogleFonts.poppins(color: AppColors.error),
              ),
            );
          }

          final transactions = snapshot.data!;
          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune transaction',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getTransactionColor(transaction.type)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        _getTransactionIcon(transaction.type),
                        style: TextStyle(
                          fontSize: 24,
                          color: _getTransactionColor(transaction.type),
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    transaction.description,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(transaction.date),
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  trailing: Text(
                    '${transaction.type == TransactionType.deposit ? '+' : '-'} ${transaction.amount.toStringAsFixed(2)} €',
                    style: GoogleFonts.poppins(
                      color: _getTransactionColor(transaction.type),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
