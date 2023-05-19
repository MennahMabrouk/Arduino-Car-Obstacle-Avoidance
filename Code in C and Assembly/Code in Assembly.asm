.include "m328pdef.inc" ; Include the ATmega328P definition file

.equ ULTRASONIC_SENSOR_TRIG, 13
.equ ULTRASONIC_SENSOR_ECHO, 12
.equ MAX_MOTOR_SPEED, 100
.equ DISTANCE_TO_CHECK, 30
.equ BUZZER_PIN_POSITIVE, 8
.equ BUZZER_PIN_NEGATIVE, 11
.equ TSOP_PIN, 3

.equ enableRightMotor, 9
.equ rightMotorPin1, 4
.equ rightMotorPin2, 5

.equ enableLeftMotor, 10
.equ leftMotorPin1, 6
.equ leftMotorPin2, 7

.equ LEFT_BUTTON_CODE, 0x47
.equ RIGHT_BUTTON_CODE, 0x7
.equ BACKWARD_BUTTON_CODE, 0x48
.equ FORWARD_BUTTON_CODE, 0x1A

.section .data
mySensor: .word 0 ; Variable to hold the address of NewPing instance
irReceiver: .word 0 ; Variable to hold the address of IRrecv instance

.section .text
.global main

main:
    ; Initialize the pins
    ldi r16, (1 << rightMotorPin1) | (1 << rightMotorPin2) | (1 << leftMotorPin1) | (1 << leftMotorPin2)
    out DDRD, r16

    ldi r16, (1 << enableRightMotor) | (1 << enableLeftMotor)
    out DDRB, r16

    ldi r16, (1 << BUZZER_PIN_POSITIVE) | (1 << BUZZER_PIN_NEGATIVE)
    out DDRB, r16

    ; Initialize serial communication
    ldi r16, (1 << RXEN0) | (1 << TXEN0)
    out UCSR0B, r16
    ldi r16, (1 << UCSZ01) | (1 << UCSZ00)
    out UCSR0C, r16
    ldi r16, 103 ; 9600 baud rate
    out UBRR0H, r16
    ldi r16, 0
    out UBRR0L, r16

    ; Initialize NewPing instance
    ldi r16, hi8(mySensor)
    ldi r17, lo8(mySensor)
    lds r18, NewPing_ping_cm_ptr
    call r18

    ; Initialize IRrecv instance
    ldi r16, hi8(irReceiver)
    ldi r17, lo8(irReceiver)
    lds r18, IRrecv_enableIRIn_ptr
    call r18

loop:
    ; Check for ultrasonic distance
    lds r18, NewPing_ping_cm_ptr
    call r18

    ; Print distance value
    lds r20, mySensor
    ldd r21, r20
    ldd r22, r20+1
    ; Convert distance to string
    ; Print the string using serial communication

    ; Check for infrared remote signals
    lds r18, IRrecv_decode_ptr
    call r18

    tst r24 ; Check if IR signal received
    brne process_ir_signal

continue_rotation:
    ; Rotate motor at maximum speed
    ldi r24, MAX_MOTOR_SPEED
    ldi r25, MAX_MOTOR_SPEED
    call rotateMotor

    ; Turn off the buzzer
    ldi r16, (1 << BUZZER_PIN_POSITIVE)
    out PORTB, r16

    rjmp loop

process_ir_signal:
    ; Process the received infrared signal
    lds r20, irReceiver
    ldd r21, r20
    ldd r22, r20+1

    ; Check the received IR signal code
    cpi r22, HIGH_BYTE(FORWARD_BUTTON_CODE)
    breq move_forward

    cpi r22, HIGH_BYTE(BACKWARD_BUTTON_CODE)
    breq move_backward

    cpi r22, HIGH_BYTE(LEFT_BUTTON_CODE)
    breq turn_left

    cpi r22, HIGH_BYTE(RIGHT_BUTTON_CODE)
    breq turn_right

    ; Handle other cases

    rjmp loop

move_forward:
    ; Rotate motor forward
    ldi r24, MAX_MOTOR_SPEED
    ldi r25, MAX_MOTOR_SPEED
    call rotateMotor
    rjmp loop

move_backward:
    ; Rotate motor backward
    ldi r24, -MAX_MOTOR_SPEED
    ldi r25, -MAX_MOTOR_SPEED
    call rotateMotor
    rjmp loop

turn_left:
    ; Rotate motor left
    ldi r24, -MAX_MOTOR_SPEED
    ldi r25, MAX_MOTOR_SPEED
    call rotateMotor
    rjmp loop

turn_right:
    ; Rotate motor right
    ldi r24, MAX_MOTOR_SPEED
    ldi r25, -MAX_MOTOR_SPEED
    call rotateMotor
    rjmp loop

rotateMotor:
    ; Save the current context
    push r16
    push r17
    push r18
    push r19

    ; Configure motor direction
    tst r24
    bpl right_motor_forward
    ; Right motor backward
    sbi PORTD, rightMotorPin1
    cbi PORTD, rightMotorPin2
    rjmp left_motor_direction

right_motor_forward:
    ; Right motor forward
    cbi PORTD, rightMotorPin1
    sbi PORTD, rightMotorPin2

left_motor_direction:
    tst r25
    bpl left_motor_forward
    ; Left motor backward
    sbi PORTD, leftMotorPin1
    cbi PORTD, leftMotorPin2
    rjmp set_motor_speed

left_motor_forward:
    ; Left motor forward
    cbi PORTD, leftMotorPin1
    sbi PORTD, leftMotorPin2

set_motor_speed:
    ; Set motor speed using PWM
    mov r16, r24
    call abs_value ; Calculate absolute value of the right motor speed
    mov r24, r16
    mov r16, r25
    call abs_value ; Calculate absolute value of the left motor speed
    mov r25, r16

    ; Set PWM duty cycle
    out OCR1A, r24 ; Right motor
    out OCR1B, r25 ; Left motor

    ; Restore the context
    pop r19
    pop r18
    pop r17
    pop r16
    ret

value:
    tst r16 ; Check if the input value is negative
    brpl abs_end
    neg r16 ; Negate the value
end:
    ret

.end

