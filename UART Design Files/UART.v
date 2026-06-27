// UART Top Level Module
module UART(UCLK,reset,W_data,wr_uart,tx_full,R_data,rd_uart,rx_empty);
parameter OVERSAMPLE=16;
parameter DATA_WIDTH=8;

input UCLK,reset;
input [DATA_WIDTH-1:0] W_data;
input wr_uart;
input rd_uart;

output rx_empty;
output [DATA_WIDTH-1:0] R_data;
output tx_full;

wire tx_rx;
wire baud_tick;

baud_gen baud_generator(UCLK,reset,baud_tick);

TX_TOP tx_top_blk(
    .UCLK(UCLK),
    .reset(reset),
    .W_data(W_data),
    .wr_uart(wr_uart),
    .tx(tx_rx),
    .tx_full(tx_full)
);
RX_TOP rx_top_blk(
    .UCLK(UCLK),
    .reset(reset),
    .rd_uart(rd_uart),
    .rx(tx_rx),
    .R_data(R_data),
    .rx_empty(rx_empty)
);
endmodule                           