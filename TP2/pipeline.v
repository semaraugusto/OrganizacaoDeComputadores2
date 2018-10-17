module pipeline(
	input				CLOCK_50,// clock da placa
	input[3:0]		KEY, // Keys
	input[17:0]		SW,  // Sw
	output[8:0]		LEDG,
	output[0:6]		HEX0, // Display de 7 segmentos 0
	output[0:6]		HEX1, // Display de 7 segmentos 1
	output[0:6]		HEX2, // Display de 7 segmentos 2
	output[0:6]		HEX3, // Display de 7 segmentos 3
	output[0:6]		HEX4  // Display de 7 segmentos 4
);


reg [31:0] clk;
integer i;

reg mult, mult1, mult2, mult3; // flag pra multiplicação

reg [9:0] PC;						//Contador de Programa
reg [9:0] CICLO = 1021;			//Ciclo do processador
reg [15:0] IRF; 					//Instrucao no estagio fetch
reg [15:0] IRD; 					//Instrucao no estagio decode
reg [15:0] IRE; 					//Instrucao no estagio execute
reg [15:0] IRM0;
reg [15:0] IRM1;
reg [15:0] IRM2;
reg [15:0] IRM3;
reg [15:0] aux1;
reg [15:0] aux2;
reg [15:0] aux3;
reg [15:0] IRW; 					//Instrucao no estagio writeback
reg [15:0] registers [15:0];	//Banco de Registradores
reg [15:0] saida_ula; 			//Saida da ula no estagio de execute
reg [15:0] saida_ulaW; 			//Saida da ula no estagio de writeback
reg [15:0] R1E; 					//Primer operando a ser utilizado no estagio de execute
reg [15:0] R2E; 					//Segundo operando a ser utilizado no estagio de execute

reg [0:0] START = 0;				//Indica o estado de inicio do processador

wire [15:0] out_mem_inst;     //Saida da memoria de instrucoes

mem_inst mem_i(.address(PC),.clock(clk[25]),.q(out_mem_inst));	//Instancia do modulo da memoria de instrucoes. A saida da memoria e salva em out_mem_inst sempre que PC mudar

//displayDecoder DP7_0(.entrada(CICLO[7:0]),.saida(HEX0)); Testar na placa
//displayDecoder DP7_1(.entrada(registers[IRW[3:0]][7:0]),.saida(HEX1)); Testar na placa

assign LEDG[0] = clk[25];

always@(posedge CLOCK_50)begin
		clk = clk + 1;
end


always@(posedge clk[25]) //Fetch
begin
		
		if(KEY[0] == 0)	//Reiniciando o processador
		begin
			PC <= 1023;
			//Inicializacao do banco de registradores
			for(i = 0; i < 16; i = i + 1)
			begin
				registers[i] = 16'b0000000000000000;
			end
			registers[1] = 16'b0000000000000011;
			registers[2] = 16'b0000000000000011;
		end
		else if(KEY[0] == 1 && START == 0)	//Indica que o processador deve iniciar a execucao do codigo. START = 1
		begin
			START = 1;
			CICLO <= 1021;
		end
		else if(KEY[0] == 1 && START == 1)	//Estagio de fetch
		begin
			IRF <= out_mem_inst;	//Salva a saida da memoria em IRF
			PC <= PC + 1;			//PC incrementado em 1 para ler a proxima instrucao
			
			IRD <= IRF;				//Salva a instrucao lida em IRD para ser utilizada no estagio de decode
			CICLO <= CICLO + 1;  //Incrementa o ciclo 
		end
end


always@(posedge clk[25]) //Decode
begin
	if(START == 1 && KEY[0] == 1)
	begin
		R2E <= registers[IRD[3:0]];	//Salva o valor do primeiro operando a ser utilizado no estagio de execute
		
		if(IRD[15:12] == 4'b0011) // slti
		begin
			R1E <= IRD[7:4]; // == ao imm da instrução
		end
		
		else if(IRD[15:12] == 4'b0111) // andi
		begin
			R1E <= IRD[7:4];
		end
		
		else if(IRD[15:12] == 4'b1000) // ori
		begin
			R1E <= IRD[7:4];
		end	
		
		else if(IRD[15:12] == 4'b1001) // xori
		begin
			R1E <= IRD[7:4];
		end	
		
		else if(IRD[15:12] == 4'b1010) // addi
		begin
			R1E <= IRD[7:4];
		end	
		
		else if(IRD[15:12] == 4'b1011) // subi
		begin
			R1E <= IRD[7:4];
		end
		
		else 	
		begin
			R1E <= registers[IRD[7:4]];   //Salva o valor do segundo operando a ser utilizado no estagio de execute
		end
		
		if(IRD[15:12] == 4'b1100)
		begin
			mult <= 1;
			IRM0 <= IRD;
			R1E  <=  registers[IRD[7:4]];
		end
		else
		begin
			IRE <= IRD;							//Salva a instrucao no estagio de decode em IRE para ser utilizada no estagio de execute
		end
	
	end
end

always@(posedge clk[25] && IRE) // Execute
begin
	if(START == 1 && KEY[0] == 1)
	begin
		
		if((IRE[15:12] == 4'b0001) || (IRE[15:12] == 4'b1010))		//Adicao = 4'b0001 ou Addi
		begin
			saida_ula <= R1E + R2E;
		end
		
		else if((IRE[15:12] == 4'b0010) || (IRE[15:12] == 4'b1011)) //Subtracao = 4'b0010 ou Subi
		begin
			saida_ula <= R1E - R2E;
		end
		
		if(IRE[15:12] == 4'b0011) // Slti 
		begin
			if(R2E > R1E)
			begin
				saida_ula <= 1;
			end
			else
			begin
				saida_ula <= 0;
			end
			
		end
		
		else if((IRE[15:12] == 4'b0100) || (IRE[15:12] == 4'b0111)) // AND ou ANDI
		begin
			saida_ula <= R1E & R2E;
		end
		
		if((IRE[15:12] == 4'b0101) || (IRE[15:12] == 4'b1000)) // Or ou Ori
		begin
			saida_ula <= R1E | R2E;
		end
		
		else if((IRE[15:12] == 4'b0110) || (IRE[15:12] == 4'b1001)) // Xor ou Xori
		begin
			saida_ula <= R1E ^ R2E;
		end
		
		
		IRW <= IRE;						//Salva a instrucao no estagio de execute em IRW para ser utilizada no estagio de writeback
		saida_ulaW <= saida_ula;   
	end
end

always@(posedge clk[25]) // Y0
begin
    if(START == 1 && KEY[0] == 1 && mult == 1)
    begin
		  mult1 <= 1;
        IRM1 <= IRM0;
		  aux1 <= R1E * R2E;
    end
	 else if(START == 1 && KEY[0] == 1 && mult == 0)
	 begin
		  mult1 <= 0;
	 end
end

always@(posedge clk[25]) // y1
begin
    if(START == 1 && KEY[0] == 1 && mult1 == 1)
    begin
	     mult2 <= 1;
        IRM2 <= IRM1;
		  aux2 <= aux1;
    end
	 else if(START == 1 && KEY[0] == 1 && mult1 == 0)
	 begin
	     mult2 <= 0;
	 end
end

always@(posedge clk[25]) // y2
begin
    if(START == 1 && KEY[0] == 1 && mult2 == 1) 
    begin
		  mult3 <= 1;
        IRM3 <= IRM2;
		  aux3 <= aux2;
    end
	 else if(START == 1 && KEY[0] == 1 && mult2 == 0)
	 begin
		  mult3 <= 0;
	 end
end

always@(posedge clk[25]) // y3
begin
    if(START == 1 && KEY[0] == 1 && mult3 == 1)
    begin
        IRW <= IRM3;
        saida_ulaW <= aux3;
    end
end

always@(posedge clk[25]) //Writeback
begin
	if(IRW == 16'b0000000000000000)
	begin
		//não dar WB 
	end
	else if(START == 1 && KEY[0] == 1)
	begin
		registers[IRW[11:8]] <= saida_ulaW;	//Escreve no banco de registradores a saida da ula calculada no estagio de execute
	end
end

endmodule
