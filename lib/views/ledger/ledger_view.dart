import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopkeeper_app/controllers/ledger_controller.dart';
import 'package:shopkeeper_app/models/entry_model.dart';
import 'package:shopkeeper_app/core/constants/app_strings.dart';
import 'package:shopkeeper_app/core/router/app_routes.dart';
import 'package:shopkeeper_app/core/theme/app_colors.dart';

class LedgerView extends StatelessWidget {
  final String customerId;

  const LedgerView({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.ledgerTitle)),
      body: SafeArea(
        child: Consumer(
          builder: (context, ref, child) {
            final entriesAsync = ref.watch(
              ledgerControllerProvider(customerId),
            );

            return entriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (ledgerState) {
                final entries = ledgerState.entries;
                final customerCode = ledgerState.customerCode;
                final totalDue = ledgerState.totalDue;
                final customerName = ledgerState.customerName;
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(ledgerControllerProvider(customerId));
                  },
                  child: Column(
                    children: [
                      // Header Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        decoration: const BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(24),
                          ),
                        ),
                        child: Card(
                          color: AppColors.surface,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: AppColors.primary,
                                  child: Text(
                                    customerName
                                            ?.substring(0, 1)
                                            .toUpperCase() ??
                                        "",
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Ideally fetch customer name too
                                Text(
                                  customerName ?? "",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  customerCode ?? "",
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${AppStrings.totalDue}: ",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      "₹ ${totalDue.toStringAsFixed(0)}",
                                      style: const TextStyle(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // List
                      Expanded(
                        child: entries.isEmpty
                            ? const Center(child: Text("No entries found"))
                            : ListView.separated(
                                padding: const EdgeInsets.all(16),
                                itemCount: entries.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final entry = entries[index];
                                  return _EntryRow(
                                    id: entry.id,
                                    amount:
                                        "₹ ${entry.amount.toStringAsFixed(0)}",
                                    status: entry.status,
                                    date: entry.createdAt.toString().split(
                                      ' ',
                                    )[0],
                                    customerId: customerId,
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(AppRoutes.addEntryTo(customerId));
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          AppStrings.addEntryTitle,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  final String id;
  final String amount;
  final EntryStatus status;
  final String date;
  final String customerId;

  const _EntryRow({
    required this.id,
    required this.amount,
    required this.status,
    required this.date,
    required this.customerId,
  });

  Color _getStatusColorFrom(EntryStatus s) {
    switch (s) {
      case EntryStatus.approved:
        return AppColors.success;
      case EntryStatus.disputed:
        return AppColors.error;
      case EntryStatus.pending:
        return Colors.orange;
    }
  }

  String _getStatusLabelFrom(EntryStatus s) {
    switch (s) {
      case EntryStatus.approved:
        return AppStrings.statusApproved;
      case EntryStatus.disputed:
        return AppStrings.statusDisputed;
      case EntryStatus.pending:
        return AppStrings.statusPending;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      amount,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(date, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColorFrom(status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusLabelFrom(status),
                    style: TextStyle(
                      color: _getStatusColorFrom(status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
