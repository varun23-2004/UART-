module RX_TOP(UCLK,BCLK,reset,R_data,rd_uart,rx,rx_empty);
parameter OVERSAMPLE=16;
parameter DATA_WIDTH=8;
parameter DATA_BITS=$clog2(DATA_WIDTH);

input UCLK,BCLK,reset;
input rx;
input rd_uart;

output rx_empty;
output [DATA_WIDTH-1:0] R_data;

wire rx_done_tk;
wire [DATA_WIDTH-1:0] rx_dout;
wire full;

RX rx_blk (BCLK,reset,rx_dout,full,rx_done_tk,rx);
	FIFO rx_fifo (UCLK,BCLK,reset,rx_done_tk,rd_uart,R_data,rx_dout,full,rx_empty);
endmodule
