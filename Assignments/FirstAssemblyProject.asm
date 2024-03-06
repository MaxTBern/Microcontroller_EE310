//-----------------------------
// Title: FirstAssemblyProject
//-----------------------------
// Purpose: This program is a preliminary build of a 
//	    temperature sensor that can connect to a heating
//	    and cooling element; this project will be built out
//	    more in the future
// Dependencies: None
// Compiler: MPLAB X IDE v6.20
// Author: Max Bernstein
// OUTPUTS: PORTD, bits 1 and 2; 1 --> Heating, 2 --> Cooling
// INPUTS: refTemp and measuredTemp are fixed values at start of program
// Versions:
//  	V1.0: 3/6/2024
//	V1.1: 3/6/2024
//-----------------------------

;---------------------
; Initialization
;---------------------
#include "C:\Users\maxbe\MPLABXProjects\FirstAssemblyProject.X\configFile.inc"
#include <xc.inc>


;---------------------
; Variables & Ports
;---------------------

    ;Inputs
    ;------
    #define refTemp	    10
    #define measuredTemp    -10
    
    ;Outputs
    ;------
    #define Cooling	PORTD, 2
    #define Heating	PORTD, 1
    
    ;Registers
    ;------
    #define refTempReg		0x20
    #define measuredTempReg	0x21
    #define contReg		0x22
    #define refTempDecOnes	0x60
    #define refTempDecTens	0x61
    #define refTempDecHuns	0x62
    #define measuredTempDecOnes 0x70
    #define measuredTempDecTens 0x71
    #define measuredTempDecHuns 0x72
    #define operation		0x00	
    #define quotient		0x05
    #define divisor		10
    
    ;----
    ;Main
    ;----
    PSECT absdata,abs,ovrld        ; Do not change
    
	ORG 0x00
	GOTO START
    
	ORG 0x20
    
START:	
	MOVLW   refTemp
	MOVWF   refTempReg
	MOVLW	divisor			    //divisor is 10 for obtaining dec values
	CLRF	quotient		    //Clear quotient register
D_1:	INCF	quotient, 1
	SUBWF	refTempReg		    //Subtracting 10 from refTempReg til negative
	BC	D_1			    //Loop til negative
					    //Carry triggered during subtraction
					    //if result is still positive
	ADDWF	refTempReg, 1		    //Overshot, add ten back
	DECF	quotient, 1		    //Overshot, minus one from quotient
	MOVFF	refTempReg, refTempDecOnes
	MOVFF	quotient, refTempReg
	CLRF	quotient
D_2:	INCF	quotient, 1		    //See D_1 loop
	SUBWF	refTempReg
	BC	D_2
	ADDWF	refTempReg, 1
	DECF	quotient, 1
	MOVFF	refTempReg, refTempDecTens
	MOVFF	quotient, refTempDecHuns
	
	MOVLW	measuredTemp
	BTFSC	WREG, 7			    //Test for signed number
	NEGF	WREG			    //Negate measTemp if negative
	MOVWF	measuredTempReg
	MOVLW	divisor
	CLRF	quotient
D_3:	INCF	quotient, 1		    //See D_1 loop
	SUBWF	measuredTempReg
	BC	D_3
	ADDWF	measuredTempReg, 1
	DECF	quotient, 1
	MOVFF	measuredTempReg, measuredTempDecOnes
	MOVFF	quotient, measuredTempReg
	CLRF	quotient
D_4:	INCF	quotient, 1		    //See D_1 loop
	SUBWF	measuredTempReg
	BC	D_4
	ADDWF	measuredTempReg, 1
	DECF	quotient, 1
	MOVFF	measuredTempReg, measuredTempDecTens
	MOVFF	quotient, measuredTempDecHuns
	
OPERATIONS:
    
	BCF	TRISD, 2		//should open PORTD
	BCF	TRISD, 1
	MOVLW	refTemp			
	MOVWF	refTempReg	
	MOVLW	measuredTemp
	SUBWF	refTempReg, 1		//Compares measuredTemp and refTemp
					//Positive difference means meas < ref
					//Negative difference means ref < meas
					//No difference means meas = ref
	BN	COOL
	BZ	NOTHING
HEAT:	
	MOVLW	1			//sends heating function
	MOVWF	operation
	MOVFF	operation, PORTD
	GOTO	FINISH
COOL:
	MOVLW	2			//sends cooling function
	MOVWF	operation
	MOVFF	operation, PORTD
	GOTO	FINISH
NOTHING:				//nothing happens, temps are equal
	MOVLW	0
	MOVWF	operation
	GOTO	FINISH
	
FINISH:	SLEEP

