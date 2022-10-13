module ProgramCounter
(
    clk,   // System clock
    rst_n, // All reset
    load,  // Next PC address
    count  // PC address for now
);
//*****************************************************************************
    // I/O port declaration
    input  wire          clk;   // System clock
    input  wire          rst_n;  // All reset
    input  wire [16-1:0] load;  // Next PC address
    output reg  [16-1:0] count; // PC address for now
//*****************************************************************************
// Block : PC data out
    always @(posedge clk or negedge rst_n) 
    begin
        if(~rst_n)
            count <= 16'd0;
        else
            count <= load;
    end
//*****************************************************************************
endmodule
