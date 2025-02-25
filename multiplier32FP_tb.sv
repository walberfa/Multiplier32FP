/*
Testbench para testar o módulo multiplier32FP.sv
Autor: Walber Florencio
Última modificação: 2025/02/24 
Projeto Físico
*/

module multiplier32FP_tb #(parameter int FREQ = `FREQ, parameter bit double = `DOUBLE, parameter string MODE = `MODE);
    parameter int PERIOD = (1.0/FREQ)*10**9;

    // Sinais de entrada
    logic clk;
    logic rst_n;
    logic start_i;
    logic [31:0] a_i, b_i;

    // Sinais de saída
    logic [31:0] product_o;
    logic done_o;
    logic nan_o;
    logic infinit_o;
    logic overflow_o;
    logic underflow_o;

    // Vetores de teste
    logic [31:0] data [0:99][2:0]; 
    logic [31:0] a [0:99];
    logic [31:0] b [0:99];
    logic [31:0] res [0:99];

    // Instancia o módulo a ser testado
    multiplier32FP UUT (
        .clk(clk),
        .rst_n(rst_n),
        .start_i(start_i),
        .a_i(a_i),
        .b_i(b_i),
        .product_o(product_o),
        .done_o(done_o),
        .nan_o(nan_o),
        .infinit_o(infinit_o),
        .overflow_o(overflow_o),
        .underflow_o(underflow_o)
    );


    // Gera o clock
    always #(PERIOD/2) clk = ~clk;

    int i;
    int correct, wrong; // Contadores de acertos e erros

    initial begin
        int active_time;

        clk = 1;

        correct = 0;
        wrong = 0;

        start_i = 0;
        rst_n = 0;
        #PERIOD
        rst_n = 1;

        #(PERIOD*9);
        start_i = 1;

        $readmemh("../vetor.txt", data);

        for (i = 0; i < 100; i++) begin
            a[i] = data[i][0];
            b[i] = data[i][1];
            res[i] = data[i][2];
        end

        $display("+-------------------------------------------------+");
        $display("+------Testbench for multiplier32FP module--------+");

        for (i = 0; i < 100; i++) begin
            a_i = a[i];
            b_i = b[i];
            wait(done_o)

            assert (product_o == res[i]) begin
                $display("Assertion %d passed!\n", i+1);
                correct += 1;
            end else begin
                $warning("Assertion %d FAILED!\n", i+1);
                wrong += 1;
            end
            wait(~done_o);

            start_i = 0;
            $display("+-------------TEST CASE %d------------+", i+1);
            $display("+----------------- hexa | float ------------+");
            $display("a_i:           %h | %f", a_i, $bitstoshortreal(a_i));
            $display("b_i:           %h | %f", b_i, $bitstoshortreal(b_i));
            $display("product_o:     %h | %f", product_o, $bitstoshortreal(product_o));
            $display("expected:      %h | %f", res[i], $bitstoshortreal(res[i]));
            $display("+------------------------------------+\n");
            #(PERIOD*2);
            start_i = 1;
        end

        start_i = 0;
        active_time = $time;
        if (double) #active_time;
        $display("Assertions passed: %d", correct);
        $display("Assertions failed: %d", wrong);
        $finish;
    end

    initial begin
        string file_name;

        if (double) begin
            file_name = $sformatf("../multiplier32FP_%0dns%s_MAX.vcd", PERIOD, MODE);
        end else begin
            file_name = $sformatf("../multiplier32FP_%0dns%s_MIN.vcd", PERIOD, MODE);
        end

        $dumpfile(file_name);
        $dumpvars(0, multiplier32FP_tb);
    end

endmodule
