/*Instantiate each of the three units (Register file  , ALU  and Shifter )  Next, add in the remaining logic blocks

Register A, B, and C will each require an instantiated flip-flop module and an assign
statement for the enable input in order to conform to the style guidelines. 

MULTIPLEXERS: 
vsel, asel, bsel
FLIP FLOPS: 
A, B,C  SELECT

*/

module datapath ( clk, readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, loadc, loads, writenum, write, mdata, sximm8, PC, Z, V, N, C, sximm5); // recall from Lab 4 that KEY0 is 1 when NOT pushed) 
  input  [1:0] vsel ;
  input  loada;
  input  loadb;
  input  asel ;
  input  bsel ;
  input  loadc;
  input  loads;
  
  input  clk;
  input  write;
  input  [15:0] mdata, sximm8;
  input  [7:0] PC;
  input  [2:0] readnum;
  input  [2:0] writenum;
  input  [15:0] sximm5;
  wire  [15:0] data_out;
  wire  [15:0] data_in;

  wire  [15:0] Ain;
  wire  [15:0] Bin; 
  input  [1:0] ALUop; 
  wire  [15:0] out; 
  output  Z;
  wire Z_in;
  output V;
  output N;

  wire  [15:0] in;
  input  [1:0] shift;
  wire [15:0] sout;
  
  output wire [15:0] C;
  
  //for between A and asel
  wire  [15:0] amidout;

  //for checking overflow variable
  reg AddSubop;
  wire [15:0] s;
  
  assign PC = 8'b0;
  assign mdata = 16'b0;

///instantiating the modules to test

  Muxb4 vselM(mdata, sximm8, {8'b0, PC}, C, vsel, data_in);
  regfile REGFILE(.data_in(data_in), .writenum(writenum), .write(write), .readnum(readnum), .clk(clk), .data_out(data_out));
  
  vDFFEf vA(clk, loada, data_out, amidout);
  Muxb2 aselM(16'b0, amidout, asel, Ain);
  
  vDFFEf vB(clk, loadb, data_out, in);
  shifter U1(.in(in), .shift(shift), .sout(sout));
  Muxb2 bselM(sximm5, sout, bsel, Bin);
  
  ALU U2(.Ain(Ain), .Bin(Bin), .ALUop(ALUop), .out(out), .Z_in(Z_in));
  vDFFEf vC(clk, loadc, out, C);

  AddSub #(16) checkOverflow(Ain, Bin, 1'b1, s, ovf) ;
  vDFFEf #(3) vStatus(clk, loads, {Z_in, out[15], ovf}, {Z, N, V});


  always @(ALUop, AddSubop) begin
    case (ALUop)
      2'b00: AddSubop = 0;
      2'b01: AddSubop = 1;
      default: AddSubop = 1'bx;
    endcase
  end

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

//MUX FOR 16 bit select 4 in binary.
module Muxb4(a3, a2, a1, a0, mux4_in, mux4_out) ;
  parameter k = 16 ;
  parameter m = 2;
  input [k-1:0] a0, a1, a2, a3;  // inputs
  input  [m-1:0] mux4_in ;          // binary select
  output reg [k-1:0] mux4_out ;
  
  always @(*) begin
    case(mux4_in) 
      2'b00: mux4_out = a0;
      2'b01: mux4_out = a1;
      2'b10: mux4_out = a2;
      2'b11: mux4_out = a3;
      default: mux4_out = {k{1'bx}} ;
  endcase
  end

endmodule
  
// multi-bit adder - behavioral (Taken from Slide Set 6)
module Adder1(a,b,cin,cout,s) ;
  parameter n = 8 ;
  input [n-1:0] a, b ;
  input cin ;
  output [n-1:0] s ;
  output cout ;
  wire [n-1:0] s;
  wire cout ;

  assign {cout, s} = a + b + cin ;
endmodule 

// add a+b or subtract a-b, check for overflow (Also taken from Slide set 6, used to check overlflow of the ALU inputs)
module AddSub(a,b,sub,s,ovf) ;
  parameter n = 8 ;
  input [n-1:0] a, b ;
  input sub ;           // subtract if sub=1, otherwise add
  output [n-1:0] s ;
  output ovf ;          // 1 if overflow
  wire c1, c2 ;         // carry out of last two bits
  wire ovf = c1 ^ c2 ;  // overflow if signs don't match

  // add non sign bits
  Adder1 #(n-1) ai(a[n-2:0],b[n-2:0]^{n-1{sub}},sub,c1,s[n-2:0]) ;
  // add sign bits
  Adder1 #(1)   as(a[n-1],b[n-1]^sub,c1,c2,s[n-1]) ;
endmodule