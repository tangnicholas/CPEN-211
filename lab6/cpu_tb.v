//-------------------------------------------------------------------------
module cpu_tb ();
  reg clk, reset, s, load;
  reg [15:0] in;
  wire [15:0] out;
  wire N, V, Z, w;
  reg [15:0] inreg_out;
  
  cpu DUT (.clk(clk), .reset(reset), .s(s), .load(load), .in(in), .out(out), .N(N), .V(V), .Z(Z), .w(w));
  //clock to forever alternate so that we can check all + rising edge cases.
  initial begin
		forever begin
			clk = 0; #5;
			clk = 1; #5;
		end
	end
  
  initial begin 
   // start at WAIT
    reset = 1; s = 0; load = 0; in = 16'bx; #5;
		$display("Output is: %b, %b, %b, %b, we expect x's for all", out, N, V, w);
    
    // TEST 1
  		//MOV1
    reset = 0; s = 1; load = 1; in = 16'b1101000000000111; #10;
   		//MOV2
    reset = 0; s = 1; load = 1; in = 16'b1101000100000010; #10;
    	//ADD 
    reset = 0; s = 1; load = 1; in = 16'b1010000101001000; #20;
    $display("w is %b, we expect 0 becuase we are in the middle of adding.", w);
    	//check
    $display("out is: %b, we expect 0000000000010000", out); 
    $display("N is: %b, we expect 0", N);
    $display ("Z is: %b, we expect 0", Z);
    $display("V is: %b, we expect 0", V);
    $display("w is: %b, we expect 1", w);
    
    //TEST 2 
    	//MOV1
    	//MOV2
    	//AND
    
    
    // Test MOVRd x3
    
    // Test ADD x3
    
    // Test AND x3
    
    // Test CMP x3
    
    // Test MVN x3
    
    
    $stop;
  end
endmodule 




