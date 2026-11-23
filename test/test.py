# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0


import cocotb
from cocotb.triggers import Timer


def reference(a, b, sel):
    if sel == 0:
        value = a + b
        r, carry = value & 15, (value >> 4) & 1
    elif sel == 1:
        value = (a - b) & 31
        r, carry = value & 15, (value >> 4) & 1
    elif sel == 2:
        r, carry = a & b, 0
    elif sel == 3:
        r, carry = a | b, 0
    elif sel == 4:
        r, carry = a ^ b, 0
    elif sel == 5:
        r, carry = (~a) & 15, 0
    elif sel == 6:
        r, carry = int(a == b), 0
    else:
        r, carry = int(a < b), 0

    zero = int(r == 0)
    return r | (carry << 4) | (zero << 5)


@cocotb.test()
async def test_all_inputs(dut):

    dut.ena.value = 1
    dut.clk.value = 0
    dut.rst_n.value = 1

    for sel in range(8):
        for a in range(16):
            for b in range(16):

                dut.ui_in.value = (b << 4) | a
                dut.uio_in.value = sel

                await Timer(10, unit="ns")

                actual = int(dut.uo_out.value)
                expected = reference(a, b, sel)

                assert actual == expected, (
                    f"SEL={sel}, A={a}, B={b}: "
                    f"actual={actual}, esperado={expected}"
                )

                assert int(dut.uio_oe.value) == 0
                assert int(dut.uio_out.value) == 0

