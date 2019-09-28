// 

module gameplay_tb ();
	reg[8:0] SIM_ain, SIM_bin;
	wire [8:0] SIM_bout;

	PlayAdjacentEdge dut(.ain(SIM_ain), .bin(SIM_bin), .bout(SIM_bout)) ;
	
	initial begin 
	// 
	SIM_ain = 0;
	SIM_bin = 0; 
	#20;
	
	//
	SIM_ain[0] = 1;		//top left and bottom right filled
	SIM_ain[8] = 1;
	SIM_bin[4] = 1;
	//
	#50;
	$display("The output is %b, we expect %b", SIM_bout[5], 1'b1);

	//
	SIM_ain = 0;
	SIM_bin = 0; 
	#20;

	//
	SIM_ain[2] = 1;		//top right and bottom left filled
	SIM_ain[6] = 1;
	SIM_bin[4] = 1;
	//
	#50;
	$display("The output is %b, we expect %b", SIM_bout[5], 1'b1);

	//
	SIM_ain = 0;
	SIM_bin = 0;
	#20;

	//
	SIM_ain[3] = 1;		//
	SIM_ain[0] = 1;
	SIM_bin[4] = 1;
	//
	#50;
	$display("The output is %b, we expect %b", SIM_bout[5], 1'b0);

	end
endmodule
