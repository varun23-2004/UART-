// UART Testbench with Parity Checking

`timescale 1ns/1ns

module uart_tb;
	parameter DATA_WIDTH=8;
	parameter CLK_PERIOD=10;
	
	reg UCLK;
	reg reset;
	reg [DATA_WIDTH-1:0] W_data;
	reg wr_uart;
	reg rd_uart;
	wire [DATA_WIDTH-1:0] R_data;
	wire tx_full;
	wire rx_empty;
	
	UART #(.DATA_WIDTH(DATA_WIDTH)) dut(
		.UCLK(UCLK),
		.reset(reset),
		.W_data(W_data),
		.wr_uart(wr_uart),
		.tx_full(tx_full),
		.R_data(R_data),
		.rd_uart(rd_uart),
		.rx_empty(rx_empty));
initial UCLK=0;
always #(CLK_PERIOD/2) UCLK=~UCLK;

initial begin
	reset=1;
	W_data=0;
	wr_uart=0;
	rd_uart=0;
	#100;
	reset=0;
	
	//WRITE 0xAA and 0x55 to TX FIFO
	@(posedge UCLK);
	W_data=8'hAA;
	wr_uart=1;
	@(posedge UCLK);
	W_data=8'h55;
	@(posedge UCLK);
	wr_uart=0;
	
	#(16*10*7*CLK_PERIOD);
	
	//Enable read from RX FIFO
	@(posedge UCLK);
	rd_uart=1;
	@(posedge UCLK);
	rd_uart=0;
	#100;
	
	#(16*10*7*CLK_PERIOD);
	@(posedge UCLK);
	rd_uart=1;
	@(posedge UCLK);
	rd_uart=0;
	
	#100;
	$display ("received data: %h",R_data);
	$stop;
end 
endmodule
	
