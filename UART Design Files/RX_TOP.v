module RX_TOP(UCLK,reset,R_data,rd_uart,rx,rx_empty);
parameter OVERSAMPLE=16;
parameter DATA_WIDTH=8;
parameter DATA_BITS=$clog2(DATA_WIDTH);

input UCLK,reset;
input rx;
input rd_uart;

output rx_empty;
output [DATA_WIDTH-1:0] R_data;

wire rx_done_tk;
wire [DATA_WIDTH-1:0] rx_dout;
wire full;
wire underflow;
wire overflow;

RX rx_blk(.BCLK(UCLK),
    .reset(reset),
    .rx_dout(rx_dout),
    .rx_write(full),
    .rx_done_tk(rx_done_tk),
    .rx(rx));
FIFO rx_fifo (UCLK,reset,rx_done_tk,rd_uart,rx_dout,R_data,full,rx_empty,overflow,underflow);
endmodule