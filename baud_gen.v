// 3.2.3 Baud Rate Generator
module baud_gen (clk, reset, BCLK);
  parameter CLK_FREQ   = 100_000_000;
  parameter BAUD_RATE  = 921600;
  parameter OVERSAMPLE = 16;
  parameter FINAL_VAL  = (CLK_FREQ/(BAUD_RATE*OVERSAMPLE))+0.5; // integer divider

  input  clk, reset;
  output reg BCLK;

  wire [15:0] divisor;
  reg  [15:0] counter;

  assign divisor = FINAL_VAL;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      BCLK    <= 0;
      counter <= 0;
    end else if (counter == (divisor-1)) begin
      BCLK    <= 1;
      counter <= 0;
    end else begin
      BCLK    <= 0;
      counter <= counter + 1;
    end
  end
endmodule
