module shifter(in,shift,sout);
	input [15:0] in;
	input [1:0] shift;
	output reg[15:0] sout;

	reg [15:0] in_temp;
	reg copyIn15;


	always @(shift) begin
		copyIn15 = in[0];

		if (shift === 2'b00) //00, then in = out
			sout = in;
		else if (shift === 2'b01) begin //1 --> shift left
			sout[15] = in[14];
			sout[14] = in[13];
			sout[13] = in[12];
			sout[12] = in[11];
			sout[11] = in[10];
			sout[10] = in[9];
			sout[9] = in[8];
			sout[8] = in[7];
			sout[7] = in[6];
			sout[6] = in[5];
			sout[5] = in[4];
			sout[4] = in[3];
			sout[3] = in[2];
			sout[2] = in[1];
			sout[1] = in[0];
			sout[0] = 0;
		end
		else if (shift === 2'b10 | shift === 2'b11) begin //shift right
			sout[0] = in[1];
			sout[1] = in[2];
			sout[2] = in[3];
			sout[3] = in[4];
			sout[4] = in[5];
			sout[5] = in[6];
			sout[6] = in[7];
			sout[7] = in[8];
			sout[8] = in[9];
			sout[9] = in[10];
			sout[10] = in[11];
			sout[11] = in[12];
			sout[12] = in[13];
			sout[13] = in[14];
			sout[14] = in[15];

			if (shift === 2'b10) //MSB is 0
				sout[15] = 0;
			else
				sout[15] = copyIn15; //MSB is copy of B[15]
		end
		else
			sout = 16'bx;
	end


// fill out the rest
endmodule