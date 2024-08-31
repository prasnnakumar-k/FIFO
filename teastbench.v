// Testbench for FIFO Buffer Module
module tb_FIFO();

    // Testbench signals
    reg clk;
    reg rst;
    reg wr_en;
    reg rd_en;
    reg [7:0] buf_in;
    wire [7:0] buf_out;
    wire buf_empty;
    wire buf_full;
    wire [6:0] fifo_counter;

    // Instantiate the FIFO module
    FIFO uut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .buf_in(buf_in),
        .buf_out(buf_out),
        .buf_empty(buf_empty),
        .buf_full(buf_full),
        .fifo_counter(fifo_counter)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        // Initialize signals
        clk = 0;
        rst = 0;
        wr_en = 0;
        rd_en = 0;
        buf_in = 8'b0;

        // Apply reset
        rst = 1;
        #10;
        rst = 0;

        // Write some data to FIFO
        wr_en = 1;
        buf_in = 8'hAA;  // Write 0xAA
        #10;
        buf_in = 8'hBB;  // Write 0xBB
        #10;
        buf_in = 8'hCC;  // Write 0xCC
        #10;
        buf_in = 8'hDD;  // Write 0xDD
        #10;
        wr_en = 0;

        // Read data from FIFO
        rd_en = 1;
        #20;  // Read 0xAA
        #10;  // Read 0xBB
        rd_en = 0;

        // Write more data to FIFO
        wr_en = 1;
        buf_in = 8'hEE;  // Write 0xEE
        #10;
        buf_in = 8'hFF;  // Write 0xFF
        #10;
        wr_en = 0;

        // Read the rest of the data
        rd_en = 1;
        #40;  // Read 0xCC, 0xDD, 0xEE, 0xFF
        rd_en = 0;

        // Finish the simulation
        #10;
        $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time: %0d | rst: %b | wr_en: %b | rd_en: %b | buf_in: %h | buf_out: %h | buf_empty: %b | buf_full: %b | fifo_counter: %d", 
                 $time, rst, wr_en, rd_en, buf_in, buf_out, buf_empty, buf_full, fifo_counter);
    end

endmodule
