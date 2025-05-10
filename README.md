**Controle de LED com o Timer0 do PIC16F877A em Assembly**
Este projeto implementa o controle de um LED utilizando o microcontrolador PIC16F877A programado em linguagem Assembly. A temporização do piscar do LED é feita com o uso do Timer0 e simulação no ambiente PICgenios.

**Funcionalidades**
- Pisca de um LED conectado ao pino RD1.
- Temporização de aproximadamente 4 milissegundos para ligar e desligar o LED.
- Utilização do Timer0 com prescaler para controle preciso do tempo.
- Código escrito 100% em Assembly.

**Objetivo**
Demonstrar o uso do temporizador Timer0 e manipulação de portas digitais no PIC16F877A, aplicando conceitos fundamentais de microcontroladores em um projeto simples e didático.

**Materiais Utilizados**
- MPLAB X IDE
- Simulador PICgenios

**Conexões**
PORTD.1: LED

**Lógica de Funcionamento**
- O LED inicia aceso ao ligar o sistema.
- O Timer0 conta ~4ms e gera uma interrupção por estouro (via verificação de flag).
- A cada interrupção, o estado do LED é invertido (liga ou desliga).
- O ciclo se repete continuamente, mantendo o piscar constante do LED.

**Arquivos**
- Timer0.asm: Código-fonte principal em Assembly
- README.md: Este arquivo de descrição

