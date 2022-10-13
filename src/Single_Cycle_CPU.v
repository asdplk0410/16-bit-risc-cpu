module Single_Cycle_CPU
(
    clk_i,
    rst_n,
    Out_R,
    flag_done,
    ex_iwe,
    ex_iaddr,
    ex_idata,
    ex_dwe,
    ex_daddr,
    ex_ddata
);
//*****************************************************************************
    ///////////////////////////////////////////////////////////////////////////
    // I/O Ports Declaration
    input           clk_i;         // System clock
    input           rst_n;         // All reset
    output [16-1:0] Out_R;
    output          flag_done;

    input           ex_iwe;
    input   [8-1:0] ex_iaddr;
    input  [16-1:0] ex_idata;
    input           ex_dwe;
    input   [8-1:0] ex_daddr;
    input  [16-1:0] ex_ddata;

    // Global variables Declaration
    wire            clk;

    // ProgramCounter
    wire [16-1:0]   PC_next;       // PC address in
    reg  [16-1:0]   PC;            // PC address out
    wire [16-1:0]   PC_plus;
    wire [16-1:0]   PC_plus_label;
    wire [16-1:0]   PC_branch;
    wire [16-1:0]   PC_jump;
    wire [16-1:0]   PC_jalr;

    // Instr_Memory
    wire [16-1:0]   instr;         // Instruction data
    wire [16-1:0]   idata;
    wire [ 8-1:0]   iaddr;

    // Controller
    wire ALU_src;                  // ALU source B select
    wire RegWrite;                 // Register Write
    wire MemWrite;                 // Memory Write
    wire RD_src;
    wire [2:0] Mem_src;            // Destination register write back data select
    wire PC_src; 
    wire Jmp;
    wire Jalr;                     // Jalr instruction
    wire Jr;
    wire OutR;

    // Reg_File
    wire [ 3-1:0] rm_addr;         // Source register 1 index
    wire [ 3-1:0] rn_addr;         // Source register 2 index
    wire [ 3-1:0] rd_addr;         // Destination register index
    wire [16-1:0] rm_data;         // Source register 1 data
    wire [16-1:0] rn_data;         // Source register 2 data
    wire [16-1:0] rd_data;         // Destination register data

    wire [ 3-1:0] rb_addr; 

    // ALU
    wire [16-1:0] B;               // ALU source B value
    wire [16-1:0] ALU_result;      // ALU operation result
    wire [ 4-1:0] NZVC;            // NZVC flag, N: Negative, Z: Zero, V: Overflow, C: Carry

    // ALU_Ctrl
    wire          Sub;        

    // Data_Memory
    wire [16-1:0] data;            // Memory read data
    wire [16-1:0] ddata;
    wire [ 8-1:0] daddr;
    wire          dwe;

    // Register
    reg [ 4-1:0] NZVC_reg; 
    ///////////////////////////////////////////////////////////////////////////
    // System conection
    // input
    assign clk = (flag_done) ? 1'b0 : clk_i;

    // output
    assign Out_R = (OutR) ? rm_data : {16{1'b0}} ;

    // Program Counter
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) PC <= 16'd0;   // Next PC value
        else       PC <= PC_next; // Present PC value
    end

    MUX_2to1 
    #(
        .DATA_WIDTH (8 )
    )
    u_Instruction_Memory_MUX_2to1(
        .s  (ex_iwe  ),
        .i0 (PC[7:0] ),
        .i1 (ex_iaddr ),
        .o  (iaddr  )
    );

    MUX_2to1 
    #(
        .DATA_WIDTH (16 )
    )
    u_Instruction_Latch_MUX_2to1(
        .s  (ex_iwe ),
        .i0 (idata  ),
        .i1 (16'd1  ),
        .o  (instr  )
    );

    // Instruction Memory
    Memory u_Instruction_Memory(
    	.clk   (clk        ),
        .addr  (iaddr      ), // Present PC value
        .idata (ex_idata   ), // Instruction data
        .wr    (ex_iwe     ),
        .odata (idata      )
    );

    MUX_2to1 
    #(
        .DATA_WIDTH (8 )
    )
    u_Data_Memory_ADDR_MUX_2to1(
        .s  (ex_dwe  ),
        .i0 (ALU_result[7:0] ),
        .i1 (ex_daddr ),
        .o  (daddr  )
    );

    MUX_2to1 
    #(
        .DATA_WIDTH (16)
    )
    u_Data_Memory_Data_MUX_2to1(
        .s  (ex_dwe   ),
        .i0 (rn_data  ),
        .i1 (ex_ddata ),
        .o  (ddata    )
    );

    assign dwe = MemWrite|ex_dwe;

    // Data Memory
    Memory u_Data_Memory(
    	.clk   (clk             ), // System clock
        .addr  (daddr           ), // Memory address value
        .idata (ddata           ), // Memory write data
        .wr    (dwe             ), // Memory write control signal
        .odata (data            )  // Memory read data
    );

    // Controller
    Controller u_Controller(
    	.instr     (instr     ),
        .NZVC      (NZVC_reg  ),
        .ALU_src   (ALU_src   ),
        .RegWrite  (RegWrite  ),
        .MemWrite  (MemWrite  ),
        .RD_src    (RD_src    ),
        .Mem_src   (Mem_src   ),
        .PC_src    (PC_src    ),
        .Jmp       (Jmp       ),
        .Jalr      (Jalr      ),
        .Jr        (Jr        ),
        .OutR      (OutR      ),
        .Hlt       (flag_done )
    );

    // Register File
    assign rd_addr = instr[10:8];
    assign rm_addr = instr[7:5];
    assign rn_addr = instr[4:2];

    RegisterFile u_RegisterFile(
    	.clk     (clk      ),
        .rst_n   (rst_n    ),
        .we      (RegWrite ), // Register write control signal
        .ra_addr (rm_addr  ), // Source register 1 index
        .rb_addr (rb_addr  ), // Source register 1 data
        .wr_addr (rd_addr  ), // Destination register index
        .wr_data (rd_data  ), // Destination register data
        .ra_data (rm_data  ), // Source register 1 data
        .rb_data (rn_data  )  // Source register 2 data
    );

    MUX_2to1 
    #(
        .DATA_WIDTH(3)
    )
    u_RB_MUX_2to1
    (
    	.s  (RD_src  ),
        .i0 (rn_addr ),
        .i1 (rd_addr ),
        .o  (rb_addr )
    );
    

    // ALU source B select
    MUX_2to1 u_ALU_MUX_2to1(
    	.s  (ALU_src           ), // ALU source B select
        .i0 (rn_data           ), // Source register 2 data
        .i1 ({11'd0,instr[4:0]}), // Immediate value
        .o  (B                 )  // ALU source B data
    );

    // Arithmetic Logic Unit
    ALU u_ALU(
    	.A      (rm_data     ), // ALU source A value
        .B      (B           ), // ALU source B value
        .Cin    (NZVC_reg[0] ),
        .Sub    (Sub         ), // ALU control signals
        .Cin_en (Cin_en      ),
        .Sum    (ALU_result  ), // ALU operation result
        .NZVC   (NZVC        )  // NZVC flag, N: Negative, Z: Zero, C: Carry, V: Overflow
    );

    always@(posedge clk) NZVC_reg <= NZVC;

    // ALU controller
    ALU_Conrtoller u_ALU_Conrtoller(
    	.opcode (instr[15:11] ), // function code
        .ALU_op (instr[1:0]   ), // ALU opcode
        .Sub    (Sub          ), // ALU Control signals
        .Cin_en (Cin_en       )
    );

    // Write back source select
    MUX_8to1 u_MUX_8to1(
    	.s  (Mem_src                    ), // Write back data select
        .i0 ({instr[7:0], rn_data[7:0]} ),
        .i1 ({{8{1'b0}} ,   instr[7:0]} ),
        .i2 (data                       ), // Memory read data
        .i3 (ALU_result                 ), // ALU operation result
        .i4 (rm_data                    ), // rm
        .i5 (PC_plus                    ), // PC+1 value
        .i6 ({16{1'b0}}                 ),
        .i7 ({16{1'b0}}                 ),
        .o  (rd_data                    ) // Destination register write back data
    );

    // Target address with branch select
    assign PC_plus       = PC + 1'b1;                        // PC + 1
    assign PC_plus_label = PC + {{8{instr[7]}}, instr[7:0]}; // Immediate Generator (Sign Extension)
    
    MUX_2to1 u_PC_0_MUX_2to1(
    	.s  (PC_src        ),
        .i0 (PC_plus       ),
        .i1 (PC_plus_label ),
        .o  (PC_branch     )
    );

    // Next PC source select
    MUX_2to1 u_PC_1_MUX_2to1(
    	.s  (Jmp                      ),
        .i0 (PC_branch                ),
        .i1 ({PC[15:11], instr[10:0]} ),
        .o  (PC_jump                  )
    );
    
    MUX_2to1 u_PC_2_MUX_2to1(
    	.s  (Jalr                     ),  // Jalr instruction
        .i0 (PC_jump                  ),
        .i1 (rm_data                  ),
        .o  (PC_jalr                  )
    );

    MUX_2to1 u_PC_3_MUX_2to1(
    	.s  (Jr                       ),
        .i0 (PC_jalr                  ), // Jump address
        .i1 (rn_data                  ),
        .o  (PC_next                  ) // Next PC value
    );

//*****************************************************************************
endmodule