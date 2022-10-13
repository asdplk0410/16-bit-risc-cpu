module MUX_8to1
(
    s,
    i0,
    i1,
    i2,
    i3,
    i4,
    i5,
    i6,
    i7,
    o
);
//*****************************************************************************
    // I/O Port Declaration
    input  wire [ 3-1:0] s;   // Select
    input  wire [16-1:0] i0;  // Mux Data 0
    input  wire [16-1:0] i1;  // Mux Data 1
    input  wire [16-1:0] i2;  // Mux Data 2
    input  wire [16-1:0] i3;  // Mux Data 3
    input  wire [16-1:0] i4;  // Mux Data 4
    input  wire [16-1:0] i5;  // Mux Data 5
    input  wire [16-1:0] i6;  // Mux Data 6
    input  wire [16-1:0] i7;  // Mux Data 7
    output reg  [16-1:0] o;   // Mux output
//*****************************************************************************
// Block: MUX select
    always @(*)
    begin
        case (s)
            3'b000:  o = i0;
            3'b001:  o = i1;
            3'b010:  o = i2;
            3'b011:  o = i3;
            3'b100:  o = i4;
            3'b101:  o = i5;
            3'b110:  o = i6;
            3'b111:  o = i7;
            default: o = 16'd0; // None
        endcase 
    end
//*****************************************************************************
endmodule