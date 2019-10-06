module regfile(data_in,writenum,write,readnum,clk,data_out);
  input [15:0] data_in;
  input [2:0] writenum, readnum;
  input write, clk;
  output [15:0] data_out;

  wire [7:0] oneHotWrite;
  wire [15:0] rout_a0, rout_a1, rout_a2, rout_a3, rout_a4, rout_a5, rout_a6, rout_a7;
	
  //call the decoder module
  decoder #(3,8) writeDecode(writenum, oneHotWrite);
  
  //call the registers with load enables module
  vDFFE #(16) r0(clk, (write & oneHotWrite[0]), data_in, rout_a0);
  vDFFE #(16) r1(clk, (write & oneHotWrite[1]), data_in, rout_a1);
  vDFFE #(16) r2(clk, (write & oneHotWrite[2]), data_in, rout_a2);
  vDFFE #(16) r3(clk, (write & oneHotWrite[3]), data_in, rout_a3);
  vDFFE #(16) r4(clk, (write & oneHotWrite[4]), data_in, rout_a4);
  vDFFE #(16) r5(clk, (write & oneHotWrite[5]), data_in, rout_a5);
  vDFFE #(16) r6(clk, (write & oneHotWrite[6]), data_in, rout_a6);
  vDFFE #(16) r7(clk, (write & oneHotWrite[7]), data_in, rout_a7);

  //call the multiplexer module
  Muxb8 #(16) m(rout_a7, rout_a6, rout_a5, rout_a4, rout_a3, rout_a2, rout_a1, rout_a0, readnum, data_out);


endmodule

//3 to 8 binary to one-hot decoder 
module decoder(binary, oneHotCode);
	parameter n = 3;
	parameter m = 8;

	input [n-1:0] binary;
	output [m-1:0] oneHotCode;

	assign oneHotCode = 1 << binary;

endmodule

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

//send multiplexer singals to onehot code
module Muxb8(a7, a6, a5, a4, a3, a2, a1, a0, readnum, data_out) ;
  
  parameter k = 1 ;
  input [k-1:0] a0, a1, a2, a3, a4, a5, a6, a7 ;  // inputs
  input [2:0]   readnum ;          // binary select
  output[k-1:0] data_out ;
  wire  [7:0]   selectOneHot;
  
  decoder #(3,8) readDecoder(readnum, selectOneHot); // Decoder converts binary to one-hot   
  Mux8_16 #(16)  m(a7, a6, a5, a4, a3, a2, a1, a0, selectOneHot, data_out) ; // multiplexer selects input 

endmodule

//implement approriate multiplexer outputs
module Mux8_16 (a7, a6, a5, a4, a3, a2, a1, a0, selectOneHot, data_out);
	parameter k = 1 ;
	input [k-1:0] a0, a1, a2, a3, a4, a5, a6, a7 ;  // inputs
  input [7:0]   selectOneHot ; // one-hot select
	output[k-1:0] data_out ;
	reg [k-1:0] data_out ;

	always @(*) begin
    	case(selectOneHot) 
      		8'b00000001: data_out = a0 ;
      		8'b00000010: data_out = a1 ;
      		8'b00000100: data_out = a2 ;
      		8'b00001000: data_out = a3 ;
      		8'b00010000: data_out = a4 ;
      		8'b00100000: data_out = a5 ;
      		8'b01000000: data_out = a6 ;
      		8'b10000000: data_out = a7 ;
    		default: data_out =  {k{1'bx}} ;
		endcase
	end


endmodule