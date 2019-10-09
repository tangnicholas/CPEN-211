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
	wire [15:0] data_out;
	reg [15:0] data_in;
 
	reg [1:0] ALUop; 
	wire [15:0] out; 
	wire Z_out;
	wire Z;

	reg [15:0] in;
	reg [1:0] shift;
	wire[15:0] sout;
  
  //for between A and asel
	reg [15:0] amidout;
	wire [15:0] datapath_out;
  
	datapath dutdata( .clk(clk), .readnum(readnum), .vsel(vsel), .loada(loada), .loadb(loadb), .shift(shift), .asel(asel), .bsel(bsel), .ALUop(ALUop), .loadc(loadc), .loads(loads), .writenum(writenum), .write(write), .datapath_in(datapath_in), .Z_out(Z_out), .datapath_out(datapath_out));
  
  
  //clock to forever alternate so that we can check all + rising edge cases.
	initial begin
		clk = 0; #10;
		forever begin
			clk = 1; #10;
			clk = 0; #10;
		end
	end

	initial begin
    	write = 0; shift = 0; vsel = 1;
    	#10;
      
    	writenum = 3'b000; write = 1'b1; datapath_in = 16'b0000000010000000; readnum = 3'b000; loadb = 1'b1; //makes sure 7 is in B
		#20; //$display("%b", in); 
      
      	writenum = 3'b001; write = 1'b1; datapath_in = 16'b0000000000000100; readnum = 3'b001; loada = 1'b1; //makes sure 2 is in A
		#20;// $display("%b", amidout); 
      
      	write = 1'b0; shift = 1'b01; bsel = 1'b0; asel = 1'b0; ALUop = 2'b00; //check out (Should be right no.)
      	#20;// $display("%b", out);
      	
      	write = 1'b1; writenum = 3'b010; vsel = 1'b0; readnum = 3'b010; //Check R2
      	#20; //$display("%b", datapath_out);
      
    	
    
      
		 //this means, take the absolute number 7 and store it in R0
		 //this means, take the absolute number 2 and store it in R1
		 //this means R2 = R1 + (R0 shifted left by 1) = 2+14=16
    
    
    
    end
  
endmodule 
  