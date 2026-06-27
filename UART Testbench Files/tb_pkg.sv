package tb_pkg;
    typedef enum bit [3:0] {
        HAPPY_PATH,
        FIFO_OVERFLOW,
        FIFO_UNDERFLOW,
        WALKING_ONES,
        SINGLE_BIT_SET,
        CONSECUTIVE_BYTES,
        IMMEDIATE_START_BURST,
        LONG_IDLE_TEST
    } test_type_e;

    `include "uart_transaction.sv"
    `include "generator.sv"
    `include "driver.sv"
    `include "monitor.sv"
    `include "scoreboard.sv"
    `include "environment.sv"
endpackage