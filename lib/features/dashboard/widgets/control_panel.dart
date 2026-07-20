import 'package:flutter/material.dart';
import '../../../services/firestore_service.dart';
import '../../../models/device_model.dart';

class ControlPanel extends StatefulWidget {
  final DeviceModel device;

  const ControlPanel({
    super.key,
    required this.device,
  });

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isRequesting = false;

  Future<void> _handleWaterNow() async {
    if (_isRequesting || widget.device.pump || widget.device.automatic) return;

    setState(() {
      _isRequesting = true;
    });

    try {
      // 1. Set pump = true
      await _firestoreService.updateDeviceFields(widget.device.id, {'pump': true});
      
      // 2. Wait wateringDuration seconds
      await Future.delayed(Duration(seconds: widget.device.wateringDuration));
      
      // 3. Set pump = false
      await _firestoreService.updateDeviceFields(widget.device.id, {'pump': false});
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Watering completed successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to complete watering: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRequesting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAutomatic = widget.device.automatic;
    final isPumpOn = widget.device.pump;
    final isWateringDisabled = isAutomatic || isPumpOn || _isRequesting;

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
                  onChanged: _isRequesting
                      ? null
                      : (value) async {
                          try {
                            await _firestoreService.updateDeviceFields(
                                widget.device.id, {'automatic': value});
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
                onPressed: isWateringDisabled ? null : _handleWaterNow,
                icon: (isPumpOn || _isRequesting)
                    ? Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Icon(Icons.water_drop),
                label: Text(
                  (isPumpOn || _isRequesting) ? 'Watering...' : 'Water Now',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
