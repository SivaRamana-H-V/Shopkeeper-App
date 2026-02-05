import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/ledger_controller.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';

class LedgerView extends ConsumerWidget {
  final String customerId;

  const LedgerView({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              data: (entries) {
                final totalDue = entries.fold<double>(
                  0,
                  (sum, item) =>
                      sum + (item.status == 'Pending' ? item.amount : 0),
                );

                return Column(
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
                                  // Simplified: Fetch customer details if needed or pass as argument
                                  // For now, assume fetched or generic
                                  "C",
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Ideally fetch customer name too
                              const Text(
                                "Customer",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "ID: $customerId",
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
                                // Date formatting skipped for brevity, implementing basic
                                return _EntryRow(
                                  amount:
                                      "₹ ${entry.amount.toStringAsFixed(0)}",
                                  status: entry.status,
                                  date: entry.createdAt.toString().split(
                                    ' ',
                                  )[0],
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(AppRoutes.addEntry);
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
  final String amount;
  final String status;
  final String date;

  const _EntryRow({
    required this.amount,
    required this.status,
    required this.date,
  });

  Color _getStatusColor() {
    switch (status) {
      case "Approved":
        return AppColors.success;
      case "Disputed":
        return AppColors.error;
      default:
        return Colors.orange;
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
        child: Row(
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
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: _getStatusColor(),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
