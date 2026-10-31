/*
 * TinyTapeout wrapper for jane_street ProtoEmu
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_yourname_protoemu (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

  wire rst = ~rst_n;

  wire [7:0] io_out_w, io_oe_w;
  wire [7:0] rx_rdata_w;

  top u_top (
    .clk       (clk),
    .rst       (rst),
    .host_run  (ui_in[0]),
    .host_wr   (ui_in[1]),
    .host_waddr({4'd0, ui_in[7:4]}),
    .host_wdata(16'd0),
    .baud_div  (16'd1),
    .tx_wr     (ui_in[2]),
    .tx_wdata  (8'd0),
    .tx_full   (uo_out[0]),
    .rx_rd     (ui_in[3]),
    .rx_rdata  (rx_rdata_w),
    .rx_valid  (uo_out[1]),
    .io_in     (uio_in),
    .io_out    (io_out_w),
    .io_oe     (io_oe_w)
  );

  assign uo_out[7:2] = rx_rdata_w[5:0];
  assign uio_out = io_out_w;
  assign uio_oe  = io_oe_w;

  wire _unused = &{ena, rx_rdata_w[7:6], 1'b0};

endmodule
