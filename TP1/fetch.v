module Fetch(
				input wire clock,
				input KEY0,
				input [15:0] PCin,
				output [15:0] PCout,
				output [3:0] codop,
				output [15:0] palavra
);
		always @(posedge clock and KEY[0]) begin
			PCout = PCin + 16'b0000000000000001;
			codop = 4'b0000;
			//palavra = SW0 até SW15
		end
endmodule
