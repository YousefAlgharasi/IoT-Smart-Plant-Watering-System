import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Plant Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return _buildWideLayout(context);
          } else {
            return _buildNarrowLayout(context);
          }
        },
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return const Center(
      child: Text('Wide Layout: Dashboard Widgets Here', style: TextStyle(fontSize: 24)),
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return const Center(
      child: Text('Narrow Layout: Dashboard Widgets Here', style: TextStyle(fontSize: 18)),
    );
  }
}
