import 'package:flutter/material.dart';
import '../../../services/firestore_service.dart';

class ControlPanel extends StatelessWidget {
  final String deviceId;
  final bool isAutomatic;

  const ControlPanel({
    super.key,
    required this.deviceId,
    required this.isAutomatic,
  });

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

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
                  value: isAutomatic,
                  onChanged: (value) async {
                    try {
                      await firestoreService.updateDeviceFields(deviceId, {'automatic': value});
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to update mode: $e')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: isAutomatic
                    ? null // Disable manual watering if automatic is on
                    : () async {
                        try {
                          await firestoreService.updateDeviceFields(deviceId, {'pump': true});
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pump turned ON manually')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to turn on pump: $e')),
                            );
                          }
                        }
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
            if (isAutomatic)
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
