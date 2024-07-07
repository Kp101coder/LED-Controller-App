#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// Services
#define LED_SERVICE "d804b643-6ce7-4e81-9f8a-ce0f699085eb"

// Characteristics
#define LED_CHARACTERISTIC "e58919dd-8e27-4a31-8675-af7c16034cb9"

BLEAdvertisementData oAdvertisementData = BLEAdvertisementData();
BLEServer *bServer;

class ServerConnectionCallbacks: public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) {
    Serial.println("CONNECTED");
  }

  void onDisconnect(BLEServer* pServer) {
    Serial.println("DISCONNECTED");
  }
};

bool lightIsOn = false;

class LEDCallbacks: public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic) {
    String value = pCharacteristic->getValue();

    if (lightIsOn) {
      digitalWrite(19, LOW);
      lightIsOn = false;
    } else {
      digitalWrite(19, HIGH);
      lightIsOn = true;
    }

    Serial.println(value);
  }
};

void setup() {
  Serial.begin(9600);
  pinMode(19, OUTPUT);
  // put your setup code here, to run once:
  Serial.println("Setting up bluetooth services.");
  BLEDevice::init("LEDController");
  bServer = BLEDevice::createServer();
  bServer->setCallbacks(new ServerConnectionCallbacks());

  BLEService *ledService = bServer->createService(LED_SERVICE);
  BLECharacteristic *ledCharacteristic = ledService->createCharacteristic(
    LED_CHARACTERISTIC, BLECharacteristic::PROPERTY_WRITE
  );
  ledCharacteristic->setCallbacks(new LEDCallbacks());

  ledService->start();

  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(LED_SERVICE);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06); 
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
}

void loop() {
  // put your main code here, to run repeatedly:

}


