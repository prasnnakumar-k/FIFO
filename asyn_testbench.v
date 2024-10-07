module tb_async_FIFO;

    reg wr_clk, rd_clk, rst, wr_en, rd_en;
    reg [7:0] buf_in;
    wire [7:0] buf_out;
    wire buf_empty, buf_full;

    // Instantiate the FIFO
    async_FIFO uut (
        .wr_clk(wr_clk),
        .rd_clk(rd_clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .buf_in(buf_in),
        .buf_out(buf_out),
        .buf_empty(buf_empty),
        .buf_full(buf_full)
    );

    // Generate independent clocks
    always #5 wr_clk = ~wr_clk; // 100 MHz write clock
    always #7 rd_clk = ~rd_clk; // 71.43 MHz read clock

    initial begin
        // Initialize signals
        wr_clk = 0; rd_clk = 0; rst = 1; wr_en = 0; rd_en = 0; buf_in = 8'h00;

        // Reset the FIFO
        #10 rst = 0;
        
        // Write some data into the FIFO
        wr_en = 1;
        buf_in = 8'hA1; #10;
        buf_in = 8'hB2; #10;
        buf_in = 8'hC3; #10;
        buf_in = 8'hD4; #10;
        wr_en = 0;

        // Read the data from the FIFO
        rd_en = 1; #30;
        rd_en = 0;

        // Add more data and repeat
        wr_en = 1;
        buf_in = 8'hE5; #10;
        wr_en = 0;

        // Read more data
        rd_en = 1; #20;
        rd_en = 0;

        // Finish simulation
        #50 $finish;
    end

    initial begin
        $monitor("Time: %0t | buf_in: %h | buf_out: %h | buf_empty: %b | buf_full: %b", $time, buf_in, buf_out, buf_empty, buf_full);
    end

endmodule
