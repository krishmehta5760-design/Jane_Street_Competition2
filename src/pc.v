module pc(pc,next,clk,rst);
input clk,rst;
input [31:0] next;
output reg [31:0] pc;

always@(posedge clk, negedge rst)begin

if(!rst) pc <= 0;

else begin

pc <= next;

end

end

endmodule
