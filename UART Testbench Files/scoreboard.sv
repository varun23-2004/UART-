//import tb_pkg::*;
class scoreboard;

    // 1. transaction handle 
    uart_transaction exp_tr;
    uart_transaction act_tr;

    //2. mailbox handle 
    mailbox #(uart_transaction) gen2scb;
    mailbox #(uart_transaction) mon2scb;
     
    int pass_count = 0;
    int fail_count = 0;
    int total_count = 0;
    int test_done = 0;

    // Test control veriable (passed from environment)
    test_type_e test_to_run = HAPPY_PATH;

     //3. constructor
     function new(
        mailbox #(uart_transaction) gen2scb,
        mailbox #(uart_transaction) mon2scb);
        this.gen2scb=gen2scb;
        this.mon2scb=mon2scb;
    endfunction: new

    // Add this inside your scoreboard class
    task reset_scoreboard();
        pass_count = 0;
        fail_count = 0;
        total_count = 0;
        test_done = 0;
        // Purge mailboxes if anything is left over
        while(gen2scb.num() > 0) begin: purge_gen gen2scb.get(exp_tr); end
        while(mon2scb.num() > 0) begin: purge_mon mon2scb.get(act_tr); end
        $display("[SCB] Scoreboard metrics flushed for next test.");
    endtask

    //4. main task
   task start();
   forever begin
        if(test_to_run == FIFO_UNDERFLOW) begin
            //Underflow injects read to an empty FIFO.
            mon2scb.get(act_tr);
            total_count=total_count+1;
            $display("[SCB] total_count=%0d at  %0t", total_count,$time);

            if (act_tr.data == 8'h00) begin
                pass_count = pass_count+1;
                $display("[SCB=PASS] [UNDERFLOW] Safety captures masked 8'h00 from empty FIFO");
            end 
            else begin
                fail_count = fail_count+1;
                $display("[SCB-FAIL] [UNDERFLOW] Expected masked 8'h00, but got %0d", act_tr.data);
            end
            test_done =1;
            //print_summary(1);
        end

        else begin
            gen2scb.get(exp_tr);
            mon2scb.get(act_tr);
            total_count=total_count+1;
            $display("[SCB] total_count=%0d at  %0t",total_count,$time);
        
        if(exp_tr.data==act_tr.data) begin
            pass_count=pass_count+1;
            $display("[SCB-PASS] Expected=%0h   |   Actual=%0h",exp_tr.data,act_tr.data);
        end
        else begin
            fail_count=fail_count+1;
            $display("[SCB-FAIL] Expected=%0h   |   Actual=%0h",exp_tr.data, act_tr.data);
        end

        case (test_to_run)
                    HAPPY_PATH: if (total_count == 10) test_done = 1;
                    FIFO_OVERFLOW: if (total_count == 16) test_done = 1;
                    WALKING_ONES: if (total_count == 8)  test_done = 1;
                    SINGLE_BIT_SET: if (total_count == 2)  test_done = 1;
                    CONSECUTIVE_BYTES: if (total_count == 6)  test_done = 1;
                    IMMEDIATE_START_BURST: if (total_count == 5)  test_done = 1;
                    LONG_IDLE_TEST: if (total_count == 3)  test_done = 1;
                endcase
                
                //if (test_done) begin
                //    print_summary(0);
                //end
        end
   end
   endtask: start

    task print_summary(bit terminate_sim);
        $display("\n---------------------------------------------------------------------");
        $display("                         FINAL VERIFICATION REPORT                     ");
        $display("-----------------------------------------------------------------------");
        $display("TEST SCNEARIO: %s", test_to_run.name());
        $display("TOTAL EVALS:   %0d", total_count);
        $display("PASSED:        %0d", pass_count);
        $display("FAILED:        %0d", fail_count);
        if(fail_count == 0 && total_count > 0 )begin
            $display("STATUS:       [PASSED COMPLETELY]");
        end else begin
            $display("FAILED:       [VERIFICATION FAILED]");
        end 
        $display("------------------------------------------------------------------------");
    endtask                
endclass
