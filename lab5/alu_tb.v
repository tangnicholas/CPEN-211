module ALU_tb ();
// No inputs or outputs, because it is a testbench

//declare signals to connect to device under test
reg [15:0] ain;
reg [15:0] bin; 
reg [1:0] ALUop; 
wire [15:0] out; 
wire Z;
reg err;

//instantiating the lab4_top module
ALU DUT(.Ain(ain), .Bin(bin), .ALUop(ALUop), .out(out), .Z(Z) );

//intial test script
initial begin
err = 1'b0;

//Tests Ain + Bin
ALUop = 2'b00; 
ain = 16'b0000010001001001;
bin = 16'b0000001000010011;
#10;
$display("Output is %b, we expect %b", out, 16'b0011001011100 );
if (out !== 16'b0011001011100)
      err = 1'b1;

//Tests Ain - Bin
ALUop = 2'b01; 
ain = 16'b0000010001001001;
bin = 16'b0000001000010011; 
#10;
$display("Output is %b, we expect %b", out,16'b001000110110 );
if (out !== 16'b001000110110)
      err = 1'b1;

//Tests Ain & Bin
ALUop = 2'b10; 
ain = 16'b0000010001001001;
bin = 16'b0000001000010011;
#10;
$display("Output is %b, we expect %b", out, 16'b0000000000000001);
if (out !== 16'b0000000000000001)
      err = 1'b1;

//Tests ~Bin
ALUop = 2'b11; 
ain = 16'b0000010001001001;
bin = 16'b0000001000010011 ;
#10;
$display("Output is %b, we expect %b", out, 16'b1111110111101100);
if (out !== 16'b1111110111101100)
      err = 1'b1;

//Test Z 
ALUop = 2'b00;
ain = 16'b0000000000000000;
bin = 16'b0000000000000000;
#10;
$display("Z Output is %b, we expect %b", Z, 1'b1);
if (Z !== 1'b1)
      err = 1'b1;

//if err is 1, display an error message, if else, then all tests are passed
 if (err) 
      $display("Oh no! Something went wrong here!");
    else 
      $display("Passed all our tests.");

$stop; 
end
endmodule 
