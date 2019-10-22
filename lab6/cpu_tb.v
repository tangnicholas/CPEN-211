//-------------------------------------------------------------------------
module cpu_tb ();
  reg clk, reset, s, load;
  reg [15:0] in;
  wire [15:0] out;
  wire N, V, Z, w;

  //to check state of R0, R1, and R2
  wire [15:0] R0 = DUT.DP.REGFILE.R0;
  wire [15:0] R1 = DUT.DP.REGFILE.R1;
  wire [15:0] R2 = DUT.DP.REGFILE.R2;
  reg err;
  
  cpu DUT(.clk(clk), .reset(reset), .s(s), .load(load), .in(in), .out(out), .N(N), .V(V), .Z(Z), .w(w));
  //clock to forever alternate so that we can check all + rising edge cases.
  initial begin
    clk = 0; #5;
    forever begin
      clk = 1; #5;
      clk = 0; #5;
    end
  end
  
  initial begin 
   // start at WAIT
    reset = 1; s = 0; load = 0; in = 16'bx; err = 0; #5;
    $display("Output is: %b, %b, %b, %b, we expect x's for all", out, N, V, w);
    
    // TEST 1
      //MOV1 (Takes 2 clk cycles)
    reset = 0; s = 1; load = 1; in = 16'b1101000000000111; #10; load = 0; #10;

    $display("%b and it should be 7", R0);
    if (R0 !== 16'b0000000000000111)
        err = 1'b1;

      //MOV2
    reset = 0; s = 1; load = 1; in = 16'b1101000100000010; #10; load = 0; #10;

    $display("%b and it should be 2", R1);
    if (R1 !== 16'b0000000000000010)
        err = 1'b1;
      
      //ADD 
    reset = 0; s = 1; load = 1; in = 16'b1010000101001000; #10; load = 0;
    $display("w is %b, we expect 0 becuase we are in the middle of adding.", w);
    
    #70;

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



