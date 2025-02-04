module tb_multiplier32FP;

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

    // Instancia o módulo a ser testado
    multiplier32FP uut (
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
    always #5 clk = ~clk;

    initial begin
        // Inicializa os sinais
        clk = 0;
        rst_n = 0;
        start_i = 0;
        a_i = 0;
        b_i = 0;

        // Reseta o circuito
        #10;
        rst_n = 1;

        // Multiplicação de 2.5 * 4.0
        a_i = $shortrealtobits(2.5); // 2.5 em ponto flutuante IEEE 754
        b_i = $shortrealtobits(4.0); // 4.0 em ponto flutuante IEEE 754
        start_i = 1;
        #10;
        start_i = 0;

        // Espera a multiplicação terminar
        wait (done_o);
        #10;
        $display("Resultado: %h", product_o); // Esperado: 0x41200000 (10.0 em ponto flutuante IEEE 754)

        // Finaliza a simulação
        $finish;
    end

endmodule