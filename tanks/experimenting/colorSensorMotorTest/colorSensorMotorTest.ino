#include <Wire.h>
#include "Adafruit_TCS34725.h"
int motorPin = 3;

/* Example code for the Adafruit TCS34725 breakout library */

/* Connect SCL    to analog 5
   Connect SDA    to analog 4
   Connect VDD    to 3.3V DC
   Connect GROUND to common ground */
   
/* Initialise with default values (int time = 2.4ms, gain = 1x) */
// Adafruit_TCS34725 tcs = Adafruit_TCS34725();

/* Initialise with specific int time and gain values */
Adafruit_TCS34725 tcs = Adafruit_TCS34725(TCS34725_INTEGRATIONTIME_2_4MS, TCS34725_GAIN_1X);

void setup(void) {
  tcs.begin();
  pinMode(motorPin, OUTPUT);
}

void loop(void) {
  uint16_t r, g, b, c;
  
  tcs.getRawData(&r, &g, &b, &c);
  
  if ((b > r) && (b > g)) {
    tcs.setInterrupt(false);      // turn on LED
    analogWrite(motorPin, 255);
  } else {
    tcs.setInterrupt(true);      // turn off LED
    if (g > r) {
      analogWrite(motorPin, 255/3);
    } else {
      analogWrite(motorPin, 0);
    }
  }
}
