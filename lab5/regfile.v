module regfile(data_in,writenum,write,readnum,clk,data_out);
  input [15:0] data_in;
  input [2:0] writenum, readnum;
  input write, clk;
  output [15:0] data_out;

  reg [7:0] oneHotWrite;
  reg [7:0] oneHotSelect;

  decoder #(3,8) writeDecode(writenum, oneHotWrite);
  decoder #(3,8) readDecoder(readnum, oneHotSelect);
  vDFF #(1,16,16) r(clk, data_in, );
// fill out the rest


always @(write) begin
	if (rst) begin
		// reset
		
	end
	else if () begin
		
	end
end

endmodule




module decoder(binary, oneHotCode);
	parameter n = 3;
	parameter m = 8;

	input [n-1:0] binary;
	output [m-1:0] oneHotCode;

	wire assign oneHotCode = 1 << binary;

endmodule

module ANDing (oneHotWrite, write, )
	always @* begin
		case(oneHotWrite)
			default: 
		endcase
	end
endmodule 

module vDFF(clk, din, dout);
	parameter n=1;
	input clk;
	input [n-1:0] din;
	output [n-1:0] dout;
	
	reg [n-1:0] dout;

	always @(posedge clk) begin
		dout = din;
	end

endmodule