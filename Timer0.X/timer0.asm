;*******************************************************************************
; Programa: Pisca LED com Timer 0 (4 ms ON/OFF)
; Microcontrolador: PIC16F877A
; Cristal: 4 MHz
; LED conectado ao pino RD1
;*******************************************************************************

PROCESSOR 16F877A
#include <PIC16f877A.inc>

; CONFIG
CONFIG  FOSC = HS          ; Oscilador HS
CONFIG  WDTE = OFF         ; WDT desativado
CONFIG  PWRTE = OFF        ; Power-up desativado
CONFIG  BOREN = OFF        ; Brown-out desativado
CONFIG  LVP = OFF          ; Programação LV desativada
CONFIG  CPD = OFF          ; Proteção EEPROM desativada
CONFIG  WRT = OFF          ; Proteção de escrita desativada
CONFIG  CP = OFF           ; Proteção de código desativada


; Definições

LED1    equ     1       ; Pino RD1 conectado ao LED
time1   equ     0x20    ; Variável para controle do estado do LED (1 = ligado, 0 = desligado)

#define      bank0   bcf STATUS, 5   ; Banco 0
#define      bank1   bsf STATUS, 5   ; Banco 1


; Vetor de Reset

  psect   RESET_VECT,class=CODE,delta=2    ; pic-as Linker: -pRESET_VECT=0h
  org     0x00
  goto    INICIALIZACAO


; Rotina de Inicialização

INICIALIZACAO:
    ; Configuração das Portas
    bank0     ; Banco 0
    clrf    PORTD           ; Zera PORTD

    bank1    ; Banco 1
    bcf     TRISD, LED1     ; Configura RD1 como saída (LED)

    ; Configuração do Timer0 (prescaler 1:32)
    movlw   0b00000110      ; Prescaler 1:32
    movwf   OPTION_REG

    ; Inicializa TMR0 com valor para gerar ~4ms
    ; Com Fosc = 4MHz ? T = 1us ? com prescaler 1:32 ? Tfinal = 8us por incremento
    ; 4ms / 8us = 500 ? 256 - (500 - 256) = 133
    movlw   133
    movwf   TMR0

    ; Inicializa variável de controle do LED
    clrf    STATUS
    movlw   0x01
    movwf   time1

    ; Acende o LED imediatamente
    bsf     PORTD, LED1     ; Acende o LED no início

LOOP:
    ; Espera o Timer0 para gerar delay
    movf    TMR0, W        ; Lê o valor do Timer
    btfss   INTCON, 2   ; Testa flag de interrupção do Timer0
    goto    LOOP           ; Se não ocorreu a interrupção, repete

    ; Inverte o estado do LED
    movf    time1, W       ; Carrega o estado atual do LED
    xorlw   0x01           ; Inverte o estado do LED
    movwf   time1          ; Atualiza o estado do LED

    ; Força LED a acender ou apagar completamente
    btfss   time1, 0        ; Testa o bit 0 (estado do LED)
    goto    LED_OFF

LED_ON:
    bsf     PORTD, LED1     ; Acende o LED
    goto    LOOP

LED_OFF:
    bcf     PORTD, LED1     ; Apaga o LED
    goto    LOOP

    END
