// Define the pin numbers
#define ENCODER_PIN 3           // Pin for encoder input (used in interrupt)
#define MOSFET_PIN 0            // Pin to control the MOSFET
#define VOLTAGE_PIN A1          // Pin to read voltage from the potential divider
#define OVERCHARGE_THRESHOLD 4.2  // Voltage threshold to activate the MOSFET (in Volts)

unsigned long previousMicros = 0;   // Variable to store the previous time in microseconds
unsigned long currentMicros = 0;    // Variable to store the current time in microseconds

void setup() {
  pinMode(ENCODER_PIN, INPUT);        // Set the encoder pin as input
  pinMode(MOSFET_PIN, OUTPUT);        // Set the MOSFET control pin as output
  Serial.begin(115200);               // Start the serial communication at 115200 baud rate
  while(!Serial);                     // Wait for the serial monitor to be connected
  
  previousMicros = micros();          // Get the initial time in microseconds
  attachInterrupt(digitalPinToInterrupt(ENCODER_PIN), encoderSig, RISING); // Set up interrupt on rising edge of encoder signal
}

void loop() {
  float voltage = readVoltage();  // Read the voltage from the potential divider

  if (voltage > OVERCHARGE_THRESHOLD) { // If the voltage exceeds the threshold, activate the MOSFET
    digitalWrite(MOSFET_PIN, HIGH);  // Turn on the MOSFET (allows current to flow through the resistors)
  } else {
    digitalWrite(MOSFET_PIN, LOW);   // Turn off the MOSFET (cuts current to high-powered resistors)
  }

  delay(1000);  // Wait 1 second before checking the voltage again (stabilise readings)
}

void encoderSig() {
  currentMicros = micros();  // Get the current time in microseconds
  comm(currentMicros - previousMicros);  // Send the time difference to the communication function
  previousMicros = currentMicros;  // Update previousMicros to the current value
}

void comm(unsigned long time_sig) {
  byte *byteArray = (byte *)&time_sig;  // Convert the unsigned long value to a byte array for transmission
  for (int i = 0; i < sizeof(time_sig); i++) {  // Loop through each byte of the time signal
    Serial.write(byteArray[i]);  // Send the byte to the serial port
  }
}

float readVoltage() {
  int sensorValue = analogRead(VOLTAGE_PIN);  // Read the raw sensor value from the potential divider
  // Convert the sensor value to voltage (assuming a 5V reference voltage for the Arduino)
  float voltage = (sensorValue / 1023.0) * 5.0;  
  return voltage;  // Return the calculated voltage
}
