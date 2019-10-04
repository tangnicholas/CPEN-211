module detect_winner(ain, bin, cin, f, valid);
	input [8:0] ain, bin, cin;
	output [2:0] f;
	output valid;

	parameter n=8;

	reg testValid;
	reg [2:0] out;

	assign valid = testValid;
	assign f = out;

	always @* begin
		//to determine output of valid (0)		
 		if ((ain[0] == 1'b1 & bin[0] == 1'b1) | (ain[0] == 1'b1 & cin[0] == 1'b1) | (bin[0] == 1'b1 & cin[0] == 1'b1) == 1)
			testValid = 1'b0;
		else if ((ain[1] == 1'b1 & bin[1] == 1'b1) | (ain[1] == 1'b1 & cin[1] == 1'b1) | (bin[1] == 1'b1 & cin[1] == 1'b1) == 1)
			testValid = 1'b0;
		else if ((ain[2] == 1'b1 & bin[2] == 1'b1) | (ain[2] == 1'b1 & cin[2] == 1'b1) | (bin[2] == 1'b1 & cin[2] == 1'b1) == 1)
			testValid = 1'b0;
		else if ((ain[3] == 1'b1 & bin[3] == 1'b1) | (ain[3] == 1'b1 & cin[3] == 1'b1) | (bin[3] == 1'b1 & cin[3] == 1'b1) == 1)
			testValid = 1'b0;
		else if ((ain[4] == 1'b1 & bin[4] == 1'b1) | (ain[4] == 1'b1 & cin[4] == 1'b1) | (bin[4] == 1'b1 & cin[4] == 1'b1) == 1)
			testValid = 1'b0;
		else if ((ain[5] == 1'b1 & bin[5] == 1'b1) | (ain[5] == 1'b1 & cin[5] == 1'b1) | (bin[5] == 1'b1 & cin[5] == 1'b1) == 1)
			testValid = 1'b0;
		else if ((ain[6] == 1'b1 & bin[6] == 1'b1) | (ain[6] == 1'b1 & cin[6] == 1'b1) | (bin[6] == 1'b1 & cin[6] == 1'b1) == 1)
			testValid = 1'b0;
		else if ((ain[7] == 1'b1 & bin[7] == 1'b1) | (ain[7] == 1'b1 & cin[7] == 1'b1) | (bin[7] == 1'b1 & cin[7] == 1'b1) == 1)
			testValid = 1'b0;
		else if ((ain[8] == 1'b1 & bin[8] == 1'b1) | (ain[8] == 1'b1 & cin[8] == 1'b1) | (bin[8] == 1'b1 & cin[8] == 1'b1) == 1)
			testValid = 1'b0;
		
		if (testValid == 1'bx) begin
			case ({ain[1],bin[1],cin[1],ain[0],bin[0],cin[0]})
 				6'b100_000: testValid = 1'b0;
 				6'b010_000: testValid = 1'b0;
 				6'b001_000: testValid = 1'b0;
 				default: testValid = 1'b1;
 			endcase
 		end
 		if (testValid == 1'bx) begin	
 			case ({ain[4],bin[4],cin[4],ain[3],bin[3],cin[3]})
 				6'b100_000: testValid = 1'b0;
 				6'b010_000: testValid = 1'b0;
 				6'b001_000: testValid = 1'b0;
 				default: testValid = 1'b1;
 			endcase
 		end
 		if (testValid == 1'bx) begin
 			case ({ain[7],bin[7],cin[7],ain[6],bin[6],cin[6]})
 				6'b100_000: testValid = 1'b0;
 				6'b010_000: testValid = 1'b0;
 				6'b001_000: testValid = 1'b0;
 				default: testValid = 1'b1;
 			endcase
 		end
 		if (testValid == 1'bx) begin	
 			case ({ain[2],bin[2],cin[2],ain[1],bin[1],cin[1]})
 				6'b100_000: testValid = 1'b0;
 				6'b010_000: testValid = 1'b0;
 				6'b001_000: testValid = 1'b0;
 				default: testValid = 1'b1;
 			endcase
 		end
 		if (testValid == 1'bx) begin	
 			case ({ain[5],bin[5],cin[5],ain[4],bin[4],cin[4]})
 				6'b100_000: testValid = 1'b0;
 				6'b010_000: testValid = 1'b0;
 				6'b001_000: testValid = 1'b0;
 				default: testValid = 1'b1;
 			endcase
 		end
 		if (testValid == 1'bx) begin
 			case ({ain[8],bin[8],cin[8],ain[7],bin[7],cin[7]})
 				6'b100_000: testValid = 1'b0;
 				6'b010_000: testValid = 1'b0;
 				6'b001_000: testValid = 1'b0;
 				default: testValid = 1'b1;
 			endcase	
 		end
		
		if (testValid == 1'bx)
			testValid = 1'b1;
				 

		//for determining output of f
		if ((ain[2] | ain[5] | ain[8]) == 1'b1)
			out[0] = 1'b1;
		else
			out[0] = 1'b0;

		if ((bin[2] | bin[5] | bin[8]) == 1'b1)
			out[1] = 1'b1;
		else
			out[1] = 1'b0;

		if ((cin[2] | cin[5] | cin[8]) == 1'b1)
			out[2] = 1'b1;
		else
			out[2] = 1'b0;

	end
endmodule


module testDec;
	reg [8:0] a;
	reg [8:0] b;
	reg [8:0] c;
	wire [2:0] fout;
	wire val;

	detect_winner dut(a, b, c, fout, val);

	initial begin
		a = 0; b = 0; c = 0; #5;
		$display("%b when we expect 0s", fout);
		$display("%b when we expect 1", val);

		a[2] = 1'b1; #5;
		$display("%b when we expect 001", fout);
		$display("%b when we expect 0", val);

		b[1] = 1'b1; c[0] = 1'b1; #5;
		$display("%b when we expect 1", val);

		b[2] = 1'b1; #5;
		$display("%b when we expect 0", val);

		c[7] = 1'b1; b[2] = 1'b0; #5;
		$display("%b when we expect 0", val);
		$display("%b", c);

	end

endmodule