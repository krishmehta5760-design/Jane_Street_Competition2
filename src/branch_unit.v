module branch_unit (is_jmp,is_jmpp,jmp_cond,flag,addr,pin_level,x_zero,tx_empty,osr_next_bit,branch_taken,branch_targ);

input is_jmp,is_jmpp;
input [1:0] jmp_cond;
input flag;
input [7:0] addr;
input pin_level;
input x_zero;
input tx_empty;
input osr_next_bit;
output reg branch_taken;
output [31:0] branch_targ;
    
assign branch_targ = {22'd0,addr,2'd0};

always@(*)begin
branch_taken = 1'b0;

if(is_jmp)begin

case(jmp_cond)

2'b00: branch_taken = 1'b1;
2'b01: branch_taken = ~x_zero;
2'b10: branch_taken = ~tx_empty;
2'b11: branch_taken = osr_next_bit;
default: branch_taken = 1'b0;

endcase
    
end

else if(is_jmpp) branch_taken = (pin_level == flag);

end
endmodule