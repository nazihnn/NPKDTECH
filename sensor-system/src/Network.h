#ifndef NETWORK_H
#define NETWORK_H

#include <WiFi.h>
#include <PubSubClient.h>
#include "Esp32MQTTClient.h"

// Azure IoT
#define IOT_CONFIG_IOTHUB_FQDN \
    "DDS.azure-devices.net"
#define IOT_CONFIG_DEVICE_ID "ultrasonicsensor"
#define IOT_CONFIG_DEVICE_KEY "HostName=DDS.azure-devices.net;DeviceId=ultrasonicsensor;SharedAccessKey=MV1FII4y70Qdvp87yQJavV5unf0FSxdgMWKCT7rOMDc="

// Sensor configuration:
#define TELEMETRY_FREQUENCY_MILLISECS 60000 // We send telemetry every 60s
#define NUM_MILISECONDS_BETWEEN_SAMPLES 250 // We take a sample every 250ms
#define PERSON_DETECTED_THRESHOLD 100       // We determine a person in present if AVG(samples)>=PERSON_DETECTED_THRESHOLD
#define MAX_SENSOR_DISTANCE_CM 400          // Max distance (cm) where the sensor provides accurate readings.

class Network
{
private:
    // const char *ssid = "vodafone649ADC";
    // const char *password = "3LFd7sXhLfnenMyy";
    const char *ssid = "vodafone649ADC";       //"MSc_IoT";         // Wi-Fi SSID (private)
    const char *password = "3LFd7sXhLfnenMyy"; //"MSc_IoT@UCL"; // Wi-Fi password (private)

    // const char *connectionString = "HostName=NPKdTECH.azure-devices.net;DeviceId=npk;SharedAccessKey=fYfTLVUlGj4cBtWEQkXYJqmaA2bLxaY10o2VlwAd+ak=";
    // bool hasIoTHub = false;

    // const char *mqttServer = "****";
    // const int mqttPort = 1883;
    // String MQTTTopic;
    // String MQTTPayload;

    // Azure IOT Hub Setup

public:
    // Constructor to initialize SSID and password

    // Connect to Wi-Fi
    void
    connect();
    // Get the current IP address
    IPAddress getIPAddress();
    // bool initializeIoTHubClient();
    // bool initializeMqttClient();
    // void generateAndSendTelemetry();
};

#endif
