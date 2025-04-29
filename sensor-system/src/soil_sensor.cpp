#include "soil_sensor.h"

void setupSensor()
{
    pinMode(SENSOR_POWER, OUTPUT);

    // Initially keep the sensor OFF
    digitalWrite(SENSOR_POWER, HIGH);
}

int readSensor()
{
    digitalWrite(SENSOR_POWER, HIGH); // Turn the sensor ON
    // delay(10);                         // Allow power to settle
    int val = analogRead(SENSOR_PIN); // Read the analog value from the sensor
    digitalWrite(SENSOR_POWER, LOW);  // Turn the sensor OFF
    return val;                       // Return analog moisture value
}

int checkSoilStatus(int moisture)
{
    Serial.print("Analog Output: ");
    Serial.println(moisture);

    // Determine the status of our soil
    int moistureP = map(moisture, SOIL_DRY, SOIL_WET, 0, 100);
    int moisturePercent = constrain(moistureP, 0, 100);

    Serial.print("percenatge value");
    Serial.println(moisturePercent);

    return moisturePercent;
}
