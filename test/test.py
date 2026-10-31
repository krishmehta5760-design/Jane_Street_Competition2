# SPDX-FileCopyrightText: © 2024 KRISH MEHTA
# SPDX-License-Identifier: Apache-2.0
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
@cocotb.test()
async def test_reset(dut):
    """Basic reset test - ensure design comes out of reset cleanly."""
    dut._log.info("Start")
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())
    # Reset
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 5)
    dut._log.info("Reset complete, design is alive")
    # After reset with no host_run, outputs should be in a known state
    # tx_full (uo_out[0]) and rx_valid (uo_out[1]) should be low
    assert dut.uo_out.value[7] == 0, "tx_full should be 0 after reset"
    assert dut.uo_out.value[6] == 0, "rx_valid should be 0 after reset"
    dut._log.info("PASS: reset test")
