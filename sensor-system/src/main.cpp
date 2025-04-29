

/*code for tests withouth azure comment the code above and uncomment bellow to tests hardware functionallity*/
#include <Arduino.h>

#include "NPK_sensor.h"
#include "soil_sensor.h"
#include "linear_actuator.h"
#include "Network.h"
#include <WiFiClientSecure.h>
#include <FirebaseClient.h>
#include "DHT.h"
#include <TinyGPS++.h>

#define Web_API_KEY ""
#define DATABASE_URL ""
#define USER_EMAIL ""
#define USER_PASS ""

#define RX1PIN D6 // The Arduino Nano ESP32 pin connected to the TX of the GPS module
#define TX1PIN D7 // The Arduino Nano ESP32 pin connected to the RX of the GPS module

#define DHTPIN D4
#define DHTTYPE DHT11

// User function
void processData(AsyncResult &aResult);

// Authentication
UserAuth user_auth(Web_API_KEY, USER_EMAIL, USER_PASS);

Network network;
SoftwareSerial mod2(12, 11);

FirebaseApp app;
WiFiClientSecure ssl_client;
using AsyncClient = AsyncClientClass;
AsyncClient aClient(ssl_client);
RealtimeDatabase Database;
int intValue;
String stringValue;
// Timer variables for sending data every 10 seconds
unsigned long lastSendTime = 0;
const unsigned long sendInterval = 5000; // 10 seconds in milliseconds

int commaIndex;

int ranges[][2] = {

    {75, 80},
    {150, 170}};

bool isInRange(int value)
{
  for (int i = 0; i < sizeof(ranges) / sizeof(ranges[0]); i++)
  {
    if (value >= ranges[i][0] && value <= ranges[i][1])
    {
      ranges[i][0] = 0;
      ranges[i][1] = 0;
      return true;
    }
  }
  return false;
}
String up = "up";
String down = "down";

void receiveddata(AsyncResult &aResult)
{
  if (!aResult.isResult())
    return;

  if (aResult.isEvent())
    Firebase.printf("Event task: %s, msg: %s, code: %d\n", aResult.uid().c_str(), aResult.eventLog().message().c_str(), aResult.eventLog().code());

  if (aResult.isDebug())
    Firebase.printf("Debug task: %s, msg: %s\n", aResult.uid().c_str(), aResult.debug().c_str());

  if (aResult.isError())
    Firebase.printf("Error task: %s, msg: %s, code: %d\n", aResult.uid().c_str(), aResult.error().message().c_str(), aResult.error().code());

  if (aResult.available())
  { // Log the task and payload
    Firebase.printf("task: %s, payload: %s\n", aResult.uid().c_str(), aResult.c_str());

    // Extract the payload as a String
    String payload = aResult.c_str();

    /// Handle int from /test/int
    if (aResult.uid() == "RTDB_Getactuator")
    {
      // Extract the value as an int
      // intValue = payload.toInt();
      stringValue = payload;
      if (stringValue == up)
      {
        Serial.println("retracting");
        retractActuator();
      }
      else if (stringValue == down)
      {
        Serial.println("extending!!!");
        extendActuator();
      }
      // Serial.println("Payload: '%s', StringValue: '%s'\n", payload.c_str(), stringValue.c_str());
      Firebase.printf("Stored stringValue: %s\n", stringValue.c_str());
    }
  }
}
// Define the processData function
void processData(AsyncResult &aResult)
{
  if (!aResult.isResult())
    return;

  if (aResult.isEvent())
    Firebase.printf("Event task: %s, msg: %s, code: %d\n", aResult.uid().c_str(), aResult.eventLog().message().c_str(), aResult.eventLog().code());

  if (aResult.isDebug())
    Firebase.printf("Debug task: %s, msg: %s\n", aResult.uid().c_str(), aResult.debug().c_str());

  if (aResult.isError())
    Firebase.printf("Error task: %s, msg: %s, code: %d\n", aResult.uid().c_str(), aResult.error().message().c_str(), aResult.error().code());

  if (aResult.available())
  {
    // Log the task and payload
    Firebase.printf("task: %s, payload: %s\n", aResult.uid().c_str(), aResult.c_str());
  }
}

DHT dht(DHTPIN, DHTTYPE); // constructor to declare our sensor
TinyGPSPlus gps;          // The TinyGPS++ object

void setup()
{
  Serial.begin(9600);

  // Initialize modbus communication
  mod.begin(9600);
  mod2.begin(9600);
  Serial1.begin(9600, SERIAL_8N1, RX1PIN, TX1PIN);

  network.connect();
  setupnpk();
  npk_off();
  // // Define pin modes for RE and DE
  pinMode(RE, OUTPUT);
  pinMode(DE, OUTPUT);
  setupSensor();   // Initialize the soil sensor
  setupActuator(); // Initialize the actuator pins
  delay(500);
  dht.begin();
  // Configure SSL client
  ssl_client.setInsecure();
  // ssl_client.setConnectionTimeout(1000);
  ssl_client.setHandshakeTimeout(1000);
  ssl_client.setHandshakeTimeout(5);

  // Initialize Firebase
  initializeApp(aClient, app, getAuth(user_auth), processData, "🔐 authTask");
  app.getApp<RealtimeDatabase>(Database);
  Database.url(DATABASE_URL);
}
float lat;
float lng;
float speed;
void loop()
{

  int x_uwb;
  int y_uwb;

  app.loop();
  // Check if authentication is ready
  if (app.ready())
  {
    if (Serial1.available() > 0)
    {
      if (gps.encode(Serial1.read()))
      {
        if (gps.location.isValid())
        {

          lat = gps.location.lat();
          Serial.print(F("- latitude: "));
          Serial.println(lat);

          lng = gps.location.lng();
          Serial.print(F("- longitude: "));
          Serial.println(gps.location.lng());
        }
        else
        {
          Serial.println(F("- location: INVALID"));
        }

        Serial.print(F("- speed: "));
        if (gps.speed.isValid())
        {
          speed = gps.speed.kmph();
          Serial.print(gps.speed.kmph());
          Serial.println(F(" km/h"));
        }
        else
        {
          Serial.println(F("INVALID"));
        }

        Serial.println();
      }
    }

    if (millis() > 5000 && gps.charsProcessed() < 10)
      Serial.println(F("No GPS data received: check wiring"));

    unsigned long currentTime = millis();
    if (currentTime - lastSendTime >= sendInterval)
    {
      // Update the last send time
      lastSendTime = currentTime;

      // if (mod2.available())
      // {
      String data = "";
      x_uwb = -100,
      y_uwb = -100,
      data = mod2.readStringUntil('\n'); // Read until newline
      Serial.println("Received: " + data);

      commaIndex = data.indexOf(',');
      if (commaIndex == -1)
      {
        Serial.println("Invalid format - missing comma");
      }

      x_uwb = data.substring(0, commaIndex).toInt();
      y_uwb = data.substring(commaIndex + 1).toInt();

      // }
      Serial.print("x:");
      Serial.println(x_uwb);
      Serial.print("y:");
      Serial.println(y_uwb);
      // The DHT11 returns at most one measurement every 1s
      float humid = dht.readHumidity();
      // Read the moisture content in %.
      float tempc = dht.readTemperature();
      // Read the temperature in degrees Celsius
      float tempf = dht.readTemperature(true);
      // true returns the temperature in Fahrenheit

      if (isnan(humid) || isnan(tempc) || isnan(tempf))
      {
        Serial.println("Failed reception");
        return;
        // Returns an error if the ESP32 does not receive any measurements
      }

      Serial.print("Humidite: ");
      Serial.print(humid);
      Serial.print("%  Temperature: ");
      Serial.print(tempc);
      Serial.print("°C, ");
      Serial.print(tempf);
      Serial.println("°F");
      // Serial.println("Extending actuator...");

      // extendActuator();
      // delay(15000);

      npk_on();

      Serial.println("the npk is on!!!!");

      // delay(10000);
      byte val1, val2, val3;
      val1 = nitrogen();
      // delay(250);
      val2 = phosphorous();
      // delay(250);
      val3 = potassium();
      // delay(250);
      String stringValue_status = "sampling"; //+ "  Phosphorus:" + String(val2) + "  Potassium:" + String(val3) + "  Moisture:" + String(moisture);
      Database.set<String>(aClient, "/Status/job", stringValue_status, processData, "RTDB_Send_status");
      // Print values to the serial monitor
      Serial.print("Nitrogen: ");
      Serial.print(val1);
      Serial.println(" mg/kg");
      Serial.print("Phosphorous: ");
      Serial.print(val2);
      Serial.println(" mg/kg");
      Serial.print("Potassium: ");
      Serial.print(val3);
      Serial.println(" mg/kg");
      npk_off();
      Serial.println("the npk is off!!!!");

      int moisture = readSensor();                // Get the soil moisture value
      int percenatge = checkSoilStatus(moisture); // Check and print the status
      // Send values to the database
      String stringValue_nitrogen = String(val1); //+ "  Phosphorus:" + String(val2) + "  Potassium:" + String(val3) + "  Moisture:" + String(moisture);
      Database.set<String>(aClient, "/NPK/nitrogen", stringValue_nitrogen, processData, "RTDB_Send_Nitrogen");

      String stringValue_phosphorus = String(val2);
      Database.set<String>(aClient, "/NPK/phosphorus", stringValue_phosphorus, processData, "RTDB_Send_Phosphorus");

      String stringValue_potassium = String(val3);
      Database.set<String>(aClient, "/NPK/potassium", stringValue_potassium, processData, "RTDB_Send_Potassium");

      String stringValue_moisture = String(percenatge);
      Database.set<String>(aClient, "/NPK/moisture", stringValue_moisture, processData, "RTDB_Send_Moisture");
      // Retract the actuator for 10 seconds

      String stringValue_humidity = String(humid);
      Database.set<String>(aClient, "/Outside/humidity", stringValue_humidity, processData, "RTDB_Send_humid");

      String stringValue_tempf = String(tempf);
      Database.set<String>(aClient, "/Outside/far", stringValue_tempf, processData, "RTDB_Send_tempf");

      String stringValue_tempc = String(tempc);
      Database.set<String>(aClient, "/Outside/cel", stringValue_tempc, processData, "RTDB_Send_tempc");

      float stringValue_lat = lat;
      Database.set<float>(aClient, "/Outside/latitude", stringValue_lat, processData, "RTDB_Send_lat");

      float stringValue_lng = lng;
      Database.set<float>(aClient, "/Outside/longitude", stringValue_lng, processData, "RTDB_Send_lng");

      String stringValue_speed = String(speed);
      Database.set<String>(aClient, "/Outside/speed", stringValue_speed, processData, "RTDB_Send_speed");

      String stringValue_x = String(x_uwb);
      Database.set<String>(aClient, "/UWB/x", stringValue_x, processData, "RTDB_Send_x");
      String stringValue_y = String(y_uwb);
      Database.set<String>(aClient, "/UWB/y", stringValue_y, processData, "RTDB_Send_y");

      Database.get(aClient, "/Controls/actuator", receiveddata, false, "RTDB_Getactuator");

      if (stringValue == "down")
      {
        extendActuator();
        Firebase.printf("Stored stringValue: %s\n", stringValue.c_str());
        Serial.println("value is down in main");
      }
      else if (stringValue == "up")
      {
        retractActuator();
        Firebase.printf("Stored stringValue: %s\n", stringValue.c_str());
        Serial.println("value is up  in main");
      }
      else
      {
        stopActuator();
      }
      // Serial.println("Retracting actuator...");
      // retractActuator();
      // delay(10000);
    }
  }
}

// SoftwareSerial mod2(12, 11);
// // char values[20];
// // size_t size = 10;
// void setup()
// {
//   mod2.begin(9600);
//   Serial.begin(9600);
// }

// void loop()
// {

//   // char x = mod2.read();
//   String data = "";
//   if (mod2.available())
//   {
//     data = mod2.readStringUntil('\n'); // Read until newline
//     Serial.println("Received: " + data);
//   }
// }
