module regfile(data_in,
               writenum,
               write,
               readnum,
               clk,
               data_out);
  input [15:0] data_in;
  input [2:0] writenum, readnum;
  input write, clk;
  output[15:0] data_out;
  // fill out the rest
  
  wire[7:0] writenumDecoded; //the writenum input but as a one-hot eight bit number
  wire[7:0] readnumDecoded; //the readenum input but as a one-hot eight bit number
  wire[7:0] load; //an 8 bit one hot signal for which register to write to
  wire[15:0] R0, R1, R2, R3, R4, R5, R6, R7; // the eight 16 bit register outputs
  
  //load is a one hot siganl for which register to write to
  //as write is a one bit signal we make 8 copies of it to AND with the one hot writenumDecoded
  assign load = {8{write}} & writenumDecoded;
  
  //decoder for the binary writenum into a one-hot writenumDecoded
  decoder WriteDec(writenum, writenumDecoded);

  //8 registers with load enable, each connected to the same clk and data_in signals for writing
  //each has a particular bit of the load signal to enable writing to that register as the 
  //load signal is one hot.
  //the modules are paramatrized to be 16 bit registers
  regLoad #(16) r0(clk, load[0], data_in, R0);
  regLoad #(16) r1(clk, load[1], data_in, R1);
  regLoad #(16) r2(clk, load[2], data_in, R2);
  regLoad #(16) r3(clk, load[3], data_in, R3);
  regLoad #(16) r4(clk, load[4], data_in, R4);
  regLoad #(16) r5(clk, load[5], data_in, R5);
  regLoad #(16) r6(clk, load[6], data_in, R6);
  regLoad #(16) r7(clk, load[7], data_in, R7);

  //decoder for the binary readnum into a one-hot readnumDecoded
  decoder ReadDec(readnum, readnumDecoded);

  //an 8 input multiplexer with each input being 16 bits for the output of the regfile
  //inputs are from the 8 registeres
  Mux8 #(16) outputMux(R0, R1, R2, R3, R4, R5, R6, R7, readnumDecoded, data_out);
  
  
endmodule
  
  // Nearly all of this decoder module is taken from Slide Set 6 (Tor Aamodt)
  module decoder(dec_in, bin_out);
    parameter iSize = 3;
    parameter oSize = 8;
    input [iSize-1:0] dec_in;
    output [oSize-1:0] bin_out;
    
    wire [oSize-1:0] bin_out = 1'b1 << dec_in;
  endmodule
    
// register with load enable from lab 5 introduction slides (Tor Aadmodt)
module regLoad(clk, load, in, out);
  parameter n = 1; // width
  input clk, load;
  input [n-1:0] in;
  output [n-1:0] out;
  reg [n-1:0] out;
  wire [n-1:0] next_out;

  // simple mux for only changing output if load is enabled
  assign next_out = load ? in : out;

  // only change output on posedge of clk
  always @(posedge clk)
    out = next_out;

endmodule

// multiplexer 8 inputs, one-hot select, variable width input/output
module Mux8(r0, r1, r2, r3, r4, r5, r6, r7, sel, out);
  parameter n = 1;
  input [n-1:0] r0, r1, r2, r3, r4, r5, r6, r7;
  input [7:0] sel;
  output [n-1:0] out;
  reg [n-1:0] out;

// using basis from SS6 slide 21, always block for output of mux based on one-hot sel
  always @(*) begin
    case(sel) //case statement is based on the one-hot select signal
      8'b00000001: out = r0;
      8'b00000010: out = r1;
      8'b00000100: out = r2;
      8'b00001000: out = r3;
      8'b00010000: out = r4;
      8'b00100000: out = r5;
      8'b01000000: out = r6;
      8'b10000000: out = r7;
      default: out     = {n{1'bx}}; //default is a output of all "don't cares" for debugging purposes
    endcase
  end
endmodule
