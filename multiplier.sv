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

typedef enum logic [2:0] {
    IDLE,
    EXTRACT,
    MULTIPLY,
    NORMALIZE,
    PACK,
    DONE
} states;

states state, next_state;

logic sign_a, sign_b, sign_o;
logic [7:0] exp_a, exp_b, exp_o;
logic [23:0] mant_a, mant_b;
logic [47:0] mant_o;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        product_o <= 0;
        done_o <= 0;
        nan_o <= 0;
        infinit_o <= 0;
        overflow_o <= 0;
        underflow_o <= 0;
    end else begin
        case (state)
            IDLE: begin
                done_o <= 0;
                if (start_i) begin
                    next_state <= EXTRACT;
                end else begin
                    next_state <= IDLE;
                end
            end
            EXTRACT: begin
                sign_a <= a_i[31];
                sign_b <= b_i[31];
                exp_a <= a_i[30:23];
                exp_b <= b_i[30:23];
                mant_a <= {1'b1, a_i[22:0]};
                mant_b <= {1'b1, b_i[22:0]};
                next_state <= MULTIPLY;
            end
            MULTIPLY: begin
                sign_o <= sign_a ^ sign_b;
                exp_o <= exp_a + exp_b - 127;
                mant_o <= mant_a * mant_b;
                next_state <= NORMALIZE;
            end
            NORMALIZE: begin
                if (mant_o[47]) begin
                    mant_o <= mant_o >> 1;
                    exp_o <= exp_o + 1;
                end else begin
                    while (mant_o[46] == 0 && exp_o > 0) begin
                        mant_o <= mant_o << 1;
                        exp_o <= exp_o - 1;
                    end
                end
                next_state <= PACK;
            end
            PACK: begin
                product_o <= {sign_o, exp_o, mant_o[46:24]};
                next_state <= DONE;
            end
            DONE: begin
                done_o <= 1;
                next_state <= IDLE;
            end
        endcase
    end
end

endmodule