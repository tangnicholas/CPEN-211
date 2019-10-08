module shifter_tb;
	reg [15:0] in;
	reg [1:0] shift;
	wire [15:0] sout;

	reg err;

	shifter dut(.in(in), .shift(shift), .sout(sout));

	initial begin
		err = 1'b0;
		in = 16'b1001010000000001;
		
		#10;
		$display("checking shift not initialized");
		if (sout != 16'bx)
			err = 1'b1;

		shift = 2'b00;
		#10;
		$display("checking shift = 00");
		if (sout != 16'b1001010000000001)
			err = 1'b1;

		shift = 2'b01;
		#10;
		$display("checking shift = 01");
		if (sout != 16'b0010100000000010)
			err = 1'b1;

		shift = 2'b10;
		#10;
		$display("checking shift = 10");
		if (sout != 16'b0100101000000000)
			err = 1'b1;

		shift = 2'b11;
		#10;
		$display("checking shift = 11");
		if (sout != 16'b1100101000000000)
			err = 1'b1;

		if (err === 1'b1)
			$display("Oh no something went wrong");
		else
			$display("No problems here.");

	end

endmodule