module cpu_tb();

reg simclk, simreset, sims, simload, err;
reg [15:0] simin;
wire [15:0] simout;
wire simN, simV, simZ, simw;

//DUT for the cpu, connecting signals using . notation
CPU DUT(.clk(simclk),
           .reset(simreset),
           .in(simin),
           .write_data(simwrite_data),
           .N(simN),
           .V(simV),
           .Z(simZ),
        	 .w(simw),
        
        .mem_addr(mem_addr),
        .mem_cmd(mem_addr),
        .read_data(mem_addr);


//forever loop for clk
initial begin
    simclk = 1'b0; #5;
    forever begin
    simclk = 1'b1; #5;
    simclk = 1'b0; #5;
    end
end

//testbench cases
initial begin 
			err = 1'b0;
      
  //Testing MOV Rn,#<im8>, should take 3 clk cycles
    $display("Testing MOV R0, #ABCD");
  //Test 1: moving postive number into R0
    simin = 16'b110_10_000_00000101; // MOV R0, #ABCD
  @(posedge DUT.DP.PC or negedge DUT.DP.PC);
    if(DUT.DP.REGFILE.R0 !== 9'd5) begin
     $display("value was not written correctly written into register Expected %b, got %b",
     9'd5, DUT.DP.REGFILE.R0);
     err = 1'b1;
     end 
        
    //Testing LDR, should take 10 clk cycles
      $display("Testing LDR R1, R0");
    //load the LDR instruction
      simin = 16'b011_00_000_001_00000; // LDR R1, R0
     @(posedge DUT.DP.PC or negedge DUT.DP.PC);
      //check if value in memory is saved in R1
  		if(DUT.DP.REGFILE.R1 !== 0'hABCD) begin
      $display("value was not written correctly written into register Expected %b, got %b",
      0'hABCD, DUT.DP.REGFILE.R1);
      err = 1'b1;
      end
      
      //Testing MOV Rn,#<im8>, should take 3 clk cycles   
      $display("Testing  MOV R2, #0000");
      simin = 16'b1101001000000110; // MOV R2, #0x0000
   		 @(posedge DUT.DP.PC or negedge DUT.DP.PC);
 			if(DUT.DP.REGFILE.R2 !== 9'd6) begin
     	$display("value was not written correctly written into register Expected %b, got %b",
     	9'd6, DUT.DP.REGFILE.R2);
     	err = 1'b1;
    	end 
      
      //Testing STR, should take 10 clk cycles   
       $display("Testing STR R1,[R2]");
    	//load the STR instruction
      simin = 16'b1000001000100000; // STR R1,[R2]
      @(posedge DUT.DP.PC or negedge DUT.DP.PC);
      //check if the contents of R1 is  read from the register file and output to datapath_out --> write_data
  		if(DUT.DP.write_data !== 0'hABCD) begin
      $display("value was not written correctly written into register Expected %b, got %b",
    	0'hABCD , DUT.DP.write_data);
      err = 1'b1;
      end
      
      //Testing HALT
      $display("Testing HALT");
      simin = 16'b1110000000000000; //HALT
      @(posedge DUT.DP.PC or negedge DUT.DP.PC);
      //check if the state is the halt stage 
      if(DUT.FSM.state !== 5'b01111) begin
      $display("HALT did not work!");
      err = 1'b1;
      end 
      
  
 //6th test:  16'b101_01_011_110_01_101
    
    end 
    if (~err) $display("INTERFACE OK");
    $stop; 
  
endmodule
