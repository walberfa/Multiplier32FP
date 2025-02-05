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
    multiplier32FP mult32FP (
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

        // Teste 1: Multiplicação de 2.5 * 4.0
        a_i = $shortrealtobits(2.5);
        b_i = $shortrealtobits(4.0);
        start_i = 1;
        #10;
        start_i = 0;

        // Espera a multiplicação terminar
        wait (done_o);
        #10;
        $display("Resultado: hexa 0x%h decimal %f", product_o, $bitstoshortreal(product_o)); // Esperado: 0x41200000 (10.0 em ponto flutuante IEEE 754)

        // Teste 2: Multiplicação de 3.02 * 4.0
        a_i = $shortrealtobits(3.02); 
        b_i = $shortrealtobits(4.0);
        start_i = 1;
        #10;
        start_i = 0;

        // Espera a multiplicação terminar
        wait (done_o);
        #10;
        $display("Resultado: haxe 0x%h decimal %f", product_o, $bitstoshortreal(product_o)); // Esperado: 0x414147ae (12.08 em ponto flutuante IEEE 754)

        // Teste 3: Multiplicação de -1.5 * 2.0
        a_i = $shortrealtobits(-1.5); 
        b_i = $shortrealtobits(2.0); 
        start_i = 1;
        #10;
        start_i = 0;

        // Espera a multiplicação terminar
        wait (done_o);
        #10;
        $display("Resultado: hexa 0x%h decimal %f", product_o, $bitstoshortreal(product_o)); // Esperado: 0xc0400000 (-3 em ponto flutuante IEEE 754)

        // Teste 4: Multiplicação de 0 * 4.0
        a_i = $shortrealtobits(0.0);
        b_i = $shortrealtobits(2.0); 
        start_i = 1;
        #10;
        start_i = 0;

        // Espera a multiplicação terminar
        wait (done_o);
        #10;
        $display("Resultado: hexa 0x%h decimal %f", product_o, $bitstoshortreal(product_o)); // Esperado: 0x00000000 (0 em ponto flutuante IEEE 754)

        // Teste 5: Multiplicação com *not a number*
        a_i = 32'h7F800001; // NaN
        b_i = $shortrealtobits(1.0); 
        start_i = 1;
        #10;
        start_i = 0;

        // Espera a multiplicação terminar
        wait (done_o);
        #10;
        $display("Resultado: hexa 0x%h decimal %f", product_o, $bitstoshortreal(product_o)); // Esperado: 0x00000000 (0 em ponto flutuante IEEE 754). NaN.
        
        // Teste 6: Multiplicação com número infinito positivo
        a_i = 32'h7F800000; // infinito positivo
        b_i = $shortrealtobits(1.0);  
        start_i = 1;
        #10;
        start_i = 0;

        // Espera a multiplicação terminar
        wait (done_o);
        #10;
        $display("Resultado: hexa 0x%h decimal %f", product_o, $bitstoshortreal(product_o)); // Esperado: 0x7F800000 (número infinito em ponto flutuante IEEE 754). Infinito.
        
        // Teste 7: Multiplicação com número infinito negativo
        a_i = 32'hFF800000; // infinito negativo
        b_i = $shortrealtobits(1.0);  
        start_i = 1;
        #10;
        start_i = 0;

        // Espera a multiplicação terminar
        wait (done_o);
        #10;
        $display("Resultado: hexa 0x%h decimal %f", product_o, $bitstoshortreal(product_o)); // Esperado: 0xFF800000 (número infinito em ponto flutuante IEEE 754). Infinito.
        
        // Teste 8: Multiplicação com números muito próximos de zero
        a_i = 32'h00000001; // número muito próximo de zero
        b_i = 32'h00000001; // número muito próximo de zero
        start_i = 1;
        #10;
        start_i = 0;

        // Espera a multiplicação terminar
        wait (done_o);
        #10;
        $display("Resultado: hexa 0x%h decimal %f", product_o, $bitstoshortreal(product_o)); // Esperado: 0x00000000 (0 em ponto flutuante IEEE 754). Underflow.
        
        // Teste 9: Multiplicação com números muito grandes
        a_i = 32'h7F7FFFFF; // Valor muito grande (próximo ao máximo representável)
        b_i = 32'h7F7FFFFF; // Valor muito grande (próximo ao máximo representável)
        start_i = 1;
        #10;
        start_i = 0;

        // Espera a multiplicação terminar
        wait (done_o);
        #10;
        $display("Resultado: hexa 0x%h decimal %f", product_o, $bitstoshortreal(product_o)); // Esperado: 0x7F800000 (infinito, overflow)

        // Finaliza a simulação
        $finish;
    end

endmodule