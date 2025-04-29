#ifndef NPK_sensor_H
#define NPK_sensor_H

#include <Arduino.h>
#include <SoftwareSerial.h>

// Pin definitions
#define RE 6
#define DE 7

const int npk_PIN1 = D5; // Extend direction
const int npk_PIN2 = D4; // Retract direction

// Modbus RTU requests
extern const byte nitro[];
extern const byte phos[];
extern const byte pota[];

// Functions for reading NPK values
byte nitrogen();
byte phosphorous();
byte potassium();
void setupnpk();
void npk_on();
void npk_off();
// Expose the SoftwareSerial object
extern SoftwareSerial mod;

#endif // NPK_sensor_H
