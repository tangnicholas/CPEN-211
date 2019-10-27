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

module lab7_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);
  input [3:0] KEY;
  input [9:0] SW;
  output [9:0] LEDR;
  output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  
 //instantiating CPU & Read-Write Memory
  cpu cpu7(.clk(si),
           .reset(simreset),
           .s(sims),
           .load(simload),
           .in(simin),
           .out(simout),
           .N(simN),
           .V(simV),
           .Z(simZ),
           .w(simw));
  
  RAM MEM(.clk(clk),.read_address(read_address),.write_address(write_address),.write(write),.din(din),.dout(dout));
  
  // fill in sseg to display 4-bits in hexidecimal 0,1,2...9,A,B,C,D,E,F
  sseg H0(out[3:0], HEX0);
  sseg H1(out[7:4], HEX1);
  sseg H2(out[11:8], HEX2);
  sseg H3(out[15:12], HEX3);
  assign HEX4 = 7'b1111111;
  assign {HEX5[2:1], HEX5[5:4]} = 4'b1111; // disabled
  assign LEDR[8] = 1'b0;
  
endmodule

//Tri-state driver ()
assign output_x = enable? input_x : 'bz;

  
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