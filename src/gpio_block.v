module gpio_block (clk,rst,
                   set_wr,out_wr,pinmode_wr,
                   pin_sel,set_val,osr_bit,pin_mode,
                   io_in,io_out,io_oe,
                   pin_in,serial_in);

input clk,rst;
input set_wr,out_wr,pinmode_wr;
input [2:0] pin_sel;
input set_val;
input osr_bit;
input [1:0] pin_mode;
input [7:0] io_in;
output [7:0] io_out;
output [7:0] io_oe;
output [7:0] pin_in;
output serial_in;

reg [7:0] latch;      // output value of each pin
reg [7:0] mode_hi;    // mode[1] of each pin
reg [7:0] mode_lo;    // mode[0] of each pin

// ---------- input side: 2-flop synchronizer ----------
reg [7:0] sync1,sync2;

always@(posedge clk,negedge rst)begin

if(!rst)begin

sync1 <= 8'hFF;
sync2 <= 8'hFF;
    
end

else begin

sync1 <= io_in;
sync2 <= sync1;
    
end

end

assign pin_in = sync2;
assign serial_in = pin_in[pin_sel];

// ---------- write side ----------
wire wdata = out_wr ? osr_bit : set_val;

always@(posedge clk,negedge rst)begin

if(!rst)begin

latch <= 8'hFF;
mode_hi <= 8'h00;
mode_lo <= 8'h00;

end

else begin

if(set_wr | out_wr) latch[pin_sel] <= wdata;

if(pinmode_wr)begin

mode_hi[pin_sel] <= pin_mode[1];
mode_lo[pin_sel] <= pin_mode[0];

end

end

end

// ---------- mode logic ----------
wire [7:0] push_pull = ~mode_hi & mode_lo;   // mode 01
wire [7:0] open_drain = mode_hi & ~mode_lo;   // mode 10

assign io_oe = push_pull | (open_drain & ~latch);
assign io_out = push_pull & latch;

endmodule