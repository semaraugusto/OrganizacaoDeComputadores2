
module regBank(input clock ,input [3:0]readReg1,input [3:0]readReg2, input [15:0]data, 
 input [3:0]ender, input in_write,input in_read, output reg [15:0] readData1,
 output reg [15:0] readData2);

	//registradores do banco
	reg [15:0] registradores[15:0];
	
	//iniciar registradores com 0
	initial 
	begin
		 registradores[0]<= 16'h00000000;
		 registradores[1]<= 16'h00000000;
		 registradores[2]<= 16'h00000000;
		 registradores[3]<= 16'h00000000;
		 registradores[4]<= 16'h00000000;
		 registradores[5]<= 16'h00000000;
		 registradores[6]<= 16'h00000000;
		 registradores[7]<= 16'h00000000;
		 registradores[8]<= 16'h00000000;
		 registradores[9]<= 16'h00000000;
		registradores[10]<= 16'h00000000;
		registradores[11]<= 16'h00000000;
		registradores[12]<= 16'h00000000;
		registradores[13]<= 16'h00000000;
		registradores[14]<= 16'h00000000;
		registradores[15]<= 16'h00000000;
	end
	
	// Read e Write
	always @(posedge clock)
	begin
	
		if(in_write) begin
			registradores[ender] <= data;
		end 
		
	end
	
	//escreve no clock negedge
	always @(negedge clock)
	begin
	
		if(in_read)begin
			readData1 <= registradores[readReg1];
			readData2 <= registradores[readReg2];
		end
		
	end	
endmodule
