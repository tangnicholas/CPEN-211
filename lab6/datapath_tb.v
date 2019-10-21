module datapath_tb;   
	
	reg vsel ;
	reg loada;
	reg loadb;
	reg asel ;
	reg bsel ;
	reg loadc;
	reg loads;
  
	reg clk;
	reg write;
	reg [15:0] datapath_in;
	reg [2:0] readnum;
	reg [2:0] writenum;
 
	reg [1:0] ALUop; 
	wire Z_out;

	reg [1:0] shift;
  
  
	wire [15:0] datapath_out;

	//to check state of R0, R1, and R2
	wire [15:0] R0 = DUT.REGFILE.R0;
	wire [15:0] R1 = DUT.REGFILE.R1;
	wire [15:0] R2 = DUT.REGFILE.R2;
	reg err;
  
	datapath DUT( .clk(clk), .readnum(readnum), .vsel(vsel), .loada(loada), .loadb(loadb), .shift(shift), .asel(asel), .bsel(bsel), .ALUop(ALUop), .loadc(loadc), .loads(loads), .writenum(writenum), .write(write), .datapath_in(datapath_in), .Z_out(Z_out), .datapath_out(datapath_out));
  
  
  //clock to forever alternate so that we can check all + rising edge cases.
	initial begin
		clk = 0; #5;
		forever begin
			clk = 1; #5;
			clk = 0; #5;
		end
	end

	initial begin
		//set everything to 0 initially
    	datapath_in = 0; write = 0; vsel=0; loada=0; loadb=0; asel=0; bsel=0; loadc=0; loads=0;
    	readnum = 0; writenum=0; shift = 0; ALUop=0; err = 0;
    	#10; $display("%b", R0); //should display x's as nothing is stored here.

      
    	writenum = 3'b000; write = 1'b1; datapath_in = 16'b0000000000000111; readnum = 3'b000; vsel = 1; //makes sure 7 is in B
		#10; $display("%b", R0);
		if (R0 !== 16'b0000000000000111)
    		err = 1'b1;
      
      	writenum = 3'b001; datapath_in = 16'b0000000000000010; readnum = 3'b001; vsel = 1;//makes sure 2 is in A
		#10; $display("%b", R1);
		if (R1 !== 16'b0000000000000010)
    		err = 1'b1;
      
      
      	// step 1 - load contents of R0 into B reg (code referenced from autograder)
    	readnum = 3'd0; 
    	loadb = 1'b1;
   		#10; // wait for clock
    	loadb = 1'b0; // done loading B, set loadb to zero so don't overwrite A 

    	// step 2 - load contents of R1 into A reg 
    	readnum = 3'd1; 
    	loada = 1'b1;
    	#10; // wait for clock
    	loada = 1'b0;

    	// step 3 - perform addition of contents of A and B registers (and shift B left), load into C
    	shift = 2'b01;
    	asel = 1'b0;
    	bsel = 1'b0;
    	ALUop = 2'b00;
    	loadc = 1'b1;
    	loads = 1'b1;
    	#10; // wait for clock
    	loadc = 1'b0;
    	loads = 1'b0;

    	// step 4 - store contents of C into R2
    	write = 1'b1;
    	writenum = 3'd2;
    	vsel = 1'b0;
    	#10;
    	write = 0;

    	$display("%b", R2);
    	if (R2 !== 16'b0000000000010000)
    		err = 1'b1;
    


    	if (err === 1'b1) 
    		$display("There is an error in this tb.");
    	else
    		$display("No errors to see here today.");
    	

      	$stop;
		 //this means, take the absolute number 7 and store it in R0
		 //this means, take the absolute number 2 and store it in R1
		 //this means R2 = R1 + (R0 shifted left by 1) = 2+14=16
    
    
    
    end
  
endmodule 
  