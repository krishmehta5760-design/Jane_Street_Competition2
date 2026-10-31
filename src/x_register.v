module x_register (clk,rst,x_load,x_dec,imm,x_zero);

input clk,rst;
input x_load,x_dec;
input [11:0] imm;
output x_zero;

reg [11:0] x;

assign x_zero = (x == 12'd0);

always@(posedge clk, negedge rst)begin

if(!rst) x <= 12'd0;
else if(x_load) x <= imm;
else if(x_dec) x <= x - 12'd1;

end

endmodule