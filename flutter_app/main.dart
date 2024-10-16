import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.location.request();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP32 Relay Control',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  FlutterBluePlus flutterBlue = FlutterBluePlus();
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? controlCharacteristic;

  bool _isPressed = false;
  TimeOfDay? _alarmTime;
  Timer? _alarmTimer;

  final String serviceUUID = "12345678-1234-5678-1234-56789abcdef0";
  final String characteristicUUID = "abcd1234-5678-1234-5678-12345678abcd";

  @override
  void initState() {
    super.initState();
    scanForDevices();
  }

  @override
  void dispose() {
    _alarmTimer?.cancel();
    super.dispose();
  }

  void scanForDevices() {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4))
        .catchError((error) {
      print('Scan failed: $error');
    });

    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.device.platformName == 'ESP32 BLE Relay Control') {
          connectToDevice(r.device);
          FlutterBluePlus.stopScan();
          break;
        }
      }
    });
  }

  void connectToDevice(BluetoothDevice device) async {
    await device.connect();
    setState(() {
      connectedDevice = device;
    });

    List<BluetoothService> services = await device.discoverServices();
    for (var service in services) {
      if (service.uuid.toString() == serviceUUID) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString() == characteristicUUID) {
            setState(() {
              controlCharacteristic = characteristic;
            });
          }
        }
      }
    }
  }

  void writeData(String value) async {
    if (controlCharacteristic != null) {
      await controlCharacteristic!.write(value.codeUnits);
    }
  }

  void _setAlarm() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _alarmTime = picked;
      });
      _scheduleAlarm();
    }
  }

  void _scheduleAlarm() {
    _alarmTimer?.cancel();
    if (_alarmTime != null) {
      final now = DateTime.now();
      var scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        _alarmTime!.hour,
        _alarmTime!.minute,
      );
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }
      final duration = scheduledTime.difference(now);
      _alarmTimer = Timer(duration, _triggerAlarm);
    }
  }

  void _triggerAlarm() {
    writeData("ON");
    Future.delayed(const Duration(seconds: 5), () {
      writeData("OFF");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ESP32 Relay Control'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                setState(() {
                  _isPressed = true;
                });
                writeData("ON");
                Future.delayed(const Duration(milliseconds: 100), () {
                  writeData("OFF");
                  setState(() {
                    _isPressed = false;
                  });
                });
              },
              onLongPressStart: (_) {
                setState(() {
                  _isPressed = true;
                });
                writeData("ON");
              },
              onLongPressEnd: (_) {
                writeData("OFF");
                setState(() {
                  _isPressed = false;
                });
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isPressed ? Colors.green : Colors.white,
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: const Center(
                  child: Text(
                    "Press",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _setAlarm,
              child: const Text('Set Alarm'),
            ),
            if (_alarmTime != null)
              Text(
                'Alarm set for: ${_alarmTime!.format(context)}',
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
