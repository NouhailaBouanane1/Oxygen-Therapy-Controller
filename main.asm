__CONFIG _DEBUG_OFF&_CP_OFF&_WRT_HALF&_CPD_OFF&_LVP_OFF&_BODEN_OFF&_PWRTE_OFF&_WDT_OFF&_XT_OSC

#INCLUDE "P16F877A.INC"


COUNTER	EQU 20H
COUNTER2 EQU 21H
ADC0	EQU 22H
ADC1	EQU 23H
VOLH	EQU 24H
VOLL	EQU 25H
RATEMP	EQU 26H
RATE1	EQU 27H
RATE2	EQU 28H
RATETOT	EQU 29H
INTCONT	EQU 30H


DIV		EQU 30H
MOD		EQU 31H
VAL		EQU 32H
OPER	EQU 33H
VAL1	EQU 34H
MAP		EQU 35H

DIG0	EQU 40H
DIG1	EQU 41H
DIG2	EQU 42H
DIG3	EQU 43H





;MAIN ROUTINE
ORG 0H
	GOTO MAIN

MAIN
	BANKSEL TRISD
	MOVLW 00FH         		;PORTA bit Number0, Number1 and Number 2 is INPUTS FOR ADC
	MOVWF TRISA
	CLRF TRISB
	CLRF TRISC
	MOVLW 03CH
	MOVWF TRISD
	CLRF TRISE
	MOVLW 04DH		    
  	MOVWF ADCON1            ;A/D data left justified, only select RA0,RA1 as ADC Channels,RA2 and RA3 are reference voltages,the rest are data PORT
	BANKSEL PORTA
	MOVLW 04H
	MOVWF T2CON				;Start Timer2 prescaler 1:1 postscaler 1:1
	MOVLW 0CH
	MOVWF CCP1CON			;SET CCP1 Module to PWM Mode ignoring least segnificant two bits
	BCF PORTE,0				;Clear Alarm LED
	CLRF CCPR1L				;PWM Duty Cycle
	;Save 2500 Liters Values to Total Volume Variable in two bytes (VOLH,VOLL)
	CALL RESET_TANK
	CALL DELAY_3ms
	CALL LCD_INIT


LOOP
	CALL DELAY_1Sec
;Get ADC Values
	CALL ADC_READ
	
;CALCULATIONS

;Get Rate1 Value
	MOVF ADC0,W
	MOVWF MAP
	CALL RATE_LOOKUP
	MOVWF RATE1
;Get Rate2 Value
	MOVF ADC1,W
	MOVWF MAP
	CALL RATE_LOOKUP
	MOVWF RATE2
;Get Rate Total
	CLRF RATETOT

;LCD Message Display
MOVLW 01H
CALL LCD_COMMAND
BTFSC PORTE,0
GOTO MSG3
BTFSS PORTD,5	;READ LCD View BUTTON
GOTO MSG2
MSG1
	MOVLW 'B'
	CALL LCD_DATA
	MOVLW 'e'
	CALL LCD_DATA
	MOVLW 'd'
	CALL LCD_DATA
	MOVLW '1'
	CALL LCD_DATA
	MOVLW ' '
	CALL LCD_DATA
	BTFSS PORTD,2
	GOTO ON1
	MOVLW 'O'
	CALL LCD_DATA
	MOVLW 'F'
	CALL LCD_DATA
	MOVLW 'F'
	CALL LCD_DATA
	MOVLW ' '
	CALL LCD_DATA
	MOVLW '-'
	CALL LCD_DATA
	MOVLW '-'
	CALL LCD_DATA
	GOTO LCD_CONTINUE1
ON1
	MOVLW 'O'
	CALL LCD_DATA
	MOVLW 'N'
	CALL LCD_DATA
	MOVLW ' '
	CALL LCD_DATA
	MOVF RATE1,W
	CALL PRINT_VALUE
	MOVLW ' '
	CALL LCD_DATA
	MOVLW 'L'
	CALL LCD_DATA
	MOVLW 'i'
	CALL LCD_DATA
	MOVLW 't'
	CALL LCD_DATA
	MOVLW 'e'
	CALL LCD_DATA
	MOVLW 'r'
	CALL LCD_DATA
	MOVLW '/'
	CALL LCD_DATA
	MOVLW 's'
	CALL LCD_DATA
LCD_CONTINUE1
	MOVLW 0C0H
	CALL LCD_COMMAND		;LCD write to second line
	MOVLW 'B'
	CALL LCD_DATA
	MOVLW 'e'
	CALL LCD_DATA
	MOVLW 'd'
	CALL LCD_DATA
	MOVLW '2'
	CALL LCD_DATA
	MOVLW ' '
	CALL LCD_DATA
	BTFSS PORTD,3
	GOTO ON2
	MOVLW 'O'
	CALL LCD_DATA
	MOVLW 'F'
	CALL LCD_DATA
	MOVLW 'F'
	CALL LCD_DATA
	MOVLW ' '
	CALL LCD_DATA
	MOVLW '-'
	CALL LCD_DATA
	MOVLW '-'
	CALL LCD_DATA
	GOTO LCD_CONTINUE2
ON2
	MOVLW 'O'
	CALL LCD_DATA
	MOVLW 'N'
	CALL LCD_DATA
	MOVLW ' '
	CALL LCD_DATA
	MOVF RATE2,W
	CALL PRINT_VALUE
	MOVLW ' '
	CALL LCD_DATA
	MOVLW 'L'
	CALL LCD_DATA
	MOVLW 'i'
	CALL LCD_DATA
	MOVLW 't'
	CALL LCD_DATA
	MOVLW 'e'
	CALL LCD_DATA
	MOVLW 'r'
	CALL LCD_DATA
	MOVLW '/'
	CALL LCD_DATA
	MOVLW 's'
	CALL LCD_DATA
LCD_CONTINUE2
	GOTO CONTINUE_LOOP
MSG2
	MOVLW 01H
	CALL LCD_COMMAND
	MOVLW 'O'
	CALL LCD_DATA
	MOVLW 'x'
	CALL LCD_DATA
	MOVLW 'y'
	CALL LCD_DATA
	MOVLW 'g'
	CALL LCD_DATA
	MOVLW 'e'
	CALL LCD_DATA
	MOVLW 'n'
	CALL LCD_DATA
	MOVLW ' '
	CALL LCD_DATA
	MOVLW 'V'
	CALL LCD_DATA
	MOVLW 'o'
	CALL LCD_DATA
	MOVLW 'l'
	CALL LCD_DATA
	MOVLW 'u'
	CALL LCD_DATA
	MOVLW 'm'
	CALL LCD_DATA
	MOVLW 'e'
	CALL LCD_DATA
	MOVLW 0C0H
	CALL LCD_COMMAND		;LCD write to second line
	MOVF VOLH,W
	CALL PRINT_VALUE
	MOVF VOLL,W
	CALL PRINT_VALUE
	GOTO CONTINUE_LOOP
MSG3
	MOVLW 01H
	CALL LCD_COMMAND
	MOVLW 'O'
	CALL LCD_DATA
	MOVLW 'x'
	CALL LCD_DATA
	MOVLW 'y'
	CALL LCD_DATA
	MOVLW 'g'
	CALL LCD_DATA
	MOVLW 'e'
	CALL LCD_DATA
	MOVLW 'n'
	CALL LCD_DATA
	MOVLW ' '
	CALL LCD_DATA
	MOVLW 'L'
	CALL LCD_DATA
	MOVLW 'e'
	CALL LCD_DATA
	MOVLW 'v'
	CALL LCD_DATA
	MOVLW 'e'
	CALL LCD_DATA
	MOVLW 'l'
	CALL LCD_DATA
	MOVLW ' '
	CALL LCD_DATA
	MOVLW 'L'
	CALL LCD_DATA
	MOVLW 'o'
	CALL LCD_DATA
	MOVLW 'w'
	CALL LCD_DATA
	MOVLW 0C0H
	CALL LCD_COMMAND
	MOVLW 'F'
	CALL LCD_DATA
	MOVLW 'i'
	CALL LCD_DATA
	MOVLW 'l'
	CALL LCD_DATA
	MOVLW 'l'
	CALL LCD_DATA
	MOVLW ' '
	CALL LCD_DATA
	MOVLW 'T'
	CALL LCD_DATA
	MOVLW 'a'
	CALL LCD_DATA
	MOVLW 'n'
	CALL LCD_DATA
	MOVLW 'k'
	CALL LCD_DATA
	MOVLW '!'
	CALL LCD_DATA
CONTINUE_LOOP
;Test Button (BED1)
	BTFSS PORTD,2
	GOTO SET1
	GOTO CLEAR1
SET1
	MOVF RATE1,W
	MOVWF RATETOT
	SUBWF VOLL,F
	BTFSS STATUS,C
	GOTO DECREMENT1 ;Its Borrow
	GOTO CLEAR1
DECREMENT1
	DECF VOLH,F ;When Borrow occured Decrement High Byte
	MOVLW .100
	ADDWF VOLL
CLEAR1
;Test Button (BED2)
	BTFSS PORTD,3
	GOTO SET2
	GOTO CLEAR2
SET2
	MOVF RATE2,W
	ADDWF RATETOT,F
	SUBWF VOLL,F
	BTFSS STATUS,C
	GOTO DECREMENT2 ;Its Borrow
	GOTO CLEAR2
DECREMENT2	
	DECF VOLH,F ;When Borrow occured Decrement High Byte
	MOVLW .100
	ADDWF VOLL
CLEAR2

;Test Button (FILL)
	BTFSS PORTD,4
	GOTO SET3
	GOTO CLEAR3
SET3
	CALL RESET_TANK
CLEAR3
;Calculate Pump Speed
	MOVF RATETOT,W
	MOVWF MAP
	CALL SPEED_LOOKUP ;using MAP variable
	MOVWF CCPR1L ;Set duty cycle for PWM depend on speed required

;Check ALARM if VOLH < 5 then it is alarm
	MOVLW .5
	SUBWF VOLH,W
	BTFSS STATUS,C 
	GOTO ALARM
	GOTO NOALARM
ALARM
	BSF PORTE,0
	GOTO LOOP
NOALARM
	BCF PORTE,0
	GOTO LOOP
;*********** LOOP Ends Here ****************

RESET_TANK
	MOVLW .25
	MOVWF VOLH
	MOVLW .0
	MOVWF VOLL	
	RETURN
	
DIVIDE
	CLRF DIV
	CLRF MOD
CHECK_AGAIN
	MOVF VAL,W
	MOVWF VAL1
	MOVF OPER,W
	SUBWF VAL1,F
	BTFSS STATUS,C		;IT'S BORROW (INVERSED)
	GOTO SET_VALUES
	MOVF OPER,W
	SUBWF VAL,F
	INCF DIV,F
	GOTO CHECK_AGAIN
SET_VALUES
	MOVF VAL,W
	MOVWF MOD
	RETURN



;READ ALL ADC CHANNELS
ADC_READ
;READ CH0
	MOVLW 0C1H
  	MOVWF ADCON0			;CLOCK is internal rc,A/D enabled
	CALL DELAY_3ms			;Wait to charge the internal capacitor
	BSF ADCON0,GO			;Start ADC Conversion
ADC_LOOP0
	BTFSC ADCON0,GO			;Test if ADC conversion finished?
	GOTO ADC_LOOP0
	MOVF ADRESH,W
	MOVWF ADC0
;READ CH1
	MOVLW 0C9H
  	MOVWF ADCON0			;CLOCK is internal rc,A/D enabled
	CALL DELAY_3ms			;Wait to charge the internal capacitor
	BSF ADCON0,GO			;Start ADC Conversion
ADC_LOOP1
	BTFSC ADCON0,GO			;Test if ADC conversion finished?
	GOTO ADC_LOOP1
	MOVF ADRESH,W
	MOVWF ADC1
	RETURN
	

PRINT_VALUE
	MOVWF VAL
	MOVLW .100
	MOVWF OPER
	CALL DIVIDE
	MOVF DIV,W
	MOVWF DIG2
	MOVF MOD,W
	MOVWF VAL
	MOVLW .10
	MOVWF OPER
	CALL DIVIDE
	MOVF DIV,W
	MOVWF DIG1
	MOVF MOD,W
	MOVWF DIG0
	;===============
	;MOVF DIG2,W
	;ADDLW 30H
	;CALL LCD_DATA
	MOVF DIG1,W
	ADDLW 30H
	CALL LCD_DATA
	MOVF DIG0,W
	ADDLW 30H
	CALL LCD_DATA
	RETURN
	

DELAY_3ms ;ON 1MHz Crystal
	MOVLW 0FAH
	MOVWF COUNTER
COUNTER_DEC
	DECFSZ COUNTER
	GOTO COUNTER_DEC
	RETURN
	
DELAY_1Sec
	MOVLW 0FAH
	MOVWF COUNTER2
COUNTER2_DEC
	CALL DELAY_3ms
	DECFSZ COUNTER2
	GOTO COUNTER2_DEC
	RETURN
	

RATE_LOOKUP
	MOVF MAP,F
	BTFSC STATUS,Z
	RETLW .0
	MOVLW .64
	SUBWF MAP,F
	BTFSS STATUS,C
	RETLW .1
	MOVLW .64
	SUBWF MAP,F
	BTFSS STATUS,C
	RETLW .5
	RETLW .10
	
SPEED_LOOKUP
	MOVF MAP,F
	BTFSC STATUS,Z
	RETLW .0
	MOVLW .5
	SUBWF MAP
	BTFSS STATUS,C
	RETLW .2 ;10RPM
	MOVLW .5
	SUBWF MAP
	BTFSS STATUS,C
	RETLW .6 ;40RPM
	MOVLW .5
	SUBWF MAP
	BTFSS STATUS,C
	RETLW .11 ;70RPM
	RETLW .16 ;100RPM

	
Enable
	BSF PORTD,1 ; E pin is high, (LCD is processing the incoming data)
	NOP
	NOP
	NOP
	NOP
    BCF PORTD,1 ; E pin is low, (LCD does not care what is happening)
	NOP
	NOP
	NOP
	NOP
    RETURN
	
LCD_INIT
    MOVLW b'00111000' ;Funtion set
    CALL LCD_COMMAND
	
	MOVLW b'00000001' ;Clearing display
	CALL LCD_COMMAND

    MOVLW b'00001101' ;Display on off
    CALL LCD_COMMAND

    MOVLW b'00000110' ;Entry mod set
    CALL LCD_COMMAND
	RETURN

LCD_COMMAND
	BCF PORTD,0 ;Setting RS as 0 (Sends command to LCD)
	MOVWF PORTB
    CALL Enable
    CALL DELAY_3ms
	RETURN

LCD_DATA
    BSF PORTD,0 ;Setting RS as 1 (Sends data to LCD)
    MOVWF PORTB
    CALL Enable
    CALL DELAY_3ms 
    RETURN


END