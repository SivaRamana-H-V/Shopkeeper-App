import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopkeeper_app/customer/controllers/customer_home_controller.dart';
import 'package:shopkeeper_app/shopkeeper/core/router/app_routes.dart';
import 'package:shopkeeper_app/shopkeeper/core/theme/app_colors.dart';
import 'package:shopkeeper_app/customer/models/customer_dashboard_model.dart';
import 'package:intl/intl.dart';

class CustomerHomeView extends ConsumerWidget {
  const CustomerHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(customerHomeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Ledger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(customerHomeControllerProvider),
          ),
        ],
      ),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (data) => _buildDashboard(context, data),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, CustomerDashboardData data) {
    return RefreshIndicator(
      onRefresh: () async {
        // trigger reload
      },
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Total Outstanding Card
          Card(
            color: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(
                    'Total Outstanding',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹ ${data.totalOutstanding.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // My Shops
          Text(
            'My Shops',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (data.shopkeepers.isEmpty)
            const Center(
              child: Text(
                'No shops found linked to this number.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ...data.shopkeepers.map((shop) => _ShopCard(shop: shop)),

          const SizedBox(height: 24),

          // Recent Activity
          Text(
            'Recent Activity',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (data.recentEntries.isEmpty)
            const Center(
              child: Text(
                'No recent activity.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ...data.recentEntries.map((entry) => _EntryCard(entry: entry)),
        ],
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  final ShopkeeperCardData shop;

  const _ShopCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            shop.shopName.isNotEmpty ? shop.shopName[0].toUpperCase() : '?',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          shop.shopName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Due: ₹ ${shop.totalDue.toStringAsFixed(2)}'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navigate to Ledger Detail for this shop
          // We reuse the route but we might need to adjust the view based on role
          context.push(AppRoutes.ledgerDetail(shop.customerId));
        },
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final CustomerEntryData entry;

  const _EntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isPayment =
        entry.amount < 0 ||
        entry.type == 'Payment'; // Adjust logic based on data
    final color = isPayment ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        leading: Icon(
          isPayment ? Icons.arrow_downward : Icons.arrow_upward,
          color: color,
        ),
        title: Text(entry.shopName),
        subtitle: Text(DateFormat('MMM d, y h:mm a').format(entry.createdAt)),
        trailing: Text(
          '₹ ${entry.amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
