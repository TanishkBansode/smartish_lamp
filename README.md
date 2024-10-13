# Smartish Lamp - ESP32 BLE Relay Control App

This project enables control of a **relay module** connected to an **ESP32** using **Bluetooth Low Energy (BLE)** via a Flutter mobile application. The app communicates with the ESP32 to toggle the relay between ON and OFF states.

## Project Structure

This repository contains the following key files:
- **`esp32/esp32_relay_control.ino`**: Arduino code to run on the ESP32.
- **`flutter_app/main.dart`**: Flutter code for the app's UI and BLE logic.
- **`flutter_app/pubspec.yaml`**: Configuration file listing dependencies for the Flutter project.

**Note:**  
You need to **create a new Flutter project** and replace the default files with the provided code.

## How to Set Up

### 1. ESP32 Setup
1. **Hardware Configuration**:  
   Connect your **relay module** to GPIO **pin 5** of the ESP32.

2. **Upload Code**:  
   - Install the **ESP32 board** in the Arduino IDE if you haven't already.
   - Use the `esp32_relay_control.ino` code provided in this repository.
   - Ensure these libraries are available:
     - `BLEDevice.h`
     - `BLEServer.h`
   - Upload the code to your ESP32.

### 2. Flutter Setup
1. **Create a New Flutter Project**:
   ```bash
   flutter create smartish_lamp
   ```

2. **Replace Files**:
   * Replace `lib/main.dart` with the provided `main.dart`.
   * Replace the `pubspec.yaml` file with the provided content.

3. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

4. **Grant Permissions**: The app requires **location permission** for BLE scanning. The `permission_handler` package prompts for this when the app starts.

## Running the App

1. **Build and Run**: Make sure **Bluetooth** is enabled on your phone. Use the following command to run the app:
   ```bash
   flutter run
   ```

2. **Relay Control**:
   * The app automatically **scans for ESP32 devices** named **"ESP32 BLE Relay Control"**.
   * **Tap the Button**: Turns the relay ON momentarily.
   * **Hold the Button**: Keeps the relay ON while pressed. The relay turns OFF upon release.

## BLE UUIDs

Ensure the following UUIDs are consistent in both the ESP32 and Flutter code:
* **Service UUID**: `12345678-1234-5678-1234-56789abcdef0`
* **Characteristic UUID**: `abcd1234-5678-1234-5678-12345678abcd`

## Dependencies

Add these dependencies in your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  permission_handler: ^11.3.1
  flutter_blue_plus: ^1.32.12
  provider: ^6.1.2 # Optional, useful for future app extensions
```

## Conclusion

This project demonstrates the use of **Bluetooth Low Energy (BLE)** to create a simple **relay control system** using an ESP32 and a Flutter mobile app. You can further expand this project by integrating **state management** using `provider` or adding more BLE-controlled devices.
