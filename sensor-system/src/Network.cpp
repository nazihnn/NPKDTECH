#include "Network.h"

// #include <azure_ca.h>
// #include <az_iot.h>
// #include <ArduinoJson.h>
// #include "Esp32MQTTClient.h"
// #include <WiFiNINA.h>
// Connect to Wi-Fi
void Network::connect()
{
    Serial.println("Connecting to Wi-Fi...");
    WiFi.begin(ssid, password);

    while (WiFi.status() != WL_CONNECTED)
    {
        delay(1000);
        Serial.println("Connecting...");
    }

    Serial.println("Connected to Wi-Fi!");
    Serial.print("IP Address: ");
    Serial.println(WiFi.localIP());
}


// Get the IP address
IPAddress Network::getIPAddress()
{
    return WiFi.localIP();
}
