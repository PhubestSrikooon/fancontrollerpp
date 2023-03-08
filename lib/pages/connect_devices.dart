import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class SelectDevicesPage extends StatefulWidget {
  const SelectDevicesPage({super.key});

  @override
  State<SelectDevicesPage> createState() => _SelectDevicesPageState();
}

class _SelectDevicesPageState extends State<SelectDevicesPage> {
  List<BluetoothDiscoveryResult> devices = [];
  bool isScanning = false;
  FlutterBluetoothSerial? flutterBluetoothSerial;
  StreamSubscription<BluetoothDiscoveryResult>? _startDis;

  @override
  void initState() {
    flutterBluetoothSerial = FlutterBluetoothSerial.instance;
    DoScan();
    super.initState();
  }

  Future<bool> PermissionInvoker() async {
    PermissionStatus result1;
    PermissionStatus result2;
    PermissionStatus result3;
    result1 = await Permission.bluetooth.request();
    result2 = await Permission.bluetoothScan.request();
    result3 = await Permission.bluetoothConnect.request();
    if (result1.isGranted && result2.isGranted && result3.isGranted) {
      return true;
    }
    return false;
  }

  Future<void> DoScan() async {
    if (await PermissionInvoker() && !isScanning) {
      devices = [];
      setState(() {
        isScanning = true;
      });
      _startDis =
          await flutterBluetoothSerial!.startDiscovery().listen((event) {
        setState(() {
          devices.add(event);
        });
      });
      _startDis?.onDone(() {
        setState(() {
          isScanning = false;
        });
      });
    }
  }

  @override
  void dispose() {
    _startDis?.cancel();
    super.dispose();
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Select Devices")),
        body: Stack(
          children: [
            SizedBox(child: isScanning ? LinearProgressIndicator() : null),
            RefreshIndicator(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: devices.length,
                    itemBuilder: (BuildContext context, int index) {
                      return (devices[index].device.name != null
                          ? ListTile(
                              onTap: () {
                                Navigator.pop(context, [
                                  devices[index].device.address,
                                  devices[index].device.name ?? "Unknown device"
                                ]);
                              },
                              leading: devices[index].device.name == null
                                  ? Icon(Icons.devices)
                                  : Icon(Icons.important_devices),
                              title: Text(devices[index].device.name ??
                                  "Unknown device"),
                              subtitle: Text(
                                  "MAC : ${devices[index].device.address} rssi : ${devices[index].rssi}"),
                            )
                          : Container());
                    }),
                onRefresh: DoScan)
          ],
        ));
  }
}
