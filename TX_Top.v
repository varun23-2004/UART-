module TX_TOP(UCLK,BCLK,reset,W_data,wr_uart,tx,tx_full);
parameter OVERSAMPLE=16;
parameter DATA_WIDTH=8;
parameter DATA_BITS=$clog2(DATA_WIDTH);

input UCLK,BCLK,reset;
input [DATA_WIDTH-1:0] W_data;
input wr_uart;

output tx_full,tx;

wire tx_done_tk;
wire [DATA_WIDTH-1:0] tx_din;
wire empty;

TX tx_blk (BCLK,reset,tx_din,!(empty),tx_done_tk,tx);
	FIFO tx_fifo (BCLK,UCLK,reset,wr_uart,tx_done_tk,W_data,tx_din,tx_full,empty);
endmodule
