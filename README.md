## Projeto final da disciplina de Projeto Físico

Especialização em Microeletrônica da **UFSM** 

Autor: Walber Florencio

CI Inovador Polo UFC

## Escopo do projeto:

Multiplicador em ponto flutuante de 32 bits no padrão IEEE 754 com saída registrada

O circuito deve manipular números positivos e negativos e tratar/identificar os
seguintes casos especiais:
1) positivo/negativo infinito (infinit_o): o expoente contém um padrão de bits reservado 11111111, a fração (mantissa) contém somente
zeros, e o bit de sinal é 0 ou 1;
2) not a number (nan_o): o expoente contém um padrão de bits reservado 11111111, a fração (mantissa) é diferente de zero, e o bit de
sinal é 0 ou 1. Neste caso, ambos operandos devem ser testados, a multiplicação não deve ser realizada e esta flag deve ir para ‘1’. Neste
caso, o valor na saída deve ser 0x00000000;
3) multiplicar números classificados como “zero sujo”. Uma representação chamada de “zero sujo”, não-normalizada, permite
representar números no intervalo entre 0 e o primeiro número representável na forma normalizada (1,0 x 2 -126 ). O bit de sinal pode ser 0 ou
1 e o expoente contém o padrão de bits 00000000. A fração contém o padrão de bits real para a magnitude do número, em vez da mantissa.
Deste modo, não existe nenhum 1 escondido neste formato. Números denormalizados, portanto, permitem que os números em ponto
flutuante atinjam valores muito menores, sacrificando a quantidade de bits no significando;
4) arredondamento: round toward zero (arredonda em direção a zero): neste caso os bits que estão a mais são desprezados.
5) overflow (overflow_o): ocorre quando o expoente resultante excede o valor máximo permitido para este número normalizado. Neste
caso, o valor na saída deve ser 0x7FFFFFFF;
6) underflow (underflow_o): devolve um número menor que o permitido normalizado. O underflow ocorre quando uma operação é
executada e retorna um valor que é menor que o menor número não zero.
a. Sobre underflow: No padrão IEEE 754 precisão simples isto significa um valor que tem a magnitude (valor absoluto) menor que
1,0 x 1 -149 (número denormalizado). Normalmente quando um número chega a este patamar de magnitude ele é arredondado para zero, o
que pode não fazer muita diferença em uma adição, mas tem um grande efeito na multiplicação. Neste caso, o valor na saída deve ser
0x00000000;

### Interface

```bash
module multiplier32FP (
    input logic clk,                // clock geral do circuito
    input logic rst_n,              // reset geral - ativo em baixo
    input logic start_i,            // indica que deve iniciar uma nova multiplicação
    input logic [31:0] a_i, b_i,    // dados a serem multiplicados
    output logic [31:0] product_o,  // resultado da multiplicação
    output logic done_o,            // indica que a multiplicação terminou
    output logic nan_o,             // flag - indica que um operando não é um número
    output logic infinit_o,         // flag - indica que um operando é infinito
    output logic overflow_o,        // flag - indica que o resultado gerou overflow
    output logic underflow_o        // flag - indica que o resultado gerou underflow
);
```

### Estrutura de um Número em Ponto Flutuante IEEE 754 (32 bits)

Um número em ponto flutuante de 32 bits no formato IEEE 754 é dividido em três partes:

1. **Sinal (1 bit)**: Indica se o número é positivo (0) ou negativo (1).
2. **Expoente (8 bits)**: Representa a magnitude do número. O expoente é armazenado com um bias de 127. Valor real do expoente = Expoente armazenado - 127
3. **Mantissa (23 bits)**: Representa a precisão do número.

### Exemplo

Vamos considerar o número `2.5` e representá-lo no formato IEEE 754 de 32 bits.

1. **Converter para Binário**:
   - `2.5` em binário é `10.1`.

2. **Normalizar o Número Binário**:
   - `10.1` pode ser escrito como `1.01 * 2^1`.

3. **Determinar o Sinal**:
   - `2.5` é positivo, então o bit de sinal é `0`.

4. **Calcular o Expoente com Bias**:
   - Expoente real = `1`
   - Bias = `127`
   - Expoente armazenado = `1 + 127 = 128` (em binário: `10000000`)

5. **Determinar a Mantissa**:
   - A parte fracionária normalizada é `01000000000000000000000` (23 bits).

### Valores Especiais

- **Zero**:
  - Positivo: `0 00000000 00000000000000000000000` (0x00000000)
  - Negativo: `1 00000000 00000000000000000000000` (0x80000000)

- **Infinito**:
  - Positivo: `0 11111111 00000000000000000000000` (0x7F800000)
  - Negativo: `1 11111111 00000000000000000000000` (0xFF800000)

- **NaN (Not a Number)**:
  - `0 11111111 10000000000000000000000` (0x7FC00000) ou qualquer valor com expoente `11111111` e mantissa diferente de zero.

