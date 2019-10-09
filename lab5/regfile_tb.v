module regfile_tb ();

  //declare signals to test 
  reg clk;
  reg write;
  reg [15:0] data_in;
  reg [2:0] readnum;
  reg [2:0] writenum;
  wire [15:0] data_out;
  reg [2:0] bin;
  wire [7:0] OH;

  reg err;

  ///instantiating the modules to test
  regfile DUT(.data_in(data_in), .writenum(writenum), .write(write), .readnum(readnum), .clk(clk), .data_out(data_out));
  decoder decodeDUT(.binary(bin), .oneHotCode(OH));
  
  //clock to forever alternate so that we can check all + rising edge cases.
  initial begin
    clk = 0; #5;
    
    forever begin
      clk = 1; #5;
      clk = 0; #5;
    end
  end
  
  //test the register file for the appropriate output given various inputs
  initial begin
    err = 1'b0; write = 1'b0; #10;
    
    write = 1'b1; //r0 initialized to be data_in (0101010101010101), output points same num, should read as such
    data_in = 16'b0101010101010101;
    readnum = 3'b000;
    writenum = 3'b000; #10;
    $display("We expect data_out from r0 to be %b, shows %b", 16'b0101010101010101, data_out);
    if (data_out !== 16'b0101010101010101)
      err = 1'b1;
    
    write = 1'b1; //r4 initialized to be data_in (0010100111000010), thus should show as such
    data_in = 16'b0010100111000010;
    readnum = 3'b100;
    writenum = 3'b100; #10;
    $display("We expect data_out from r4 to be %b, shows %b", 16'b0010100111000010, data_out);
    if (data_out !== 16'b0010100111000010)
      err = 1'b1;
    
    write = 1'b1; //r3 not initialized, so should print x's
    data_in = 16'b1111111111111111;
    readnum = 3'b011;
    writenum = 3'b101; #10;
    $display("We expect data_out from r3 to be %b (note we wrote to r5 instead), shows %b", 16'bx, data_out);
    if (data_out !== 16'bx)
      err = 1'b1;

    write = 1'b0; //r4 should not deviate from earlier because writenum != readnum
    data_in = 16'b0101010101010101;
    readnum = 3'b100;
    writenum = 3'b100; #10;
    $display("We expect data_out from r4 to be %b (changed data_in to be what r0 is, but write is now 0), shows %b", 16'b0010100111000010, data_out);
    if (data_out !== 16'b0010100111000010)
      err = 1'b1;
  
    //test that the decoder module works
    //test #1
    bin = 3'b001; #10;
    if (OH !== 8'b00000010)
      err = 1'b1;
    $display("Output is %b, we expect %b", OH, 8'b00000010);  
     
    //test #2
    bin = 3'b111; #10;
    if (OH !== 8'b10000000)
      err = 1'b1;
    $display("Output is %b, we expect %b", OH, 8'b10000000); 
   
    //test #3
    bin = 3'b000; #10;
     if (OH !== 8'b00000001)
      err = 1'b1;
    $display("Output is %b, we expect %b", OH, 8'b00000001);
    
    //Your regfile_tb must contain a signal err that is set to 1 if an error is found and stays at 1 thereafter
    if (~err) 
      $display("Passed all our tests.");
    else 
      $display("Oh no! Something went wrong here!");
    

    $stop;
  end
  
endmodule

