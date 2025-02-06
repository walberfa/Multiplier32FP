module multiplier32FP_tb;
    logic [31:0] data [0:29][2:0]; 
    logic [31:0] a [0:29];
    logic [31:0] b [0:29];
    logic [31:0] res [0:29];

    logic [31:0] a_i, b_i;
    logic [31:0] product_o;
    logic clk, rst_n;
    logic start_i;
    logic done_o;
    logic nan_o;
    logic infinit_o;
    logic overflow_o;
    logic underflow_o;

    multiplier32FP U1 (.start_i(start_i), .clk(clk), .rst_n(rst_n), .a_i(a_i), .b_i(b_i), .product_o(product_o), .done_o(done_o), .nan_o(nan_o), .infinit_o(infinit_o), .overflow_o(overflow_o), .underflow_o(underflow_o));

    initial begin
        clk = 1;
        forever #5 clk = ~clk;
    end

    initial begin
        start_i = 0;
        rst_n = 0;
        #100;
        rst_n = 1;
        start_i = 1;

        $readmemh("vetor.txt", data);

        for (int i = 0; i < 32; i++) begin
            a[i] = data[i][0];
            b[i] = data[i][1];
            res[i] = data[i][2];
        end
        #1;

        for (int i = 0; i < 30; i++) begin
            wait(~done_o)
            a_i = a[i];
            b_i = b[i];
            wait(done_o)
            #1;
            $display("+-------caso %1d binario-------------------------+", i);
            $display("a_i:       %h", a_i);
            $display("b_i:       %h", b_i);
            $display("product_o: %h", product_o);
            $display("expected:  %h", res[i]);
            $display("+-------caso %1d decimal-------------------------+",i);
            $display("a_i:       %f", $bitstoshortreal(a_i));
            $display("b_i:       %f", $bitstoshortreal(b_i));
            $display("product_o: %f", $bitstoshortreal(product_o));
            $display("expected:  %f", $bitstoshortreal(res[i]));
            $display("expected:  %f", shortreal'($bitstoshortreal(a_i)*$bitstoshortreal(b_i)));
            $display("+------------------------------------------------+");
        end
        #1000;
        $finish;
    end

    initial begin
        $dumpfile("multiplier32FP.vcd");
        $dumpvars("");
    end

endmodule