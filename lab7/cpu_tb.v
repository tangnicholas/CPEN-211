module cpu_tb();

reg simclk, simreset, sims, simload, err;
reg [15:0] simin;
wire [15:0] simout;
wire simN, simV, simZ, simw;

//DUT for the cpu, connecting signals using . notation
cpu DUT(.clk(simclk),
           .reset(simreset),
           .in(simin),
           .write_data(simwrite_data),
           .N(simN),
           .V(simV),
           .Z(simZ),
        	 .w(simw),
        
           .mem_addr,
           mem_cmd,
           read_data);


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
    #10; //wait until next falling edge of clock 
    if(DUT.DP.REGFILE.R0 !== 12'hABCD) begin
     $display("value was not written correctly written into register Expected %b, got %b",
     12'hABCD, DUT.DP.REGFILE.R0);
     err = 1'b1;
     end 
        
    //Testing LDR, should take 10 clk cycles
      $display("Testing LDR R1, R0");
    //load the LDR instruction
      simin = 16'b011_00_000_001_00000; // LDR R1, R0
      #10; 
      //check if value in memory is saved in R1
      if(DUT.DP.REGFILE.R1 !== /* address of R0*/) begin
      $display("value was not written correctly written into register Expected %b, got %b",
      /* address of R0*/ , DUT.DP.REGFILE.R0);
      err = 1'b1;
      end
      
      //Testing MOV Rn,#<im8>, should take 3 clk cycles   
      $display("Testing  MOV R2, #0000 ");
      simin = 16'b1101001000000110; // MOV R2, #0x0000
   		#10; //wait until next falling edge of clock 
      if(DUT.DP.REGFILE.R2 !== 12'h0000) begin
     	$display("value was not written correctly written into register Expected %b, got %b",
     	12'h0000, DUT.DP.REGFILE.R2);
     	err = 1'b1;
    	end 
      
      //Testing STR, should take 10 clk cycles   
       $display("Testing STR R1,[R2]");
    	//load the STR instruction
      simin = 16'b1000001000100000; // STR R1,[R2]
      #10; 
      //check if the contents of R1 is  read from the register file and output to datapath_out --> write_data
      if(DUT.DP.write_data !== /* content of R1 = address of R0*/) begin
      $display("value was not written correctly written into register Expected %b, got %b",
      /*content of R1 = address of R0*/ , DUT.DP.write_data);
      err = 1'b1;
      end
      
      //Testing HALT
      $display("Testing HALT");
      simin = 16'b1110000000000000; //HALT
      #10;
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
