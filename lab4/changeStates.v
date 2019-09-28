`define s1 4'd0
`define s2 4'd1
`define s3 4'd2
`define s4 4'd3
`define s5 4'd4

module changeStates(
	input clk,
	input revWhen0,
	input reset,
	output reg [3:0] outDigit);

	reg [3:0] stateCurrent;

	always @(posedge clk) begin
		if (reset) begin
			stateCurrent = `s1;						//references Prof's SS5 Code, modified.
			outDigit = `s1;
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
				default: stateCurrent = 4'bxxxx;
			endcase
			
			case (stateCurrent)
				`s1: outDigit = `s1;
				`s2: outDigit = `s2;
				`s3: outDigit = `s3;
				`s4: outDigit = `s4;
				`s5: outDigit = `s5;
				default: outDigit = 4'bxxxx;
			endcase		
		end
	end
endmodule
