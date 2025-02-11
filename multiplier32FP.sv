/*
RTL do Multiplicador para ponto flutuante IEEE 754 de 32 bits
Autor: Walber Florencio
Data: 6 Fev 2025
Projeto Físico
*/

`timescale 1ns/10ps

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

logic sign_a, sign_b, sign_o;       // indica se o número é positivo (0) ou negativo (1)
logic [7:0] exp_a, exp_b, exp_o;    // expoente do número
logic [9:0] exp_e;                  // expoente com bit extra para cálculo
logic [23:0] mant_a, mant_b;        // mantissa das entradas
logic [47:0] mant_o;                // mantissa do resultado
logic [31:0] product_o_ff;          // registrador para o resultado

typedef enum logic [1:0] {
    IDLE,
    VERIFY_NAN,
    CALCULATE,
    DONE
} states;

states state;
states next_state;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        product_o_ff <= 0;
    end else begin
        state <= next_state;
        product_o_ff <= product_o;
    end
end

always_comb begin
    next_state = state;
    product_o = product_o_ff;
    done_o = 0;
    nan_o = 0; 
    infinit_o = 0;
    overflow_o = 0;
    underflow_o = 0;
    
    if(!rst_n) begin
        next_state = IDLE;
        product_o = 0;
        done_o = 0;
        nan_o = 0; 
        infinit_o = 0;
        overflow_o = 0;
        underflow_o = 0;
    end else begin
        case(state)
            IDLE: begin
                if(start_i) begin
                    next_state = VERIFY_NAN;
                end 
            end
            VERIFY_NAN: begin
                // Extração
                sign_a = a_i[31];
                sign_b = b_i[31];
                exp_a = a_i[30:23];
                exp_b = b_i[30:23];

                next_state = CALCULATE;

                // Verificação se os operandos são Not a Number
                if (exp_a == 8'b11111111 && a_i[22:0] != 0|| exp_b == 8'b11111111 && b_i[22:0] != 0) begin
                    nan_o = 1;
                    product_o = 32'b0;
                    next_state = DONE;
                end
            end
            CALCULATE: begin               
                // Mantissa
                mant_a = {1'b1, a_i[22:0]};
                mant_b = {1'b1, b_i[22:0]};

                // Verificação se é não normalizado "zero sujo"
                if (a_i[30:23] == 8'b0 && a_i[22:0] != 0)
                    mant_a = {1'b0, a_i[22:0]};
                if (b_i[30:23] == 8'b0 && b_i[22:0] != 0)
                    mant_b = {1'b0, b_i[22:0]};

                // Multiplicação
                sign_o = sign_a ^ sign_b;
                exp_e = exp_a + exp_b - 127;
                mant_o = mant_a * mant_b;

                if (mant_a[23] == 0 ^ mant_b[23] == 0) exp_e = exp_a + exp_b - 126; // Verificação se um dos operandos é não normalizado
                if (mant_a[23] == 0 && mant_b[23] == 0) exp_e = 8'b0;               // Verificação se os dois operandos são não normalizados

                // Normalização
                if (mant_o[47]) begin
                    mant_o = mant_o >> 1;
                    exp_e = exp_e + 1;
                end

                exp_o = exp_e[7:0];
                
                // Empacotamento
                product_o = {sign_o, exp_o, mant_o[45:23]};

                // Verificação de underflow
                if (exp_e[9]) begin
                    underflow_o = 1;
                    product_o = {sign_o, 31'b0};
                end
                
                // Verificação se um dos operandos é zero
                if(a_i[30:0] == 31'b0 || b_i[30:0] == 31'b0) begin
                    product_o[30:0] = 31'b0;
                    product_o[31] = sign_o;
                end

                // Verificação se um dos operandos é infinito
                if (exp_a == 8'b11111111 && a_i[22:0] == 23'b0|| exp_b == 8'b11111111 && b_i[22:0] == 23'b0) begin
                    infinit_o = 1;
                    product_o = {sign_o, 31'h7FFFFFFF};
                end else if (~exp_e[9] && exp_e > 9'b011111110) begin // Verificação de overflow
                    overflow_o = 1;
                    product_o = {sign_o, 31'h7FFFFFFF};
                end
                
                next_state = DONE;
            end
            DONE: begin
                done_o = 1;
                next_state = IDLE;
            end
        endcase
    end
end

endmodule