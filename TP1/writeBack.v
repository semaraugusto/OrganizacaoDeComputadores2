module writeBack (
  input clk,
  input [15:0] saida_alu,
  input [3:0] endereco_r3,
  output reg in_read, 
  output reg in_write
);

  // chamar banco de registradores e salvar
  always @(posedge clk and saida_alu) begin
    in_read = 1'b0;
    in_write = 1'b1;
  end


endmodule
