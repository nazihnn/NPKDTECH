#include "linear_actuator.h"

void setupActuator()
{
    pinMode(ACTUATOR_PIN1, OUTPUT);
    pinMode(ACTUATOR_PIN2, OUTPUT);

    // Initially stop the actuator
    stopActuator();
}

void extendActuator()
{
    Serial.println("Extending actuator...");
    analogWrite(A0, 255); // ENA   pin
    digitalWrite(ACTUATOR_PIN1, HIGH);
    digitalWrite(ACTUATOR_PIN2, LOW);
    // delay(5000);
}

void retractActuator()
{
    Serial.println("Retracting actuator...");
    analogWrite(A0, 255); // ENA   pin
    digitalWrite(ACTUATOR_PIN1, LOW);
    digitalWrite(ACTUATOR_PIN2, HIGH);
    // delay(5000);
}

void stopActuator()
{
    analogWrite(A0, 0); // ENA   pin
    digitalWrite(ACTUATOR_PIN1, LOW);
    digitalWrite(ACTUATOR_PIN2, LOW);
}

/*TEST CODE FOR LINEAR ACTUATOR COPY INTO MAIN*/
/*
int motorPin1 = 9;
int motorPin2 = 8;


void setup() {
  // put your setup code here, to run once:
  pinMode(motorPin1, OUTPUT);
   pinMode(motorPin2, OUTPUT);


  //(Optional)
  pinMode(9,  OUTPUT);
  pinMode(10, OUTPUT);
  //(Optional)
}

void loop() {
   // put your main code here, to run repeatedly:

  //Controlling speed (0   = off and 255 = max speed):
  //(Optional)
  analogWrite(A0, 255); //ENA   pin
  //(Optional)

  digitalWrite(motorPin1, HIGH);
  digitalWrite(motorPin2, LOW);

  delay(10000);

  digitalWrite(motorPin1,   LOW);
  digitalWrite(motorPin2, HIGH);

  delay(10000);
}*/