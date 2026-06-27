import tb_pkg::*;
class generator;
    
    // 1. transaction handle
    uart_transaction gen_trans;
    
    // 2. mailbox handle
    mailbox #(uart_transaction) gen2drv;
    mailbox #(uart_transaction) gen2scb;
    
    // 3. Constructor
    function new (mailbox #(uart_transaction) gen2drv,
                  mailbox #(uart_transaction) gen2scb);
                  this.gen2drv=gen2drv;
                  this.gen2scb=gen2scb;
    endfunction:new
    
    // 4.number of transactions to generate
    test_type_e test_to_run = HAPPY_PATH;
    int no_of_trans=10;
    bit [7:0] corner_cases[4] = '{8'h00, 8'hFF, 8'hAA, 8'h55};

    // 5. Main Task
    task start();
                    case (test_to_run)
                        HAPPY_PATH: run_happy_path();
                        FIFO_OVERFLOW: run_fifo_overflow();
                        FIFO_UNDERFLOW: run_fifo_underflow();
                        WALKING_ONES: run_walking_ones();
                        SINGLE_BIT_SET: run_single_bit_set();
                        CONSECUTIVE_BYTES: run_consecutive_bytes();
                        IMMEDIATE_START_BURST: run_immediate_start_burst();
                        LONG_IDLE_TEST: run_long_idle_reset();
                    default: run_happy_path();
                    endcase
    endtask: start

    //NORMAL WRITE AND READ TEST
    task run_happy_path();
        $display("[GEN] Starting HAPPY_PATH Test Sequence");
        for(int i=0; i<no_of_trans; i++) begin
            gen_trans = new();
            gen_trans.data = i[7:0]; 
            gen2drv.put(gen_trans); 
            gen2scb.put(gen_trans); 
        end
    endtask

    //FIFO OVERFLOW TEST (pumping 20 bytes into a DEPTH-16 FIFO)
    task run_fifo_overflow();
    $display("[GEN] Starting FIFO_OVERFLOW Test Sequence");
    for(int i=0; i<20; i++)
    begin
        gen_trans = new();
        gen_trans.data = (i<4)?corner_cases[i]:i[7:0];
        gen2drv.put(gen_trans);
        if(i<16) begin
            gen2scb.put(gen_trans);
        end
    end
    endtask

    //FIFO UNDERFLOW TEST
    task run_fifo_underflow();
    $display("[GEN] Starting FIFO_UNDERFLOW Test Sequence");
    gen_trans = new();
    gen_trans.data = 8'h00;
    $display("[GEN] Injecting an artificial read request into an empty FIFO");
    gen2drv.put(gen_trans);
    endtask

    //WALKING ONES PATTERN (Shifting a '1' through all 8 positions)
    task run_walking_ones();
    $display("[GEN] Starting WALKING_ONES Test Sequence");
    for(int i=0; i<8; i++)
    begin
        gen_trans = new();
        gen_trans.data = (1 << i); // 01,02,04,08,10,20,40,80
        gen2drv.put(gen_trans);
        gen2scb.put(gen_trans);
    end
    endtask

    //SINGLE BIT SET
    task run_single_bit_set();
    int i;
    bit [7:0] patterns[2];
    patterns[0]=8'h01;
    patterns[1]=8'h80;
    $display("[GEN ] Starting SINGLE_BIT_SET Test Sequence");
    for(i=0; i<2; i++)
    begin
        gen_trans = new();
        gen_trans.data = patterns[i];
        gen2drv.put(gen_trans);
        gen2scb.put(gen_trans);
    end
    endtask

    //START CONSECUTIVE BYTES
    task run_consecutive_bytes();
        for(int i=0; i<6; i++) begin
            gen_trans = new(); gen_trans.data = 8'hAA;
            gen2drv.put(gen_trans); gen2scb.put(gen_trans);
        end
    endtask

    //START IMMEDIATELY AFTER PREVIOUS FRAME
    task run_immediate_start_burst();
    int i;
    $display("[GEN] Starting IMMEDIATE_START_BURST Test Sequence");
    for(i=0; i<5; i++)
    begin
        gen_trans=new();
        gen_trans.data = corner_cases[i % 4];
        gen2drv.put(gen_trans);
        gen2scb.put(gen_trans);
    end
    endtask

    //LONG IDLE TASK
     task run_long_idle_reset();
     $display("[GEN] Starting LONG_IDLE_TEST Test Sequence");
     for(int i=0; i<3; i++)
     begin
        gen_trans=new();
        gen_trans.data=i[7:0];
        gen2drv.put(gen_trans);
        gen2scb.put(gen_trans);
     end
     endtask

endclass: generator
        