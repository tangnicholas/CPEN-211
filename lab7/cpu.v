// Constants for the nsel possible values
`define RN 3'b100
`define RD 3'b010
`define RM 3'b001

module cpu(clk,
           reset,
           s,
           load,
           in,
           out,
           N,
           V,
           Z,
           w);
  input clk, reset, s;
  input [15:0] in;
  output [15:0] out;
  output N, V, Z, w;
  // Do not change above this line.
  
  // instruction decoder stuff
  wire [15:0] instruction,sximm5, sximm8;
  wire [2:0] nsel,  opcode, readnum, writenum;
  wire [1:0] ALUop, op, shift;
  
  // datapath wires
  wire [3:0] vsel;
  wire [15:0] mdata;
  wire [7:0] PC;
  wire write, loada, loadb, loadc, loads, asel, bsel;
  
  //Lab7 FSM new stuff
  output [8:0] mem_addr;
  output [1:0] mem_cmd;
  output [15:0] read_data;
  wire load_pc, load_ir, reset_pc, addr_sel, m_cmd;
  
  //Program Counter regs
  reg [8:0] modulePC_count;
  
  //set to zero for lab6 only
  assign mdata = 16'b0;
  assign PC = 8'b0;
  
  // Datapath instantiation with dot notation
  datapath DP(
  .clk(clk),
  .readnum(readnum),
  .vsel(vsel),
  .loada(loada),
  .loadb(loadb),
  .shift(shift),
  .asel(asel),
  .bsel(bsel),
  .ALUop(ALUop),
  .loadc(loadc),
  .loads(loads),
  .writenum(writenum),
  .write(write),
  .datapath_in(sximm8),
  .sximm5(sximm5),
  .mdata(mdata),
  .PC(PC),
  .Z_out(Z),
  .V_out(V),
  .N_out(N),
  .datapath_out(out));
  
  // Instruction register without dot notation
  regLoad #(16) instructionRegister(clk, load_ir, read_data, instruction);
  
  // Instruction decoder instantiation with dot notation
  instructionDecoder instructionDecoded(
  .nsel(nsel),
  .instruction(instruction),
  .ALUop(ALUop),
  .sximm5(sximm5),
  .sximm8(sximm8),
  .readnum(readnum),
  .writenum(writenum),
  .opcode(opcode),
  .op(op),
  .shift(shift));

  // Instantiates the datapath controller FSM using dot notation
  InstructionSM FSM(.clk(clk),
                    .start(s), //May have to delete not sure
                     .reset(reset),
                    .w(w), 		//May also have to delete unsure
                     .nsel(nsel),
                     .loada(loada),
                     .loadb(loadb),
                     .loadc(loadc),
                     .loads(loads),
                     .vsel(vsel),
                     .write(write),
                     .opcode(opcode),
                     .op(op),
                     .asel(asel),
                    .bsel(bsel),
                    
                    .addr_sel(addr_sel),
                    .load_pc(load_pc),
                    .reset_pc(reset_pc),
                    .load_ir(load_ir),
                   );
  
  //Instantiates entire Program Counter, which includes the adding and the mux
  ProgramCounter pc(clk, reset_pc, modulePC_count);
  
  //takes output of Program Counter and 0's and mux them based on addr_sel
  assign mem_addr = addr_sel ? modulePC_count : 9'b0;
  
endmodule
  
  
  module instructionDecoder(nsel, instruction, ALUop, sximm5, sximm8, readnum, writenum, opcode, op, shift);
    input [15:0] instruction;
    input[2:0] nsel;
    output [1:0] ALUop, op, shift;
    output[2:0] opcode, readnum, writenum;
    output[15:0] sximm5, sximm8;
    
    // Determines readnum based on which register is selected by nsel: Rd, Rn, or Rm
    Mux3 #(3) regNum(instruction[2:0], instruction[7:5], instruction[10:8], nsel, readnum);
    // Since writenum is the same as readnum, we assign them together
    assign writenum = readnum;
    // The ALU operation is bits 12 and 11 no matter what category of operation we're in, so we feed it directly into the ALU
    assign ALUop   = instruction[12:11];
    // The shift is set directly by bits 4 and 3 of the instruction
    assign shift   = instruction[4:3];
    // sximm5 is the 16 bit sign extended version of the first 5 bits of instruction
    assign sximm5  = {{11{instruction[4]}}, instruction[4:0]};
    // sximm8 is the 16 bit sign extended version of the first 8 bits of instruction
    assign sximm8  = {{8{instruction[7]}}, instruction[7:0]};
    // The opcode is the category of operation
    assign opcode  = instruction[15:13];
    // The op determines the operation within the category given by opcode
    assign op = instruction[12:11];
    
    
  endmodule
    
    // multiplexer 3 inputs, one-hot select, variable width input/output
    module Mux3(r0, r1, r2, sel, out);
      parameter n = 1;
      input [n-1:0] r0, r1, r2;
      input [2:0] sel;
      output [n-1:0] out;
      reg [n-1:0] out;
      
      // using basis from SS6 slide 21, always block for output of mux based on one-hot sel
      always @(*) begin
        case(sel) // case statement is based on the one-hot select signal
          3'b001: out  = r0;
          3'b010: out  = r1;
          3'b100: out  = r2;
          default: out = {n{1'bx}}; // default is a output of all "don't cares" for debugging purposes
        endcase
      end
    endmodule


//PROGRAM COUNTER 
module ProgramCounter(clk, rst, count) ;
  parameter n=5 ;
  input rst, clk ; // reset and clock
  output [n-1:0] count ;

  wire   [n-1:0] next = rst ? 0 : count + 1 ;

  vDFFPC #(n) count(clk, load_pc, next, count) ;
endmodule

// FLIP FLOP MODULE FOR THE PC COUNTER 
module vDFFPC (clk, load_pc, next, count);
  parameter n = 1; // width
  input clk, load_pc; 
  input [8:0] next;
  output [8:0] clk;
  reg [8:0] count; 
  
  always @(posedge clk) begin
      if (load_pc === 1)
        count = next;
  end
endmodule
  
