
module datapath (clk,
                 readnum,
                 vsel,
                 loada,
                 loadb,
                 shift,
                 asel,
                 bsel,
                 ALUop,
                 loadc,
                 loads,
                 writenum,
                 write,
                 datapath_in,
                 sximm5,
                 mdata,
                 PC,
                 Z_out,
                 V_out,
                 N_out,
                 datapath_out);
  
  input clk, write, loada, loadb, loadc, loads, asel, bsel;
  input[3:0] vsel;
  input[15:0] datapath_in, mdata, sximm5;
  input[7:0] PC;
  input[2:0] readnum, writenum;
  input[1:0] shift, ALUop;
  output Z_out, V_out, N_out;
  output [15:0] datapath_out;
  

  wire [15:0] data_in;
  wire [15:0] data_out, aout, in, Ain, Bin, out, sout;
  wire Z, V, N;
  

  //the REGFILE is connected to data_in, writenum, write, readnum, and clk as inputs
  //the output of the regfile is stored in data_out
  regfile REGFILE(data_in,
  writenum,
  write,
  readnum,
  clk,
  data_out);
  
  //load enabled register (16 bit) to hold output of register file, knowing this value cannot be shifted
  regLoad #(16) A(clk, loada, data_out, aout);
  //load enabled register (16 bit) to hold output of register file, 
  //the output of this register can be connected to the shifter
  regLoad #(16) B(clk, loadb, data_out, in);
  //load enabled register to hold output of the ALU
  regLoad #(16) C(clk, loadc, out, datapath_out);
  //load enabled register Z, N and V flags (zero, negative, overflow)
  regLoad #(3) STATUS(clk, loads, {Z,V,N}, {Z_out, V_out, N_out});
  
  //The ALU is connected to the outputs of two multiplexers (Ain and Bin) represeted by conditional statments below
  //its main output is connected to signal out and Z is a 1 if the output of the ALU is zero
  //ALUop decides what operation is to be preformed
  ALU  U2(Ain, Bin, ALUop, out, Z, V, N);
  
  //The shifter is connected to the output value from the B register
  //Its output is connected to the signal sout, shift decides what operation is to be preformed
  shifter U1(in, shift, sout);
  
  //4 input multiplexer for deciding data into register file
  Mux4 #(16) dataIn(datapath_out, datapath_in, mdata, {8'b0, PC} , vsel, data_in);

  //2 input multiplexer to decide the Ain input to the ALU based on asel
  assign Ain = asel ? 16'b0 : aout;
  //2 input multiplexer to decide the Bin input to the ALU based on bsel
  assign Bin = bsel ? sximm5 : sout;
  
  
endmodule

// multiplexer 4 inputs, one-hot select, variable width input/output
module Mux4(r0, r1, r2, r3, sel, out);
  parameter n = 1;
  input [n-1:0] r0, r1, r2, r3;
  input [3:0] sel;
  output [n-1:0] out;
  reg [n-1:0] out;

// using basis from SS6 slide 21, always block for output of mux based on one-hot sel
  always @(*) begin
    case(sel) //case statement is based on the one-hot select signal
      4'b0001: out = r0;
      4'b0010: out = r1;
      4'b0100: out = r2;
      4'b1000: out = r3;
      default: out     = {n{1'bx}}; //default is a output of all "don't cares" for debugging purposes
    endcase
  end
endmodule