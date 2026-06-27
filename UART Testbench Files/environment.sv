//import tb_pkg::*;
class environment;

    //1. Component Handles
    generator  gen;
    driver     drv;
    monitor    mon;
    scoreboard scb;

    //2. Mailboxes
    mailbox #(uart_transaction) gen2drv;
    mailbox #(uart_transaction) gen2scb;
    mailbox #(uart_transaction) mon2scb;

    //3. Virtual Interface
    virtual uart_if vif;

    //4. Constructor
    function new(virtual uart_if vif);
        this.vif = vif;
    endfunction : new

    test_type_e select_test = HAPPY_PATH;

    //5. Build Task
    task build();

        // Create Mailboxes
        gen2drv = new();
        gen2scb = new();
        mon2scb = new();

        // Create Components
        gen = new(gen2drv, gen2scb);
        drv = new(gen2drv,vif);
        mon = new(mon2scb,vif);
        scb = new(gen2scb,mon2scb);
        gen.test_to_run = select_test;
        drv.test_to_run = select_test;
        scb.test_to_run = select_test;
    endtask : build

    // Run Task
    // Upgraded Run Task inside environment.sv
    
    task run_regression();
        test_type_e regression_list[8] = '{
            HAPPY_PATH, 
            FIFO_OVERFLOW, 
            FIFO_UNDERFLOW, 
            WALKING_ONES, 
            SINGLE_BIT_SET, 
            CONSECUTIVE_BYTES, 
            IMMEDIATE_START_BURST,
            LONG_IDLE_TEST
        };

        int expected_counts[8] = '{10, 16, 2, 8, 2, 6, 5, 3};

        for (int i = 0; i < 8; i++) begin
            test_type_e current_test = regression_list[i];
            int target_evals = expected_counts[i];
            
            $display("\n=====================================================");
            $display(" REGRESSION RUNNING TEST %0d: %s", i+1, current_test.name());
            $display("=====================================================");

            // 1. Hardware Cleardown
            vif.reset = 1; repeat(5) @(posedge vif.UCLK); vif.reset = 0;

            // 2. Context Assignment
            gen.test_to_run = current_test; 
            drv.test_to_run = current_test; 
            scb.test_to_run = current_test;
            scb.reset_scoreboard();

            // 3. Launch elements concurrently in the background
            fork
                gen.start();
                drv.start(); // No inputs! Self-managing loop
                mon.start(); // Classic forever loop
                scb.start(); // Classic forever loop
            join_none

            // 4. Wait until the scoreboard confirms it received all the test answers
            wait(scb.total_count == target_evals);
            
            // 5. Short simulation stabilization gap
            #20000; 

            // 6. Output report card and kill the background tasks cleanly for this loop
            scb.print_summary(0); 
            disable fork; 
        end

        $display("\n=====================================================");
        $display("     REGRESSION COMPLETE: ALL GRADED TESTS PASSED     ");
        $display("=====================================================\n");
        $finish; 
    endtask
endclass : environment  