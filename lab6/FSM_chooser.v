//define the states for finite state  machine
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
  reg [2:0] next_state ;

  wire [2:0] chosenOne; //chosen state from multiplexer
  wire wANDs = w & s; //used to determine if we are in WAIT state, need to leave WAIT state, or need to go to WAIT
  
  //Multiplexer chooses a state, depending on the {opcode,op} input
  MuxChooser choose(`MVN, `AND, `CMP, `ADD, `MOVRd, `MOVRn, {opcode, op}, chosenOne);

  //reg the chosen state
  assign chosenOne = next_state;

  always @(posedge clk) begin 
    //on the rising edge of the clock, if we are in state WAIT, w&s != 0 or it is NOT reseting, we go to the next state
    if (next_state !== `WAIT | wANDs !== 0 | reset === 0) begin
      casex ({next_state, step}) //evaluates the cases based on the current state and state step
        {`MOVRn, 3'bx}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, next_state, step} = {12'b0_0_0_0_0_10_1_00_0_0, `WAIT, 3'd0};
        
        {`MOVRd, 3'd0}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, next_state, step} = {12'b0_1_1_1_0_10_0_10_0_0, `MOVRd, 3'd1};
        {`MOVRd, 3'd1}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, next_state, step} = {12'b0_0_0_0_0_00_1_01_0_0, `WAIT, 3'd0};
        
        {`ADD, 3'd0}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, next_state, step} = {12'b1_0_0_0_0_10_0_00_0_0, `ADD, 3'd1};
        {`ADD, 3'd1}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, next_state, step} = {12'b0_1_0_0_0_10_0_10_0_0, `ADD, 3'd2};
        {`ADD, 3'd2}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, next_state, step} = {12'b0_0_1_0_0_10_0_10_0_0, `ADD, 3'd3};
        {`ADD, 3'd3}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, next_state, step} = {12'b0_0_0_0_0_00_1_01_0_0, `WAIT, 3'd0};
        
        {`CMP, 3'd0}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, next_state, step} = {12'b1_0_0_0_0_10_0_00_0_0, `CMP, 3'd1};
        {`CMP, 3'd1}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, next_state, step} = {12'b0_1_0_0_0_10_0_10_0_0, `CMP, 3'd2};
        {`CMP, 3'd2}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, next_state, step} = {12'b0_0_1_0_0_10_0_10_0_1, `WAIT, 3'd0};
        
        {`AND, 3'd0}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, next_state, step} = {12'b1_0_0_0_0_10_0_00_0_0, `AND, 3'd1};
        {`AND, 3'd1}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, next_state, step} = {12'b0_1_0_0_0_10_0_10_0_0, `AND, 3'd2};
        {`AND, 3'd2}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, next_state, step} = {12'b0_0_1_0_0_10_0_10_0_0, `AND, 3'd3};
        {`AND, 3'd3}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, next_state, step} = {12'b0_0_0_0_0_00_1_01_0_0, `WAIT, 3'd0};
        
        {`MVN, 3'd0}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, next_state, step} = {12'b0_1_1_1_0_10_0_10_0_0, `MVN, 3'd1};
        {`MVN, 3'd1}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, next_state, step} = {12'b0_0_0_0_0_00_1_01_0_0, `WAIT, 3'd0};
          
        default:{loada, loadb, loadc, asel, bsel, vsel, write, nsel, w, loads, next_state, step} = {18'bx};
      endcase 
    end
    //else case: current state is WAIT	
    else begin
      loada = 1'b0;
      loadb = 1'b0;
      loadc = 1'b0;
      asel = 1'b0;
      bsel = 1'b0;
      vsel = 2'b10;
      write = 1'b0;
      nsel  = 2'b00;
      step = 3'd0;
      loads = 1'b0;
      w = 1;
    end
  end           
endmodule 

//multiplexer to choose state: chosenOne
module MuxChooser(a5, a4, a3, a2, a1, a0, muxC_in, muxC_out) ;
  parameter k = 3;
  parameter m = 5;
  input [k-1:0] a5, a4, a3, a2, a1, a0;  // inputs states to pick from
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
      default: muxC_out = {k{1'bx}} ;
    endcase
  end 
endmodule 