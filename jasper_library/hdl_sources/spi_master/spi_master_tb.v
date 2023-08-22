module spi_master_tb;

    reg clk = 0;
    always #5 clk = !clk;

    reg [2:0] cs_in;
    reg [2:0] cs_in_idle;
    reg [23:0] din;
    reg trigger = 0;
    reg ack;
    wire [23:0] dout;
    wire dvld;

    wire [2:0] cs;
    wire sclk;
    wire mosi;

    initial begin
      $dumpfile("spi_master_tb.vcd");
      $dumpvars(0,spi_master_tb);
      #55 din = 24'hdeadbe; cs_in = 3'b000; cs_in_idle = 3'b111; trigger = 1'b1;
      #10 din = 0; cs_in = 0; trigger = 0;
      #2500 $finish;
    end

    always @(posedge clk) begin
      if (dvld == 1'b1) begin
        ack <= 1'b1;
      end
    end

    spi_master #(
      .NCLKDIVBITS(2)
      ) uut (
      .clk(clk),
      .cs_in(cs_in),
      .cs_in_idle(cs_in_idle),
      .din(din),
      .trigger(trigger),
      .ack(ack),
      .dout(dout),
      .dvld(dvld),

      .cs(cs),
      .sclk(sclk),
      .mosi(mosi),
      .miso(~mosi) // Inverted loopback
    );

endmodule
