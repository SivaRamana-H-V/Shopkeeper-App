import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/customer_controller.dart';
import '../../models/customer_model.dart';
import '../../providers/toast_provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';

class CustomerListView extends ConsumerWidget {
  const CustomerListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.customersTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push(AppRoutes.addCustomer);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer(
            builder: (context, ref, child) {
              final customersAsync = ref.watch(customerControllerProvider);

              // Listen for errors
              ref.listen<AsyncValue<List<Customer>>>(
                customerControllerProvider,
                (previous, next) {
                  if (next.hasError && !next.isLoading) {
                    ref
                        .read(toastProvider.notifier)
                        .showError(AppStrings.toastFetchFailed);
                  }
                },
              );

              return customersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => const Center(
                  child: Text(AppStrings.emptyCustomerList),
                ), // Show empty/error state as requested
                data: (customers) {
                  final totalDue = customers.fold<double>(
                    0,
                    (sum, item) => sum + (item.totalDue ?? 0),
                  );

                  return Column(
                    children: [
                      // Summary Data Card
                      Card(
                        color: AppColors.primary,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildSummaryItem(
                                context,
                                AppStrings.totalCustomers,
                                customers.length.toString(),
                                Colors.white,
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.white24,
                              ),
                              _buildSummaryItem(
                                context,
                                AppStrings.totalOutstanding,
                                "₹ ${totalDue.toStringAsFixed(0)}",
                                Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Search Field
                      TextField(
                        decoration: const InputDecoration(
                          hintText: AppStrings.searchHint,
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // List
                      Expanded(
                        child: customers.isEmpty
                            ? const Center(
                                child: Text(AppStrings.emptyCustomerList),
                              )
                            : ListView.separated(
                                itemCount: customers.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final customer = customers[index];
                                  return _CustomerCard(
                                    name: customer.name,
                                    amount:
                                        "₹ ${(customer.totalDue ?? 0).toStringAsFixed(0)}",
                                    onTap: () {
                                      context.push(
                                        '${AppRoutes.ledger}/${customer.id}',
                                      );
                                    },
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
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: color.withValues(alpha: 0.8)),
        ),
      ],
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final String name;
  final String amount;
  final VoidCallback onTap;

  const _CustomerCard({
    required this.name,
    required this.amount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            name[0],
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          AppStrings.totalDue,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Text(
          amount,
          style: const TextStyle(
            color: AppColors.error,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
