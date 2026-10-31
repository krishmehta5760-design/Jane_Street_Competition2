module byte_buf (clk,rst,wr,wdata,rd,rdata,valid);
input clk,rst,wr,rd;
input [7:0] wdata;
output [7:0] rdata;
output reg valid;

reg [7:0] data;
assign rdata = data;

always@(posedge clk or negedge rst)begin
    if(!rst)begin
        valid <= 1'b0;
        data  <= 8'd0;
    end
    else if(wr & ~valid)begin
        data  <= wdata;
        valid <= 1'b1;
    end
    else if(rd & valid)
        valid <= 1'b0;
end
endmodule