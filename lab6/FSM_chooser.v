
//define the states for finite state machine
`define WAIT 3'b000 
`define MOVRn 3'b001
`define MOVRd 3'b010
`define ADD 3'b011
`define CMP 3'b100
`define AND 3'b101
`define MVN 3'b111

//FINITE STATE MACHINE 
module FSM_chooser(clk, s, reset, opcode, op, nsel, w, loada, loadb, loadc, loads, asel, bsel, write, vsel);
  //inputs and outputs
  input clk, s, reset;
  input [2:0] opcode;
  input [1:0] op;
  
  output [1:0] nsel, vsel;
  output w, loada, loadb, loadc, loads, asel, bsel, write;
  
  reg loada, loadb, loadc, loads, asel, bsel, write, w;
  reg [1:0] nsel, vsel; 
  reg [2:0] step;
  reg [2:0] next_state;

  reg custom; //custom=1 identifies the end of an instruction

  wire [2:0] chosenOne; //chosen state from multiplexer
  wire [2:0] chosenOne_reset;
  wire wANDs = w & s; //used to determine if we are in WAIT

  assign resetOrcustom = reset | custom;
 
  MuxChooser choose(`MVN, `AND, `CMP, `ADD, `MOVRd, `MOVRn, {opcode, op}, chosenOne); //chooses the next state
  assign chosenOne_reset = resetOrcustom? `WAIT: chosenOne;
  //vDFFE #(3) vSelFF(clk, 1'b1, resetOrcustom ? `WAIT : chosenOne, chosenOne_reset); //determines if the next state is WAIT 

  

  always @(posedge clk) begin
    next_state = chosenOne_reset;
    
    casex ({next_state, step, wANDs}) 
      {`MOVRn, 3'bx, 1'b1}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, custom, step} = {12'b0_0_0_0_0_10_1_00_0_0, 1'b1, 3'd0};
       
      {`MOVRd, 3'd0, 1'b1}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, custom, step} = {12'b0_1_1_1_0_10_0_10_0_0, 1'b0, 3'd1};
      {`MOVRd, 3'd1, 1'b0}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, custom, step} = {12'b0_0_0_0_0_00_1_01_0_0, 1'b1, 3'd0};
        
      {`ADD, 3'd0, 1'b1}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, custom, step} = {12'b1_0_0_0_0_10_0_00_0_0, 1'b0, 3'd1};
      {`ADD, 3'd1, 1'b0}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, custom, step} = {12'b0_1_0_0_0_10_0_10_0_0, 1'b0, 3'd2};
      {`ADD, 3'd2, 1'b0}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, custom, step} = {12'b0_0_1_0_0_10_0_10_0_0, 1'b0, 3'd3};
      {`ADD, 3'd3, 1'b0}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, custom, step} = {12'b0_0_0_0_0_00_1_01_0_0, 1'b1, 3'd0};
        
      {`CMP, 3'd0, 1'b1}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, custom, step} = {12'b1_0_0_0_0_10_0_00_0_0, 1'b0, 3'd1};
      {`CMP, 3'd1, 1'b0}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, custom, step} = {12'b0_1_0_0_0_10_0_10_0_0, 1'b0, 3'd2};
      {`CMP, 3'd2, 1'b0}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, custom, step} = {12'b0_0_1_0_0_10_0_10_0_1, 1'b1, 3'd0};
        
      {`AND, 3'd0, 1'b1}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, custom, step} = {12'b1_0_0_0_0_10_0_00_0_0, 1'b0, 3'd1};
      {`AND, 3'd1, 1'b0}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, custom, step} = {12'b0_1_0_0_0_10_0_10_0_0, 1'b0, 3'd2};
      {`AND, 3'd2, 1'b0}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, custom, step} = {12'b0_0_1_0_0_10_0_10_0_0, 1'b0, 3'd3};
      {`AND, 3'd3, 1'b0}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, custom, step} = {12'b0_0_0_0_0_00_1_01_0_0, 1'b1, 3'd0};
        
      {`MVN, 3'd0, 1'b1}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, custom, step} = {12'b0_1_1_1_0_10_0_10_0_0, 1'b0, 3'd1};
      {`MVN, 3'd1, 1'b0}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, custom, step} = {12'b0_0_0_0_0_00_1_01_0_0, 1'b1, 3'd0};

      {`WAIT, 3'bxxx, 1'b1}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, custom, step} = {12'b0_0_0_0_0_00_0_00_1_0, 1'b0, 3'd0};
          
      default:{loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, custom, step} = {12'b0_0_0_0_0_00_0_00_1_0, 1'b0, 3'd0};
    endcase 



  end           
endmodule 


module MuxChooser(a5, a4, a3, a2, a1, a0, muxC_in, muxC_out) ;
  parameter k = 3;
  parameter m = 5;
  input [k-1:0] a5, a4, a3, a2, a1, a0;  // inputs
  input  [m-1:0] muxC_in;          
  output [k-1:0] muxC_out;
  reg [k-1:0] muxC_out;

  always @(*) begin
    case(muxC_in)
      5'b110_10: muxC_out = a0;
      5'b110_00: muxC_out = a1;
      5'b101_00: muxC_out = a2;
      5'b101_01: muxC_out = a3;
      5'b101_10: muxC_out = a4;
      5'b101_11: muxC_out = a5;
      default: muxC_out = {k{1'bx}};
    endcase
  end 
endmodule
/*
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
*/