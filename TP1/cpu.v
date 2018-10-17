module I2O2();
	//cria as variaveis
	reg clock;
	reg [15:0] PC;
	reg [15:0] palavra; //de algum jeito essa variavel le da placa
	reg [3:0] codop;
	reg [15:0] r1;
	reg [3:0] imm;
	reg [15:0] r2;
	reg [15:0] r3;
	reg [3:0] endereco_r1;
	reg [3:0] endereco_r2;
	reg [3:0] endereco_r3;
	reg [15:0] saida_alu;
	reg in_write;
	reg in_read;
	reg [15:0] data;
	//SUPONHA UMA ENTRADA PRA KEY 0 chamada como KEY[0]
	

	regBank BancoRegs(.clock(clock), .readReg1(endereco_r1), .readReg2(endereco_r2), .in_write(in_write), .in_read(in_read), .readData1(r1), readData2(r2), .data(data), .ender(endereco_r3));
	ALU alu(.a(r1), .b(r2), .Select(codop), .Imm(imm), .Result(saida_alu));

	//cria as instancias dos modulos
	Fetch fetch(.clock(clock), .KEY0(KEY[0]), .PCin(PC), .PCout(PC), .codop(codop), .palavra(palavra));
	//Quando vc mudar o clock E apertar o KEY0, lá dentro do fetch a palavra vai ser lida. por padrão o PC é somado de 1 e o código de operação zerado.
	
	Decode decode(.clock(clock), .palavra(palavra), .codop(codop), .endereco_r1(endereco_r1), .endereco_r2(endereco_r2), .imm(imm), .endereco_r3(endereco_r3), .in_write(in_write), .in_read(in_read));
	//No código do decode só acontece mudança quando o clock muda e a palavra tb, mas repara que o que muda a palavra é o Fetch, o que implica em sequência
	//As mudanças que rolam no decode alteram os argumentos que o regbank usa, fazendo usar ele

	Execute execute(.clock(clock), .r1(r1), .r2(r2), .codop(codop), .imm(imm), .saida_alu(saida_alu)); //"inútil" no momento. podemos declarar a ALU aqui dentro, faz mais sentido.
	//com os endereços mudando o regbank vai automaticamente alterar os conteúdos em r1 e e2, que vao se alterar e então a ALU é disparada 

	WriteBack writeback(.clock(clock), .saida_alu(saida_alu), endereco_r3(endereco_r3), .in_write(in_write), .in_read(in_read));	
	//quando a saída da alu se altera e recebe um clock, o write back muda os sinais de in_write e in_read, forçando o reg bank novamente, agora para escrita
	
	//roda as inicializações em blocs contínuo
	initial begin
		PC = 16'b0000000000000000;
		imm = 4'b0000;
		//...
	end

	//roda o programa
	always begin 
	   #1 clock = ~clock; 
		//E atualiza a palavra de algum jeito que n~ao se sabe como
	end 
endmodule
