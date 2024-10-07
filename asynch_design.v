module async_FIFO #(parameter DATA_WIDTH = 8, parameter FIFO_DEPTH = 64)(
    input wr_clk,               // Write clock
    input rd_clk,               // Read clock
    input rst,                  // Reset
    input wr_en,                // Write enable
    input rd_en,                // Read enable
    input [DATA_WIDTH-1:0] buf_in,  // Data input (write)
    output reg [DATA_WIDTH-1:0] buf_out, // Data output (read)
    output reg buf_empty,        // FIFO empty flag
    output reg buf_full          // FIFO full flag
);

    reg [DATA_WIDTH-1:0] buf_mem[FIFO_DEPTH-1:0];   // FIFO memory
    reg [5:0] wr_ptr, rd_ptr;                       // Write and read pointers (binary)
    reg [5:0] wr_ptr_gray, rd_ptr_gray;             // Write and read pointers (Gray code)
    reg [5:0] rd_ptr_gray_sync1, rd_ptr_gray_sync2; // Synchronized read pointer in write clock domain
    reg [5:0] wr_ptr_gray_sync1, wr_ptr_gray_sync2; // Synchronized write pointer in read clock domain

    // Gray code conversion (binary to gray)
    function [5:0] binary_to_gray(input [5:0] binary);
        binary_to_gray = (binary >> 1) ^ binary;
    endfunction

    // Gray code to binary conversion
    function [5:0] gray_to_binary(input [5:0] gray);
        integer i;
        begin
            gray_to_binary[5] = gray[5];
            for (i = 4; i >= 0; i = i - 1)
                gray_to_binary[i] = gray[i] ^ gray_to_binary[i+1];
        end
    endfunction

    // Write pointer update (write clock domain)
    always @(posedge wr_clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 0;
            wr_ptr_gray <= 0;
        end else if (wr_en && !buf_full) begin
            buf_mem[wr_ptr] <= buf_in;
            wr_ptr <= wr_ptr + 1;
            wr_ptr_gray <= binary_to_gray(wr_ptr + 1);
        end
    end

    // Read pointer update (read clock domain)
    always @(posedge rd_clk or posedge rst) begin
        if (rst) begin
            rd_ptr <= 0;
            rd_ptr_gray <= 0;
        end else if (rd_en && !buf_empty) begin
            buf_out <= buf_mem[rd_ptr];
            rd_ptr <= rd_ptr + 1;
            rd_ptr_gray <= binary_to_gray(rd_ptr + 1);
        end
    end

    // Synchronize read pointer to write clock domain
    always @(posedge wr_clk or posedge rst) begin
        if (rst) begin
            rd_ptr_gray_sync1 <= 0;
            rd_ptr_gray_sync2 <= 0;
        end else begin
            rd_ptr_gray_sync1 <= rd_ptr_gray;
            rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;
        end
    end

    // Synchronize write pointer to read clock domain
    always @(posedge rd_clk or posedge rst) begin
        if (rst) begin
            wr_ptr_gray_sync1 <= 0;
            wr_ptr_gray_sync2 <= 0;
        end else begin
            wr_ptr_gray_sync1 <= wr_ptr_gray;
            wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;
        end
    end

    // Full condition check (write clock domain)
    always @(posedge wr_clk or posedge rst) begin
        if (rst)
            buf_full <= 0;
        else
            buf_full <= (wr_ptr_gray == {~rd_ptr_gray_sync2[5:4], rd_ptr_gray_sync2[3:0]});
    end

    // Empty condition check (read clock domain)
    always @(posedge rd_clk or posedge rst) begin
        if (rst)
            buf_empty <= 1;
        else
            buf_empty <= (rd_ptr_gray == wr_ptr_gray_sync2);
    end

endmodule
