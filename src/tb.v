// Verilog test fixture created from schematic D:\FPGA_HW_1\CPU\CPU.sch - Sun Nov 14 04:04:13 2021

`timescale 1ns / 1ps
`define auto_init

module TB();

parameter clk_period = 20;
parameter delay_factor = 2;

// Inputs
	reg          clk_i;
	reg          rst_n;

	reg          ex_iwe;
	reg [ 8-1:0] ex_iaddr;
	reg [16-1:0] ex_idata;
	reg          ex_dwe;
	reg [ 8-1:0] ex_daddr;
	reg [16-1:0] ex_ddata;

// Output
	wire [15:0] Out_R;
	wire flag_done;

// Bidirs

	/*****************************************************/
	/*                                                   */
	/*                Instantiate the UUT                */
	/*                                                   */
	/*****************************************************/

	Single_Cycle_CPU u_Single_Cycle_CPU(
		.clk_i     (clk_i     ),
		.rst_n     (rst_n     ),
		.Out_R     (Out_R     ),
		.flag_done (flag_done ),
		.ex_iwe    (ex_iwe    ),
		.ex_iaddr  (ex_iaddr  ),
		.ex_idata  (ex_idata  ),
		.ex_dwe    (ex_dwe    ),
		.ex_daddr  (ex_daddr  ),
		.ex_ddata  (ex_ddata  )
	);
	
	
	/*****************************************************/
	/*                                                   */
	/*                 Initialize Inputs                 */
	/*                                                   */
	/*****************************************************/

	`ifdef auto_init
		initial begin
			clk_i    = 1'b0;   
			rst_n    = 1'b0;
			ex_iwe   = 1'b0;
			ex_dwe   = 1'b0;
			ex_iaddr =  8'd0;
			ex_idata = 16'd0;
			ex_daddr =  8'd0;
			ex_ddata = 16'd0;
		end
	`endif

	/*****************************************************/
	/*                                                   */
	/*             Generate the clock signal             */
	/*                                                   */
	/*****************************************************/

	always begin
		#(clk_period/2) clk_i <= 1'b0;
		#(clk_period/2) clk_i <= 1'b1;
	end

	/*****************************************************/
	/*                                                   */
	/*                   Main Program                    */
	/*                                                   */
	/*****************************************************/

	initial begin
		
		///////////////////////////////////////////////////////////////////////////////////
		//                                                                               //
		//             Find the minimum and maximum from two numbers in memory.          //
		//                                                                               // 
		///////////////////////////////////////////////////////////////////////////////////	
		
		// $readmemb("max_min_test.txt", UUT.u_Instruction_Memory.memory);
		write_imem(8'h00, 16'b00010_000_00100101) ;   //LLI  R0,#25h
		write_imem(8'h01, 16'b00011_001_000_00000) ;  //LDR  R1, R0, #0
		write_imem(8'h02, 16'b00011_010_000_00001) ;  //LDR  R2, R0, #1
		write_imem(8'h03, 16'b11100_000_001_000_00) ; //OUTR R1 (20h)
		write_imem(8'h04, 16'b11100_000_010_000_00) ; //OUTR R2 (10h)
		write_imem(8'h05, 16'b00110_000_001_010_01) ; //CMP  R1, R2
		write_imem(8'h06, 16'b1100_0010_00000010) ;   //BCS  R1_bigger
		write_imem(8'h07, 16'b01011_001_010_000_00) ; //MOV  R1, R2.
		write_imem(8'h08, 16'b00101_001_000_00010) ;  //STR  R1, R0, #2
		write_imem(8'h09, 16'b11100_000_001_000_00) ; //OUTR R1 (20h)
		write_imem(8'h0A, 16'b11100_0000_00000_01) ;  //HLT

		write_dmem(8'h25, 16'h20 ) ;                  // data (25h, 20h)
		write_dmem(8'h26, 16'h10 ) ;                  // data (26h, 10h)

		//start
		#(clk_period) ex_iwe = 1'b0;
		#(clk_period) ex_dwe = 1'b0;
		#(clk_period) rst_n = 1'b1;

		wait(flag_done);
		
		///////////////////////////////////////////////////////////////////////////////////
		//                                                                               //
		//   Add two numbers in memory and store the result in another memory location.  //
		//                                                                               // 
		///////////////////////////////////////////////////////////////////////////////////		
		
		// $readmemb("add_test.txt", UUT.u_Instruction_Memory.memory);
		write_imem(8'h00, 16'b00010_000_00100101) ;   // LLI  R0,      #25h
		write_imem(8'h01, 16'b00011_001_000_00000) ;  // LDR  R1, R0,  #0
		write_imem(8'h02, 16'b00011_010_000_00001) ;  // LDR  R2, R0,  #1
		write_imem(8'h03, 16'b11100_000_001_000_00) ; // OUTR R1 (10h)
		write_imem(8'h04, 16'b11100_000_010_000_00) ; // OUTR R2 (20h)
		write_imem(8'h05, 16'b00000_011_001_010_00) ; // ADD  R3, R1,  R2
		write_imem(8'h06, 16'b00101_011_000_00010) ;  // STR  R3, R0,  #2
		write_imem(8'h07, 16'b11100_000_011_000_00) ; // OUTR R3 (30h)
		write_imem(8'h08, 16'b11100_0000_00000_01) ;  // HLT

		write_dmem(8'h25, 16'h20 ) ;                  // data (25h, 20h)
		write_dmem(8'h26, 16'h10 ) ;                  // data (26h, 10h)

		//start
		#(clk_period) ex_iwe = 1'b0;
		#(clk_period) ex_dwe = 1'b0;
		#(clk_period) rst_n = 1'b1;

		wait(flag_done);	
		
		///////////////////////////////////////////////////////////////////////////////////
		//                                                                               //
		//                  Add ten numbers in consecutive memory locations.             //
		//                                                                               // 
		///////////////////////////////////////////////////////////////////////////////////	
		
		// $readmemb("ten_acc_test.txt", UUT.u_Instruction_Memory.memory);
		write_imem(8'h00, 16'b00010_000_00100101) ;    //LLI  R0,  #25h
		write_imem(8'h01, 16'b00010_011_00001010) ;    //LLI  R3,  #10
		write_imem(8'h02, 16'b00010_100_00000001) ;    //LLI  R4,  #1
		write_imem(8'h03, 16'b00010_010_00000000) ;    //LLI  R2,  #0
		write_imem(8'h04, 16'b00011_001_000_00000) ;   //LDR  R1,  R0, #0
		write_imem(8'h05, 16'b11100_000_001_000_00) ;  //OUTR R1  (1,2,3,4,5,6,7,8,9)
		write_imem(8'h06, 16'b00000_010_010_001_00) ;  //ADD  R2,  R2, R1
		write_imem(8'h07, 16'b00111_000_000_00001) ;   //ADDI R0,  R0, 1
		write_imem(8'h08, 16'b01000_011_011_00001) ;   //SUBI R3,  R3, 1
		write_imem(8'h09, 16'b00110_000_011_100_01) ;  //CMP  R3,  R4
		write_imem(8'h0A, 16'b1100_0010_11111010) ;    //BCS  Loop
		write_imem(8'h0B, 16'b00101_010_000_00101) ;   //STR  R2,  R0, #5
		write_imem(8'h0C, 16'b11100_000_010_000_00) ;  //OUTR R2  (45)
		write_imem(8'h0D, 16'b11100_0000_00000_01) ;   //HLT

		write_dmem(8'h25, 16'h1 ) ;                    // data (25h, 1h)
		write_dmem(8'h26, 16'h2 ) ;                    // data (26h, 2h)
		write_dmem(8'h27, 16'h3 ) ;                    // data (27h, 3h)
		write_dmem(8'h28, 16'h4 ) ;                    // data (28h, 4h)
		write_dmem(8'h29, 16'h5 ) ;                    // data (29h, 5h)
		write_dmem(8'h2A, 16'h6 ) ;                    // data (2Ah, 6h)
		write_dmem(8'h2B, 16'h7 ) ;                    // data (2Bh, 7h)
		write_dmem(8'h2C, 16'h8 ) ;                    // data (2Ch, 8h)
		write_dmem(8'h2D, 16'h9 ) ;                    // data (2Dh, 9h)
		write_dmem(8'h2E, 16'hA ) ;                    // data (2Eh, Ah)

		//start
		#(clk_period) ex_iwe = 1'b0;
		#(clk_period) ex_dwe = 1'b0;
		#(clk_period) rst_n = 1'b1;

		wait(flag_done);
		
		///////////////////////////////////////////////////////////////////////////////////
		//                                                                               //
		//             Mov a memory block of N words from one place to another.          //
		//                                                                               // 
		///////////////////////////////////////////////////////////////////////////////////	
		
		//$readmemb("D:/FPGA/FPGA_HW_2/data/mov_10_test.txt", UUT.u_Instruction_Memory.memory);
		write_imem(8'h00, 16'b00010_000_00100101) ;   //LLI  R0, #25h
		write_imem(8'h01, 16'b00010_010_00001010) ;   //LLI  R2, #10
		write_imem(8'h02, 16'b00010_011_00000001) ;   //LLI  R3, #1
		write_imem(8'h03, 16'b00010_100_00111001) ;   //LLI  R4, #39h
		write_imem(8'h04, 16'b00011_001_000_00000) ;  //LDR  R1, R0, #0
		write_imem(8'h05, 16'b11100_000_001_000_00) ; //OUTR R1 (1,2,3,4,5,6,7,8,9,10)
		write_imem(8'h06, 16'b00101_001_000_10100) ;  //STR  R1, R0, #20
		write_imem(8'h07, 16'b00111_000_000_00001) ;  //ADDI R0, R0, 1
		write_imem(8'h08, 16'b01000_010_010_00001) ;  //SUBI R2, R2, 1
		write_imem(8'h09, 16'b00110_000_010_011_01) ; //CMP  R2, R3
		write_imem(8'h0A, 16'b1100_0010_11111010) ;   //BCS  Loop
		write_imem(8'h0B, 16'b00010_010_00001010) ;   //LLI  R2, #10
		write_imem(8'h0C, 16'b00011_001_100_00000) ;  //LDR  R1, R4, #0
		write_imem(8'h0D, 16'b11100_000_001_000_00) ; //OUTR R1 (1,2,3,4,5,6,7,8,9,10)
		write_imem(8'h0E, 16'b00111_100_100_00001) ;  //ADDI R4, R4, #1
		write_imem(8'h0F, 16'b01000_010_010_00001) ;  //SUBI R2, R2, #1
		write_imem(8'h10, 16'b00110_000_010_011_01) ; //CMP  R2, R3
		write_imem(8'h11, 16'b1100_0010_11111011) ;   //BCS  Loop_check
		write_imem(8'h12, 16'b11100_0000_00000_01) ;  //HLT

		write_dmem(8'h25, 16'h1 ) ;                   // data (25h, 1h)
		write_dmem(8'h26, 16'h2 ) ;                   // data (26h, 2h)
		write_dmem(8'h27, 16'h3 ) ;                   // data (27h, 3h)
		write_dmem(8'h28, 16'h4 ) ;                   // data (28h, 4h)
		write_dmem(8'h29, 16'h5 ) ;                   // data (29h, 5h)
		write_dmem(8'h2A, 16'h6 ) ;                   // data (2Ah, 6h)
		write_dmem(8'h2B, 16'h7 ) ;                   // data (2Bh, 7h)
		write_dmem(8'h2C, 16'h8 ) ;                   // data (2Ch, 8h)
		write_dmem(8'h2D, 16'h9 ) ;                   // data (2Dh, 9h)
		write_dmem(8'h2E, 16'hA ) ;                   // data (2Eh, Ah)

		//start
		#(clk_period) ex_iwe = 1'b0;
		#(clk_period) ex_dwe = 1'b0;
		#(clk_period) rst_n = 1'b1;

		wait(flag_done);
		
		#100 $finish;
	end

	/*****************************************************/
	/*                                                   */
	/*            Write Instrucion to Memoery            */
	/*                                                   */
	/*****************************************************/
	
	task write_imem;
		input [7:0] addr;
		input [15:0] data;
		begin
			@(posedge clk_i) #(clk_period/delay_factor) begin
				ex_iwe = 1'b1;
				ex_iaddr = addr;
				ex_idata = data;
			end
		end
	endtask

	/*****************************************************/
	/*                                                   */
	/*               Write Data to Memoery               */
	/*                                                   */
	/*****************************************************/
	
	task write_dmem;
		input [7:0] addr;
		input [15:0] data;
		begin
			@(posedge clk_i) #(clk_period/delay_factor) begin
				ex_dwe = 1'b1;
				ex_daddr = addr;
				ex_ddata = data;
			end
		end
	endtask

	/*****************************************************/
	/*                                                   */
	/*                      Monitor                      */
	/*                                                   */
	/*****************************************************/
	
	initial #100000 $finish;
	initial
	$monitor($realtime,"ns %h %h %h \n", clk_i, rst_n, Out_R, flag_done);
	
endmodule

