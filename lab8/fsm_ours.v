
//define the states for finite state machine
`define RESET 4'd0 
`define MOVRn 4'd1
`define MOVRd 4'd2
`define ADD 4'd3
`define CMP 4'd4
`define AND 4'd5
`define MVN 4'd6
 //state defintions for lab 7
`define BEGIN 4'd7
`define LDR 4'd8
`define STR 4'd9
`define HLT 4'd10
 //state defintions for lab 8
`define B 4'd11
`define BEQ 4'd12
`define BNE 4'd13
`define BLT 4'd14
`define BLE 4'd15

//define Mread, Mwrite, MNull for Lab 7
`define MNL 2'd0
`define MRD 2'd1
`define MWL 2'd2

//FINITE STATE MACHINE 
module FSM_chooser(clk, reset, opcode, op, //inputs 
                   nsel, loada, loadb, loadc, loads, asel, bsel, write, vsel, //lab 6 out
                   reset_pc, load_pc, addr_sel, load_ir, m_cmd, load_addr);  //lab 7 out
  //inputs and outputs
  input clk, reset;
  input [2:0] opcode;
  input [1:0] op;
  
  output reg [1:0] m_cmd, reset_pc;
  output reg [2:0] nsel;
  output reg [3:0] vsel;
  output reg loada, loadb, loadc, loads, asel, bsel, write;
  output reg load_pc, addr_sel, load_ir, load_addr;

  //Variables in FSM
  reg [3:0] step;
  reg [3:0] next_state;
  reg done; //done = 1 identifies the end of an instruction

  wire [3:0] chosenOne; //chosen state from multiplexer
  wire [3:0] chosenOne_reset_done;
 
  MuxChooser choose(`HLT, `STR, `LDR, `MVN, `AND, `CMP, `ADD, `MOVRd, `MOVRn, `B, `BEQ, `BNE, `BLT, `BLE,  {opcode, op}, chosenOne); //chooses the next state
  assign chosenOne_reset_done = reset ? `RESET: (done ? `BEGIN : chosenOne);
  

  always @(posedge clk) begin
    next_state = chosenOne_reset_done;
    
    casex ({next_state, step}) 
      //MOVRn INSTRUCTION
      {`MOVRn, 4'd0}: {vsel, write, nsel, step, done} = {8'b0010_1_100, 4'd0, 1'b1};
       
      //MOVRn INSTRUCTION
      {`MOVRd, 4'd0}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, step}       = {13'b1_0_0_1_0_0010_0_xxx, 4'd1}; //Load 0s to A (asel = 1)
      {`MOVRd, 4'd1}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, step}       = {13'b0_1_0_0_0_0010_0_001, 4'd2}; //Load Rm to B
      {`MOVRd, 4'd2}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, step}       = {13'b0_0_1_0_0_0010_0_001, 4'd3}; //Load sum to C
      {`MOVRd, 4'd3}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, step, done} = {13'b0_0_0_0_0_0001_1_010, 4'd0, 1'b1}; //Store data_out in Rd
      
      //ADD INSTRUCTION
      {`ADD, 4'd0}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, step}       = {13'b1_0_0_0_0_0010_0_100, 4'd1}; //Load Rn to A
      {`ADD, 4'd1}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, step}       = {13'b0_1_0_0_0_0010_0_001, 4'd2}; //Load Rm to B
      {`ADD, 4'd2}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, step}       = {13'b0_0_1_0_0_0010_0_001, 4'd3}; //Load sum to C
      {`ADD, 4'd3}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, step, done} = {13'b0_0_0_0_0_0001_1_010, 4'd0, 1'b1}; //Store data_out in Rd
       
      //CMP INSTRUCTION
      {`CMP, 4'd0}: {loada, loadb, loadc, asel, bsel, vsel, nsel, loads, step}       = {13'b1_0_0_0_0010_0_100_0, 4'd1};
      {`CMP, 4'd1}: {loada, loadb, loadc, asel, bsel, vsel, nsel, loads, step}       = {13'b0_1_0_0_0010_0_001_0, 4'd2};
      {`CMP, 4'd2}: {loada, loadb, loadc, asel, bsel, vsel, nsel, loads, step, done} = {13'b0_0_1_0_0010_0_001_1, 4'd0, 1'b1};
       
      //AND INSTRUCTION
      {`AND, 4'd0}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, step}       = {13'b1_0_0_0_0_0010_0_100, 4'd1}; //exact same as ADD
      {`AND, 4'd1}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, step}       = {13'b0_1_0_0_0_0010_0_001, 4'd2};
      {`AND, 4'd2}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, step}       = {13'b0_0_1_0_0_0010_0_001, 4'd3};
      {`AND, 4'd3}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, step, done} = {13'b0_0_0_0_0_0001_1_010, 4'd0, 1'b1};
       
      //MVN INSTRUCTION
      {`MVN, 4'd1}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, step}       = {13'b0_1_0_0_0_0010_0_001, 4'd2}; //Load Rm to B
      {`MVN, 4'd2}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, step}       = {13'b0_0_1_0_0_0010_0_001, 4'd3}; //Load sum to C
      {`MVN, 4'd3}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, step, done} = {13'b0_0_0_0_0_0001_1_010, 4'd0, 1'b1}; //Store data_out in Rd

      //LDR INSTRUCTION
      {`LDR, 4'd0}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, step} = {13'b1_0_0_0_0_0010_0_100, 4'd1}; //Load Rn to A
      {`LDR, 4'd1}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, step} = {13'b0_1_0_0_1_0010_0_xxx, 4'd2}; //Load sximm5 to B
      {`LDR, 4'd2}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, step} = {13'b0_0_1_0_1_0010_0_xxx, 4'd3}; //Load sum to C
      {`LDR, 4'd3}: {addr_sel, load_addr, m_cmd, step} = {2'b0_1, `MRD, 4'd4};                                  //parse addr to memory
      {`LDR, 4'd4}: {addr_sel, load_addr, m_cmd, vsel, step} = {2'b0_1, `MRD, 2'b11, 4'd5};                     //burner to wait for output
      {`LDR, 4'd5}: {vsel, write, nsel, step, done} = {8'b0100_1_010, 4'd0, 1'b1};                                 //write to Rd

      //STR INSTRUCTION 
      {`STR, 4'd0}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, step} = {13'b1_0_0_0_0_0010_0_100, 4'd1}; //Load Rn to A
      {`STR, 4'd1}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, step} = {13'b0_1_0_0_1_0010_0_xxx, 4'd2}; //Load sximm5 to B
      {`STR, 4'd2}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, step} = {13'b0_0_1_0_1_0010_0_xxx, 4'd3}; //Load sum to C
      {`STR, 4'd3}: {addr_sel, load_addr, m_cmd, step} = {2'b0_1, `MWL, 4'd4};                                  //parse addr to memory
      {`STR, 4'd4}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, step} = {13'b1_0_0_1_0_0010_0_xxx, 4'd5}; //Load 0s to A (asel = 1)
      {`STR, 4'd5}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, step} = {13'b0_1_0_1_0_0010_0_010, 4'd6}; //Load Rd to B
      {`STR, 4'd6}: {loada, loadb, loadc, asel, bsel, vsel, write, nsel, step} = {13'b0_0_1_1_0_0010_0_xxx, 4'd7}; //Load sum to C
      {`STR, 4'd7}: {addr_sel, load_addr, m_cmd, vsel, step, done} = {2'b0_1, `MWL, 4'b0100, 4'd0, 1'b1};         //burner to wait for output
     
      //HALT INSTRUCTION
      {`HLT, 4'd0}: step = 4'b0; 
      
      //B INSTRUCTION  branches unconditionally to the label provided 
      {`B, 4'd0}: {reset_pc, load_pc, addr_sel, step} = {2'b10,1'b0,1'b0,4'd1};
      {`B, 4'd1}: {reset_pc, load_pc, addr_sel, step} = {2'b10,1'b1,1'b0,4'd2};
      {`B, 4'd2}: {reset_pc, load_pc, addr_sel, step, done} = {2'b10,1'b0,1'b1,4'd0, 1'b1};
      
      //BEQ INSTRUCTION branches to appropriate label IF source operands are equal (if Z = 1)
      {`BEQ, 4'd0}: 
        if (Z === 1) begin  // same instructions as B
          case(step)
          4'd0: {reset_pc, load_pc, addr_sel, step} = {2'b10,1'b0,1'b0,4'd1};
          4'd1: {reset_pc, load_pc, addr_sel, step} = {2'b10,1'b1,1'b0,4'd2};
          4'd2: {reset_pc, load_pc, addr_sel, step, done} = {2'b10,1'b0,1'b1,4'd0, 1'b1};
          endcase 
        end 
        else begin 
          case(step) //increment pc
          4'd0: {reset_pc, load_pc, addr_sel, step} = {2'b00,1'b0,1'b0,4'd1};
          4'd1: {reset_pc, load_pc, addr_sel, step} = {2'b00,1'b1,1'b0,4'd2};
          4'd2: {reset_pc, load_pc, addr_sel, step, done} = {2'b00,1'b0,1'b1,4'd0, 1'b1};
          endcase 
        end 
        
      //BNE INSTRUCTION branches to appropriate label IF source operands are NOT equal (if Z = 0)
      {`BNE, 4'd0}: 
        if (Z === 0) begin  // same instructions as B
          case(step)
          4'd0: {reset_pc, load_pc, addr_sel, step} = {2'b10,1'b0,1'b0,4'd1};
          4'd1: {reset_pc, load_pc, addr_sel, step} = {2'b10,1'b1,1'b0,4'd2};
          4'd2: {reset_pc, load_pc, addr_sel, step, done} = {2'b10,1'b0,1'b1,4'd0, 1'b1};
          endcase 
        end 
        else begin 
          case(step) //increment pc
          4'd0: {reset_pc, load_pc, addr_sel, step} = {2'b00,1'b0,1'b0,4'd1};
          4'd1: {reset_pc, load_pc, addr_sel, step} = {2'b00,1'b1,1'b0,4'd2};
          4'd2: {reset_pc, load_pc, addr_sel, step, done} = {2'b00,1'b0,1'b1,4'd0, 1'b1};
          endcase 
        end 
      
      //BLT INTRUCTION branches if first operand is less than the second (N != V)
      {`BLT, 4'd0}: 
        if (N !== V) begin  // same instructions as B
          case(step)
          4'd0: {reset_pc, load_pc, addr_sel, step} = {2'b10,1'b0,1'b0,4'd1};
          4'd1: {reset_pc, load_pc, addr_sel, step} = {2'b10,1'b1,1'b0,4'd2};
          4'd2: {reset_pc, load_pc, addr_sel, step, done} = {2'b10,1'b0,1'b1,4'd0, 1'b1};
          endcase 
        end 
        else begin 
          case(step) //increment pc
          4'd0: {reset_pc, load_pc, addr_sel, step} = {2'b00,1'b0,1'b0,4'd1};
          4'd1: {reset_pc, load_pc, addr_sel, step} = {2'b00,1'b1,1'b0,4'd2};
          4'd2: {reset_pc, load_pc, addr_sel, step, done} = {2'b00,1'b0,1'b1,4'd0, 1'b1};
          endcase 
        end 
      
      //BLE INSTRUCTION branches if first operand is less than or equal to second (N!=V or Z= 1) 
      {`BLE, 4'd0}: 
        if (N !== v | Z === 1) begin  // same instructions as B
          case(step)
          4'd0: {reset_pc, load_pc, addr_sel, step} = {2'b10,1'b0,1'b0,4'd1};
          4'd1: {reset_pc, load_pc, addr_sel, step} = {2'b10,1'b1,1'b0,4'd2};
          4'd2: {reset_pc, load_pc, addr_sel, step, done} = {2'b10,1'b0,1'b1,4'd0, 1'b1};
          endcase 
        end 
        else begin 
          case(step) //increment pc
          4'd0: {reset_pc, load_pc, addr_sel, step} = {2'b00,1'b0,1'b0,4'd1};
          4'd1: {reset_pc, load_pc, addr_sel, step} = {2'b00,1'b1,1'b0,4'd2};
          4'd2: {reset_pc, load_pc, addr_sel, step, done} = {2'b00,1'b0,1'b1,4'd0, 1'b1};
          endcase 
        end 
			
      //RESET STATE + FOLLOWING INSTRUCTIONS
      {`RESET, 4'd0}: {reset_pc, load_pc, addr_sel, load_ir, m_cmd, step, done} = {5'b01_1_0_0, `MNL, 4'd0, 1'b1};
      {`BEGIN, 4'b0}: begin
        {reset_pc, load_pc, addr_sel, load_ir, m_cmd, step, done} = {5'b00_0_1_0, `MRD, 4'd1, 1'b1}; //IF1
        {vsel, nsel, write} = {7'dx,1'b0};
      end
      {`BEGIN, 4'd1}: {reset_pc, load_pc, addr_sel, load_ir, m_cmd, step, done} = {5'b00_0_1_1, `MRD, 4'd2, 1'b1}; //IF2
      {`BEGIN, 4'd2}: {reset_pc, load_pc, addr_sel, load_ir, m_cmd, step, done} = {5'b00_1_0_0, `MNL, 4'd3, 1'b1}; //UpdatePC
      {`BEGIN, 4'd3}: {reset_pc, load_pc, addr_sel, load_ir, m_cmd, step, done} = {5'b00_0_0_0, `MNL, 4'd0, 1'b0}; //Decode
          
      default: begin
        {loada, loadb, loadc, asel, bsel, vsel, write, nsel, loads, step} = {16'dx, 1'b0};
        {reset_pc, load_pc, addr_sel, load_ir, m_cmd, done} = {8'dx};
        load_addr = 1'dx;
      end
    endcase 
  end           
endmodule 


module MuxChooser(a8, a7, a6, a5, a4, a3, a2, a1, a0, muxC_in, muxC_out) ;
  parameter k = 4;
  parameter m = 5;
  input [k-1:0] a8, a7, a6, a5, a4, a3, a2, a1, a0;  // inputs
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
      5'b011_00: muxC_out = a6;
      5'b100_00: muxC_out = a7;
      5'b111_00: muxC_out = a8;
      default: muxC_out = {k{1'bx}};
    endcase
  end 
endmodule
