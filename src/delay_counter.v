module delay_counter (clk,rst,core_en,delay_load,imm,delay_done);

input clk,rst;
input core_en;
input delay_load;
input [11:0] imm;
output delay_done;

reg [11:0] cnt;

assign delay_done = (cnt == 12'd0);

always@(posedge clk, negedge rst)begin

if(!rst) cnt <= 12'd0;
else if(delay_load) cnt <= imm;
else if(core_en && cnt != 12'd0) cnt <= cnt - 12'd1;

end

endmodule