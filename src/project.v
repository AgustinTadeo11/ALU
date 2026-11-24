/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */



`default_nettype none

module tt_um_ALU (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    wire [3:0] A   = ui_in[3:0];
    wire [3:0] B   = ui_in[7:4];
    wire [3:0] SEL = uio_in[2:0];

    reg [3:0] R;
    reg Carry;
    reg [4:0] temp;

    wire Zero = (R == 4'b0000);

    always @(*) begin
        R     = 4'b0000;
        Carry = 1'b0;
        temp  = 5'b00000;

        case (SEL)
            3'b000: begin
                temp  = {1'b0, A} + {1'b0, B};
                R     = temp[3:0];
                Carry = temp[4];
            end

            3'b001: begin
                temp  = {1'b0, A} - {1'b0, B};
                R     = temp[3:0];
                Carry = temp[4];
            end

            3'b0010: R = A & B;
            3'b0011: R = A | B;
            3'b0100: R = A ^ B;
            3'b0101: R = ~A;
            3'b0110: R = ~(A & B);
            3'b0111: R = ~(A | B);

            3'b1000:
                R = (A == B) ? 4'b0001 : 4'b0000;

            3'b1001:
                R = (A < B) ? 4'b0001 : 4'b0000;
            3'b1010;
                R = (A > B) ? 4'b0001 : 4'b0000;

            default: R = 4'b0000;
        endcase
    end

    // Asignacion de salidas
    assign uo_out = {2'b00, Zero, Carry, R};

    // Pines bidireccionales como entradas
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

    // Senales no utilizadas
    wire _unused = &{
        ena, clk, rst_n, uio_in[7:3], 1'b0
    };

endmodule

`default_nettype wire

