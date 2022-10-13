module RegisterFile
(
    clk,
    rst_n,
    we,
    ra_addr,
    rb_addr,
    wr_addr,
    wr_data,
    ra_data,
    rb_data
);
//*****************************************************************************
    // I/O port declaration
    input           clk;     // System clock
    input           rst_n;   // All reset
    input           we;      // Register write
    input  [ 3-1:0] ra_addr; // Source register 1 index
    input  [ 3-1:0] rb_addr; // Source register 2 index
    input  [ 3-1:0] wr_addr; // Destination register index
    input  [16-1:0] wr_data; // Destination register data
    output [16-1:0] ra_data; // Source register 1 data
    output [16-1:0] rb_data; // Source register 2 data

    // Global variable declaration
    // System
    reg signed [15:0] register [0:7]; // 16 word registers

    // System conection
    // Output
    assign ra_data = register[ra_addr];
    assign rb_data = register[rb_addr];
//*****************************************************************************
// Block: Register File
    always @(posedge clk or negedge rst_n) 
    begin
        if (~rst_n) // Initial
        begin
            register[0] <= 16'd0; register[1] <= 16'd0; register[2] <= 16'd0; register[3] <= 16'd0;
            register[4] <= 16'd0; register[5] <= 16'd0; register[6] <= 16'd0; register[7] <= 16'd0;
        end
        else
        begin
            if (we) // Write
                register[wr_addr] <= wr_data;
        end
    end
//*****************************************************************************
endmodule