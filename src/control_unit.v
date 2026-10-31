module control_unit (clk,rst,host_run,core_en,
                     is_set,is_wait,is_out,is_in,is_delay,is_pull,is_push,is_setx,is_jmp,is_pinmode,
                     jmp_cond,pin_sel,flag,
                     pin_in,tx_empty,rx_full,delay_done,x_zero,
                     pc_en,delay_load,
                     set_wr,out_wr,pinmode_wr,
                     osr_load,osr_shift,isr_shift,
                     fifo_pop,fifo_push_en,
                     x_load,x_dec);

input clk,rst;
input host_run,core_en;

input is_set,is_wait,is_out,is_in,is_delay;
input is_pull,is_push,is_setx,is_jmp,is_pinmode;
input [1:0] jmp_cond;
input [2:0] pin_sel;
input flag;

input [7:0] pin_in;     
input tx_empty,rx_full;
input delay_done;
input x_zero;

output pc_en;
output delay_load;
output set_wr,out_wr,pinmode_wr;
output osr_load,osr_shift,isr_shift;
output fifo_pop,fifo_push_en;
output x_load,x_dec;

reg delay_active;
reg blocked;

always@(*)begin

blocked = 1'b0;
if(is_wait) blocked = (pin_in[pin_sel] != flag);
else if(is_pull) blocked = tx_empty;
else if(is_push) blocked = rx_full;
else if(is_delay) blocked = ~(delay_active & delay_done);
    
end

assign pc_en = (host_run & core_en & ~blocked);

assign set_wr = (pc_en & is_set);
assign out_wr = (pc_en & is_out);
assign osr_shift = (pc_en & is_out);  
assign isr_shift = (pc_en & is_in);
assign osr_load = (pc_en & is_pull);
assign fifo_pop = (pc_en & is_pull);
assign fifo_push_en = (pc_en & is_push);
assign pinmode_wr = (pc_en & is_pinmode);
assign x_load = (pc_en & is_setx);
assign x_dec = (pc_en & is_jmp & (jmp_cond == 2'b01) & ~x_zero);

assign delay_load = (host_run & core_en & is_delay & ~delay_active);

always@(posedge clk or negedge rst)begin

if(!rst) delay_active <= 1'b0;
else if(!host_run) delay_active <= 1'b0;  
else if(delay_load) delay_active <= 1'b1;
else if(pc_en & is_delay) delay_active <= 1'b0;

end

endmodule