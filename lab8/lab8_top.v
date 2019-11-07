
`define NUM0 7'b1000000
`define NUM1 7'b1001111
`define NUM2 7'b0100100
`define NUM3 7'b0110000
`define NUM4 7'b0011001
`define NUM5 7'b0010010
`define NUM6 7'b0000010
`define NUM7 7'b1111000
`define NUM8 7'b0000000
`define NUM9 7'b0010000
`define NUMA 7'b0001000
`define NUMB 7'b0000011
`define NUMC 7'b1000110
`define NUMD 7'b0100001
`define NUME 7'b0000110
`define NUMF 7'b0001110

// Memory read/write signals
`define MREAD 2'b01
`define MWRITE 2'b10

module lab8_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,CLOCK_50);
input [3:0] KEY;
input [9:0] SW;
input CLOCK_50;
output [9:0] LEDR;
output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

  wire [15:0] out;
  wire  N, V, Z, w, msel, isMREAD, isMWRITE, writeRAM, loadLEDS, readSwitches;
  wire [1:0] mem_cmd;
  wire[8:0] mem_addr;
  wire[15:0] read_data, dout;
  wire[7:0] ledValues;

  assign msel = (mem_addr[8] === 1'b0); //if address range in memory to read from
  assign isMREAD = (mem_cmd === `MREAD); //check if read op
  assign isMWRITE = (mem_cmd === `MWRITE); //check if write op

  assign writeRAM = isMWRITE & msel; //only write is msel and write op



    //cpu instantitaion, connect clk to KEY[0], reset connected to KEY[1] (remembering flipped buttons),
    //in which is the future instruction is connected to read_data (from the RAM)
    //out is just the output from the datapath along side the various flags Z, N, V, w
    //the additional memory parameters are also passed 
  cpu CPU( .clk   (CLOCK_50), // recall from Lab 4 that KEY0 is 1 when NOT pushed
         .reset (~KEY[1]),
         .in    (read_data), 
         .out   (out),
         .Z     (Z),
         .N     (N),
         .V     (V),
         .w     (w), 
         .mem_cmd(mem_cmd),
         .mem_addr(mem_addr),
         .mdata(read_data)
         );

    //RAM instantiation, making sure to use lower 8 bits for address and write signal defined above
    //din is the output of the datapath that should be stored into memory
    //dout is the output of the memory block
    RAM MEM(.clk (CLOCK_50),
            .read_address(mem_addr[7:0]),
            .write_address(mem_addr[7:0]), 
            .write(writeRAM),
            .din(out),
            .dout(dout)); 

  assign HEX5[0] = ~Z; 
  assign HEX5[6] = ~N;
  assign HEX5[3] = ~V;

  // fill in sseg to display 4-bits in hexidecimal 0,1,2...9,A,B,C,D,E,F
  sseg H0(out[3:0],   HEX0);
  sseg H1(out[7:4],   HEX1);
  sseg H2(out[11:8],  HEX2);
  sseg H3(out[15:12], HEX3);
  assign HEX4 = 7'b1111111;
  assign {HEX5[2:1],HEX5[5:4]} = 4'b1111; // disabled
  assign LEDR[8] = w;

    //register for holding LED values
    regLoad #(8) LEDS(CLOCK_50,loadLEDS, ledValues, LEDR[7:0]);

  //for memory mapped I/O (block on left of Figure 7 labelled "design this circuit):
    assign readSwitches = isMREAD & (mem_addr === 9'b101000000); //check if we can read from switches

    assign loadLEDS = (mem_addr === 9'b100000000) & isMWRITE; //check if mem_address is correct for loading LEDS and if we're in memory write state

    //combined tristate drivers for read_data, first checks for readSwitches, then if we're reading from a valid location, otherwise disconnects
    assign read_data = readSwitches ? ({8'b0, SW[7:0]}): ((msel & isMREAD) ? dout : 16'bz);
    assign ledValues = out[7:0]; //potential LED values based on output of datapath. Won't be updated until loadLEDS is asserted high

endmodule

//RAM from SS7 -Tor Aamodt
module RAM(clk,read_address,write_address,write,din,dout);
  parameter data_width = 16; 
  parameter addr_width = 8;
  parameter filename = "lab8fig4.txt";

  input clk;
  input [addr_width-1:0] read_address, write_address;
  input write;
  input [data_width-1:0] din;
  output [data_width-1:0] dout;
  reg [data_width-1:0] dout;

  reg [data_width-1:0] mem [2**addr_width-1:0];

  initial $readmemb(filename, mem);

  always @ (posedge clk) begin
    if (write)
      mem[write_address] <= din;
    dout <= mem[read_address]; // dout doesn't get din in this clock cycle 
                               // (this is due to Verilog non-blocking assignment "<=")
  end 
endmodule




module sseg(in,segs);
  input [3:0] in;
  output [6:0] segs;

  reg [6:0] segs;
  // change display to 7-segment display based on input number (binary --> hex)
  always @*
    case(in)
    4'b0000: segs = `NUM0;
    4'b0001: segs = `NUM1;
    4'b0010: segs = `NUM2;
    4'b0011: segs = `NUM3;
    4'b0100: segs = `NUM4;
    4'b0101: segs = `NUM5;
    4'b0110: segs = `NUM6;
    4'b0111: segs = `NUM7;
    4'b1000: segs = `NUM8;
    4'b1001: segs = `NUM9;
    4'd10: segs = `NUMA;
    4'd11: segs = `NUMB;
    4'd12: segs = `NUMC;
    4'd13: segs = `NUMD;
    4'd14: segs = `NUME;
    4'd15: segs = `NUMF;
    default: segs = {4{1'bx}};
  endcase

endmodule

module vDFF(clk,D,Q);
  parameter n=1;
  input clk;
  input [n-1:0] D;
  output [n-1:0] Q;
  reg [n-1:0] Q;
  always @(posedge clk)
    Q <= D;
endmodule

