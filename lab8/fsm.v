// The size of a state
`define STATESIZE 5

// Opcodes -- categories of operations
`define MOVOPCODE 3'b110
`define ALUOPCODE 3'b101
`define HLTOPCODE 3'b111
`define LDROPCODE 3'b011
`define STROPCODE 3'b100

//LAB8 Instructions
`define BRANCH_OPCODE 3'b001
`define CALL_OPCODE 3'b010

// Operations -- note that more than one may share the same number since they may be in different categories
`define ADDOP 2'b00
`define CMPOP 2'b01
`define ANDOP 2'b10
`define MVNOP 2'b11
`define MOVOP 2'b10
`define MOVRR 2'b00

//LAB 8 opcode for Call & Return
`define BL 2'b11
`define BLX 2'b10
`define BX 2'b00

// Constants for states
// Note that each state may be used for multiple instructions
`define RESETSTAGE `STATESIZE'd0
`define IF1STAGE `STATESIZE'd12
`define IF2STAGE `STATESIZE'd13
`define PCSTAGE `STATESIZE'd14
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
`define HLTSTAGE `STATESIZE'd15
`define SETADDRSTAGE `STATESIZE'd16
`define LOADADDRSTAGE `STATESIZE'd17
`define LDRWB1STAGE `STATESIZE'd18
`define LDRWB2STAGE `STATESIZE'd19
`define STORE1STAGE `STATESIZE'd20
`define STORE2STAGE `STATESIZE'd21

//lab8 stages
`define BRANCHSTAGE `STATESIZE'd22
`define PC_SXIM8 `STATESIZE'd23
`define PCNORM `STATESIZE'd24
`define CALLRETURNSTAGE `STATESIZE'd25
`define R7PC `STATESIZE'd26
`define PCRD `STATESIZE'd27
`define PCRD2 `STATESIZE'd28

// Vsel options
`define READDATAPATHIN 4'b0010
`define READDATAPATHOUT 4'b0001
`define READPC 4'b1000
`define READMDATA 4'b0100

// Instruction registers for {read/write}num
`define RN 3'b100
`define RD 3'b010
`define RM 3'b001

// Memory read/write signals
`define MREAD 2'b01
`define MWRITE 2'b10
`define MINACTIVE 2'b00

//COND encoding for BRANCHES
`define B 3'b000
`define BEQ 3'b001
`define BNE 3'b010
`define BLT 3'b011
`define BLE 3'b100

// State Machine module declaration
module InstructionSM(clk,
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
                     bsel,
                     loadir,
                     loadpc,
                     reset_pc,
                     addr_sel,
                     mem_cmd,
                     load_addr,
                     N,
                     V,
                     Z,
                     cond);
  
  input clk, reset;
  
  //mew inputs
  input N, V, Z;
  input [2:0] cond;
  
  output reg  loada, loadb, loadc, loads, write, asel, bsel, loadir, loadpc, addr_sel, load_addr;
  output reg [1:0] mem_cmd, reset_pc;
  output reg [2:0] nsel;
  output reg [3:0] vsel;
  input [2:0] opcode;
  input [1:0] op;

  // w is the wait signal, output when we are in the WAITSTAGE state
  output wire w;
  
  // State is the current state, while nextState is the proposedState or WAITSTAGE if reset if 1
  // proposedState is the state that we will go to if reset is 0
  wire [`STATESIZE-1:0] state;
  reg [`STATESIZE-1:0] proposedState;
  wire [`STATESIZE-1: 0] nextState;
  assign nextState = reset ? `RESETSTAGE : proposedState;
  
  assign w  = (state === `HLTSTAGE); // w is now linked to when the HALT instruction is loaded, signifying that the program has ended

  // This flip-flop stores the state
  vDFF #(`STATESIZE) stateFF(clk, nextState, state);
  
  
  always @(*) begin
    // This case statement determines the next state based on the current state and the start signal
    // Additionally, it sets the outputs of the FSM to the datapath based on the current state
    casex(state)
      // The HALT state can only be exited by resetting, as it is the last stage of a program
      // While not many inputs matter in HALT, we set most things to 0 for consistency
      `HLTSTAGE: begin
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel} = {7'b0, 7'bx};
        {loadir, loadpc, reset_pc} = 4'b0000;
        {load_addr, addr_sel, mem_cmd} = {1'b0, 1'b1, `MINACTIVE};
        proposedState = `HLTSTAGE;
        
      end
      // The reset state resets the program counter to zero so that we start the program again
      `RESETSTAGE: begin
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel} = {7'b0, 7'bx};
        {loadir, loadpc, reset_pc} = 4'b01_01;
        {load_addr, addr_sel, mem_cmd} = {1'b0, 1'b1, `MINACTIVE};
        proposedState = `IF1STAGE;
      end
      // The first stage, wherewe set the address selector to 1, so that we read from the PC logic
      `IF1STAGE: begin
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel} = {7'b0, 7'bx};
        {loadir, loadpc, reset_pc} = 4'b00_00;
        {load_addr, addr_sel, mem_cmd} = {1'b0, 1'b1, `MINACTIVE};
        proposedState = `IF2STAGE;
      end
      // We now load the instruction register with the data from memory accessed in the previous state
      `IF2STAGE: begin
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel} = {7'b0, 7'bx};
        {loadir, loadpc, reset_pc} = 4'b10_00;
        {load_addr, addr_sel, mem_cmd} = {1'b0, 1'b1, `MREAD};
        proposedState = `PCSTAGE;
      end
      // The PC state updates the program counter so that we move on to the next instruction on the next pass through the system
      `PCSTAGE: begin
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel} = {7'b0, 7'bx};
        {loadir, loadpc, reset_pc} = 4'b01_00;
        {load_addr, addr_sel, mem_cmd} = {1'b0, 1'b1, `MINACTIVE};
        proposedState = `DECODESTAGE;
      end
      // In DECODESTAGE, we determine the next state based on the operation defined in opcode and op
      `DECODESTAGE: begin 
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel} = {7'b0, 7'bx};
        {loadir, loadpc, reset_pc} = 4'b00_00;
        {load_addr, addr_sel, mem_cmd} = {1'b0, 1'b1, `MINACTIVE};
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
        // In both the LDR and STR operations, we leed to load register A with the value in Rn
        end else if (|{(opcode === `LDROPCODE), (opcode === `STROPCODE)}) begin
          proposedState = `LOADASTAGE;
        // When HALT is the instruction, all roads lead to HALT
        end else if (opcode === `HLTOPCODE) begin
          proposedState = `HLTSTAGE;
        end else if (opcode === `BRANCH_OPCODE) begin 
        // When the OPCODE indicates a branch instruction, go to the BRANCHSTATE
          proposedState = `BRANCHSTAGE;
        end else if (opcode === `CALL_OPCODE) begin 
        //When the OPCODE indicates a Call & Return function, go to CALLRETURNSTATE
          proposedState = `CALLRETURNSTAGE;
        end else
        // If the input is outside of the expected values, we set the proposed state to all x, which lets us detect problems in ModelSim
          proposedState = {`STATESIZE{1'bx}};
      end
      // This state is specific to the operation where we load the value from the datapath input into a register
      `MOVRNSTAGE: begin
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel} = {1'b1, 6'b0, `READDATAPATHIN, `RN};
        {loadir, loadpc, reset_pc} = 3'b000;
        {load_addr, addr_sel, mem_cmd} = {1'b0, 1'b1, `MINACTIVE};
        proposedState                            = `IF1STAGE;
      end
      // This multipurpose state allows us to load the value from Rn into register A
      `LOADASTAGE: begin
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel} = {1'b0, 1'b1, 5'b0, 4'bx, `RN};
        {loadir, loadpc, reset_pc} = 4'b0000;
        {load_addr, addr_sel, mem_cmd} = {1'b0, 1'b1, `MINACTIVE};
        // If we are doing LDR or STR, then we go to SETADDRSTAGE
        if (|{(opcode === `LDROPCODE), (opcode === `STROPCODE)}) begin
          proposedState = `SETADDRSTAGE;
        // Otherwise go to the LoadB state
        end else begin
          proposedState                            = `LOADBSTAGE;
        end
      end
      // This multipurpose state allows us to load the value from Rm into register B
      `LOADBSTAGE: begin
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel} = {2'b0, 1'b1, 4'b0, 4'bx, `RM};
        {loadir, loadpc, reset_pc} = 4'b0000;
        {load_addr, addr_sel, mem_cmd} = {1'b0, 1'b1, `MINACTIVE};
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
      `CMPSTAGE: begin
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel} = {4'b0, 1'b1, 2'b0, 7'bx};
        {loadir, loadpc, reset_pc} = 4'b0000;
        {load_addr, addr_sel, mem_cmd} = {1'b0, 1'b1, `MINACTIVE};
        proposedState                            = `IF1STAGE;
      end
      // The AND and ADD stages differ only in ALU operation, which is passed directly to the ALU
      // They output to register C only
      `ANDADDSTAGE: begin
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel} = {3'b0, 1'b1, 3'b0, 7'bx};
        {loadir, loadpc, reset_pc} = 4'b0000;
        {load_addr, addr_sel, mem_cmd} = {1'b0, 1'b1, `MINACTIVE};
        proposedState                            = `WRITEBACKSTAGE;
      end
      // The REGREG state differs from the ANDADD state by having asel be 1, since we want to add 0 to the number in the ALU
      `REGREGSTAGE: begin
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel} = {3'b0, 1'b1, 1'b0, 1'b1, 1'b0, 7'bx};
        {loadir, loadpc, reset_pc} = 4'b0000;
        {load_addr, addr_sel, mem_cmd} = {1'b0, 1'b1, `MINACTIVE};
        if (op === `BX | op === `BLX)
          proposedState = `PCRD2;
        else
        proposedState  = `WRITEBACKSTAGE;
      end
      // The MVN state also has asel be 1, as we are again only dealing with the output of register b (and the shifter)
      `MVNSTAGE: begin
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel} = {3'b0, 1'b1, 1'b0, 1'b1, 1'b0, 7'bx};
        {loadir, loadpc, reset_pc} = 4'b0000;
        {load_addr, addr_sel, mem_cmd} = {1'b0, 1'b1, `MINACTIVE};
        proposedState                      = `WRITEBACKSTAGE;
      end
      // The WRITEBACK state writes the contents of register C (and therefore datapath_out) to register Rd
      `WRITEBACKSTAGE: begin
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel} = {1'b1, {6{1'b0}}, `READDATAPATHOUT, `RD};
        {loadir, loadpc, reset_pc} = 4'b0000;
        {load_addr, addr_sel, mem_cmd} = {1'b0, 1'b1, `MINACTIVE};
        proposedState = `IF1STAGE;
      end
      // The SETADDR state computes the address to STR or LDR to
      `SETADDRSTAGE: begin
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel} = {3'b0, 1'b1, 2'b0, 1'b1, 7'bx};
        {loadir, loadpc, reset_pc} = 4'b0000;
        {load_addr, addr_sel, mem_cmd} = {1'b0, 1'b1, `MINACTIVE};
        proposedState = `LOADADDRSTAGE;
      end
      // The first STORE state loads the value to store into register C, and therefore outputs it to datapath_out
      `STORE1STAGE: begin
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel} = {3'b0, 1'b1, 1'b0, 1'b1, 1'b0, 7'bx};
        {loadir, loadpc, reset_pc} = 4'b0000;
        {load_addr, addr_sel, mem_cmd} = {1'b0, 1'b0, `MINACTIVE};
        proposedState = `STORE2STAGE;
      end
      // The second STORE state writes the value from the register Rd (and subsequently registers B and C) into memory at the address previously computed
      `STORE2STAGE: begin
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel} = {7'b0, 7'bx};
        {loadir, loadpc, reset_pc} = 4'b0000;
        {load_addr, addr_sel, mem_cmd} = {1'b0, 1'b0, `MWRITE};
        proposedState = `IF1STAGE;
      end
      // The LOADADDR state loads the address register with the address computed in the SETADDR state
      `LOADADDRSTAGE: begin
        // LoadB is 1 because (a) B is not used in the LDR instruction, and (b) we need to load B with Rn for STR
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel} = {2'b0, 1'b1, 4'b0, 4'bx, `RD};
        {loadir, loadpc, reset_pc} = 4'b0000;
        {load_addr, addr_sel, mem_cmd} = {1'b1, 1'b1, `MINACTIVE};
        // Since there's two states that we could go to from here, we have an if statement
        if (opcode === `LDROPCODE) begin
          proposedState = `LDRWB1STAGE;
        end else if (opcode === `STROPCODE) begin
          proposedState = `STORE1STAGE;
        // As is standard, if something is strange, there are x
        end else begin
          proposedState = {`STATESIZE{1'bx}};
        end
        
      end
      // The LDR WriteBack 1 state allows us to read from the memory into the mdata wire
      `LDRWB1STAGE: begin
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel} = {{7{1'b0}}, 7'bxxx};
        {loadir, loadpc, reset_pc} = 4'b0000;
        {load_addr, addr_sel, mem_cmd} = {1'b0, 1'b0, `MREAD};
        proposedState = `LDRWB2STAGE;
      end
      // Subsequent to WriteBack 1, we have WriteBack 2, which actually writes back into register Rd
      `LDRWB2STAGE: begin
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel} = {1'b1, {6{1'b0}}, `READMDATA, `RD};
        {loadir, loadpc, reset_pc} = 4'b0000;
        {load_addr, addr_sel, mem_cmd} = {1'b0, 1'b0, `MREAD};
        proposedState = `IF1STAGE;
      end
      
      //BRANCHSTAGE decides which operation to perform based on the cond and operand values  
      `BRANCHSTAGE: begin  
        if (cond === `B)
          proposedState = `PCNORM; 
        else if (cond === `BEQ & Z === 1)
          proposedState = `PC_SXIM8;
        else if (cond === `BEQ & Z !== 1)
          proposedState = `PCNORM;
        else if (cond === `BNE & Z === 0)
          proposedState = `PC_SXIM8;
        else if (cond === `BNE & Z !== 0)
          proposedState = `PCNORM;
        else if (cond === `BLT & N !== V)
          proposedState = `PC_SXIM8;
        else if (cond === `BLT & ~(N !== V))
          proposedState = `PCNORM;
        else if (cond === `BLE & (N !== V | Z === 1))
          proposedState = `PC_SXIM8;
        else if (cond === `BLE & ~(N !== V | Z === 1))
          proposedState = `PCNORM;
        else
          proposedState = {`STATESIZE{1'bx}};
      end 
     
      //increment PC by 1
      `PCNORM: begin
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel, loadir, mem_cmd, load_addr} = {{7{1'b0}}, 7'bxxx, 1'b0, `MINACTIVE, 1'b0};
        {reset_pc, loadpc, addr_sel} = {2'b00, 1'b1, 1'b1};
        if (op === `BL | op === `BLX)
          proposedState = `R7PC;
        else 
          proposedState = `IF1STAGE; 
      end 
      
      //PC = PC+Sxim8 + 1
      `PC_SXIM8: begin
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel, loadir, mem_cmd, load_addr} = {{7{1'b0}}, 7'bxxx, 1'b0, `MINACTIVE, 1'b0};
        {reset_pc, loadpc, addr_sel} = {2'b10, 1'b1, 1'b1};
      	proposedState = `IF1STAGE;
      end 
      
      //determine which function call perform based on OP
      `CALLRETURNSTAGE: begin 
        if (op === `BL)
          proposedState = `PCNORM;
        else if (op === `BLX)
          proposedState = `PCNORM;
        else if (cond === `BX)
          proposedState = `PCRD;
        else 
          proposedState = {`STATESIZE{1'bx}};
      end 
      
      //Saves PC+1 to link register (R7) 
      `R7PC: begin 
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel} = {{7{1'b0}}, 4'b1000, `RN};
        {loadir, loadpc, reset_pc} = 4'b0000;
        {load_addr, addr_sel, mem_cmd} = {1'b0, 1'b0, `MINACTIVE};
        if (op === `BL)  
          proposedState = `PC_SXIM8; //then update PC to address of the start of function call
        else if (op === `BLX)
          proposedState = `PCRD; //then copies the specified register to PC
        else
          proposedState = {`STATESIZE{1'bx}};
        end 
      
      //Copies the specified register to PC 
      
      `PCRD: begin 
        //load contents of RD to B 
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel} = {2'b0, 1'b1, 4'b0, 4'bx, `RD};
        {loadir, loadpc, reset_pc} = 4'b0000;
        {load_addr, addr_sel, mem_cmd} = {1'b0, 1'b1, `MINACTIVE};
        proposedState = `REGREGSTAGE; //load 0's to A
      end 
      
      `PCRD2: begin //PC = datapath_out stage
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel} = {1'b0, {6{1'b0}}, 7'bx};
        {loadir, loadpc, reset_pc} = 4'b0011;
        {load_addr, addr_sel, mem_cmd} = {1'b0, 1'b1, `MINACTIVE};
        proposedState = `IF1STAGE;
      end 
          
      default : begin 
        // If the input is outside of the expected values, we set the proposed state to all x, which lets us detect problems in ModelSim
        proposedState = {`STATESIZE{1'bx}};
        {write, loada, loadb, loadc, loads, asel, bsel, vsel, nsel} = {7'b0, 7'bx};
        {loadir, loadpc, reset_pc} = 4'b0000;
        {load_addr, addr_sel, mem_cmd} = {1'b0, 1'b1, `MINACTIVE};
      end
    endcase
  end
  
endmodule
