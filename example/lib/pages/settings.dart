import 'package:flutter/material.dart';
import 'package:ricoh_theta/ricoh_theta.dart';
import 'package:ricoh_theta_example/utils.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _ricohThetaPlugin = RicohTheta();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                final deviceInfo = await _ricohThetaPlugin.getDeviceInfo();
                if (deviceInfo == null) {
                  return;
                }
                showResultDialog(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Model: ${deviceInfo.model}'),
                      Text('Firmware: ${deviceInfo.firmwareVersion}'),
                      Text('Serial: ${deviceInfo.serialNumber}'),
                    ],
                  ),
                );
              },
              child: const Text('Get device data'),
            ),
            ElevatedButton(
              onPressed: () async {
                final storageInfo = await _ricohThetaPlugin.getStorageInfo();
                if (storageInfo == null) {
                  return;
                }
                showResultDialog(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Max capacity: ${storageInfo.maxCapacity}'),
                      Text('Free space (bytes): ${storageInfo.freeSpaceInBytes}'),
                      Text(
                          'Free space (images): ${storageInfo.freeSpaceInImages}'),
                      Text('Image height: ${storageInfo.imageHeight}'),
                      Text('Image width: ${storageInfo.imageWidth}'),
                    ],
                  ),
                );
              },
              child: const Text('Get storage info'),
            ),
            ElevatedButton(
              onPressed: () async {
                final batteryLevel = await _ricohThetaPlugin.batteryLevel();

                showResultDialog(
                  context,
                  child: Text('Battery: $batteryLevel %'),
                );
              },
              child: const Text('Get battery level'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _ricohThetaPlugin.disconnect();
                Navigator.pushReplacementNamed(context, '/connect');
              },
              child: const Text('Disconnect'),
            ),
          ],
        ),
      ),
    );
  }
}
