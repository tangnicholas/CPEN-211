module displayNum(
	input [3:0] inNum,
	output reg [6:0] outHEX);							 		//These are for the 7 digit display
	
	always @(inNum) begin
		case (inNum)
			4'd0: outHEX = 7'b1000000;						//This is for 0
			4'd1: outHEX = 7'b1111001;						//This is for 1 etc.
			4'd2: outHEX = 7'b0100100;
			4'd3: outHEX = 7'b0110000;
			4'd4: outHEX = 7'b0011001;
			4'd5: outHEX = 7'b0010010;
			4'd6: outHEX = 7'b0000010;
			4'd7: outHEX = 7'b1111000;
			4'd8: outHEX = 7'b0000000;
			4'd9: outHEX = 7'b0010000;
			default: outHEX = 7'bxxxxxxx;
		endcase
	end
endmodule