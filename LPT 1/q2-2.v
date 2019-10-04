module q2_tb;
	reg [2:0] a;
	reg b, c;

	initial begin
		a = 3'b101;
		b = 1'b1;
		c = 1'b1;
		#5;

		c = 1'b0;
		#5;

		a = 3'b010;
		b = 1'b0;
		#5;

		c = 1'b1;
		#5;

		b = 1'b1;
		c = 1'b0;
		#5;

		b = 1'b0;
		#5;

		a = 3'b010;
		b = 1'b1;
		c = 1'b1;
		#5;

		c = 1'b0;
		#5;
	end

endmodule