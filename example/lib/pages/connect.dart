import 'package:flutter/material.dart';
import 'package:ricoh_theta/ricoh_theta.dart';

class ConnectPage extends StatefulWidget {
  const ConnectPage({super.key});

  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  final _ricohThetaPlugin = RicohTheta();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ipAddressTextController =
      TextEditingController(text: '192.168.1.1');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _ipAddressTextController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an IP address';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await _ricohThetaPlugin
                      .setTargetIp(_ipAddressTextController.text);
                  await _ricohThetaPlugin.getDeviceInfo().then((value) {
                    Navigator.pushReplacementNamed(context, '/home');
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Impossible to connect to the camera'),
                    ));
                  });
                }
              },
              child: const Text('Set target IP'),
            ),
          ],
        ),
      ),
    );
  }
}
