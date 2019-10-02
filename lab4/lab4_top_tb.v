`define s1 3'b000
`define s2 3'b001
`define s3 3'b010
`define s4 3'b011
`define s5 3'b100

module lab4_top_tb;
	reg clk, rev, reset, err;
	wire [3:0] outDigit;
	reg [3:0] KEY;
	reg [9:0] SW;
	wire[6:0] HEX0;

	changeStates dut(.clk(clk), .revWhen0(rev), .reset(reset), .outDigit(outDigit));
	lab4_top toplevdut(.SW(SW), .KEY(~KEY), .HEX0(HEX0));

	//task to check state and outputs (compares them)
	task checkInOut;
		input [2:0] expected_state;
		input [3:0] expected_output;

	begin
		if (lab4_top_tb.dut.stateCurrent !== expected_state) begin
			$display("ERROR ** state is %b, expected $b", 
				lab4_top_tb.dut.stateCurrent, expected_state);
		err = 1'b1;
		end
		if (outDigit != expected_output)begin
			$display("ERROR ** output is %b, expected $b", 
				lab4_top_tb.dut.outDigit, expected_output);
			err = 1'b1;
		end
	end
	endtask

	//clock to forever alternate so that we can check all + rising edge cases.
	initial begin
		clk = 0; #5;
		
		forever begin
			clk = 1; #5;
			clk = 0; #5;
		end
	end

	initial begin
		reset = 1'b1; rev = 1'b1; err = 1'b0;	//reset button KEY[1] pressed (should show 5 as default)
		#10;
		checkInOut(`s1, 4'd5);
		reset = 1'b0;
		
		$display("checking s1 -> s2"); 		//following 4 are in + direction (reverse switch off)
		rev = 1'b1; #10;
		checkInOut(`s2, 4'd6);

		$display("checking s2 -> s3");		//Note that these are all for FSM (changeStates)
		rev = 1'b1; #10;
		checkInOut(`s3, 4'd7);

		$display("checking s3 -> s4");
		rev = 1'b1; #10;
		checkInOut(`s4, 4'd8);

		$display("checking s4 -> s5");
		rev = 1'b1; #10;
		checkInOut(`s5, 4'd9);

		reset = 1'b1; rev = 1'b0; #10; reset = 1'b0;

		$display("checking s1 -> s5");		//following to check reverse cases. (reverse switch on)
		rev = 1'b0; #10;
		checkInOut(`s5, 4'd9);

		$display("checking s5 -> s4");
		rev = 1'b0; #10;
		checkInOut(`s4, 4'd8);

		$display("checking s4 -> s3");
		rev = 1'b0; #10;
		checkInOut(`s3, 4'd7);

		$display("checking s3 -> s2");
		rev = 1'b0; #10;
		checkInOut(`s2, 4'd6);

		$display("checking s2 -> s1");
		rev = 1'b0; #10;
		checkInOut(`s1, 4'd5);

		if (~err) 
			$display("Pass.");
		else 
			$display("Oh no! Something went wrong here!");
	
		KEY[0] = 1; KEY[1] = 1; SW = 10'b000000001; #10; //both reset and clk keys are pressed. (This and below are for top level I/O)
		$display ("We expect 7 segment display to show %b (resetted --> 5), output is %b", 7'b0010010, HEX0);
		
		KEY = 4'b0000; #10; //clk and reset keys are not pressed. Should stay same
		$display ("We expect 7 segment display to show %b (5 inverted), output is %b", 7'b0010010, HEX0);

		KEY[0] = 1; SW = 10'b00000000; #10;  //clk is pressed while switch is off (reverse mode)
		$display ("We expect 7 segment display to show %b (9 inverted), output is %b", 7'b0010000, HEX0);

		KEY[0] = 0; #5; KEY[0] = 1; #5; //same thing, clk is pressed again.
		$display ("We expect 7 segment display to show %b (8 inverted), output is %b", 7'b0000000, HEX0);

		KEY[0] = 0; SW = 10'b00000001; #10; KEY[0] = 1; #5; //switch is now on (not reversed), clk is pressed.
		$display ("We expect 7 segment display to show %b (9 inverted), output is %b", 7'b0010000, HEX0);
		$stop;
	end
	
endmodule