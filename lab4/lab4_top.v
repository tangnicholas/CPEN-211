module lab4_top(SW,KEY,HEX0);
	input [9:0] SW;
	input [3:0] KEY;
	output [6:0] HEX0;

	wire [3:0] digittoDisplay;								//number to print in decimal
	wire [6:0] outHEXnum;									//number in binary to print
	
	changeStates state ( .clk(~KEY[0]), .revWhen0(SW), 
  				.outDigit(digittoDisplay), .reset(~KEY[1]) );			//Changes the state, and outputs correct next value.
	displayNum numberConverter ( .inNum(digittoDisplay), .outHEX(outHEXnum) );		//Makes the input num to a displayable 7 bit code
	
	assign HEX0 = outHEXnum;								//makes LED display the wanted number


endmodule