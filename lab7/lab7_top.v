`define MREAD 2'bxx
`define MWRITE 2'bxx

module lab7_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);
  input [3:0] KEY;
  input [9:0] SW;
  output [9:0] LEDR;
  output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  
  //Instantiation wire declarations
  wire [15:0] dout;
  wire [15:0] write_data;
  wire [1:0] mem_cmd;
  wire [8:0] mem_addr;
  wire [15:0] read_data;
  wire [15:0] in;
 
  //Tri state declaration and write AND gate
  wire enable;
  wire msel;
  wire write;
  assign msel = (1'b0 === mem_addr[8:8]);
  assign enable = (`MREAD === mem_cmd) & msel;
  assign write =  msel & (`MWRITE === mem_cmd);
  
  //Tri-state driver
  assign read_data = enable? dout : 16'bz;
  
 //instantiating CPU & Read-Write Memory
  cpu CPU(.clk(clk),
           .reset(reset),
           .in(in),
           .write_data(write_data),
           .N(N),
           .V(V),
           .Z(Z),
           .w(w),
           .mem_addr(mem_addr),
           .mem_cmd(mem_cmd),
           .read_data(read_data) );
  
  RAM #(16,8) MEM(.clk(clk),.read_address(mem_addr[7:0]),.write_address(mem_addr[7:0]),.write(write),.din(write_data),.dout(dout));  
  
  //instantiate SWdata and its corresponding tri state buffers
  wire SWdata_enable;
  SWdata SWdata(9'h140, mem_cmd, mem_addr[8:0], SWdata_enable);
  assign read_data[15:8] = SWdata_enable ? 8'h00 : 8'bz;
  assign read_data[7:0] = SWdata_enable ? SW[7:0] : 8'bz;
  
  //instantiate LEDout and the corresponding flip-flop
  wire LEDout_load;
  LEDout LEDout(9'h100, mem_cmd, mem_addr, LEDout_load);
  regLoad #(8) LEDff(clk, LEDout_load, write_data[7:0], LEDR[7:0]);
  
endmodule

//SWdata is a circuit which takes the slider switches as inputs for read_data 
module SWdata (hexinput, mem_cmd, mem_addr, SWdata_enable);
  input [8:0] hexinput; 
  input [1:0] mem_cmd;
  input [8:0] mem_addr; 
  output reg SWdata_enable;
  
  //insert circuit code here:
  always @* begin
    if (mem_addr === hexinput & mem_cmd === `MWRITE)
      SWdata_enable = 1;
    else
      SWdata_enable = 0;
  end
endmodule 

//LEDout is a circuit which outputs the data in write_data
module LEDout(hexinput, mem_cmd, mem_addr, LEDout_load);
  input [8:0] hexinput; 
  input [1:0] mem_cmd;
  input [8:0] mem_addr; 
  output reg LEDout_load;
  
  //insert circuit code here: 
    always @* begin
      if (mem_addr === hexinput & mem_cmd === `MREAD)
      LEDout_load = 1;
    else
      LEDout_load = 0;
  end
endmodule 
