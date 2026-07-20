import 'package:flutter/material.dart';

class ControlPanel extends StatefulWidget {
  final bool isAutomatic;

  const ControlPanel({
    super.key,
    required this.isAutomatic,
  });

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  late bool _isAuto;

  @override
  void initState() {
    super.initState();
    _isAuto = widget.isAutomatic;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2), width: 1),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Controls',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.auto_mode, color: Colors.purple),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Automatic Watering',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isAuto,
                  onChanged: (value) {
                    setState(() {
                      _isAuto = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: _isAuto
                    ? null // Disable manual watering if automatic is on
                    : () {
                        // Handle manual watering
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Watering started...')),
                        );
                      },
                icon: const Icon(Icons.water_drop),
                label: const Text(
                  'Water Now',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            if (_isAuto)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  'Manual watering is disabled while automatic mode is on.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
