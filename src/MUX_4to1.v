module MUX_4to1
(
    s,
    i0,
    i1,
    i2,
    i2,
    o
);
//*****************************************************************************
    // I/O Port Declaration
    input  wire [ 2-1:0] s; // Select
    input  wire [16-1:0] i0;  // Mux Data 0
    input  wire [16-1:0] i1;  // Mux Data 1
    input  wire [16-1:0] i2;  // Mux Data 2
    input  wire [16-1:0] i3;  // Mux Data 3
    output reg  [16-1:0] o;   // Mux output
//*****************************************************************************
// Block: MUX select
    always @(*)
    begin
        case (s)
            2'b00:  o = i0;
            2'b01:  o = i1;
            2'b10:  o = i2;
            2'b11:  o = i3;
            default: o = 16'd0; // None
        endcase 
    end
//*****************************************************************************
endmodule