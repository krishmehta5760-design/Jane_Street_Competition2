module isr (clk,rst,isr_shift,dir,serial_in,isr_data);

input clk,rst;
input isr_shift;
input dir;                  
input serial_in;            
output [7:0] isr_data;

reg [7:0] isr_reg;

assign isr_data = isr_reg;

always@(posedge clk, negedge rst)begin

if(!rst) isr_reg <= 8'd0;
else if(isr_shift)begin

if(!dir) isr_reg <= {serial_in,isr_reg[7:1]}; 
else isr_reg <= {isr_reg[6:0],serial_in};
    
end

end

endmodule