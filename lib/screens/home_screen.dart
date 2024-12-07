// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:walletapp/models/card_model.dart';
import 'package:walletapp/models/notifications.dart';
import 'package:walletapp/models/transaction_model.dart';
import 'package:walletapp/models/user_model.dart';
import 'package:walletapp/screens/add_funds_screen.dart';
import 'package:walletapp/screens/bill_payement_screen.dart';
import 'package:walletapp/screens/create_card_screen.dart';
import 'package:walletapp/screens/profil_screen.dart';
import 'package:walletapp/screens/transfer_screen.dart';
import 'package:walletapp/screens/transfert_history_screen.dart';
import 'package:walletapp/services/database_helper.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  WalletCard? _userCard;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<TransactionModel> _recentTransactions = [];
  List<WalletNotification> _notifications = [];
  bool _isLoading = true;

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final transactions = await _dbHelper.getUserTransactions(widget.user.id!);
      final notifications =
          await _dbHelper.getUserNotifications(widget.user.id!);

      setState(() {
        _recentTransactions = transactions.take(5).toList();
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      // Gérer les erreurs
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserCard();
    _loadData();
  }

  Future<void> _loadUserCard() async {
    setState(() => _isLoading = true);
    try {
      final card = await DatabaseHelper.instance.getUserCard(widget.user.id!);
      setState(() => _userCard = card);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // En-tête avec salutation
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bonjour,',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            widget.user.username,
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                user: widget.user,
                                card: _userCard,
                              ),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.blue,
                          child: Text(
                            widget.user.username[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Carte de solde
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
                            'Solde disponible',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                            ),
                          ),
                          const Icon(
                            Icons.account_balance_wallet,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        NumberFormat.currency(
                          locale: 'fr_FR',
                          symbol: '€',
                          decimalDigits: 2,
                        ).format(widget.user.balance),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
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
                              letterSpacing: 2,
                            ),
                          ),
                          if (_isLoading)
                            const CircularProgressIndicator(color: Colors.white)
                          else if (_userCard != null)
                            Text(
                              _userCard!.cardNumber.replaceAllMapped(
                                RegExp(r'.{4}'),
                                (match) => '${match.group(0)} ',
                              ),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            )
                          else
                            TextButton(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CreateCardScreen(user: widget.user),
                                  ),
                                );
                                if (result == true) {
                                  _loadUserCard();
                                }
                              },
                              child: Text(
                                'Créer une carte',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions rapides
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickAction(
                        context,
                        icon: Icons.add,
                        label: 'Ajouter',
                        color: Colors.green,
                        onTap: () {
                          final result = Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddFundsScreen(user: widget.user),
                            ),
                          );
                          if (result == true) {
                            // Recharger les données si des fonds ont été ajoutés
                            _loadData();
                          }
                        },
                      ),
                      _buildQuickAction(
                        context,
                        icon: Icons.send,
                        label: 'Envoyer',
                        color: Colors.blue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TransferScreen(user: widget.user),
                            ),
                          );
                        },
                      ),
                      _buildQuickAction(
                        context,
                        icon: Icons.payment,
                        label: 'Payer',
                        color: Colors.orange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BillPaymentScreen(user: widget.user),
                            ),
                          );
                        },
                      ),
                      _buildQuickAction(
                        context,
                        icon: Icons.history,
                        label: 'Historique',
                        color: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TransactionHistoryScreen(user: widget.user),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Transactions récentes
                _buildRecentTransactions(),

                // Notifications
                _buildNotifications(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transactions récentes',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TransactionHistoryScreen(user: widget.user),
                    ),
                  );
                },
                child: const Text('Voir tout'),
              ),
            ],
          ),
        ),
        if (_recentTransactions.isEmpty)
          Center(
            child: Text(
              'Aucune transaction récente',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentTransactions.length,
            itemBuilder: (context, index) {
              final transaction = _recentTransactions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: transaction.type == 'credit'
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    child: Icon(
                      transaction.type == 'credit'
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: transaction.type == 'credit'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  title: Text(
                    transaction.description,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    DateFormat('dd/MM/yyyy HH:mm')
                        .format(DateTime.parse(transaction.date.toString())),
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  trailing: Text(
                    '${transaction.type == 'credit' ? '+' : '-'}${NumberFormat.currency(
                      locale: 'fr_FR',
                      symbol: '€',
                    ).format(transaction.amount)}',
                    style: GoogleFonts.poppins(
                      color: transaction.type == 'credit'
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildNotifications() {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'Notifications',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (_notifications.isEmpty)
          Center(
            child: Text(
              'Aucune notification',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _notifications.length > 3 ? 3 : _notifications.length,
            itemBuilder: (context, index) {
              final notification = _notifications[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: notification.isRead
                    ? Colors.white
                    : Colors.blue.withOpacity(0.05),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    child: Icon(
                      _getNotificationIcon(notification.type.name),
                      color: Colors.blue,
                    ),
                  ),
                  title: Text(
                    notification.title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.message,
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(
                            DateTime.parse(notification.date.toString())),
                        style: GoogleFonts.poppins(
                          color: Colors.grey[500],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  onTap: () async {
                    if (!notification.isRead) {
                      await _dbHelper.markNotificationAsRead(notification.id!);
                      _loadData();
                    }
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'transaction':
        return Icons.payment;
      case 'security':
        return Icons.security;
      case 'info':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }
}
