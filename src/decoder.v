module decoder #(parameter N = 15) (rst,inst,is_set,is_wait,is_out,is_in,is_delay,is_pull,is_push,is_setx,is_jmp,is_jmpp,is_pinmode,opcode,pin_sel,flag,addr,imm,jmp_cond,pin_mode,illegal);
input rst;
input [N:0] inst;

output wire [3:0] opcode;
output wire [2:0] pin_sel;
output wire flag;
output wire [7:0] addr;
output wire [11:0] imm;
output wire [1:0] jmp_cond;
output wire [1:0] pin_mode;

output reg is_set,is_wait,is_out,is_in,is_delay;
output reg is_pull,is_push,is_setx;
output reg is_jmp,is_jmpp,is_pinmode;
output reg illegal;

localparam OP_SET = 4'd0;
localparam OP_WAIT = 4'd1;
localparam OP_OUT = 4'd2;
localparam OP_IN = 4'd3;
localparam OP_DELAY = 4'd4;
localparam OP_PULL = 4'd5;
localparam OP_PUSH = 4'd6;
localparam OP_SETX = 4'd7;
localparam OP_JMP = 4'd8;
localparam OP_JMPP = 4'd9;
localparam OP_PINMODE = 4'd10;

assign opcode = inst[15:12];
assign pin_sel = inst[11:9];
assign flag = inst[8];
assign addr = inst[7:0];
assign imm = inst[11:0];
assign jmp_cond = inst[11:10];
assign pin_mode = {inst[8],inst[7]};

always@(*)begin

if(!rst) {is_set,is_wait,is_out,is_in,is_delay,is_pull,is_push,is_setx,is_jmp,is_jmpp,is_pinmode,illegal} = 0;

else begin

{is_set,is_wait,is_out,is_in,is_delay,is_pull,is_push,is_setx,is_jmp,is_jmpp,is_pinmode,illegal} = 0;

case(opcode)

OP_SET: is_set = 1'b1;
OP_WAIT: is_wait = 1'b1;
OP_OUT: is_out = 1'b1;
OP_IN: is_in = 1'b1;
OP_DELAY: is_delay = 1'b1;
OP_PULL: is_pull = 1'b1;
OP_PUSH: is_push = 1'b1;
OP_SETX: is_setx = 1'b1;
OP_JMP: is_jmp = 1'b1;
OP_JMPP: is_jmpp = 1'b1;
OP_PINMODE: is_pinmode = 1'b1;
default: illegal = 1'b1;

endcase

end
end

endmodule
