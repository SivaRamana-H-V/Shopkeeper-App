import 'package:flutter/material.dart';
import 'package:pulse_ledger/core/theme/app_theme.dart';
import 'package:pulse_ledger/models/message_model.dart';

class CreditRequestCard extends StatelessWidget {
  const CreditRequestCard({
    super.key,
    required this.message,
    required this.isShopOwner,
    required this.isSender,
    required this.onApprove,
    required this.onReject,
    this.onPay,
  });

  final MessageModel message;
  final bool isShopOwner;
  final bool isSender;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback? onPay;

  @override
  Widget build(BuildContext context) {
    final amount = message.metadata[MessageModel.amountKey] ?? 0;
    final description =
        message.metadata[MessageModel.descriptionKey] ?? 'Credit';
    final status =
        message.metadata[MessageModel.statusKey] ?? MessageModel.statusPending;
    final theme = Theme.of(context);

    final bool isPending = status == MessageModel.statusPending;
    final bool isApproved = status == MessageModel.statusApproved;
    final bool isRejected = status == MessageModel.statusRejected;
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        width: MediaQuery.of(context).size.width * 0.75,
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isApproved
                ? Colors.green.withValues(alpha: 0.8)
                : isRejected
                    ? Colors.red.withValues(alpha: 0.8)
                    : AppTheme.royalPurple.withValues(alpha: 0.8),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Amount Area (Amber Gold Background)
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: const BoxDecoration(
                  color: AppTheme.amberGold,
                ),
                child: Column(
                  children: [
                    Text(
                      '₹$amount',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'AMOUNT REQUESTED',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Description Area
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppTheme.onSurfaceMuted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Interaction Area (Strict Role-Lock)
                    if (isSender)
                      _OwnerStatus(status: status)
                    else if (isPending)
                      _CustomerActions(onApprove: onApprove, onReject: onReject)
                    else
                      _CustomerResult(
                        status: status,
                        amount: amount,
                        onPay: onPay,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OwnerStatus extends StatelessWidget {
  const _OwnerStatus({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    if (status == MessageModel.statusPending) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time_filled_rounded,
                color: AppTheme.amberGold, size: 20),
            SizedBox(width: 8),
            Text(
              'Pending Customer Approval',
              style: TextStyle(
                color: AppTheme.amberGold,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _CustomerActions extends StatelessWidget {
  const _CustomerActions({required this.onApprove, required this.onReject});
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: onReject,
            style: TextButton.styleFrom(
              foregroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.redAccent, width: 1.5),
              ),
            ),
            child: const Text('Decline',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onApprove,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Approve',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

class _CustomerResult extends StatelessWidget {
  const _CustomerResult({
    required this.status,
    this.amount,
    this.onPay,
  });
  final String status;
  final num? amount;
  final VoidCallback? onPay;

  @override
  Widget build(BuildContext context) {
    final isApproved = status == MessageModel.statusApproved;
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                (isApproved ? Colors.green : Colors.red).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isApproved ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isApproved ? Colors.green : Colors.red,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                isApproved
                    ? 'You approved this credit'
                    : 'You rejected this credit',
                style: TextStyle(
                  color: isApproved ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        if (isApproved && onPay != null && amount != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onPay,
              icon: const Icon(Icons.payment, size: 18),
              label: Text(
                'Pay ₹${amount!.toStringAsFixed(0)} via UPI',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.royalPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
