/*Instantiate each of the three units (Register file  , ALU  and Shifter )  Next, add in the remaining logic blocks

Register A, B, and C will each require an instantiated flip-flop module and an assign
statement for the enable input in order to conform to the style guidelines. 

MULTIPLEXERS: 
vsel, asel, bsel
FLIP FLOPS: 
A, B,C  SELECT

*/

module datapath ( clk, readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, loadc, loads, writenum, write, datapath_in, Z_out, datapath_out); // recall from Lab 4 that KEY0 is 1 when NOT pushed)	
	input  vsel ;
	input  loada;
	input  loadb;
	input  asel ;
	input  bsel ;
	input  loadc;
	input  loads;
  
	input  clk;
	input  write;
	input  [15:0] datapath_in;
	input  [2:0] readnum;
	input  [2:0] writenum;
	wire  [15:0] data_out;
	wire  [15:0] data_in;

	wire  [15:0] Ain;
	wire  [15:0] Bin; 
	input  [1:0] ALUop; 
	wire  [15:0] out; 
	output  Z_out;
	wire  Z;

	wire  [15:0] in;
	input  [1:0] shift;
	wire [15:0] sout;
  
	output  [15:0] datapath_out;
  
  //for between A and asel
	wire  [15:0] amidout;


///instantiating the modules to test
  Muxb2 vselM(datapath_in, datapath_out, vsel, data_in);
  regfile U0(.data_in(data_in), .writenum(writenum), .write(write), .readnum(readnum), .clk(clk), .data_out(data_out));
  
  vDFFEf vA(clk, loada, data_out, amidout);
  Muxb2 aselM(16'b0, amidout, asel, Ain);
  
  vDFFEf vB(clk, loadb, data_out, in);
  shifter U1(.in(in), .shift(shift), .sout(sout));
  Muxb2 bselM({11'b0, datapath_in[4:0]}, sout, bsel, Bin);
  
  ALU U2(.Ain(Ain), .Bin(Bin), .ALUop(ALUop), .out(out), .Z(Z));
  vDFFEf vC(clk, loadc, out, datapath_out);
  vDFFEf #(1) vZ(clk, loads, Z, Z_out);

endmodule

 // MULTIPLEXER // 
//send multiplexer singals to onehot code
module Muxb2(a1, a0, mux_in, mux_out) ;
  
  parameter k = 16 ;
  input [k-1:0] a0, a1;  // inputs
  input  mux_in ;          // binary select
  output[k-1:0] mux_out ;
  reg [k-1:0] mux_out;
  
  always @(*) begin
    case(mux_in) 
  	1'b0: mux_out = a0 ;
      	1'b1: mux_out = a1 ;
    	default: mux_out = {k{1'bx}} ;
	endcase
  end

endmodule
  
// Instantiated flip-flop module //
module vDFFEf(clk, en, in, out) ;
  parameter n = 16;  // width
  input clk, en ;
  input  [n-1:0] in ;
  output [n-1:0] out ;
  reg    [n-1:0] out ;
  wire   [n-1:0] next_out ;

  assign next_out = en ? in : out;

  always @(posedge clk) begin
    out = next_out;  
	end

endmodule
    