// 3.2.3 Baud Rate Generator
module baud_gen (clk, reset, baud_tick);
  parameter CLK_FREQ   = 100_000_000;
  parameter BAUD_RATE  = 921600;
  parameter OVERSAMPLE = 16;
  parameter FINAL_VAL  = (CLK_FREQ + (BAUD_RATE*OVERSAMPLE)/2) / (BAUD_RATE*OVERSAMPLE); // integer divider

  localparam WIDTH 	  = $clog2(FINAL_VAL);
  localparam divisor = FINAL_VAL;
  
  input  clk, reset;
  output reg baud_tick;

  reg  [WIDTH-1:0] counter;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      baud_tick    <= 0;
      counter <= 0;
    end else if (counter == (divisor-1)) begin
      baud_tick    <= 1;
      counter <= 0;
    end else begin
      baud_tick    <= 0;
      counter <= counter + 4'd1;
    end
  end
endmodule