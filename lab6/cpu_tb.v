module cpu_tb ();
  reg clk, reset, s, load;
  reg [15:0] in;
  wire [15:0] out;
  wire N, V, Z, w;

  //to check state of R0, R1, and R2
  wire [15:0] R0 = DUT.DP.REGFILE.R0;
  wire [15:0] R1 = DUT.DP.REGFILE.R1;
  wire [15:0] R2 = DUT.DP.REGFILE.R2;
  wire [15:0] R3 = DUT.DP.REGFILE.R3;
  wire [15:0] R4 = DUT.DP.REGFILE.R4;
  wire [15:0] R5 = DUT.DP.REGFILE.R5;
  wire [15:0] R6 = DUT.DP.REGFILE.R6;
  wire [15:0] R7 = DUT.DP.REGFILE.R7;
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
    
    // TEST 1 (7<<1 + 2 = 16)
      //MOV1 (Takes 2 clk cycles)
    reset = 0; #10;
    load = 1; in = 16'b1101000000000111; #10; s = 1; load = 0; #10; s=0; #10;
    $display("%b and it should be 7", R0);
    if(R0 !== 16'd7)
    	err = 1; 
    //MOV2 (move 2 into R1)
    reset = 0; load = 1; in = 16'b1101000100000010; #10; s = 1; load = 0; #10; s=0; #10;
    $display("%b and it should be 2", R1);
 	if(R1 !== 16'd2)
    	err = 1;
   //ADD (14+2 = 16)
    reset = 0; load = 1; in = 16'b10100001010_01000; #10; s = 1; load = 0; #10; s=0; #10; //stores in r2
    $display("w is %b, we expect 0 becuase we are in the middle of adding.", w);
    #60;
    //check
    $display("out is: %b, we expect 0000000000010000", out);
    if(R2 !== 16'd16)
    	err = 1;
    //AND 
    s=0; #10;
    load=1; in = 16'b101_10_000_011_00_001; #10; s=1; load=0; #10; s=0; #40;
    $display("R3 is %b, should be 2", R3);
    if(R3 !== 16'd2)
    	err = 1;
    //CMP (7-2 =5)
    s=0; #10;
    load=1; in = 16'b101_01_000_000_00_001; #10; s=1; load=0; #10; s=0; #40;
    $display("out = %b, should be 5", out);
    $display("Z V N w should be 0, 0, 0, 1; %b %b %b %b", Z, V, N, w);
    if (Z !== 1'b0 | V !== 1'b0 | w !== 1'b1 | N !== 1'b0)
        err = 1'b1;
    //MVN 
    s=0; #10;
    load=1; in=16'b101_11_000_100_00_000; #10; s=1; load=0; #10; s=0; #30;
    $display("R4 is %b, should be ~2 = -3", R4);
    if(R4 !== 16'b1111111111111101)
    	err = 1;
    
    

    //MOV
    s=0; #10;
    load = 1; in = 16'b110_10_000_00000011; #10; s = 1; load = 0; #10; s=0; #20;
    $display("R0 should now be 3, %b", R0);
    if(R0 !== 16'd3)
    	err = 1;
    //ADD
    s=0; #10;
    load = 1; in = 16'b101_10_000_010_10_001; #10; s = 1; load = 0; #10; s=0; #40;
     $display("R2 should now be 1, %b", R2);
     if(R2 !== 16'd1)
    	err = 1;
    //AND
    s=0; #10;
    load=1; in = 16'b101_10_000_011_00_001; #10; s=1; load=0; #10; s=0; #60;
    $display("R3 is %b, should be 2", R3);
    if(R3 !== 16'd2)
    	err = 1;
    //CMP (r0-r1 = 3-2 = 1)
    s=0; #10;
    load=1; in = 16'b101_01_010_000_00_000; #10; s=1; load=0; #10; s=0; #40;
    $display("out = %b, should be -1", out);
    $display("Z V N w should be 0, 0, 1, 1; %b %b %b %b", Z, V, N, w);
    if (Z !== 1'b0 | V !== 1'b0 | N !== 1'b1 | w !== 1'b1)
        err = 1'b1;

    //MVN (R7 = ~2)
    s=0; #10;
    load=1; in=16'b101_11_000_111_00_011; #10; s=1; load=0; #10; s=0; #70;
    $display("R7 is %b, should be ~2", R7);
    if(R7 !== 16'b1111111111111100)
    	err = 1;



    //MOV (r5 = 127)
    s=0; #10;
    load=1; in=16'b110_10_101_01111111; #10; s=1; load=0; #10; s=0; #20;
    $display("R5 is %b, should be 127", R5);
    if(R5 !== 16'd127)
    	err = 1;
    // ADD
    s=0; #10;
    load=1; in=16'b101_00_101_110_00_100; #10; s=1; load=0; #10; s=0; #50;
    $display("R6 is %b, should be 127-3=124", R6);
    if(R6 !== 16'd124)
    	err = 1;
    // CMP
    s=0; #10;
    load=1; in=16'b101_01_010_000_00_010; #10; s=1; load=0; #10; s=0; #30;
    $display("out is %b, should be 1-(1) = 0", out);
    $display("Z V N w should be 1, 0, 0, 1; %b %b %b %b", Z, V, N, w);
    if (Z !== 1'b1 | V !== 1'b0 | N !== 0 | w !== 1 )
        err = 1'b1;
    //AND
    s=0; #10;
    load=1; in=16'b101_10_100_101_00_101; #10; s=1; load=0; #10; s=0; #50;
    $display("R5 is %b, should be 1111101", R5);
    if(R5 !== 16'b0000000001111101)
    	err = 1;
    //MVN (~127 or -128)
    s=0; #10;
    load=1; in=16'b101_11_000_111_10_101; #10; s=1; load=0; #10; s=0; #50;
    $display("R7 is %b, should be ~127", R7);
    if(R7 !== 16'b1111111111000000)
    	err = 1;


    if (err === 1'b1) begin
      $display("GO BACK AND CHECK WORK.");
    end
    else begin
      $display("YOU DID IT. NOW GO ENJOY LIFE.");
    end

    $stop;
  end
endmodule 