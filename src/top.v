module top (clk,rst,
            host_run,host_wr,host_waddr,host_wdata,baud_div,
            tx_wr,tx_wdata,tx_full,
            rx_rd,rx_rdata,rx_valid,
            io_in,io_out,io_oe);

input clk,rst;

input host_run;
input host_wr;
input [7:0]  host_waddr;
input [15:0] host_wdata;
input [15:0] baud_div;
input tx_wr;
input [7:0] tx_wdata;
output tx_full;
input rx_rd;
output [7:0] rx_rdata;
output rx_valid;

input  [7:0] io_in;
output [7:0] io_out;
output [7:0] io_oe;

wire [31:0] pc, next, next_seq, branch_targ;
wire [15:0] inst;
wire branch_taken, pc_en;

assign next_seq = branch_taken ? branch_targ : (pc + 32'd4);
assign next = pc_en ? next_seq : pc;

pc u_pc (.pc(pc), .next(next), .clk(clk), .rst(rst));

imem u_imem (.clk(clk), .rst(rst), .pc(pc), .inst(inst),
             .host_wr(host_wr & ~host_run),
             .host_waddr(host_waddr), .host_wdata(host_wdata));

wire is_set,is_wait,is_out,is_in,is_delay,is_pull,is_push,is_setx;
wire is_jmp,is_jmpp,is_pinmode,illegal;
wire [3:0] opcode;
wire [2:0] pin_sel;
wire flag;
wire [7:0] addr;
wire [11:0] imm;
wire [1:0] jmp_cond, pin_mode;

decoder u_dec (.rst(rst), .inst(inst),
               .is_set(is_set), .is_wait(is_wait), .is_out(is_out), .is_in(is_in),
               .is_delay(is_delay), .is_pull(is_pull), .is_push(is_push),
               .is_setx(is_setx), .is_jmp(is_jmp), .is_jmpp(is_jmpp),
               .is_pinmode(is_pinmode), .opcode(opcode), .pin_sel(pin_sel),
               .flag(flag), .addr(addr), .imm(imm), .jmp_cond(jmp_cond),
               .pin_mode(pin_mode), .illegal(illegal));

wire core_en;
wire delay_load, delay_done;
wire set_wr,out_wr,pinmode_wr;
wire osr_load,osr_shift,isr_shift;
wire fifo_pop,fifo_push_en;
wire x_load,x_dec,x_zero;
wire tx_empty,rx_full;
wire [7:0] pin_in;

control_unit u_ctrl (.clk(clk), .rst(rst), .host_run(host_run), .core_en(core_en),
                     .is_set(is_set), .is_wait(is_wait), .is_out(is_out), .is_in(is_in),
                     .is_delay(is_delay), .is_pull(is_pull), .is_push(is_push),
                     .is_setx(is_setx), .is_jmp(is_jmp), .is_pinmode(is_pinmode),
                     .jmp_cond(jmp_cond), .pin_sel(pin_sel), .flag(flag),
                     .pin_in(pin_in), .tx_empty(tx_empty), .rx_full(rx_full),
                     .delay_done(delay_done), .x_zero(x_zero),
                     .pc_en(pc_en), .delay_load(delay_load),
                     .set_wr(set_wr), .out_wr(out_wr), .pinmode_wr(pinmode_wr),
                     .osr_load(osr_load), .osr_shift(osr_shift), .isr_shift(isr_shift),
                     .fifo_pop(fifo_pop), .fifo_push_en(fifo_push_en),
                     .x_load(x_load), .x_dec(x_dec));

baud_gen u_baud (.clk(clk), .rst(rst), .baud_div(baud_div), .core_en(core_en));

wire osr_serial_out;
wire pin_level = pin_in[pin_sel];

branch_unit u_br (.is_jmp(is_jmp), .is_jmpp(is_jmpp), .jmp_cond(jmp_cond),
                  .flag(flag), .addr(addr), .pin_level(pin_level),
                  .x_zero(x_zero), .tx_empty(tx_empty),
                  .osr_next_bit(osr_serial_out),
                  .branch_taken(branch_taken), .branch_targ(branch_targ));

wire serial_in;
wire [7:0] isr_data, tx_rdata;

x_register u_x (.clk(clk), .rst(rst), .x_load(x_load), .x_dec(x_dec),
                .imm(imm), .x_zero(x_zero));

delay_counter u_dly (.clk(clk), .rst(rst), .core_en(core_en),
                     .delay_load(delay_load), .imm(imm), .delay_done(delay_done));

isr u_isr (.clk(clk), .rst(rst), .isr_shift(isr_shift), .dir(flag),
           .serial_in(serial_in), .isr_data(isr_data));

osr u_osr (.clk(clk), .rst(rst), .osr_load(osr_load), .osr_shift(osr_shift),
           .dir(flag), .load_data(tx_rdata), .serial_out(osr_serial_out));

gpio_block u_gpio (.clk(clk), .rst(rst),
                   .set_wr(set_wr), .out_wr(out_wr), .pinmode_wr(pinmode_wr),
                   .pin_sel(pin_sel), .set_val(flag), .osr_bit(osr_serial_out),
                   .pin_mode(pin_mode),
                   .io_in(io_in), .io_out(io_out), .io_oe(io_oe),
                   .pin_in(pin_in), .serial_in(serial_in));

wire tx_valid;
assign tx_empty = ~tx_valid;
assign tx_full  = tx_valid;

byte_buf u_txbuf (.clk(clk), .rst(rst), .wr(tx_wr), .wdata(tx_wdata),
                  .rd(fifo_pop), .rdata(tx_rdata), .valid(tx_valid));

byte_buf u_rxbuf (.clk(clk), .rst(rst), .wr(fifo_push_en), .wdata(isr_data),
                  .rd(rx_rd), .rdata(rx_rdata), .valid(rx_valid));

assign rx_full = rx_valid;

endmodule