module regfile_tb;

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

  ///instantiating the regfile module
  regfile dut(.data_in(data_in), .writenum(writenum), .write(write), .readnum(readnum), .clk(clk), .data_out(data_out));
  decoder decodeDUT(.binary(bin), .oneHotCode(OH));
  
  //clock to forever alternate so that we can check all + rising edge cases.
  initial begin
    clk = 0; #5;
    
    forever begin
      clk = 1; #5;
      clk = 0; #5;
    end
  end
  
  //test various cases
  initial begin
    err = 1'b0; write = 1'b0; #10;
    
    write = 1'b1; 
    data_in = 16'b0101010101010101;
    readnum = 3'b000;
    writenum = 3'b000; #10;
    $display("We expect data_out from r0 to be %b, shows %b", 16'b0101010101010101, data_out);
    
    write = 1'b1; 
    data_in = 16'b0010100111000010;
    readnum = 3'b100;
    writenum = 3'b100; #10;
    $display("We expect data_out from r4 to be %b, shows %b", 16'b0010100111000010, data_out);
    
    write = 1'b1; 
    data_in = 16'b1111111111111111;
    readnum = 3'b011;
    writenum = 3'b100; #10;
    $display("We expect data_out from r3 to be %b (note we wrote to r4 instead), shows %b", 16'bx, data_out);

    
    //Your regfile_tb must contain a signal err that is set to 1 if an error is found and stays at 1 thereafter
    if (~err) 
      $display("Pass.");
    else 
      $display("Oh no! Something went wrong here!");
  
    //test the decoder 
     bin = 3'b001; #10;
    $display("Output is %b, we expect %b", OH, 8'b00000010); 
     
    
    bin = 3'b111; #10;
    $display("Output is %b, we expect %b", OH, 8'b10000000); 
   
    
    bin = 3'b000; #10;
    $display("Output is %b, we expect %b", OH, 8'b00000001);
     
    

    $stop;
  end
  
  
endmodule
