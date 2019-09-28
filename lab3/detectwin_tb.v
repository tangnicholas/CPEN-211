module detectwin_tb ();
	reg [8:0] xin, oin ;		//note to use waveWIN.do
	wire [7:0] x_or_o_win ;

	DetectWinner dut (
		.ain(xin) ,
		.bin(oin) ,
		.win_line(x_or_o_win)
	);

	initial begin
		xin = 1'b0; //set inputs all 0s
		oin = 1'b0;

		#10; //add delay to allow for inputs and display to update
		$display ("Output is %b, we expect no wins.", x_or_o_win);
	
		xin[5] = 1'b1;		//win case [1] by x
		xin[4] = 1'b1;
		xin[3] = 1'b1;
		
		#10; //add delay to allow for inputs and display to update
		$display("Output is %b, we expected %b in win case 1 by x", x_or_o_win[1], 1'b1);

		xin[5] = 1'b0;		//win case [0] by o
		xin[4] = 1'b0;
		xin[3] = 1'b0;
		oin[8] = 1'b1;
		oin[7] = 1'b1;
		oin[6] = 1'b1;
		
		#10; //add delay to allow for inputs and display to update
		$display("Output is %b, we expected %b in win case 0 by o", x_or_o_win[0], 1'b1);

		xin[2] = 1'b1;		//win case [7] by x
		xin[4] = 1'b1;
		xin[6] = 1'b1;
		oin[8] = 1'b0;
		oin[7] = 1'b0;
		oin[6] = 1'b0;

		#10; //add delay to allow for inputs and display to update
		$display("Output is %b, we expected %b in win case 7 by x", x_or_o_win[7], 1'b1);


		xin[2] = 1'b1;		//win case [4] by o + messy outputs
		xin[4] = 1'b0;
		xin[6] = 1'b0;
		oin[7] = 1'b1;
		oin[4] = 1'b1;
		oin[1] = 1'b1;
		
		#10; //add delay to allow for inputs and display to update
		$display("Output is %b, we expected %b in win case 4 by o", x_or_o_win[4], 1'b1);

		oin[7] = 1'b1;		//win case [3] by x + almost win by o
		oin[4] = 1'b1;
		oin[1] = 1'b0;
		xin[8] = 1'b1;
		xin[5] = 1'b1;
		xin[2] = 1'b1;

		#10; //add delay to allow for inputs and display to update
		$display("Output is %b, we expected %b in win case 3 by x", x_or_o_win[3], 1'b1);

		oin[7] = 1'b0;		//win case [2] by x
		oin[4] = 1'b0;
		xin[8] = 1'b0;
		xin[5] = 1'b0;
		
		xin[2] = 1'b1;
		xin[1] = 1'b1;
		xin[0] = 1'b1;

		#10; //add delay to allow for inputs and display to update
		$display("Output is %b, we expected %b in win case 2 by x", x_or_o_win[2], 1'b1);

		oin[6] = 1'b1;		//win case [5] by o
		oin[3] = 1'b1;
		oin[0] = 1'b1;
		xin[2] = 1'b0;
		xin[1] = 1'b0;
		xin[0] = 1'b0;

		#10; //add delay to allow for inputs and display to update
		$display("Output is %b, we expected %b in win case 5 by o", x_or_o_win[5], 1'b1);


		oin[6] = 1'b0;		//win case [6]
		oin[3] = 1'b0;
		oin[0] = 1'b0;
		xin[8] = 1'b1;
		xin[4] = 1'b1;
		xin[0] = 1'b1;

		#10; //add delay to allow for inputs and display to update
		$display("Output is %b, we expected %b in win case 6 by x", x_or_o_win[6], 1'b1);

		//resetting
		xin[8] = 1'b0;
		xin[4] = 1'b0;
		xin[0] = 1'b0;

		//lets try non-winning cases
		oin[4] = 1'b1; //just middle is placed by o

		#10;
		$display("Output is %b, we expect no wins", x_or_o_win);

		oin[4] = 1'b0;

		xin[7] = 1'b1;		
		xin[6] = 1'b1;		//almost win case top row.
		xin[5] = 1'b0;
		
		#10;
		$display("Output is %b, we expect no wins", x_or_o_win);
		xin[7] = 1'b0;
		xin[6] = 1'b0;

		xin[4] = 1'b1;		//Just middle is placed by x, 1 other by o.
		oin[5] = 1'b1;
		
		#10;
		$display("Output is %b, we expect no wins", x_or_o_win);

		xin[4] = 1'b0;
		oin[5] = 1'b0;
		
		xin[0] = 1'b1;
		xin[8] = 1'b1;		//All 4 corners are filled, others empty.
		oin[2] = 1'b1;
		oin[6] = 1'b1; 

		#10;
		$display("Output is %b, we expect no wins", x_or_o_win);


	end

endmodule