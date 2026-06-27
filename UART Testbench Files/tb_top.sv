`timescale 1ns/1ps
import tb_pkg::*;
module tb_top;

//environment
environment env;

//interface
uart_if vif();

//DUT instance
UART dut(
    .UCLK(vif.UCLK), .reset(vif.reset),
    .W_data(vif.W_data), .wr_uart(vif.wr_uart),
    .tx_full(vif.tx_full), 
    .R_data(vif.R_data), .rd_uart(vif.rd_uart),
    .rx_empty(vif.rx_empty)
);

initial begin
    vif.UCLK=0;
    forever #5 vif.UCLK=~vif.UCLK;
end

initial begin
    #1;
    $display("wr_uart=%b", vif.wr_uart);
end

initial begin
    vif.reset=1;
    repeat(5) @(posedge vif.UCLK);
    vif.reset=0;
end 

initial begin
    env = new(vif);
    env.build();
    env.run_regression();
end

endmodule