module osr (clk,rst,osr_load,osr_shift,dir,load_data,serial_out);

input clk,rst;
input osr_load,osr_shift;
input dir;                  
input [7:0] load_data;     
output serial_out;

reg [7:0] osr_reg;

assign serial_out = dir ? osr_reg[7] : osr_reg[0];

always@(posedge clk, negedge rst)begin

if(!rst) osr_reg <= 8'd0;
else if(osr_load) osr_reg <= load_data;
else if(osr_shift)begin

if(!dir) osr_reg <= {1'b0,osr_reg[7:1]};   
else osr_reg <= {osr_reg[6:0],1'b0};
    
end
    
end

endmodule