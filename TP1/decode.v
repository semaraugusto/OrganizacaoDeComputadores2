module Decode(
  input            clk,
  input      [15:0]  palavra,
  output reg [3:0]   codop,
  output reg [3:0]   end_reg1,
  output reg [3:0]   end_reg2,
  output reg [3:0]   end_reg3,
  output reg [3:0]   imm,
  output reg in_write,
  output reg in_read,
);

  always @(posedge clk and palavra) begin
    codop = palavra[15:12];
    end_reg1 = palavra[11:8];
    imm      = palavra[11:8];
    end_reg2 = palavra[7:4];
    end_reg3 = palavra[3:0];
    in_read = 1'b1; //sempre no decode vai ler
    in_write = 1'b0; //escrever é só no write back
  end


endmodule
