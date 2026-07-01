//import tb_pkg::*;
class monitor;

    // 1. Transaction handle 
    uart_transaction tr;

    //2. Mailbox handle
    mailbox #(uart_transaction) mon2scb;

    //3. Virtual Interface handle
    virtual uart_if vif;

    //4. Constructor 
    function new(
        mailbox #(uart_transaction) mon2scb,
        virtual uart_if vif);
        this.mon2scb=mon2scb;
        this.vif=vif;
    endfunction:new

    //5. main task
    task start();
    forever begin
        @(posedge vif.UCLK);
        if(vif.rd_uart)
        begin
            tr = new();
            tr.data = vif.R_data;
            tr.display("MON");
            mon2scb.put(tr);
        end
    end
endtask
endclass
