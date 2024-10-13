#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

const int relayPin = 5;  // Define the relay pin

// Define UUIDs
#define SERVICE_UUID        "12345678-1234-5678-1234-56789abcdef0"
#define CHARACTERISTIC_UUID "abcd1234-5678-1234-5678-12345678abcd"

// BLE Server Callbacks
class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) {
    Serial.println("Client Connected");
  }

  void onDisconnect(BLEServer* pServer) {
    Serial.println("Client Disconnected");
  }
};

// BLE Characteristic Callbacks
class MyCharacteristicCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic* pCharacteristic) {
    String value = pCharacteristic->getValue().c_str();
    Serial.println(value);
    if (value == "ON") {
      digitalWrite(relayPin, LOW);  
      Serial.println("Relay is ON (HIGH)");
    } else if (value == "OFF") {
      digitalWrite(relayPin, HIGH);   
      Serial.println("Relay is OFF (LOW)");
    }
  }
};

void setup() {
  Serial.begin(115200);
  pinMode(relayPin, OUTPUT);
  digitalWrite(relayPin, HIGH);  // Start with the relay off

  // Initialize BLE
  BLEDevice::init("ESP32 BLE Relay Control");
  BLEServer *pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // Create BLE Service
  BLEService *pService = pServer->createService(SERVICE_UUID);

  // Create BLE Characteristic
  BLECharacteristic *pCharacteristic = pService->createCharacteristic(
    CHARACTERISTIC_UUID,
    BLECharacteristic::PROPERTY_READ |
    BLECharacteristic::PROPERTY_WRITE
  );

  pCharacteristic->setCallbacks(new MyCharacteristicCallbacks());
  pCharacteristic->setValue("OFF");  // Initial value

  // Start the service
  pService->start();

  // Start advertising
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(false);
  pAdvertising->setMinPreferred(0x06);  // iPhone requires at least 7ms
  pAdvertising->start();

  Serial.println("Waiting for a client to connect...");
}

void loop() {
  // Nothing to do here, BLE callbacks handle everything
}
