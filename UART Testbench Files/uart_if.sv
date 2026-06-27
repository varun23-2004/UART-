interface uart_if;

    logic UCLK;
    logic reset;

    logic [7:0] W_data;

    logic [7:0] R_data;

    logic tx_full;
    logic rx_empty;

    logic wr_uart;
    logic rd_uart;

////////////////
//DRIVER MODPORT
////////////////
    modport DRIVER (
        input UCLK,
        input tx_full,
        input rx_empty,
        input R_data,

        output W_data,
        output wr_uart,
        output rd_uart
    );

//////////////////
///MONITOR MODPORT
//////////////////
    modport MONITOR (
        input UCLK,
        input reset,

        input W_data,
        input wr_uart,
        
        input R_data,
        input rd_uart,
        
        input tx_full,
        input rx_empty
    );
endinterface