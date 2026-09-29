/*
 * ============================================================
 * MILKORA - ESP32 + DS18B20 + BLE
 * ============================================================
 *
 * ESP32 Dev Module
 * DS18B20 Data -> GPIO 4
 *
 * DS18B20:
 * VCC  -> 3.3V
 * GND  -> GND
 * DATA -> GPIO 4
 *
 * IMPORTANT:
 * Use 4.7k resistor between DATA and 3.3V
 *
 * BLE Device:
 * MILKORA-CAN-01
 *
 * Service UUID:
 * 12345678-1234-1234-1234-1234567890AB
 *
 * Temperature Characteristic:
 * 12345678-1234-1234-1234-1234567890AC
 *
 * Temperature update:
 * Every 1.5 seconds
 * ============================================================
 */

#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

#include <OneWire.h>
#include <DallasTemperature.h>


// ============================================================
// DS18B20
// ============================================================

#define ONE_WIRE_BUS 4

OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);


// ============================================================
// MILKORA BLE UUIDs
// ============================================================

#define SERVICE_UUID \
"12345678-1234-1234-1234-1234567890AB"

#define CHARACTERISTIC_UUID \
"12345678-1234-1234-1234-1234567890AC"


// ============================================================
// BLE VARIABLES
// ============================================================

BLEServer* pServer = nullptr;
BLECharacteristic* pTempCharacteristic = nullptr;

bool deviceConnected = false;
bool oldDeviceConnected = false;


// ============================================================
// TIMING
// ============================================================

unsigned long lastSensorReadTime = 0;

const unsigned long SENSOR_INTERVAL = 1500;


// ============================================================
// BLE SERVER CALLBACKS
// ============================================================

class MilkoraServerCallbacks : public BLEServerCallbacks {

  void onConnect(BLEServer* pServer) override {

    deviceConnected = true;

    Serial.println();
    Serial.println("================================");
    Serial.println("BLE: PHONE CONNECTED");
    Serial.println("================================");
  }


  void onDisconnect(BLEServer* pServer) override {

    deviceConnected = false;

    Serial.println();
    Serial.println("BLE: PHONE DISCONNECTED");
  }
};


// ============================================================
// SETUP
// ============================================================

void setup() {

  Serial.begin(115200);

  delay(1000);

  Serial.println();
  Serial.println("========================================");
  Serial.println("       MILKORA SMART MILK CAN");
  Serial.println("========================================");

  // ----------------------------------------------------------
  // DS18B20
  // ----------------------------------------------------------

  Serial.println("Initializing DS18B20...");

  sensors.begin();

  int sensorCount = sensors.getDeviceCount();

  Serial.print("DS18B20 sensors detected: ");
  Serial.println(sensorCount);

  if (sensorCount == 0) {

    Serial.println("WARNING: No DS18B20 detected!");
    Serial.println("Check:");
    Serial.println("1. DATA -> GPIO 4");
    Serial.println("2. VCC -> 3.3V");
    Serial.println("3. GND -> GND");
    Serial.println("4. 4.7k resistor DATA -> 3.3V");
  }

  // Use asynchronous conversion
  sensors.setWaitForConversion(false);

  // Start first temperature conversion
  sensors.requestTemperatures();


  // ----------------------------------------------------------
  // BLE INITIALIZATION
  // ----------------------------------------------------------

  Serial.println();
  Serial.println("Initializing BLE...");

  BLEDevice::init("MILKORA-CAN-01");

  pServer = BLEDevice::createServer();

  pServer->setCallbacks(
    new MilkoraServerCallbacks()
  );


  // ----------------------------------------------------------
  // CREATE BLE SERVICE
  // ----------------------------------------------------------

  BLEService* pService =
    pServer->createService(SERVICE_UUID);


  // ----------------------------------------------------------
  // CREATE TEMPERATURE CHARACTERISTIC
  // ----------------------------------------------------------

  pTempCharacteristic =
    pService->createCharacteristic(

      CHARACTERISTIC_UUID,

      BLECharacteristic::PROPERTY_READ |
      BLECharacteristic::PROPERTY_NOTIFY
    );


  // Enable notifications
  pTempCharacteristic->addDescriptor(
    new BLE2902()
  );


  // Initial value
  pTempCharacteristic->setValue(
    "0.0 C"
  );


  // ----------------------------------------------------------
  // START SERVICE
  // ----------------------------------------------------------

  pService->start();


  // ----------------------------------------------------------
  // BLE ADVERTISING
  // ----------------------------------------------------------

  BLEAdvertising* pAdvertising =
    BLEDevice::getAdvertising();

  pAdvertising->addServiceUUID(
    SERVICE_UUID
  );

  pAdvertising->setScanResponse(true);

  pAdvertising->setMinPreferred(0x06);
  pAdvertising->setMinPreferred(0x12);

  BLEDevice::startAdvertising();


  // ----------------------------------------------------------
  // READY
  // ----------------------------------------------------------

  Serial.println();
  Serial.println("========================================");
  Serial.println("       MILKORA BLE READY");
  Serial.println("========================================");

  Serial.println(
    "BLE Device: MILKORA-CAN-01"
  );

  Serial.println(
    "Service UUID: "
    SERVICE_UUID
  );

  Serial.println(
    "Temperature UUID: "
    CHARACTERISTIC_UUID
  );

  Serial.println(
    "BLE: Waiting for phone..."
  );

  Serial.println(
    "========================================");
}


// ============================================================
// LOOP
// ============================================================

void loop() {

  unsigned long currentMillis =
    millis();


  // ==========================================================
  // TEMPERATURE UPDATE EVERY 1.5 SECONDS
  // ==========================================================

  if (
    currentMillis - lastSensorReadTime
    >= SENSOR_INTERVAL
  ) {

    lastSensorReadTime =
      currentMillis;


    // --------------------------------------------------------
    // READ PREVIOUS CONVERSION
    // --------------------------------------------------------

    float temperatureC =
      sensors.getTempCByIndex(0);


    // --------------------------------------------------------
    // START NEXT CONVERSION
    // --------------------------------------------------------

    sensors.requestTemperatures();


    // --------------------------------------------------------
    // CHECK SENSOR
    // --------------------------------------------------------

    if (
      temperatureC == DEVICE_DISCONNECTED_C ||
      temperatureC < -40.0 ||
      temperatureC > 85.0
    ) {

      Serial.println();
      Serial.println(
        "WARNING: DS18B20 SENSOR ERROR!"
      );

      Serial.println(
        "No valid temperature transmitted."
      );

      Serial.println(
        "Check sensor wiring."
      );

      Serial.println(
        "--------------------------------"
      );

      // IMPORTANT:
      // Do NOT send fake temperature.
      // Do NOT send 6.8 C fallback.

    }

    else {

      // ------------------------------------------------------
      // FORMAT TEMPERATURE
      // ------------------------------------------------------

      char tempStr[16];

      snprintf(
        tempStr,
        sizeof(tempStr),
        "%.1f C",
        temperatureC
      );


      // ------------------------------------------------------
      // SERIAL MONITOR
      // ------------------------------------------------------

      Serial.println();
      Serial.println("MILKORA");

      Serial.println(
        "BLE Device: MILKORA-CAN-01"
      );

      Serial.print(
        "Temperature: "
      );

      Serial.println(
        tempStr
      );


      // ------------------------------------------------------
      // BLE TRANSMISSION
      // ------------------------------------------------------

      if (deviceConnected) {

        Serial.println(
          "BLE: Connected"
        );

        // Update characteristic
        pTempCharacteristic->setValue(
          tempStr
        );

        // Send notification
        pTempCharacteristic->notify();

        Serial.println(
          "Temperature sent to phone"
        );

      }

      else {

        Serial.println(
          "BLE: Waiting for phone..."
        );
      }


      Serial.println(
        "--------------------------------"
      );
    }
  }


  // ==========================================================
  // HANDLE DISCONNECTION
  // ==========================================================

  if (
    !deviceConnected &&
    oldDeviceConnected
  ) {

    delay(200);

    pServer->startAdvertising();

    Serial.println(
      "BLE: Advertising restarted"
    );

    oldDeviceConnected =
      deviceConnected;
  }


  // ==========================================================
  // HANDLE NEW CONNECTION
  // ==========================================================

  if (
    deviceConnected &&
    !oldDeviceConnected
  ) {

    Serial.println(
      "BLE: Client connected successfully!"
    );

    oldDeviceConnected =
      deviceConnected;
  }


  // Small delay
  delay(10);
}