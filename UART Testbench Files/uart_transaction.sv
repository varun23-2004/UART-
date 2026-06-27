class uart_transaction;
    bit [7:0] data;

    function void display(string tag);
        $display("[%s] data = %0h", tag, data);
    endfunction
endclass