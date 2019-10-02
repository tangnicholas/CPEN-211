`define s1 3'b000
`define s2 3'b001
`define s3 3'b010
`define s4 3'b011
`define s5 3'b100

module changeStates(
	input clk,
	input revWhen0,
	input reset,
	output reg [3:0] outDigit);

	reg [2:0] stateCurrent;

	always @(posedge clk) begin
		if (reset) begin
			stateCurrent = `s1;						//references Prof's SS5 Code, modified.
			outDigit = 4'd5;
		end
		else begin
			case (stateCurrent)
				`s1: if (revWhen0 == 1)
						stateCurrent = `s2;
					else begin
						stateCurrent = `s5;	
					end
				`s2: if (revWhen0 == 1)
						stateCurrent = `s3;
					else begin
						stateCurrent = `s1;	
					end
				`s3: if (revWhen0 == 1)
						stateCurrent = `s4;
					else begin
						stateCurrent = `s2;	
					end
				`s4: if (revWhen0 == 1)
						stateCurrent = `s5;
					else begin
						stateCurrent = `s3;	
					end
				`s5: if (revWhen0 == 1)
						stateCurrent = `s1;
					else begin
						stateCurrent = `s4;	
					end
				default: stateCurrent = 3'bxxx;
			endcase
			
			case (stateCurrent)
				`s1: outDigit = 4'd5;
				`s2: outDigit = 4'd6;
				`s3: outDigit = 4'd7;
				`s4: outDigit = 4'd8;
				`s5: outDigit = 4'd9;
				default: outDigit = 4'bxxxx;
			endcase		
		end
	end
endmodule
