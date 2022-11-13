
/* RISC-V CPU Core

RISC-V core based on the design used in edX course by Steve Hoover "Building a RISC-V CPU Core".

core features:
RV32I
no pipeline

*/


module program_counter(
	input clk,
	input reset,
	output reg [31:0]pc
	);
	
	reg [31:0]pc_next;		// internal signal

	initial begin
		pc <= 32'b0;
	end
	
	always @(posedge clk)  	begin
		if (!reset) begin
			pc <= 0;			
			pc_next <= 0;
		end
		else
			pc = pc_next;			// use blocking assignments for sequential execution
			pc_next = pc_next + 4;	// 32 bit wide instructions begin every 4 adresses
	end
endmodule

// read only instruction memory
module instruction_memory(
	input wire clk,
	input [31:0] addr,	
	output reg[31:0] instr
	);

	reg [31:0]rom_data;		// signal to store rom until its output via instr

	always @(posedge clk) instr <= rom_data;
	
	always @*
		case(addr)	// lookup table - instructions from Steven Hoover RISC-V tutorial https://github.com/stevehoover/LF-Building-a-RISC-V-CPU-Core.git
			32'h0:	rom_data = 32'b0000_0001_0101_0000_0000_0000_1001_0011;		// (I) ADDI x1, x0, 10101
			32'h4:	rom_data = 32'b0000_0000_0111_0000_0000_0000_0001_0011;		// (I) ADDI x2, x0, 111
			32'h8:	rom_data = 32'b1111_1111_1100_0000_0000_0001_1001_0011;		// (I) ADDI x3, x0, 111111111100
			32'hc:	rom_data = 32'b0000_0101_1100_0000_1111_0010_1001_0011;		// (I) ANDI x5, x1, 1011100
			32'h10:	rom_data = 32'b0000_0001_0101_0010_1100_0010_1001_0011;		// (I) XORI x6, x6, 10101
			32'h14:	rom_data = 32'b0000_0000_0010_0000_1111_1010_0011_0011;		// Cycle 13 (R) AND r10, x1, x2
			32'h18:	rom_data = 32'b0000_0000_0000_0000_0000_1001_1011_0111;		// Cycle 31 (U) LUI x19, 0
			32'h1c:	rom_data = 32'b0000_0000_0100_0000_0000_1100_1110_1111;		// Cycle 44 (J) JAL x25, 10
			32'h20:	rom_data = 32'b0000_0000_0001_0001_0010_0000_1010_0011;		// Cycle 51 (S) SW x2, x1, 1
		endcase
endmodule


// extract information from instruction
module instruction_decode(
	input wire clk,
	input [31:0]instr,
	output reg is_r_instr, is_i_instr, is_s_instr, is_b_instr, is_u_instr, is_j_instr
	);

	initial begin
		is_r_instr <= 0;
		is_i_instr <= 0;
		is_s_instr <= 0;
		is_b_instr <= 0;
		is_u_instr <= 0;
		is_j_instr <= 0;
	end

	always @(posedge clk) begin	// RISC-V spec v2.2 p. 104
		is_r_instr <= instr[6:2] == 5'b01011 || instr[6:2] == 5'b01100 || instr[6:2] == 5'b01110 || instr[6:2] == 5'b10100;
		is_i_instr <= instr[6:2] == 5'b00000 || instr[6:2] == 5'b00001 || instr[6:2] == 5'b00100 || instr[6:2] == 5'b00110 || instr[6:2] == 5'b11001;
		is_s_instr <= instr[6:2] == 5'b01000 || instr[6:2] == 5'b01001;
		is_b_instr <= instr[6:2] == 5'b11000;
		is_u_instr <= instr[6:2] == 5'b00101 || instr[6:2] == 5'b01101;
		is_j_instr <= instr[6:2] == 5'b11011;
	end
endmodule
