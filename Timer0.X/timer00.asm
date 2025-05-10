;*******************************************************************************
; Programa: Pisca LED com Interrup��o do Timer 0 (4 ms ON/OFF)
; Microcontrolador: PIC16F877A (assumido)
; Frequ�ncia do Cristal: 4MHz (assumido)
; LED conectado ao pino RD1
; Objetivo: Acender por 4 ms e apagar por 4 ms
; Compilador: PIC AS (MPLAB)
;*******************************************************************************

    LIST        p=16f877a       ; Define o tipo de processador
    #include    <xc.inc>   

CONFIG  FOSC = HS			; Bits de sele??o do oscilador (oscilador HS)
    CONFIG  WDTE = OFF			; Bit de ativa??o do temporizador Watchdog (WDT desativado)
    CONFIG  PWRTE = OFF			; Bit de ativa??o do temporizador Power-up (PWRT desativado)
    CONFIG  BOREN = OFF			; Bit de ativa??o de reinicializa??o de Brown-out (BOR desativado)
    CONFIG  LVP = OFF			; Bit de ativa??o de programa??o s?rie em circuito de baixa tens?o (alimenta??o ?nica) (RB3 ? E/S digital, HV em MCLR deve ser usado para programa??o)
    CONFIG  CPD = OFF			; Bit de prote??o do c?digo da mem?ria EEPROM de dados (prote??o do c?digo da EEPROM de dados desligada)
    CONFIG  WRT = OFF			; Bits de habilita??o de escrita da mem?ria de programa flash (prote??o contra escrita desativada; toda a mem?ria de programa pode ser escrita pelo controle EECON)
    CONFIG  CP = OFF		


;*******************************************************************************
; Declara��o de Vari�veis
;*******************************************************************************
#define	    bank0	bcf STATUS, 5	; Colocar o Bit 5 do registrador STATUS em n?vel baixo - banco 0
#define	    bank1	bsf STATUS, 5	; Colocar o Bit 5 do registrador STATUS em n?vel alto - banco 1
    
time1	    equ	    0x20


;*******************************************************************************
; Defini��o de sa�das
;*******************************************************************************
    #define         LED1  PORTD, 1   ; led em RD1

;*******************************************************************************
; Vetor de Reset
;*******************************************************************************
    ORG         0x00
    GOTO        INICIALIZACAO

;*******************************************************************************
; Vetor de Interrup��o
;*******************************************************************************
    ORG         0x04
    GOTO        ROTINA_INTERRUPCAO

;*******************************************************************************
; Rotina de Inicializa��o
;*******************************************************************************
INICIALIZACAO:
    ; Configura��o das Portas
    bank1   ; Seleciona o Banco 1
    CLRF        TRISD           ; Define PORTD como sa�da
    bank0    ; Seleciona o Banco 0
    CLRF        PORTD           ; Inicializa PORTD com todos os pinos em n�vel baixo

    ; Configura��o do Timer 0
    bank1     ; Seleciona o Banco 1
    MOVLW       0b00000110    ; Configura��es do OPTION_REG (prescaler 1:32)
    MOVWF       OPTION_REG
    bank0    ; Seleciona o Banco 0
    CLRWDT                      ; Limpa o Watchdog Timer

    ; Inicializa��o do Timer 0 com o valor para ~4ms
    MOVLW       133          ; Carrega o valor inicial de 133 em W
    MOVWF       TMR0            ; Carrega W em TMR0

    ; Inicializa��o do Estado do LED
    MOVLW       0x01            ; Inicializa o LED como ligado (pode come�ar apagado com 0)
    MOVWF       time1 

    ; Habilitar Interrup��es
    bank1				; Ir para o banco 1 
    movlw   0b11111111			; Copia o valor da constante 0xFF (255) para registrador de trabalho
    movwf   TRISB			; Copia o conte?do do registrado W para o registrador TRISB - define a Porta B como entrada.
    movlw   0b00000000			; Copia o valor da constante 0x00 (0) para registrador de trabalho
    movwf   TRISD			; Copia o conte?do do registrado W para TRISD - define a Porta D como sa?da
    movlw   0b10000000			; Defini??o dos bits PS0, PS1 e PS2 (PRESCALER) 
    movwf   OPTION_REG
    bank0				; Vai para o banco 1
    movlw   0b00000000
    movwf   PORTD			; Copia o conte?do do registrado W para PORTD ? todos os pinos em n?vel baixo
    movlw   0b10100000			; Habilitar interrup??o no Timer0
    movwf   INTCON
    
    bcf STATUS,0			;clear carry BCF INTCON,0 ; clear int flag


PRINCIPAL:
    SLEEP                       ; Coloca o microcontrolador em modo de baixo consumo
    GOTO        PRINCIPAL       ; Loop infinito

;*******************************************************************************
; Rotina de Tratamento da Interrup��o do Timer 0
;*******************************************************************************
ROTINA_INTERRUPCAO:
    BCF         INTCON, 2    ; Limpa a flag de interrup��o do Timer 0

    MOVLW       133          ; Recarrega o valor inicial de 133 em W
    MOVWF       TMR0            ; Carrega W em TMR0 para o pr�ximo intervalo

    ; Troca o estado do LED a cada interrup��o
    MOVF        time1, W    ; Carrega o estado atual do LED em W
    XORLW       0x01             ; Inverte o estado
    MOVWF       time1       ; Atualiza o estado do LED

    bank1    ; Seleciona o Banco 1
    BTFSC       time1, 0    ; Testa o bit 0 da vari�vel ESTADO_LED
    BSF         LED1   ; Se for 1, acende o LED
    BTFSS       time1, 0    ; Testa o bit 0 da vari�vel ESTADO_LED
    BCF         LED1   ; Se for 0, apaga o LED
    bank0     ; Seleciona o Banco 0

SAIR_INTERRUPCAO:
    RETFIE                      ; Retorna da rotina de interrup��o

    END                         ; Fim do programa