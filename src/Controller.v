module Controller
(
    instr,
    ALU_src,
    RegWrite,
    MemWrite,
    RD_src,
    Mem_src,
    PC_src,
    Jmp,
    Jalr,
    Jr,
    OutR,
    Hlt,
    NZVC
);
//*****************************************************************************
    // Parameters declaration
    // Operation codes
    localparam LHI  = 5'b00001; 
    localparam LLI  = 5'b00010; 
    localparam LDR  = 5'b00011; 
    localparam STR  = 5'b00101; 
    localparam ALU  = 5'b00000; 
    localparam CMP  = 5'b00110; 
    localparam ADDI = 5'b00111; 
    localparam SUBI = 5'b01000; 
    localparam MOV  = 5'b01011; 
    localparam BRN  = 5'b11000;
    localparam BAL  = 5'b11001;
    localparam JMP  = 5'b10000;
    localparam JAL  = 5'b10001;
    localparam JALR = 5'b10010;
    localparam JR   = 5'b10011;
    localparam OUT  = 5'b11100;

    // I/O port declaration
    input  wire [16-1:0] instr; // Instruction opcode
    input  wire [   3:0] NZVC;
    output reg ALU_src;
    output reg RegWrite;
    output reg MemWrite;
    output reg RD_src;
    output reg [2:0] Mem_src;
    output reg PC_src;
    output reg Jmp;
    output reg Jalr;
    output reg Jr;
    output reg OutR;
    output reg Hlt;

//*****************************************************************************
// Block: Control Singal Decoder
    always @(*)
    begin
        case (instr[15:11]) // Acturally use 5 bits
        ///////////////////////////////////////////////////////////////////////////
        // Solve the truth table
        ///////////////////////////////////////////////////////////////////////////
        // opcode | RegWrite | ALU_src | MemWrite |  Mem_src | RD_src | Jmp | Jalr | Jr |   OutR  |   Hlt   |
        // -------+----------+---------+----------+----------+--------+-----+------+----|---------+---------+-----
        //  00001 |     1    |    0    |    0     |    000   |    1   |  0  |   0  |  0 |    0    |    0    | LHI
        //  00010 |     1    |    0    |    0     |    001   |    0   |  0  |   0  |  0 |    0    |    0    | LLI
        //  00011 |     1    |    1    |    0     |    010   |    0   |  0  |   0  |  0 |    0    |    0    | LDR
        //  00101 |     0    |    1    |    1     |    000   |    1   |  0  |   0  |  0 |    0    |    0    | STR
        //  00000 |     0    |    0    |    0     |    011   |    0   |  0  |   0  |  0 |    0    |    0    | ALU
        //  00110 |     0    |    0    |    0     |    000   |    0   |  0  |   0  |  0 |    0    |    0    | CMP
        //  00111 |     1    |    1    |    0     |    011   |    0   |  0  |   0  |  0 |    0    |    0    | ADDI
        //  01000 |     1    |    1    |    0     |    011   |    0   |  0  |   0  |  0 |    0    |    0    | SUBI
        //  01011 |     1    |    0    |    0     |    100   |    0   |  0  |   0  |  0 |    0    |    0    | MOV
        //  11000 |     0    |    0    |    0     |    000   |    0   |  0  |   0  |  0 |    0    |    0    | BRN
        //  11001 |     0    |    0    |    0     |    000   |    0   |  0  |   0  |  0 |    0    |    0    | BAL
        //  10000 |     0    |    0    |    0     |    000   |    0   |  1  |   0  |  0 |    0    |    0    | JMP
        //  10001 |     1    |    0    |    0     |    101   |    0   |  0  |   0  |  0 |    0    |    0    | JAL
        //  10010 |     1    |    0    |    0     |    101   |    0   |  0  |   1  |  0 |    0    |    0    | JALR
        //  10011 |     0    |    0    |    0     |    000   |    1   |  0  |   0  |  1 |    0    |    0    | JR
        //  11100 |     0    |    0    |    0     |    000   |    0   |  0  |   0  |  0 |~instr[0]| instr[0]| OUT
        ///////////////////////////////////////////////////////////////////////////
        // opcode | instr[9:8] | Z | C | PC_src |
        // -------+------------+---+---+--------+
        //  11000 |     00     | 1 | x |    1   |
        //  11000 |     01     | 0 | x |    1   |
        //  11000 |     10     | x | 1 |    1   |
        //  11000 |     11     | x | 0 |    1   |
        //  11001 |     xx     | x | x |    1   |
        //  10001 |     xx     | x | x |    1   |
        ///////////////////////////////////////////////////////////////////////////

            LHI :
            begin
                ALU_src   = 1'b0;
                RegWrite  = 1'b1;
                MemWrite  = 1'b0;
                RD_src    = 1'b1;
                Mem_src   = 3'b000;
                PC_src    = 1'b0;
                Jmp       = 1'b0;
                Jalr      = 1'b0;
                Jr        = 1'b0;
                OutR      = 1'b0;
                Hlt       = 1'b0;
            end
            LLI :
            begin
                ALU_src   = 1'b0;
                RegWrite  = 1'b1;
                MemWrite  = 1'b0;
                RD_src    = 1'b0;
                Mem_src   = 3'b001;
                PC_src    = 1'b0;
                Jmp       = 1'b0;
                Jalr      = 1'b0;
                Jr        = 1'b0;
                OutR      = 1'b0;
                Hlt       = 1'b0;
            end
            LDR :
            begin
                ALU_src   = 1'b1;
                RegWrite  = 1'b1;
                MemWrite  = 1'b0;
                RD_src    = 1'b0;
                Mem_src   = 3'b010;
                PC_src    = 1'b0;
                Jmp       = 1'b0;
                Jalr      = 1'b0;
                Jr        = 1'b0;
                OutR      = 1'b0;
                Hlt       = 1'b0;
            end
            STR :
            begin
                ALU_src   = 1'b1;
                RegWrite  = 1'b0;
                MemWrite  = 1'b1;
                RD_src    = 1'b1;
                Mem_src   = 3'b000;
                PC_src    = 1'b0;
                Jmp       = 1'b0;
                Jalr      = 1'b0;
                Jr        = 1'b0;
                OutR      = 1'b0;
                Hlt       = 1'b0;
            end
            ALU :
            begin
                ALU_src   = 1'b0;
                RegWrite  = 1'b1;
                MemWrite  = 1'b0;
                RD_src    = 1'b0;
                Mem_src   = 3'b011;
                PC_src    = 1'b0;
                Jmp       = 1'b0;
                Jalr      = 1'b0;
                Jr        = 1'b0;
                OutR      = 1'b0;
                Hlt       = 1'b0;
            end
            CMP :
            begin
                ALU_src   = 1'b0;
                RegWrite  = 1'b0;
                MemWrite  = 1'b0;
                RD_src    = 1'b0;
                Mem_src   = 3'b000;
                PC_src    = 1'b0;
                Jmp       = 1'b0;
                Jalr      = 1'b0;
                Jr        = 1'b0;
                OutR      = 1'b0;
                Hlt       = 1'b0;
            end
            ADDI:
            begin
                ALU_src   = 1'b1;
                RegWrite  = 1'b1;
                MemWrite  = 1'b0;
                RD_src    = 1'b0;
                Mem_src   = 3'b011;
                PC_src    = 1'b0;
                Jmp       = 1'b0;
                Jalr      = 1'b0;
                Jr        = 1'b0;
                OutR      = 1'b0;
                Hlt       = 1'b0;
            end
            SUBI:
            begin
                ALU_src   = 1'b1;
                RegWrite  = 1'b1;
                MemWrite  = 1'b0;
                RD_src    = 1'b0;
                Mem_src   = 3'b011;
                PC_src    = 1'b0;
                Jmp       = 1'b0;
                Jalr      = 1'b0;
                Jr        = 1'b0;
                OutR      = 1'b0;
                Hlt       = 1'b0;
            end
            MOV :
            begin
                ALU_src   = 1'b0;
                RegWrite  = 1'b1;
                MemWrite  = 1'b0;
                RD_src    = 1'b0;
                Mem_src   = 3'b100;
                PC_src    = 1'b0;
                Jmp       = 1'b0;
                Jalr      = 1'b0;
                Jr        = 1'b0;
                OutR      = 1'b0;
                Hlt       = 1'b0;
            end
            BRN :
            begin
                ALU_src   = 1'b0;
                RegWrite  = 1'b0;
                MemWrite  = 1'b0;
                RD_src    = 1'b0;
                Mem_src   = 3'b000;
                Jmp       = 1'b0;
                Jalr      = 1'b0;
                Jr        = 1'b0;
                OutR      = 1'b0;
                Hlt       = 1'b0;
                case (instr[9:8])
                    2'b00:  PC_src = ( NZVC[2]) ? 1'b1 : 1'b0;
                    2'b01:  PC_src = (!NZVC[2]) ? 1'b1 : 1'b0;
                    2'b10:  PC_src = ( NZVC[0]) ? 1'b1 : 1'b0;
                    2'b11:  PC_src = (!NZVC[0]) ? 1'b1 : 1'b0;
                    default:PC_src = 1'b0;
                endcase
            end
            BAL :
            begin
                ALU_src   = 1'b0;
                RegWrite  = 1'b0;
                MemWrite  = 1'b0;
                RD_src    = 1'b0;
                Mem_src   = 3'b000;
                PC_src    = 1'b1;
                Jmp       = 1'b0;
                Jalr      = 1'b0;
                Jr        = 1'b0;
                OutR      = 1'b0;
                Hlt       = 1'b0;
            end
            JMP :
            begin
                ALU_src   = 1'b0;
                RegWrite  = 1'b0;
                MemWrite  = 1'b0;
                RD_src    = 1'b0;
                Mem_src   = 3'b000;
                PC_src    = 1'b0;
                Jmp       = 1'b1;
                Jalr      = 1'b0;
                Jr        = 1'b0;
                OutR      = 1'b0;
                Hlt       = 1'b0;
            end
            JAL :
            begin
                ALU_src   = 1'b0;
                RegWrite  = 1'b1;
                MemWrite  = 1'b0;
                RD_src    = 1'b0;
                Mem_src   = 3'b101;
                PC_src    = 1'b1;
                Jmp       = 1'b0;
                Jalr      = 1'b0;
                Jr        = 1'b0;
                OutR      = 1'b0;
                Hlt       = 1'b0;
            end
            JALR:
            begin
                ALU_src   = 1'b0;
                RegWrite  = 1'b1;
                MemWrite  = 1'b0;
                RD_src    = 1'b0;
                Mem_src   = 3'b101;
                PC_src    = 1'b0;
                Jmp       = 1'b0;
                Jalr      = 1'b1;
                Jr        = 1'b0;
                OutR      = 1'b0;
                Hlt       = 1'b0;
            end
            JR  :
            begin
                ALU_src   = 1'b0;
                RegWrite  = 1'b0;
                MemWrite  = 1'b0;
                RD_src    = 1'b1;
                Mem_src   = 3'b000;
                PC_src    = 1'b0;
                Jmp       = 1'b0;
                Jalr      = 1'b0;
                Jr        = 1'b1;
                OutR      = 1'b0;
                Hlt       = 1'b0;
            end
            OUT :
            begin
                ALU_src   = 1'b0;
                RegWrite  = 1'b0;
                MemWrite  = 1'b0;
                RD_src    = 1'b0;
                Mem_src   = 3'b000;
                PC_src    = 1'b0;
                Jmp       = 1'b0;
                Jalr      = 1'b0;
                Jr        = 1'b0;
                OutR      = ~instr[0];
                Hlt       =  instr[0];
            end
            default: // None
            begin
                ALU_src   = 1'b0;
                RegWrite  = 1'b0;
                MemWrite  = 1'b0;
                RD_src    = 1'b0;
                Mem_src   = 3'b000;
                PC_src    = 1'b0;
                Jmp       = 1'b0;
                Jalr      = 1'b0;
                Jr        = 1'b0;
                OutR      = 1'b0;
                Hlt       = 1'b0;
            end
        endcase
    end
//*****************************************************************************
endmodule