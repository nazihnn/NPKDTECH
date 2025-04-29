#ifndef LINEAR_ACTUATOR_H
#define LINEAR_ACTUATOR_H

#include <Arduino.h>

// Define the pins for the actuator
const int ACTUATOR_PIN1 = D9; // Extend direction
const int ACTUATOR_PIN2 = D8; // Retract direction

// Function prototypes
void setupActuator();
void extendActuator();
void retractActuator();
void stopActuator();

#endif // LINEAR_ACTUATOR_H
