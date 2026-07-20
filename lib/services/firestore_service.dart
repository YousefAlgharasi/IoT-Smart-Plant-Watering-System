import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/device_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection reference
  CollectionReference get _devices => _db.collection('devices');

  // Read a single device stream
  Stream<DeviceModel> getDeviceStream(String deviceId) {
    return _devices.doc(deviceId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return DeviceModel.fromFirestore(snapshot);
      } else {
        throw Exception("Device not found");
      }
    });
  }

  // Read a single device once
  Future<DeviceModel?> getDevice(String deviceId) async {
    final snapshot = await _devices.doc(deviceId).get();
    if (snapshot.exists) {
      return DeviceModel.fromFirestore(snapshot);
    }
    return null;
  }

  // Write/Update a device
  Future<void> updateDevice(DeviceModel device) async {
    await _devices.doc(device.id).set(
      device.toFirestore(),
      SetOptions(merge: true),
    );
  }

  // Update specific fields (e.g., toggling the pump)
  Future<void> updateDeviceFields(String deviceId, Map<String, dynamic> fields) async {
    await _devices.doc(deviceId).update(fields);
  }
}
