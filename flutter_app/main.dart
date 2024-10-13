import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ask for location permission (needed for BLE scan)
  await Permission.location.request();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // Add a named `Key` parameter in the constructor
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
  // Add a named `Key` parameter in the constructor
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  FlutterBluePlus flutterBlue = FlutterBluePlus();
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? controlCharacteristic;

  bool _isPressed = false; // Track button press state

  // UUIDs should match the ones on your ESP32
  final String serviceUUID = "12345678-1234-5678-1234-56789abcdef0";
  final String characteristicUUID = "abcd1234-5678-1234-5678-12345678abcd";

  @override
  void initState() {
    super.initState();
    scanForDevices();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ESP32 Relay Control'),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            setState(() {
              _isPressed = true; // Immediately update UI
            });
            // Toggle the relay with tap (momentary action)
            writeData("ON");
            Future.delayed(const Duration(milliseconds: 100), () {
              writeData("OFF");
              setState(() {
                _isPressed = false; // Update UI after relay action is completed
              });
            });
          },
          onLongPressStart: (_) {
            setState(() {
              _isPressed = true; // Immediately update UI
            });
            // Hold the relay ON while holding the button
            writeData("ON");
          },
          onLongPressEnd: (_) {
            writeData("OFF");
            setState(() {
              _isPressed = false; // Update UI immediately after release
            });
          },
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isPressed
                  ? Colors.green
                  : Colors.white, // Change color based on press state
              border: Border.all(
                  color: Colors.green, width: 2), // Green border for visibility
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
      ),
    );
  }
}
