`define SHIFTPASS 2'b00
`define SHIFTLEFT 2'b01
`define SHIFTRIGHT 2'b10
`define SHIFTRIGHTSPEC 2'b11


module shifter(in,
               shift,
               sout);

  // Though for this lab, the shifter is always 16 bits, it is better to parameterize it if possible for future use
  parameter shifterSize = 16;

  input [shifterSize-1:0] in;
  input [1:0] shift;
  output [shifterSize-1:0] sout;
  reg [shifterSize-1:0] sout;
  
  // As the shifter is purely combinational logic, we use an always block with a wildcard sensitivity list
  always @(*) begin
    case (shift)
      // 00 - Passthrough
      `SHIFTPASS: sout = in;
      // 01 - Shift left by one bit, leaving 0 in bit 0
      `SHIFTLEFT: begin
        sout    = in << 1;
        sout[0] = 1'b0;
      end
      // 10 - Shift right by one bit, leaving 0 in bit 15
      `SHIFTRIGHT: begin
        sout     = in >> 1;
        sout[shifterSize-1] = 1'b0;
      end
      // 11 - Shift right by one bit, leaving in[15] in bit 15
      `SHIFTRIGHTSPEC: begin
        sout     = in >> 1;
        sout[shifterSize-1] = in[shifterSize-1];
      end
      // We use a default with 16 x bits to detect errors in the waveform if any exist. Note that this condition should never be triggered.
      default: sout = {shifterSize{1'bx}};
    endcase
  end
  
endmodule
