// 3.2.4 FIFO Buffers
module FIFO(clk,reset,wr_en,rd_en,data_in,data_out,full,empty,overflow,underflow);

parameter FIFO_WIDTH = 8;
parameter FIFO_DEPTH = 16;

localparam max_fifo_addr = $clog2(FIFO_DEPTH);

input clk, reset;
input wr_en, rd_en;
input [FIFO_WIDTH-1:0] data_in;

output reg [FIFO_WIDTH-1:0] data_out;
output full, empty;
output reg overflow;
output reg underflow;

reg [FIFO_WIDTH-1:0] FIFO_mem [FIFO_DEPTH-1:0];
reg [FIFO_WIDTH -1:0] last_read_val;

reg [max_fifo_addr-1:0] wr_ptr;
reg [max_fifo_addr-1:0] rd_ptr;
reg [max_fifo_addr:0]   count;


// WRITE LOGIC
always @(posedge clk or posedge reset)
begin
    if(reset)
    begin
        wr_ptr <= 0;
    end
    else if(wr_en && !full)
    begin
        FIFO_mem[wr_ptr] <= data_in;
        wr_ptr <= wr_ptr + 4'd1;
    end
end

// READ LOGIC
always @(posedge clk or posedge reset)
begin
    if(reset)
   begin        
    rd_ptr <= 0;
    last_read_val<=0;
   // data_out <=0;
    end
   else if(rd_en && !empty)
  begin
     //   data_out<=  FIFO_mem[rd_ptr];
       rd_ptr <= rd_ptr + 4'd1;
       last_read_val<=FIFO_mem[rd_ptr];
  end
 end

always @(*) begin
    if(empty)
    data_out = last_read_val;//Keeps the last data on the bus;
    else
    data_out=FIFO_mem[rd_ptr];//New valid data;
end

// FIFO OCCUPANCY COUNT
always @(posedge clk or posedge reset)
begin
    if(reset)
    begin
        count <= 0;
    end
    // write only
    else if(wr_en && !full && !(rd_en && !empty))
    begin
        count <= count + 4'd1;
    end
    // read only
    else if(rd_en && !empty && !(wr_en && !full))
    begin
        count <= count - 4'd1;
    end
    // simultaneous read/write or idle
    else
    begin
        count <= count;
    end
end

// OVERFLOW / UNDERFLOW FLAGS
always @(posedge clk or posedge reset)
begin
    if(reset)
    begin
        overflow <= 0;
        underflow <= 0;
    end
    else
    begin
        if(wr_en && full)
            overflow <= 1'b1;

        if(rd_en && empty)
            underflow <= 1'b1;
    end
end
assign full  = (count == FIFO_DEPTH);
assign empty = (count == 0);
endmodule