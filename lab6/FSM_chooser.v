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
  
  reg [2:0] next_state; 
  reg [2:0] step;
  

   
  //reg [10:0] chosenOutput = {loada, loadb, loadc, asel, bsel, vsel, write, nsel, m}; //1, 1, 1, 1, 1, 2, 1, 2, m
  wire wANDs = w & s;
  
  MuxChooser choose(`MVN, `AND, `CMP, `ADD, `MOVRd, `MOVRn, {opcode, op} , next_state);
  
  always @(posedge clk) begin 
    
    if (~((next_state === `WAIT & wANDs === 0) | reset === 1)) begin
      casex ({next_state, step}) 
        {`MOVRn, 3'bx}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, next_state, step} = {12'bx_x_x_x_x_10_1_00_0_x, `WAIT, 3'bxxx};
        
        {`MOVRd, 3'd0}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, next_state, step} = {12'bx_1_1_1_x_10_0_10_0_x, `MOVRd, 3'd1};
        {`MOVRd, 3'd1}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, next_state, step} = {12'bx_0_0_0_x_00_1_01_x_x, `WAIT, 3'bxxx};
        
        {`ADD, 3'd0}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, next_state, step} = {12'b1_x_x_0_x_10_0_00_0_x, `ADD, 3'd1};
        {`ADD, 3'd1}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, next_state, step} = {12'b0_1_x_x_0_10_x_10_x_x, `ADD, 3'd2};
        {`ADD, 3'd2}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, next_state, step} = {12'bx_0_1_x_x_10_x_xx_x_x, `ADD, 3'd3};
        {`ADD, 3'd3}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, next_state, step} = {12'bx_x_0_x_x_00_1_01_x_x, `WAIT, 3'bxxx};
        
        {`CMP, 3'd0}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, next_state, step} = {12'b1_x_x_0_x_10_0_00_0_x, `CMP, 3'd1};
        {`CMP, 3'd1}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, next_state, step} = {12'b0_1_x_x_0_10_x_10_x_x, `CMP, 3'd2};
        {`CMP, 3'd2}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, next_state, step} = {12'bx_0_1_x_x_xx_x_xx_x_1, `WAIT, 3'bxxx};
        
        {`AND, 3'd0}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, next_state, step} = {12'b1_x_x_0_x_10_0_00_0_x, `AND, 3'd1};
        {`AND, 3'd1}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, next_state, step} = {12'b0_1_x_x_0_10_x_10_x_x, `AND, 3'd2};
        {`AND, 3'd2}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, next_state, step} = {12'bx_0_1_x_x_10_x_xx_x_x, `AND, 3'd3};
        {`AND, 3'd3}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, next_state, step} = {12'bx_x_0_x_x_00_1_01_x_x, `WAIT, 3'bxxx};
        
        {`MVN, 3'd0}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, next_state, step} = {12'bx_1_1_1_x_10_0_10_0_x, `MVN, 3'd1};
        {`MVN, 3'd1}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, next_state, step} = {12'bx_0_0_0_x_00_1_01_x_x, `WAIT, 3'bxxx};
          
        default:{loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, next_state, step} = {18'bx};
      endcase 
    end
    else begin
    	loada = 0;
    	loadb = 0;
    	loadc = 0;
      asel = 0;
      bsel = 0;
      vsel = 2;
      write = 0;
    	nsel  = 0;
      next_state = `WAIT;
      step = 0;
      loads = 0;
      w = 1;
    end
  end           
endmodule 


module MuxChooser(a5, a4, a3, a2, a1, a0, muxC_in, muxC_out) ;
  parameter k = 3;
  parameter m = 5;
  input [k-1:0] a5, a4, a3, a2, a1, a0;  // inputs
  input  [m-1:0] muxC_in;          // binary select
  output reg [k-1:0] muxC_out;
  
  always @(*) begin
    case(muxC_in) 
      5'b110_10: muxC_out = a0;
      5'b110_00: muxC_out = a1;
      5'b101_00: muxC_out = a2;
      5'b101_01: muxC_out = a3;
      5'b101_10: muxC_out = a4;
      5'b101_11: muxC_out = a5;
      default: muxC_out = {k{1'bx}} ;
 		endcase
	end 
endmodule
