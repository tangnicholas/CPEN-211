module ALU(Ain,Bin,ALUop,out,Z_in);
input [15:0] Ain, Bin;
input [1:0] ALUop;
output [15:0] out;
output Z_in;

// fill out the rest

reg [15:0] out; 
reg Z_in;

always @(*) begin
	// Ain + Bin
	if (ALUop == 2'b00) begin 
		 out = (Ain + Bin);
	end 
	//Ain- Bin
	else if (ALUop == 2'b01) begin 
		 out = (Ain - Bin);
	end 
	//Ain & Bin
	else if (ALUop == 2'b10) begin 
		 out = (Ain & Bin);
	end 
	// ~Bin
	else begin 
		 out = ~Bin;
	end 

	//if out is zero, Z = 1
	if (out == 16'b0000000000000000)
		 Z_in = 1'b1;		
	else 
		 Z_in = 1'b0;

end 
endmodule 
