module spi_mux#(
    parameter N = 3
)(
    input [N-1:0] cs_n,
    input [N-1:0] miso_i,
    output miso_o
);

// MASK with active high chip select, then reduce OR
wire [N-1:0] cs = ~cs_n;
wire [N-1:0] masked = miso_i & cs;
assign miso_o = |masked;

endmodule
