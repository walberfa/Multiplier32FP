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

logic sign_a, sign_b, sign_o;
logic [7:0] exp_a, exp_b, exp_o;
logic [23:0] mant_a, mant_b;
logic [47:0] mant_o;
logic [31:0] product_o_ff;

typedef enum logic [1:0] {
    IDLE,
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
                    next_state = CALCULATE;
                end 
            end
            CALCULATE: begin
                // Extração
                sign_a = a_i[31];
                sign_b = b_i[31];
                exp_a = a_i[30:23];
                exp_b = b_i[30:23];

                if(exp_a == 8'b11111111) begin
                    if(a_i[22:0] != 0) begin
                        nan_o = 1;
                        product_o = 0;
                        next_state = DONE;
                    end else begin
                        infinit_o = 1;
                        next_state = DONE;
                    end
                end

                if(exp_b == 8'b11111111) begin
                    if(b_i[22:0] != 0) begin
                        nan_o = 1;
                        product_o = 0;
                        next_state = DONE;
                    end else begin
                        infinit_o = 1;
                    end
                end 

                mant_a = {1'b1, a_i[22:0]};
                mant_b = {1'b1, b_i[22:0]};

                // Multiplicação
                sign_o = sign_a ^ sign_b;
                exp_o = exp_a + exp_b - 127;
                mant_o = mant_a * mant_b;

                // Normalização
                if (mant_o[47]) begin
                    mant_o = mant_o >> 1;
                    exp_o = exp_o + 1;
                end

                // Empacotamento
                product_o = {sign_o, exp_o, mant_o[45:23]};
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