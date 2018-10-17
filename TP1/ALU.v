module ALU(
				input wire [15:0] a,
				input wire [15:0] b,
				input wire [3:0] Select,
				input wire [3:0] Imm,
				output reg [15:0] Result
		);
		
		always @( a, b, Select)
		begin
			case(Select)
			4'b0000:
			 Result <= a + b;
			4'b0001:
			 Result <= a - b;
			4'b0010:
			 begin
					if (b > Imm) begin
						Result <= 1;
					end else begin
						Result <= 0;
						end
			 end
			 4'b0011:
			  Result <= a & b;
			 4'b0100:
			  Result <= a | b;
			 4'b0101:
			  Result <= a ^ b;
			 4'b0110:
			  Result <= b & Imm;
			 4'b0111:
			  Result <= b | Imm;
			 4'b1000:
			  Result <= b ^ Imm;
			 4'b1001:
			  Result <= b + Imm;
			 4'b1010: 
			  Result <= b - Imm;
			 default: Result <= a + b;
			endcase
		end

endmodule
