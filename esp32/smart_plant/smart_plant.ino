#include <Arduino.h>
#include <WiFi.h>
#include <time.h>
#include <Firebase_ESP_Client.h>

// Required for Firebase token generation
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"

// 1. Network Credentials
#define WIFI_SSID "YOUR_WIFI_SSID"
#define WIFI_PASSWORD "YOUR_WIFI_PASSWORD"

// 2. Firebase Credentials
#define API_KEY "YOUR_FIREBASE_API_KEY"
#define PROJECT_ID "YOUR_FIREBASE_PROJECT_ID"
#define USER_EMAIL "YOUR_FIREBASE_USER_EMAIL"
#define USER_PASSWORD "YOUR_FIREBASE_USER_PASSWORD"

// 3. Hardware Pins
#define PUMP_PIN 5
#define SOIL_MOISTURE_PIN 36 // A0
#define TEMP_PIN 39          
#define WATER_LEVEL_PIN 34   

// 4. Firebase Objects
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

String documentPath = "devices/plant_001";

unsigned long lastUpdateMillis = 0;
const unsigned long UPDATE_INTERVAL = 3000; // 3 seconds

// 5. State Variables
bool pumpState = false;
bool isAutomatic = false;
double threshold = 30.0;
int wateringDuration = 5;

unsigned long wateringStartTime = 0;
bool isWateringActive = false;

// Function Prototypes
void readFirestoreData();
void publishSensorData(double soilMoisture, double temperature, double waterLevel);
void updateFirestorePumpState(bool state);
String getIsoTimestamp();

void setup() {
  Serial.begin(115200);
  
  pinMode(PUMP_PIN, OUTPUT);
  digitalWrite(PUMP_PIN, LOW);

  // Connect to Wi-Fi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println("\nConnected to Wi-Fi!");

  // Initialize NTP for timestamping
  configTime(0, 0, "pool.ntp.org", "time.nist.gov");

  // Initialize Firebase
  config.api_key = API_KEY;
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;
  config.token_status_callback = tokenStatusCallback; 

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
}

void loop() {
  // 1. Process Hardware Automation Logic
  if (isWateringActive) {
    if (millis() - wateringStartTime >= (wateringDuration * 1000UL)) {
      isWateringActive = false;
      pumpState = false;
      digitalWrite(PUMP_PIN, LOW);
      
      // Immediately notify the cloud that watering is finished
      updateFirestorePumpState(false);
      Serial.println("Automatic watering cycle finished.");
    }
  }

  // 2. Process Cloud Sync (Every 3 seconds)
  if (Firebase.ready() && (millis() - lastUpdateMillis > UPDATE_INTERVAL)) {
    lastUpdateMillis = millis();

    // A. Read Physical Sensors
    // (Note: math conversions depend on your exact sensor hardware)
    int rawSoil = analogRead(SOIL_MOISTURE_PIN);
    double soilMoisture = map(rawSoil, 4095, 0, 0, 100); 

    int rawTemp = analogRead(TEMP_PIN);
    double temperature = rawTemp * (330.0 / 4095.0); 

    int rawLevel = analogRead(WATER_LEVEL_PIN);
    double waterLevel = map(rawLevel, 0, 4095, 0, 100);
    
    // Clamp the ranges physically
    soilMoisture = constrain(soilMoisture, 0.0, 100.0);
    waterLevel = constrain(waterLevel, 0.0, 100.0);

    // B. Read commands from Firestore
    readFirestoreData();

    // C. Handle Automatic Triggering 
    // Do not start if already watering or if pump was manually forced ON
    if (isAutomatic && soilMoisture < threshold && !isWateringActive && !pumpState) {
      isWateringActive = true;
      pumpState = true;
      digitalWrite(PUMP_PIN, HIGH);
      wateringStartTime = millis();
      Serial.println("Automatic watering triggered!");
    }
    
    // D. Handle Manual Override
    if (!isWateringActive) {
      if (pumpState) {
        digitalWrite(PUMP_PIN, HIGH);
      } else {
        digitalWrite(PUMP_PIN, LOW);
      }
    }

    // E. Upload sensor states back to Firestore
    publishSensorData(soilMoisture, temperature, waterLevel);
  }
}

void readFirestoreData() {
  // Pull down the document from Firestore
  if (Firebase.Firestore.getDocument(&fbdo, PROJECT_ID, "", documentPath.c_str(), "")) {
    FirebaseJson json(fbdo.payload().c_str());
    FirebaseJsonData jsonData;
    
    json.get(jsonData, "fields/pump/booleanValue");
    if (jsonData.success) pumpState = jsonData.boolValue;
    
    json.get(jsonData, "fields/automatic/booleanValue");
    if (jsonData.success) isAutomatic = jsonData.boolValue;
    
    json.get(jsonData, "fields/threshold/doubleValue");
    if (jsonData.success) threshold = jsonData.doubleValue;
    
    json.get(jsonData, "fields/wateringDuration/integerValue");
    if (jsonData.success) wateringDuration = jsonData.intValue;
    
  } else {
    Serial.println("Error reading Firestore: " + fbdo.errorReason());
  }
}

void publishSensorData(double soilMoisture, double temperature, double waterLevel) {
  FirebaseJson content;
  content.set("fields/soilMoisture/doubleValue", soilMoisture);
  content.set("fields/temperature/doubleValue", temperature);
  content.set("fields/waterLevel/doubleValue", waterLevel);
  content.set("fields/online/booleanValue", true);
  
  // Set the current timestamp
  content.set("fields/lastUpdated/timestampValue", getIsoTimestamp());
  
  // Patch pump state to mirror ESP32 truth back to Flutter app
  content.set("fields/pump/booleanValue", pumpState);

  String updateMask = "soilMoisture,temperature,waterLevel,online,lastUpdated,pump";
  
  if (Firebase.Firestore.patchDocument(&fbdo, PROJECT_ID, "", documentPath.c_str(), content.raw(), updateMask)) {
    Serial.println("Sensor data uploaded successfully.");
  } else {
    Serial.println("Error writing Firestore: " + fbdo.errorReason());
  }
}

void updateFirestorePumpState(bool state) {
  FirebaseJson content;
  content.set("fields/pump/booleanValue", state);
  String updateMask = "pump";
  Firebase.Firestore.patchDocument(&fbdo, PROJECT_ID, "", documentPath.c_str(), content.raw(), updateMask);
}

String getIsoTimestamp() {
  struct tm timeinfo;
  if(!getLocalTime(&timeinfo)){
    return "1970-01-01T00:00:00Z";
  }
  char timeStringBuff[50];
  strftime(timeStringBuff, sizeof(timeStringBuff), "%Y-%m-%dT%H:%M:%SZ", &timeinfo);
  return String(timeStringBuff);
}
