//import tb_pkg::*;
class driver;
    
    // 1. transaction Handle
    uart_transaction tr;

    // 2. mailbox handle
    mailbox #(uart_transaction) gen2drv;

    //3. Virtual interface handle 
    virtual uart_if vif;

    // test control variable (PASSED FROM ENVIRONMENT)
    test_type_e test_to_run = HAPPY_PATH;

    //4. Consturctor
    function new(mailbox #(uart_transaction) gen2drv,virtual uart_if vif);
        this.gen2drv = gen2drv;
        this.vif     = vif;
    endfunction: new

    // 5. Write Task
    task write_uart();
        vif.W_data <= tr.data;
        @(posedge vif.UCLK);
        vif.wr_uart <= 1'b1;

        @(posedge vif.UCLK);
        vif.wr_uart <=1'b0;

        $display("[DRV] Written Data = %0h at %t" , tr.data, $time);
    endtask

    // 6. Read Task
    task read_uart();
        if(test_to_run == FIFO_UNDERFLOW) begin
            $display("[DRV-UNDERFLOW] Bypassing rx_empty check to inject illegal read");
        end
        else  begin
            //$display("[DRV] Waiting for rx_empty");
            wait(vif.rx_empty == 0);
        end
        vif.rd_uart <= 1'b1;
        @(posedge vif.UCLK);
        vif.rd_uart <= 1'b0;
        //$display("[DRV] Read Triggered");
    endtask

    //7 Initialization
    task initialize_signals();
    vif.wr_uart <=0;
    vif.rd_uart <=0;
    vif.W_data  <=0;
    //$display("[DRV] wr_uart initialized");
    endtask

    //8. Main Task
    task start();
        vif.wr_uart <= 0; vif.rd_uart <= 0; vif.W_data <= 0; 
        wait(vif.reset == 0); 
        
        forever begin
            // 1. Wait for the generator to dump packets into the mailbox
            wait(gen2drv.num() > 0);
            $display("[DRV] Detected %0d transactions in mailbox. Starting execution loop.", gen2drv.num());

            // 2. Process EVERY SINGLE packet currently waiting in the pipeline
            while (gen2drv.num() > 0) begin
                
                // SPECIAL EXCEPTION: FIFO UNDERFLOW
                if (test_to_run == FIFO_UNDERFLOW) begin
                    gen2drv.get(tr);
                    read_uart();
                end
                
                // SPECIAL EXCEPTION: IMMEDIATE START BURST
                else if (test_to_run == IMMEDIATE_START_BURST) begin
                    $display("[DRV-BURST] Rapidly streaming remaining %0d burst packets...", gen2drv.num());
                    
                    // Pull and write everything to maximize the bus throughput immediately
                    while(gen2drv.num() > 0) begin
                        gen2drv.get(tr);
                        write_uart();
                    end
                    
                    // The TX pipeline is completely full now! Wait and read them back out.
                    $display("[DRV-BURST] Transmission burst sent. Beginning synchronized read cycles.");
                    repeat(5) begin
                        wait(vif.rx_empty == 0);
                        @(posedge vif.UCLK);
                        read_uart();
                    end
                end
                
                // STANDARD SCENARIOS (Happy Path, Overflow, Walking Ones, Patterns, Long Idle)
                else begin
                    gen2drv.get(tr);
                    if (test_to_run == LONG_IDLE_TEST) begin
                        $display("[DRV-IDLE] Injecting 20,000ns line idle period before fetching next packet...");
                        #5000ns;
			            $display("[DRV-IDLE]%t",$time);
                    end
                    write_uart();
                    read_uart();
                    
                end
            end
            
            $display("[DRV] Mailbox fully drained. Standing by for next regression test cycle.");
        end
    endtask
endclass

	