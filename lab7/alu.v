`define ALUADD 2'b00
`define ALUSUB 2'b01
`define ALUNOT 2'b11
`define ALUAND 2'b10

//four operation ALU, can add, subtract, and, and not values 
//depending on ALUop select
module ALU(Ain,Bin,ALUop,out,Z, V, N);
  input [15:0] Ain, Bin;
  input [1:0] ALUop;
  output [15:0] out;
  output Z, V, N;

  wire [15:0] asOut;
  // fill out the rest

  // Instantiation of AddSub module
  AddSub #(16) adderSubber(Ain, Bin, ALUop[0], asOut, V);

  reg [15:0] out;
  always @(*)
    casex(ALUop)
      // 00 and 01 - Addition or Subtraction
      2'b0x: out = asOut;
      // 10 - ANDing
      `ALUAND: out = Ain & Bin;
      // 11 - NOTing b
      `ALUNOT: out = ~Bin;
      default: out = {15{1'bx}};
    endcase

  //if out is all zeros |out = 0, z is 1 when |out = 0 so we ~(|out) to get z = 1 when out = 16'b0
  assign Z = ~(|out);

  // If out is negative, set N to 1, because using 2's complement we can use out[15]
  assign N = out[15];

endmodule

// multi-bit adder - behavioral -- Slide Set 6, Tor Aamodt
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

// add a+b or subtract a-b, check for overflow -- Slide Set 6, Tor Aamodt
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