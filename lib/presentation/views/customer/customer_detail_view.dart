import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/services_locator.dart';
import '../../../domain/entities/customer/customer.dart';
import '../../../domain/entities/customer/transaction.dart';
import '../../../l10n/app_localizations.dart';
import '../../blocs/customer/customer_bloc.dart';

class CustomerDetailView extends StatefulWidget {
  final Customer customer;
  const CustomerDetailView({super.key, required this.customer});

  @override
  State<CustomerDetailView> createState() => _CustomerDetailViewState();
}

class _CustomerDetailViewState extends State<CustomerDetailView> {
  @override
  Widget build(BuildContext context) {
    final customer = widget.customer;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final horizontalPadding = isTablet ? screenWidth * 0.1 : 16.0;

    return BlocProvider(
      create: (_) => sl<CustomerBloc>()
        ..add(LoadCustomerTransactions(customer.id)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: Text(customer.fullName),
          backgroundColor: const Color(0xFF00574C),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: BlocConsumer<CustomerBloc, CustomerState>(
          listener: (context, state) {
            final l = AppLocalizations.of(context)!;
            if (state is ReverseSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${l.transactionReversed}. ${state.result.reversedPoints} ${l.pointsReversed}.',
                  ),
                  backgroundColor: const Color(0xFF388E3C),
                ),
              );
              // Reload transactions
              context.read<CustomerBloc>().add(
                    LoadCustomerTransactions(customer.id),
                  );
            }
            if (state is ReverseError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l.reverseFailed),
                  backgroundColor: Colors.red[400],
                ),
              );
            }
          },
          builder: (context, state) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding, vertical: 16),
              children: [
                _buildCustomerInfo(customer),
                const SizedBox(height: 16),
                if (customer.loyaltyCards.isNotEmpty)
                  ..._buildLoyaltyCards(customer),
                const SizedBox(height: 16),
                _buildTransactionsSection(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCustomerInfo(Customer customer) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: const Color(0xFF00574C).withValues(alpha: 0.1),
            child: Text(
              customer.fullName.isNotEmpty
                  ? customer.fullName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00574C),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            customer.fullName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.phone_outlined, customer.phoneNumber),
          if (customer.email != null && customer.email!.isNotEmpty)
            _infoRow(Icons.email_outlined, customer.email!),
          if (customer.dateOfBirth != null)
            _infoRow(
              Icons.cake_outlined,
              '${customer.dateOfBirth!.day.toString().padLeft(2, '0')}.${customer.dateOfBirth!.month.toString().padLeft(2, '0')}.${customer.dateOfBirth!.year}',
            ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: Colors.grey[500]),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        ],
      ),
    );
  }

  List<Widget> _buildLoyaltyCards(Customer customer) {
    return customer.loyaltyCards.map((card) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00574C), Color(0xFF008066)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00574C).withValues(alpha: 0.3),
              blurRadius: 12,
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
                  'Kart: ${card.cardNumber}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                if (card.freeRewardLabel != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      card.freeRewardLabel!,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 11),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _cardStat('Cari xal', card.currentPoints.toString()),
                _cardStat('Mükafat', card.availableRewardCount.toString()),
                _cardStat('Tamamlanan', card.completedCycles.toString()),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _cardStat('Addımlar', card.currentSteps.toString()),
                if (card.currency != null)
                  _cardStat('Valyuta', card.currency!),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _cardStat(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsSection(BuildContext context, CustomerState state) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l.customerTransactions,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const Spacer(),
            if (state is! TransactionsLoading && state is! ReverseLoading)
              GestureDetector(
                onTap: () => context.read<CustomerBloc>().add(
                      LoadCustomerTransactions(widget.customer.id),
                    ),
                child: Icon(Icons.refresh_rounded,
                    color: Colors.grey[500], size: 22),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (state is TransactionsLoading || state is CustomerInitial)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        else if (state is ReverseLoading)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  Text(l.loading),
                ],
              ),
            ),
          )
        else if (state is CustomerError)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.error_outline, size: 40, color: Colors.red[300]),
                  const SizedBox(height: 8),
                  Text(l.statsLoadFailed),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => context.read<CustomerBloc>().add(
                          LoadCustomerTransactions(widget.customer.id),
                        ),
                    child: Text(l.retry),
                  ),
                ],
              ),
            ),
          )
        else if (state is TransactionsLoaded)
          _buildTransactionList(context, state.transactions)
        else if (state is ReverseSuccess)
          // After reverse success, we reload transactions; show loading
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildTransactionList(
      BuildContext context, List<Transaction> transactions) {
    final l = AppLocalizations.of(context)!;
    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: Text(
          l.noTransactions,
          style: TextStyle(color: Colors.grey[500], fontSize: 14),
        ),
      );
    }

    return Column(
      children: transactions
          .map((t) => _buildTransactionCard(context, t))
          .toList(),
    );
  }

  Widget _buildTransactionCard(BuildContext context, Transaction transaction) {
    final l = AppLocalizations.of(context)!;
    final isEarn = transaction.type == 1;
    final isRedeemed = transaction.type == 2;
    final color = isEarn
        ? const Color(0xFF388E3C)
        : isRedeemed
            ? const Color(0xFFE64A19)
            : Colors.grey[700]!;
    final icon = isEarn
        ? Icons.trending_up_rounded
        : isRedeemed
            ? Icons.trending_down_rounded
            : Icons.swap_horiz_rounded;
    final prefix = isEarn ? '+' : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.typeName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      transaction.createdAt ?? '',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$prefix${transaction.points}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: color,
                    ),
                  ),
                  _buildStatusBadge(transaction),
                ],
              ),
            ],
          ),
          if (transaction.description != null &&
              transaction.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              transaction.description!,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
          if (transaction.reverseReason != null &&
              transaction.reverseReason!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${l.reverseReasonLabel} ${transaction.reverseReason}',
                style: const TextStyle(fontSize: 11, color: Colors.orange),
              ),
            ),
          ],
          if (transaction.canReverse) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showReverseDialog(context, transaction),
                icon: const Icon(Icons.undo_rounded, size: 16),
                label: Text(l.reverseButton),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red[600],
                  side: BorderSide(color: Colors.red[300]!),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(Transaction transaction) {
    Color badgeColor;
    switch (transaction.status) {
      case 1:
        badgeColor = const Color(0xFF388E3C);
        break;
      case 4:
        badgeColor = Colors.orange;
        break;
      case 2:
        badgeColor = Colors.red;
        break;
      default:
        badgeColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        transaction.statusName,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: badgeColor,
        ),
      ),
    );
  }

  void _showReverseDialog(BuildContext context, Transaction transaction) {
    final l = AppLocalizations.of(context)!;
    final reasonController = TextEditingController();
    final bloc = context.read<CustomerBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(l.reverseTransaction),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${transaction.typeName} - ${transaction.points} ${l.points}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: l.reverseReason,
                  hintText: l.reverseReasonPlaceholder,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.reverseReasonPlaceholder)),
                  );
                  return;
                }
                Navigator.pop(dialogContext);
                bloc.add(ReverseTransactionEvent(
                  orderId: transaction.orderId ?? '',
                  transactionId: transaction.id,
                  originalType: transaction.type == 1 ? 'EARN' : 'REDEEM',
                  reason: reason,
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(l.reverseButton),
            ),
          ],
        );
      },
    );
  }
}
