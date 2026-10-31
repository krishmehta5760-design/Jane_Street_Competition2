module baud_gen #(parameter W = 16) (clk,rst,baud_div,core_en);

input clk,rst;
input [W-1:0] baud_div;
output reg core_en;

reg [W-1:0] cnt;

wire last = ({1'b0,cnt} + 1'b1) >= {1'b0,baud_div};

always@(posedge clk, negedge rst)begin

if(!rst)begin

cnt <= {W{1'b0}};
core_en <= 1'b0;

end

else if(last)begin

cnt <= {W{1'b0}};
core_en <= 1'b1;

end

else begin

cnt <= cnt + 1'b1;
core_en <= 1'b0;
    
end
    
end

endmodule