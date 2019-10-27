// The size of a state
`define STATESIZE 4

// Opcodes -- categories of operations
`define MOVOPCODE 3'b110
`define ALUOPCODE 3'b101

// Operations -- note that more than one may share the same number since they may be in different categories
`define ADDOP 2'b00
`define CMPOP 2'b01
`define ANDOP 2'b10
`define MVNOP 2'b11
`define MOVOP 2'b10
`define MOVRR 2'b00

// Constants for states
// Note that each state may be used for multiple instructions
// REPLACED WAITSTAGE with RESET, IF1, IF2 and UPDATEPC 
`define RESET `STATESIZE'd0
`define IF1 `STATESIZE'd12
`define IF2 `STATESZIE'd13 
`define UPDATEPC `STATESIZE'd14

`define DECODESTAGE `STATESIZE'd1
`define MOVRNSTAGE `STATESIZE'd2
`define LOADASTAGE `STATESIZE'd3
`define LOADBSTAGE `STATESIZE'd4
`define LOADCSTAGE `STATESIZE'd5
`define LOADSSTAGE `STATESIZE'd6
`define WRITEBACKSTAGE `STATESIZE'd7
`define CMPSTAGE `STATESIZE'd8
`define ANDADDSTAGE `STATESIZE'd9
`define MVNSTAGE `STATESIZE'd10
`define REGREGSTAGE `STATESIZE'd11

// Vsel options
`define READDATAPATHIN 4'b0010
`define READDATAPATHOUT 4'b0001

// Instruction registers for {read/write}num
`define RN 3'b100
`define RD 3'b010
`define RM 3'b001

// State Machine module declaration
module InstructionSM(clk,
                     start,
                     reset,
                     w,
                     nsel,
                     loada,
                     loadb,
                     loadc,
                     loads,
                     vsel,
                     write,
                     opcode,
                     op,
                     asel,
                     bsel);
  
  input clk, reset, start;
  output reg  loada, loadb, loadc, loads, write, asel, bsel;
  output reg [2:0] nsel;
  output reg [3:0] vsel;
  input [2:0] opcode;
  input [1:0] op;

  // w is the wait signal, output when we are in the WAITSTAGE state
  output w;
  
  // State is the current state, while nextState is the proposedState or RESET if reset if 1 
  // proposedState is the state that we will go to if reset is 0
  wire [`STATESIZE-1:0] state;
  reg [`STATESIZE-1:0] proposedState;
  wire [`STATESIZE-1: 0] nextState;
  assign w = (state == `RESET | `IF1 | `IF2 | `UPDATEPC );
  assign nextState = reset ? `RESET : proposedState;
  
  // This flip-flop stores the state
  vDFF #(`STATESIZE) stateFF(clk, nextState, state);
  
  always @(*) begin
    // This case statement determines the next state based on the current state and the start signal
    // Additionally, it sets the outputs of the FSM to the datapath based on the current state
    casex(state)
      // Current state is RESET: we start the machine, going to the IF1
      `RESET :begin
        proposedState  = `IF1;
        //resetPC = 1, load_pc = 1 ... 0 is inputed into and loaded by the program counter 
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel, load_pc, load_ir, reset_pc, addr_sel, m_cmd } = {7'b0, 7'bx};
        {load_pc, load_ir, reset_pc, addr_sel, m_cmd} = {1'b1, 1'bx, 1'b1, 1'bx, 1'bx};
      end
      
      // Current state is Not RESET: we iterate through onto DECODESTAGE regardless of other states on rising edge of clk cycle and set the outputs
      `IF1 :begin
        proposedState  = `IF2;
        // Current state is IF1, address in PC is sent to instruction memory, we go on to IF2
        //We make addr_sel = 1 and m_cmd = R
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel, load_pc, load_ir, reset_pc, addr_sel, m_cmd} = {7'b0, 7'bx};
        {load_pc, load_ir, reset_pc, addr_sel, m_cmd} = {1'bx, 1'bx, 1'bx, 1'b1, R};
      end
      `IF2 :begin
        proposedState  = `UPDATEPC;
        //Current state is IF2, 16bit instruction should be at dout. 
        //We make addr_sel = 1, m_cmd = R, and load_ir = 1. Rest are x's 
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel, load_pc, load_ir, reset_pc, addr_sel, m_cmd} = {7'b0, 7'bx};
        {load_pc, load_ir, reset_pc, addr_sel, m_cmd} = {1'bx, 1'b1, 1'bx, 1'b1, R};
      end
      `UPDATEPC :begin
        proposedState  = `DECODESTAGE;
        //Current state is UPDATEPC, we set load_pc = 1, updating the PC on the rising edge of clk. Then we go to DECODESTAGE
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel, } = {7'b0, 7'bx};
        {load_pc, load_ir, reset_pc, addr_sel, m_cmd} = {1'b1, 1'bx, 1'bx, 1'bx, 1'bx};
      end
     
      // For all states except for RESET, IF1, IF2, and UPDATEPC
      // In DECODESTAGE, we determine the next state based on the operation defined in opcode and op
      `DECODESTAGE : begin 
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel} = {7'b0, 7'bx};
        {load_pc, load_ir, reset_pc, addr_sel, m_cmd} = {5'bx};
        // We first check opcode
        if (opcode === `MOVOPCODE) begin
          // Inside of the check for opcode, we check op, and move to the proper state
          if (op === `MOVOP)
            proposedState = `MOVRNSTAGE;
          else if (op === `MOVRR)
            proposedState = `LOADBSTAGE;
          else
            proposedState = {`STATESIZE{1'bx}};
        end else if (opcode === `ALUOPCODE) begin
          // Inside of the check for opcode, we check op, and move to the proper state
          // Since multiple stages go to LOADASTAGE from DECODESTAGE, we concatenate their equality and OR it, so that if it is any one of them, we choose LOADASTAGE
          if (|{(op === `ADDOP), (op === `ANDOP), (op === `CMPOP)})
            proposedState = `LOADASTAGE;
          else if(op === `MVNOP)
            proposedState = `LOADBSTAGE;
          else
            // If the input is outside of the expected values, we set the proposed state to all x, which lets us detect problems in ModelSim
            proposedState = {`STATESIZE{1'bx}};
        end else
          // If the input is outside of the expected values, we set the proposed state to all x, which lets us detect problems in ModelSim
          proposedState = {`STATESIZE{1'bx}};
      end
      // This state is specific to the operation where we load the value from the datapath input into a register
      {`MOVRNSTAGE, 1'bx}: begin
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel} = {1'b1, 6'b0, `READDATAPATHIN, `RN};
        proposedState  = `IF1;
      end
      // This multipurpose state allows us to load the value from Rn into register A
      `LOADASTAGE : begin
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel} = {1'b0, 1'b1, 5'b0, 4'bx, `RN};
        proposedState = `LOADBSTAGE;
      end
      // This multipurpose state allows us to load the value from Rm into register B
      `LOADBSTAGE : begin
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel} = {2'b0, 1'b1, 4'b0, 4'bx, `RM};
        // Since this is used by multiple different operations, we must decide on the next state based on op and opcode
        if(opcode === `MOVOPCODE)
          // Since only REGREG of the MOV operations uses this state, we don't need a second level of if statements
          proposedState  = `REGREGSTAGE;
        else if(opcode === `ALUOPCODE) begin
          // AND and ADD are identical in terms of their state machine, so we go to the same state for both
          if (|{(op === `ADDOP), (op === `ANDOP)})
            proposedState = `ANDADDSTAGE;
          // CMP goes to its own state
          else if(op === `CMPOP)
            proposedState = `CMPSTAGE;
          // MVN also has its own state
          else if(op === `MVNOP)
            proposedState = `MVNSTAGE;
          // If the input is outside of the expected values, we set the proposed state to all x, which lets us detect problems in ModelSim
          else
            proposedState = {`STATESIZE{1'bx}};
        // If the input is outside of the expected values, we set the proposed state to all x, which lets us detect problems in ModelSim
        end else
          proposedState = {`STATESIZE{1'bx}};
      end
      // The CMP state outputs only to the status register, and not the C register
      `CMPSTAGE : begin
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel} = {4'b0, 1'b1, 2'b0, 7'bx};
        proposedState = `IF1;
      end
      // The AND and ADD stages differ only in ALU operation, which is passed directly to the ALU
      // They output to register C only
      `ANDADDSTAGE : begin
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel} = {3'b0, 1'b1, 3'b0, 7'bx, 5'bx};
        proposedState  = `WRITEBACKSTAGE;
      end
      // The REGREG state differs from the ANDADD state by having asel be 1, since we want to add 0 to the number in the ALU
      `REGREGSTAGE : begin
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel} = {3'b0, 1'b1, 1'b0, 1'b1, 1'b0, 7'bx, 5'bx};
        proposedState = `WRITEBACKSTAGE;
      end
      // The MVN state also has asel be 1, as we are again only dealing with the output of register b (and the shifter)
      `MVNSTAGE : begin
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel} = {3'b0, 1'b1, 1'b0, 1'b1, 1'b0, 7'bx};
        proposedState = `WRITEBACKSTAGE;
      end
      // The WRITEBACK stage writes the contents of register C (and therefore datapath_out) to register Rd
      `WRITEBACKSTAGE : begin
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel} = {1'b1, 6'b0, `READDATAPATHOUT, `RD};
        proposedState = `IF1;
      end
      default: begin 
        // If the input is outside of the expected values, we set the proposed state to all x, which lets us detect problems in ModelSim
        proposedState = {`STATESIZE{1'bx}};
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel} = {7'b0, 7'bx};
      end
    endcase
  end
  
  
  
endmodule