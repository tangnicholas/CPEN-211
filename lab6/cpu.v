module cpu(clk,reset,s,load,in,out,N,V,Z,w);
  input clk, reset, s, load;
  input [15:0] in;
  output [15:0] out;
  output N, V, Z, w;
  wire [15:0] inreg_out;
  

// INSTRUCTION REGISTER 
  //on the rising edge of the clock 
 	// if load is 1 --> copy value in to instruction register 
	// if load is 0 --> values 
 	
vDFFE #(16) inreg(clk,load,in,inreg_out);

//INSTRUCTION DECODER
//declaration of variables
  wire opcode = inreg_out[15:13];
  wire op = inreg_out [12:11];

  wire [1:0] nsel; //assumes this is binary 
  wire [2:0] Rm = inreg_out[2:0]; 
  wire [2:0] Rd = inreg_out[7:5];
  wire [2:0] Rn = inreg_out [10:8];
  wire imm8 = inreg_out[7:0];
  wire imm5 = inreg_out[4:0];
  
  //outputs from decoder to go to datapath (and modules that lead to output)
  wire [1:0] shift = inreg_out[4:3];
  wire [15:0] sximm5 = ~{11'b0, imm5} + 1; //sign extend
  wire [15:0] sximm8 = ~{8'b0, imm8} + 1;  //sign extend
  wire ALUop = inreg_out[12:11];
  
  Muxb3 #(3,2) numR(Rn, Rd, Rm, nsel, readnum);
  Muxb3 #(3,2) numW(Rn, Rd, Rm, nsel, writenum);
  
//FSM declaration
     
  
  
  
// on the rising edge of the clock 
	// if reset is 1 --> state machine goes to reset 
	// if s is 1 --> value on out is contents of register C
	
	// outputs N = negative, V overflow, Z zero status bits

	/* w should be set to 1 if your state machine is in the reset state and is waiting for s to be set to 1 */

	
endmodule 

//load enabled register 
module vDFFE(clk, en, din, dout);
	parameter n = 16;
	input clk, en;
	input [n-1:0] din;
	output [n-1:0] dout;
	reg [n-1:0] dout;
	wire [n-1:0] next_out;

	assign next_out = en ? din : dout;

	always @(posedge clk) begin
		dout = next_out;
	end

endmodule

//MUX FOR 3 bit select 3 in binary.
module Muxb3(a2, a1, a0, mux3_in, mux3_out) ;
  parameter k = 3;
  parameter m = 2;
  input [k-1:0] a0, a1, a2;  // inputs
  input  [m-1:0] mux3_in;          // binary select
  output reg [k-1:0] mux3_out;
  
  always @(*) begin
    case(mux3_in) 
      2'b00: mux3_out = a0;
      2'b01: mux3_out = a1;
      2'b10: mux3_out = a2;
      default: mux3_out = {k{1'bx}} ;
  endcase
end 
endmodule
  