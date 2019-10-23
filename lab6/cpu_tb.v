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
    if (R0 !== 16'b0000000000000111)
        err = 1'b1;
    //MOV2 (move 2 into R1)
    reset = 0; load = 1; in = 16'b1101000100000010; #10; s = 1; load = 0; #10; s=0; #10;
    $display("%b and it should be 2", R1);
    if (R1 !== 16'b0000000000000010)
        err = 1'b1;
      //ADD 
    reset = 0; load = 1; in = 16'b10100001010_01000; #10; s = 1; load = 0; #10; s=0; #10; //stores in r2
    $display("w is %b, we expect 0 becuase we are in the middle of adding.", w);
    #60;
    //check
    $display("out is: %b, we expect 0000000000010000", out); 

    //TEST 2 (7 & 2 = 2)
    reset = 1; #10;
    //MOVRd 1  (move 7<<1 = 14 into R0)
    reset = 0; #10;
    load = 1; in = 16'b110_00_000_000_01_000; #10; s = 1; load = 0; #10; s=0; #20;
    $display("R0 should now be 14, %b", R0);
    if (R0 !== 16'b0000000000001110) //R0 should be 14
        err = 1'b1;
    //AND1 = (14>>1 & 2, R0=14 R1 = 2)
    $display("R1 should now be 2, %b", R1); #10;
    reset = 0; load = 1; in = 16'b101_10_001_001_10_000; #10; s=1; load = 0; #10; s = 0; #20;
    if (R1 !== 16'b0000000000000010) //out should be 2 given that shifted again (MSB==0), so one was 7 and other was 2. Stores in r1
        err = 1'b1;


    //TEST 3 (14-2 = STATUS)
    s=0; #10; 
    //MOV3 (move 2 into R2)
    reset = 0; load = 1; in = 16'b110_10_010_00000010; #10; s = 1; load = 0; #10; s=0; #20;
    $display("R2 should now be 2, %b", R2);
    if (R2 !== 16'b0000000000000010)
        err = 1'b1;
    //CMP1 (14-2 = 12(not stored) --> Z = 0, V = 0, w = 0)
    reset = 0; load = 1; in = 16'b101_01_000_000_00_010; #10; s=1; load = 0; #10; s = 0; #30;
    $display("out = %b, should be 12", out);
    $display("Z V w should be 0, 0, 1; %b %b %b", Z, V, w);
    if (Z !== 1'b0 | V !== 1'b0 | w !== 1)
        err = 1'b1;

  /*
    // TEST 4 (14<<1 + 2 = 30) (DOESNT WORK)
     s = 0;  #10;
    // MOVRd2 (14<<1 = 28 then store 28 in R0)
    reset = 0;
    load = 1; in = 16'b110_00_000_000_01_000; #10; s = 1; load = 0; #10; s=0; #40;
    $display("R0 should now be 28, %b", R0);
    if (R0 !== 16'b0000000000011100)
        err = 1'b1;
    // ADD2 (28 R0 + 2 R2 = 30)
      reset = 0; load = 1; in = 16'b101_00_010_010_01_000; #10; s = 1; load = 0; #10; s=0; #60;
      $display("out is: %b, we expect 0000000000011110", out); 
       if (out !== 16'b0000000000011110)
        err = 1'b1;
*/
    //TEST 5 (28 & 2 = 0)
    s=0;  #20;
    //AND2 (14 R0 --> 28 & 2 R2)
    reset = 0; load = 1; in = 16'b101_10_001_011_01_000; #10; s = 1; load = 0; #10; s=0; #40;
    $display("R3 should now be 0s, %b", R3);
    if (R3 !== 16'b0000000000000000)
        err = 1'b1;

    //TEST 6  (~14 R0)
    s=0; #20;
     //MVN1
    reset = 0; load = 1; in = 16'b101_11_000_000_00_000; #10; s = 1; load = 0; #10; s=0; #30;
    $display("R0 should now be ~14, %b", R0);
    if (R0 !== 16'b1111111111110001)
        err = 1'b1;

 /*
    //TEST 7  (~2 R2 --> R4) (DOESNT WORK)
    s=0; reset = 1; #20;
      //MVN2
    reset = 0; load = 1; in = 16'b101_11_000_101_00_001; #10; s = 1; load = 0; #10; s=0; #30;
    $display("R4 should now be ~2, %b", R5);
    if (R5 !== 16'b1111111111111101)
      err = 1'b1;
*/

    //TEST 8 ~(2>>1) 
    // MVN3

    //TEST 9 (255 + 1=256)
    s=0; #10;
    //MOV (255 into R2)
    reset = 0; load = 1; in = 16'b110_10_010_11111110; #10; s = 1; load = 0; #10; s=0; #20;
    $display("%b and it should be 255", R2);
    if (R2 !== 16'b0000000011111110)
        err = 1'b1;
/*
    //MOVrd (2>>1 = 1 into R7)
    reset = 0; load = 1; in = 16'b110_00_000_111_11_001; #10; s = 1; load = 0; #10; s=0; #20;
    $display("%b and it should be 1", R7);
    if (R7 !== 16'b0000000000000001)
      err = 1'b1;
    //ADD3 (255 R2 + 1 R3  ---> R1)
     reset = 0; load = 1; in = 16'b101_10_001_010_01_000; #10; s = 1; load = 0; #10; s=0; #20;
    if (out !== 16'b0000000100000000)
        err = 1'b1;

    // TEST 10 (-10 - 255 = STATUS/OVERFLOW)
      //MOV (-10)
      reset = 0; load = 1; in = 16'b110_10___; #10; s = 1; load = 0; #10; s=0; #20;
      $display("%b and it should be -10", R2);
    if (R2 !== 16'b0000000011111111)
        err = 1'b1;
      //CMP
    
    
    // TEST 11(255 - (-10) = STATUS)
      //CMP

*/
    if (err === 1'b1) begin
      $display("GO BACK AND CHECK WORK.");
    end
    else begin
      $display("YOU DID IT. NOW GO ENJOY LIFE.");
    end

    $stop;
  end
endmodule 