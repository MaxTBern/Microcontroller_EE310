;---------------------
; Title: FirstAssemblyProject
;---------------------

;---------------------
; Initialization
;---------------------
#include "C:\Users\maxbe\MPLABXProjects\FirstAssemblyProject.X\AssemblyConfig.inc"
#include <xc.inc>


;---------------------
; Variables & Ports
;---------------------

    ;Inputs
    ;------
    #define refTemp	    30
    #define measuredTemp    -30
    
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
	MOVLW	divisor
	CLRF	quotient
D_1:	INCF	quotient, 1
	SUBWF	refTempReg
	BC	D_1
	ADDWF	refTempReg, 1
	DECF	quotient, 1
	MOVFF	refTempReg, refTempDecOnes
	MOVFF	quotient, refTempReg
	CLRF	quotient
D_2:	INCF	quotient, 1
	SUBWF	refTempReg
	BC	D_2
	ADDWF	refTempReg, 1
	DECF	quotient, 1
	MOVFF	refTempReg, refTempDecTens
	MOVFF	quotient, refTempDecHuns
	
	MOVLW	measuredTemp
	BTFSC	WREG, 7
	NEGF	WREG
	MOVWF	measuredTempReg
	MOVLW	divisor
	CLRF	quotient
D_3:	INCF	quotient, 1
	SUBWF	measuredTempReg
	BC	D_3
	ADDWF	measuredTempReg, 1
	DECF	quotient, 1
	MOVFF	measuredTempReg, measuredTempDecOnes
	MOVFF	quotient, measuredTempReg
	CLRF	quotient
D_4:	INCF	quotient, 1
	SUBWF	measuredTempReg
	BC	D_4
	ADDWF	measuredTempReg, 1
	DECF	quotient, 1
	MOVFF	measuredTempReg, measuredTempDecTens
	MOVFF	quotient, measuredTempDecHuns
	
OPERATIONS:
    
	BCF	TRISD, 2
	BCF	TRISD, 1
	MOVLW	refTemp
	MOVWF	refTempReg
	MOVLW	measuredTemp
	SUBWF	refTempReg, 1	
	BN	COOL
	BZ	NOTHING
HEAT:	
	MOVLW	1
	MOVWF	operation
	MOVFF	operation, PORTD
	GOTO	FINISH
COOL:
	MOVLW	2
	MOVWF	operation
	MOVFF	operation, PORTD
	GOTO	FINISH
NOTHING:    
	MOVLW	0
	MOVWF	operation
	GOTO	FINISH
	
FINISH:	SLEEP