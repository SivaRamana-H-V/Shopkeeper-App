import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopkeeper_app/controllers/customer_controller.dart';
import 'package:shopkeeper_app/providers/toast_provider.dart';
import 'package:shopkeeper_app/core/constants/app_strings.dart';
import 'package:shopkeeper_app/core/ui/gradient_button.dart';
import 'package:shopkeeper_app/core/ui/custom_text_field.dart';

class AddCustomerView extends ConsumerStatefulWidget {
  const AddCustomerView({super.key});

  @override
  ConsumerState<AddCustomerView> createState() => _AddCustomerViewState();
}

class _AddCustomerViewState extends ConsumerState<AddCustomerView> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ref.read(toastProvider.notifier).showInfo(AppStrings.validationError);
      return;
    }

    FocusScope.of(context).unfocus();

    await ref
        .read(customerControllerProvider.notifier)
        .addCustomer(name, phone);

    // Check for error in state?
    // addCustomer in controller updates state to loading then value.
    // If we want to know success, we can check if state has error.
    // However, simplest "Task D" compliance is just calling it.
    // Adding a small delay or check might be good, but per instructions,
    // "After adding a customer: Call loadCustomers()" - controller does this.
    // We just pop.

    if (mounted) {
      // Optional: We could check ref.read(customerControllerProvider).hasError
      // asking for simplicity, assuming success if no exception thrown by await
      // (controller catches exceptions inside AsyncValue.guard)

      // Ideally we check if state is error.
      final state = ref.read(customerControllerProvider);
      if (!state.hasError) {
        context.pop();
      } else {
        ref.read(toastProvider.notifier).showError("Failed to save customer");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.addCustomerTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              CustomTextField(
                controller: _nameController,
                hintText: AppStrings.customerName,
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                hintText: AppStrings.phoneNumber,
                prefixIcon: Icons.phone_outlined,
                isPhone: true,
              ),
              const Spacer(),
              GradientButton(
                label: AppStrings.saveCustomer,
                isLoading: isLoading,
                onPressed: () {
                  _handleSave();
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
