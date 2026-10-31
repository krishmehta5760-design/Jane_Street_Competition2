/*
 * TinyTapeout wrapper for ProtoEmu with serial loader
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
  // ---- Serial shift-register loader (2 pins) ----
  // ui_in[7] = shift_en, ui_in[6] = serial data in (MSB first)
  // ui_in[5] = latch,    ui_in[4] = target select
  //   tgt_sel=0 → latch to host_wdata[15:0]
  //   tgt_sel=1 → latch to {host_waddr[7:0], tx_wdata[7:0]}
  wire shift_en = ui_in[7];
  wire sdi      = ui_in[6];
  wire latch    = ui_in[5];
  wire tgt_sel  = ui_in[4];
  reg [15:0] sr;
  reg [15:0] host_wdata_r;
  reg  [7:0] host_waddr_r;
  reg  [7:0] tx_wdata_r;
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      sr           <= 16'd0;
      host_wdata_r <= 16'd0;
      host_waddr_r <=  8'd0;
      tx_wdata_r   <=  8'd0;
    end else if (shift_en) begin
      sr <= {sr[14:0], sdi};
    end else if (latch) begin
      if (!tgt_sel)
        host_wdata_r <= sr;
      else begin
        host_waddr_r <= sr[15:8];
        tx_wdata_r   <= sr[7:0];
      end
    end
  end
  // ---- ProtoEmu core ----
  wire [7:0] io_out_w, io_oe_w;
  wire [7:0] rx_rdata_w;
  top u_top (
    .clk       (clk),
    .rst       (rst),
    .host_run  (ui_in[0]),
    .host_wr   (ui_in[1]),
    .host_waddr(host_waddr_r),       // ← NOW DYNAMIC
    .host_wdata(host_wdata_r),       // ← NOW DYNAMIC
    .baud_div  (16'd434),
    .tx_wr     (ui_in[2]),
    .tx_wdata  (tx_wdata_r),         // ← NOW DYNAMIC
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
