module lab4_top(SW,KEY,HEX0);
	input [9:0] SW;
	input [3:0] KEY;
	output [6:0] HEX0;

	wire [3:0] digittoDisplay;								//number to print in decimal
	wire [6:0] outHEXnum;									//number in binary to print
	
	changeStates state ( .clk(~KEY[0]), .revWhen0(SW), 
  				.outDigit(digittoDisplay), .reset(~KEY[1]) );			//Changes the state, and outputs correct next value.
	displayNum numberConverter ( .inNum(digittoDisplay), .outHEX(outHEXnum) );		//Makes the input num to a displayable 7 bit code
	
	assign HEX0[0] = outHEXnum[0];								//makes LED display the wanted number
	assign HEX0[1] = outHEXnum[1];
	assign HEX0[2] = outHEXnum[2];
	assign HEX0[3] = outHEXnum[3];
	assign HEX0[4] = outHEXnum[4];
	assign HEX0[5] = outHEXnum[5];
	assign HEX0[6] = outHEXnum[6];

endmodule

/*
		case({ array, stateChange, reset})
			default: output = num0;					//This is for all cases where the output is num0, 
													//including when reset is pressed. So rest of the cases is when reset ISN't pressed
			9'b000001_01_0: output = num1;
			9'b000010_01_0: output = num2;
			9'b000100_01_0: output = num3;
			9'b001000: output = num4;
		endcase			
*/