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
 
  //Tri state declaration and write AND gate
  wire enable;
  wire msel;
  wire write;
  assign msel = (1'b0 === mem_addr[8:8]);
  assign enable = (`MREAD === mem_cmd) & msel;
  assign write =  msel & (`MWRITE === mem_cmd)
  
  //Tri-state driver ()
	assign read_data = enable? dout : 16'bz;
  
 //instantiating CPU & Read-Write Memory
  cpu cpu7(.clk(clk),
           .reset(reset),
           .s(s),
           .load(load),
           .in(in),
           .out(write_data),
           .N(N),
           .V(V),
           .Z(Z),
           .w(w)
           .mem_addr(mem_addr)
           .mem_cmd(mem_cmd)
           .read_data(read_data) );
  
  RAM MEM(.clk(clk),.read_address(mem_addr[7:0]),.write_address(mem_addr[7:0]),.write(write),.din(write_data),.dout(dout));  
  
endmodule
