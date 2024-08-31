// FIFO Buffer Module
module FIFO(
    input clk,
    input rst,
    input wr_en,
    input rd_en,
    input [7:0] buf_in,
    output reg [7:0] buf_out,
    output reg buf_empty,
    output reg buf_full,
    output reg [6:0] fifo_counter
);

    reg [3:0] rd_ptr, wr_ptr;
    reg [7:0] buf_mem[63:0];

    // Update empty and full flags based on fifo_counter
    always @(fifo_counter) begin
        buf_empty = (fifo_counter == 0);
        buf_full = (fifo_counter == 64);
    end

    // Update fifo_counter based on write and read operations
    always @(posedge clk or posedge rst) begin
        if (rst)
            fifo_counter <= 0;
        else if ((wr_en && !buf_full) && (rd_en && !buf_empty))
            fifo_counter <= fifo_counter;
        else if (wr_en && !buf_full)
            fifo_counter <= fifo_counter + 1;
        else if (rd_en && !buf_empty)
            fifo_counter <= fifo_counter - 1;
        else
            fifo_counter <= fifo_counter;
    end

    // Update buf_out based on read operations
    always @(posedge clk or posedge rst) begin
        if (rst)
            buf_out <= 0;
        else if (rd_en && !buf_empty)
            buf_out <= buf_mem[rd_ptr];
    end

    // Write data into buf_mem based on write operations
    always @(posedge clk) begin
        if (wr_en && !buf_full)
            buf_mem[wr_ptr] <= buf_in;
    end

    // Update write and read pointers
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
        end else begin
            if (wr_en && !buf_full)
                wr_ptr <= wr_ptr + 1;
            if (rd_en && !buf_empty)
                rd_ptr <= rd_ptr + 1;
        end
    end

endmodule
