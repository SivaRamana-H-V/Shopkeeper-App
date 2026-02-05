import 'package:flutter/material.dart';

class CustomerListView extends StatelessWidget {
  const CustomerListView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Customer List Screen", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
