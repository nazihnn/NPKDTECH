#include "NPK_sensor.h"

// Modbus RTU requests
const byte nitro[] = {0x01, 0x03, 0x00, 0x1e, 0x00, 0x01, 0xe4, 0x0c};
const byte phos[] = {0x01, 0x03, 0x00, 0x1f, 0x00, 0x01, 0xb5, 0xcc};
const byte pota[] = {0x01, 0x03, 0x00, 0x20, 0x00, 0x01, 0x85, 0xc0};

// SoftwareSerial object
SoftwareSerial mod(0, 1);

// A variable used to store NPK values
byte values[11];

byte nitrogen()
{
    digitalWrite(DE, HIGH);
    digitalWrite(RE, HIGH);
    delay(10);
    if (mod.write(nitro, sizeof(nitro)) == 8)
    {
        digitalWrite(DE, LOW);
        digitalWrite(RE, LOW);
        for (byte i = 0; i < 7; i++)
        {
            values[i] = mod.read();
            Serial.print(values[i], HEX);
        }
        Serial.println();
    }
    return values[4];
}

byte phosphorous()
{
    digitalWrite(DE, HIGH);
    digitalWrite(RE, HIGH);
    delay(10);
    if (mod.write(phos, sizeof(phos)) == 8)
    {
        digitalWrite(DE, LOW);
        digitalWrite(RE, LOW);
        for (byte i = 0; i < 7; i++)
        {
            values[i] = mod.read();
            Serial.print(values[i], HEX);
        }
        Serial.println();
    }
    return values[4];
}

byte potassium()
{
    digitalWrite(DE, HIGH);
    digitalWrite(RE, HIGH);
    delay(10);
    if (mod.write(pota, sizeof(pota)) == 8)
    {
        digitalWrite(DE, LOW);
        digitalWrite(RE, LOW);
        for (byte i = 0; i < 7; i++)
        {
            values[i] = mod.read();
            Serial.print(values[i], HEX);
        }
        Serial.println();
    }
    return values[4];
}

void setupnpk()
{
    pinMode(npk_PIN1, OUTPUT);
    pinMode(npk_PIN2, OUTPUT);

    // Initially stop the actuator
}

void npk_on()
{
    analogWrite(A0, 255); // ENA   pin
    digitalWrite(npk_PIN1, HIGH);
    digitalWrite(npk_PIN2, LOW);
}
void npk_off()
{
    analogWrite(A0, 255); // ENA   pin
    digitalWrite(npk_PIN1, LOW);
    digitalWrite(npk_PIN2, LOW);
}

/* TEST CODE FOR NPK SENSOR COPY TO MAIN*/
/*#include "NPK_sensor.h"

void setup() {
    Serial.begin(9600);

    // Initialize modbus communication
    mod.begin(9600);

    // Define pin modes for RE and DE
    pinMode(RE, OUTPUT);
    pinMode(DE, OUTPUT);

    delay(500);
}

void loop() {
    byte val1, val2, val3;
    val1 = nitrogen();
    delay(250);
    val2 = phosphorous();
    delay(250);
    val3 = potassium();
    delay(250);

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

    delay(2000);
}
*/