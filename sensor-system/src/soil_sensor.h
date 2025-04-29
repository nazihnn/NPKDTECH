#ifndef SOIL_SENSOR_H
#define SOIL_SENSOR_H

#include <Arduino.h>

// The range of the sensor is from 1000 being completly wete and 3000 being dry
// Calibration values
#define SOIL_WET 1000 // Max value for 'wet' soil
#define SOIL_DRY 3000 // Min value for 'dry' soil

// Sensor pins
const int SENSOR_POWER = 7;
const int SENSOR_PIN = A0;
// volatile int moisturePercent;
// extern int moistureP;

// Function prototypes
void setupSensor();
int readSensor();
int checkSoilStatus(int moisture);

#endif // SOIL_SENSOR_H
