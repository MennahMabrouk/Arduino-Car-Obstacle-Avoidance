#include <NewPing.h>
#include <IRremote.h>

#define ULTRASONIC_SENSOR_TRIG 13
#define ULTRASONIC_SENSOR_ECHO 12
#define MAX_MOTOR_SPEED 100
#define DISTANCE_TO_CHECK 30.0
#define BUZZER_PIN_POSITIVE 8
#define BUZZER_PIN_NEGATIVE 11
#define TSOP_PIN 3

// Right motor
int enableRightMotor = 9;
int rightMotorPin1 = 4;
int rightMotorPin2 = 5;

// Left motor
int enableLeftMotor = 10;
int leftMotorPin1 = 6;
int leftMotorPin2 = 7;

NewPing mySensor(ULTRASONIC_SENSOR_TRIG, ULTRASONIC_SENSOR_ECHO, 300);
IRrecv irReceiver(TSOP_PIN);

const unsigned int LEFT_BUTTON_CODE = 0x47;    // Button for turning the robot left
const unsigned int RIGHT_BUTTON_CODE = 0x7;    // Button for turning the robot right
const unsigned int BACKWARD_BUTTON_CODE = 0x48; // Button for moving the robot backward
const unsigned int FORWARD_BUTTON_CODE = 0x1A;  // Button for moving the robot forward

void setup()
{
  pinMode(enableRightMotor, OUTPUT);
  pinMode(rightMotorPin1, OUTPUT);
  pinMode(rightMotorPin2, OUTPUT);

  pinMode(enableLeftMotor, OUTPUT);
  pinMode(leftMotorPin1, OUTPUT);
  pinMode(leftMotorPin2, OUTPUT);

  pinMode(BUZZER_PIN_POSITIVE, OUTPUT);
  pinMode(BUZZER_PIN_NEGATIVE, OUTPUT);

  Serial.begin(9600);
  rotateMotor(MAX_MOTOR_SPEED, MAX_MOTOR_SPEED); // forward

  irReceiver.enableIRIn();
}

void loop()
{
  // Check for ultrasonic distance
  float distance = mySensor.ping_cm();
  Serial.println(distance);

  // Check for infrared remote signals
  if (irReceiver.decode())
  {
    // Process the received infrared signal
    switch (irReceiver.decodedIRData.command)
    {
      case FORWARD_BUTTON_CODE: // Button for moving the robot forward
        rotateMotor(MAX_MOTOR_SPEED, MAX_MOTOR_SPEED);
        break;

      case BACKWARD_BUTTON_CODE: // Button for moving the robot backward
        rotateMotor(-MAX_MOTOR_SPEED, -MAX_MOTOR_SPEED);
        break;

      case LEFT_BUTTON_CODE: // Button for turning the robot left
        rotateMotor(-MAX_MOTOR_SPEED, MAX_MOTOR_SPEED);
        break;

      case RIGHT_BUTTON_CODE: // Button for turning the robot right
        rotateMotor(MAX_MOTOR_SPEED, -MAX_MOTOR_SPEED);
        break;

      default:
        break;
    }

    irReceiver.resume(); // Receive the next value
  }

  if (distance > 0.0 && distance < DISTANCE_TO_CHECK)
  {
    rotateMotor(0, 0); // stop
    digitalWrite(BUZZER_PIN_POSITIVE, HIGH); // turn on the buzzer
    delay(500);

    rotateMotor(-MAX_MOTOR_SPEED, -MAX_MOTOR_SPEED);
    delay(200); // back

    rotateMotor(0, 0);
    digitalWrite(BUZZER_PIN_POSITIVE, LOW); // turn off the buzzer
    delay(500);

    rotateMotor(MAX_MOTOR_SPEED, -MAX_MOTOR_SPEED);
    delay(200);
  }
  else
  {
    rotateMotor(MAX_MOTOR_SPEED, MAX_MOTOR_SPEED);
    digitalWrite(BUZZER_PIN_POSITIVE, LOW); // turn off the buzzer
    delay(50);
  }
}

void rotateMotor(int rightMotorSpeed, int leftMotorSpeed)
{
  if (rightMotorSpeed < 0)
  {
    digitalWrite(rightMotorPin1, LOW);
    digitalWrite(rightMotorPin2, HIGH);
  }
  else if (rightMotorSpeed >= 0)
  {
    digitalWrite(rightMotorPin1, HIGH);
    digitalWrite(rightMotorPin2, LOW);
  }

  if (leftMotorSpeed < 0)
  {
    digitalWrite(leftMotorPin1, LOW);
    digitalWrite(leftMotorPin2, HIGH);
  }
  else if (leftMotorSpeed >= 0)
  {
    digitalWrite(leftMotorPin1, HIGH);
    digitalWrite(leftMotorPin2, LOW);
  }

  analogWrite(enableRightMotor, abs(rightMotorSpeed));
  analogWrite(enableLeftMotor, abs(leftMotorSpeed));
}
