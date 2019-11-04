// Constants for the nsel possible values
`define RN 3'b100
`define RD 3'b010
`define RM 3'b001

module cpu(clk,
           reset,
           in,
           out,
           N,
           V,
           Z,
           w,
           mem_cmd,
           mem_addr, 
           mdata);
  input clk, reset;
  input [15:0] in, mdata;
  output [15:0] out;
  output [8:0] mem_addr;
  output[1:0] mem_cmd;
  output N, V, Z, w;
  
  // instruction decoder stuff
  wire [15:0] instruction,sximm5, sximm8;
  wire [2:0] nsel,  opcode, readnum, writenum;
  wire [1:0] ALUop, op, shift;
  
  wire [2:0] cond;
  assign cond = instruction[10:8];
  
  // datapath wires
  wire [3:0] vsel;
  wire [15:0] mdata;
  wire [8:0] PC, next_PC, dataAdressOut;
  wire write, loada, loadb, loadc, loads, asel, bsel, loadir, loadpc, reset_pc, addr_sel, load_addr;
  
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
  regLoad #(16) instructionRegister(clk, loadir, in, instruction);
  
  //Program Counter Reg
  regLoad #(9) PCCounter(clk, loadpc, next_PC, PC);

  //Data Adress Reg
  regLoad #(9) DataAdress(clk, load_addr, out[8:0], dataAdressOut);

  Mux4b (9'b0, (PC + 1'b1), (PC + 1'b1 + sximm8), (readnum), reset_pc, next_pc);

  assign mem_addr = addr_sel ? PC : dataAdressOut; //mem_adder will be dataaddress if adder_sel is 1'b1 otherwise it's just the PC counter

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
                     .reset(reset),
                     .w(w),
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
                     .loadir(loadir),
                     .loadpc(loadpc),
                     .reset_pc(reset_pc),
                     .addr_sel(addr_sel),
                     .mem_cmd(mem_cmd),
                    .load_addr(load_addr),
                     .N(N),
                     .V(V),
                     .Z(Z),
                     .cond(cond));

  
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
    assign ALUop    = instruction[12:11];
    // The shift is set directly by bits 4 and 3 of the instruction, if doing a LDR or STR we should override with 2'b00 so immx5 isn't shifted
    assign shift    = (opcode === 3'b100) ? op : instruction[4:3];
    // sximm5 is the 16 bit sign extended version of the first 5 bits of instruction
    assign sximm5   = {{11{instruction[4]}}, instruction[4:0]};
    // sximm8 is the 16 bit sign extended version of the first 8 bits of instruction
    assign sximm8   = {{8{instruction[7]}}, instruction[7:0]};
    // The opcode is the category of operation
    assign opcode   = instruction[15:13];
    // The op determines the operation within the category given by opcode
    assign op       = instruction[12:11];
    
    
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

    // multiplexer 4 inputs, binary, variable width input/output
		module Mux4b(r0, r1, r2, r3, sel, out);
      parameter n = 1;
  		input [n-1:0] r0, r1, r2, r3;
      input [1:0] sel;
      output [n-1:0] out;
      reg [n-1:0] out;
      
      // using basis from SS6 slide 21, always block for output of mux based on one-hot sel
      always @(*) begin
        case(sel) // case statement is based on the one-hot select signal
          2'b00: out  = r0;
          2'b01: out  = r1;
          2'b10: out  = r2;
          2'b11: out  = r3;
          default: out = {n{1'bx}}; // default is a output of all "don't cares" for debugging purposes
        endcase
      end
    endmodule




