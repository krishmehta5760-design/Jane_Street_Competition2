module imem #(parameter N = 15) (clk,rst,pc,inst,host_wr,host_waddr,host_wdata);
input clk,rst;
input [31:0] pc;
output [15:0] inst;
input host_wr;
input [7:0] host_waddr;
input [15:0] host_wdata;

reg [N:0] mem [0:255];

assign inst = mem[pc[9:2]];

always@(posedge clk)
    if(host_wr) mem[host_waddr] <= host_wdata;
endmodule