#include <Arduino.h>
#include <SoftwareSerial.h>

#define rxPin 13
#define txPin 12
SoftwareSerial mySerial(rxPin, txPin); // RX, TX
char myChar;
int i = 0;
void setup()
{
  Serial.begin(57600);
  Serial.println("Beginning");
  mySerial.begin(57600);
}
void loop()
{
  while (mySerial.available())
  {
    myChar = mySerial.read();
    Serial.print(myChar);
    //Serial.println(""); // when converted to hex, this prints 0d 0a
  }
}