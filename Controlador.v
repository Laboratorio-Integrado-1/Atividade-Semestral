module Contolador (Clock50, reset, Entradas, v_sync, avancar, head, left, under, barrier ,girar, remover, LEDG, LEDR, LinhaSprites1, LinhaSprites2, LinhaSprites3, LinhaSprites4, LinhaSprites5, LinhaSprites6, LinhaSprites7, LinhaSprites8, LinhaSprites9, LinhaSprites10);

parameter N = 2'b00, S = 2'b01, L = 2'b10, O = 2'b11;

input Clock50, reset, v_sync;
input [11:0] Entradas;

input avancar, girar, remover;
output reg head, left, under, barrier;

output reg [79:0] LinhaSprites1, LinhaSprites2, LinhaSprites3, LinhaSprites4, LinhaSprites5, LinhaSprites6, LinhaSprites7, LinhaSprites8, LinhaSprites9, LinhaSprites10;
reg [79:0] linha_temp; // Inicializa um registrador temporÃ¡rio para armazenar a linha convertida
output reg [7:0] LEDG;
output reg [7:0] LEDR;

reg [3:0] Mapa [0:10][0:19];

integer entulho_life; // Vida do entulho, representa quantas iteracoes sÃ£o necessarias para remove-lo

reg [5:0] ColunaCelulaPreta;
reg [5:0] ColunaRobo;
reg [5:0] ColunaCursor;

reg [3:0] Orientacao_Hex; 
reg [7:0] Orientacao_Robo;

reg [5:0] LinhaCelulaPreta;
reg [5:0] LinhaRobo;
reg [5:0] LinhaCursor;

reg [5:0] ContadorFrames;
reg [5:0] ContadorFramesRobo;
reg IteracaoRobo;
reg HabilitaNovaLeitura;

reg [79:0] temp [0:10];
integer i, j;

reg step_mode;
reg btn_step;

// Flag baseado na deteccao de borda de subida de v_sync
reg v_sync_Primeiro_FlipFLop, v_sync_Segundo_FlipFLop;
wire Flag;

always @(negedge Clock50)
begin
	v_sync_Primeiro_FlipFLop <= v_sync;
	v_sync_Segundo_FlipFLop <= v_sync_Primeiro_FlipFLop;
end

assign Flag = v_sync_Primeiro_FlipFLop && !v_sync_Segundo_FlipFLop;

always @(posedge Clock50)
begin
	if (reset)
	begin		
		// ConfiguraÃ§Ã£o do mapa 
        // 0: Caminho Livre -	Celula onde o robÃ´ pode se mover livremente.
        // 1: Parede - Obstaculo que impede o movimento do robÃ´.
        // 2: Celula Preta - CÃ©lula que indica o inicio ou final de uma tubulacao.
        // 3: Entulho Leve - Entulho que requer 3 ciclos para ser removido.
        // 4: Entulho Medio - Entulho que requer 6 ciclos para ser removido.
        // 5: Entulho Pesado - Entulho que requer 9 ciclos para ser removido.

        $readmemh("Mapa.txt", temp);

        LinhaRobo = temp[0][79:72]; //  (0Âº linha, 0-1 caracteres)
        ColunaRobo = temp[0][71:64]; // (0Âº linha, 2-3 caracteres)
        Orientacao_Hex = temp[0][63:60]; // (0Âº linha, 4Âº caractere)
        
        // Converter o valor hexadecimal da orientacao para a string correspondente
        case (Orientacao_Hex)
            4'h0: Orientacao_Robo = N; // 0 -> N
            4'h1: Orientacao_Robo = O; // 1 -> O
            4'h2: Orientacao_Robo = S; // 2 -> S
            4'h3: Orientacao_Robo = L; // 3 -> L
            default: Orientacao_Robo = N;
        endcase

        // Preencher a matriz com os valores restantes
        for (i = 0; i < 10; i = i + 1) begin
            for (j = 0; j < 20; j = j + 1) begin
                if (temp[i+1][79 - j*4 -: 4] == 2) begin // IdentificaÃ§Ã£o da celula preta
                    LinhaCelulaPreta = i;
                    ColunaCelulaPreta = j;
                end
                Mapa[i][j] = temp[i+1][79 - j*4 -: 4]; // Preencher a matriz ignorando a primeira linha
            end
        end
		
	    HabilitaNovaLeitura = 1;
	    LEDG <= 8'b00010000;
        LEDR <= 8'b00010000;
        left <= 0;
        under <= 0;
        barrier <= 0;
        step_mode <= 0; // Inicializa no modo contÃ­nuo
        btn_step <= 0; // Inicializa no modo contÃ­nuo
        entulho_life <= 0; // Inicializa a vida do entulho como 0
        linha_temp <= 80'b0;
	end
	
	if (HabilitaNovaLeitura && Flag)
	begin
		HabilitaNovaLeitura <= 0;
		ContadorFrames <= 0;		
		
		Le_Inputs;
        Define_Sensores;
	end


    if (IteracaoRobo && Flag)
    begin
        IteracaoRobo <= 0;
        ContadorFramesRobo <= 0;

        // Espera o robÃ´ rodar para atualizar a posiÃ§Ã£o
        @ (negedge Clock50);

        // VerificaÃ§Ãµes do tipo de execuÃ§Ã£o
        if (step_mode && btn_step) begin
            Atualiza_Posicao_Robo;
            btn_step <= 0;
        end
        
        if(!step_mode) begin
            Atualiza_Posicao_Robo;
        end
    end

    if (Situacoes_Anomalas(1)) begin
        $display("Estado AnÃ´malo Detectado. Aguardando reset...");
        @ (negedge reset);
    end 

	if (Flag)
	begin
		if (ContadorFrames == 4)
		begin
			HabilitaNovaLeitura <= 1;
			ContadorFrames <= 0;
		end
		else
		begin
			ContadorFrames <= ContadorFrames + 1;	
		end

        if(ContadorFramesRobo == 8)
        begin
            ContadorFramesRobo <= 0;
            IteracaoRobo <= 1;
        end
        else
        begin
            ContadorFramesRobo <= ContadorFramesRobo + 1;
        end

	end	
end

always @(negedge Clock50)
begin
    Atualiza_Tela;
end

task Le_Inputs;
begin
    // Tratamento de entradas do gamepad
    // Entradas[11] = Saida_Mode
    // Entradas[10] = Saida_Start
    // Entradas[9] = Saida_Z
    // Entradas[8] = Saida_Y
    // Entradas[7] = Saida_X
    // Entradas[6] = Saida_C
    // Entradas[5] = Saida_B
    // Entradas[4] = Saida_A
    // Entradas[3] = Saida_Right
    // Entradas[2] = Saida_Left
    // Entradas[1] = Saida_Down
    // Entradas[0] = Saida_Up 
    
    // Atualiza posiÃ§Ã£o do robÃ´
    if (Entradas[4])
    begin
        if (Mapa[LinhaRobo][ColunaRobo] == 0 || Mapa[LinhaRobo][ColunaRobo] == 2) begin
            ColunaRobo <= ColunaCursor;
            LinhaRobo <= LinhaCursor;
        end
    end

    // Atualiza posiÃ§Ã£o do cursor (Saida_Up)
    if (Entradas[0])
    begin
        if (LinhaCursor == 1)
        begin
            LinhaCursor <= 5;
        end
        else
        begin
            LinhaCursor <= LinhaCursor - 1;
        end

        // Desloca LED Vermelho p/ Esquerda
        if (LEDR == 8'b10000000 || LEDR == 8'b00000000)
        begin
            LEDR <= 8'b00000001;
        end
        else 
        begin
            LEDR <= LEDR << 1;
        end
    end
    
    // Atualiza posiÃ§Ã£o do cursor (Saida_Down)
    if (Entradas[1])
    begin
        if (LinhaCursor == 5)
        begin
            LinhaCursor <= 1;
        end
        else
        begin
            LinhaCursor <= LinhaCursor + 1;
        end

        // Desloca LED Vermelho p/ Direita
        if (LEDR == 8'b10000000 || LEDR == 8'b00000000)
        begin
            LEDR <= 8'b10000000;
        end
        else 
        begin
            LEDR <= LEDR >> 1;
        end
    end
    
    // Atualiza posiÃ§Ã£o do cursor (Saida_Left)
    if (Entradas[2])
    begin
        if (ColunaCursor == 1)
        begin
            ColunaCursor <= 10;
        end
        else
        begin
            ColunaCursor <= ColunaCursor - 1;
        end
        
        // Desloca LED Verde p/ Esquerda
        if (LEDG == 8'b10000000 || LEDG == 8'b00000000)
        begin
            LEDG <= 8'b00000001;
        end
        else 
        begin
            LEDG <= LEDG << 1;
        end
    end
    
    // Atualiza posiÃ§Ã£o do cursor (Saida_Right)
    if (Entradas[3])
    begin
        if (ColunaCursor == 10)
        begin
            ColunaCursor <= 1;
        end
        else
        begin
            ColunaCursor <= ColunaCursor + 1;
        end

        // Desloca LED Verde p/ Direita
        if (LEDG == 8'b00000001 || LEDG == 8'b00000000)
        begin
            LEDG <= 8'b10000000;
        end
        else 
        begin
            LEDG <= LEDG >> 1;
        end
    end		

    // Atualiza posiÃ§Ã£o da celula preta 
    if (Entradas[5])
    begin
        if (Mapa[LinhaCursor][ColunaCursor] == 0) begin
            Mapa[LinhaCursor][ColunaCursor] <= 1;
            Mapa[LinhaCelulaPreta][ColunaCelulaPreta] <= 0;
        end

        // Acende LEDs Verde e Vermelho
        LEDG <= 8'b01110111;
        LEDR <= 8'b01110111;
    end
    else
    begin
        // Apaga as LEDs Verde e Vermelho, exceto [4]
        LEDG <= 8'b00010000;
        LEDR <= 8'b00010000;
    end

    // Remove entulho
    if (Entradas[6])
    begin
        if (Mapa[LinhaCursor][ColunaCursor] > 2) begin
            Mapa[LinhaCursor][ColunaCursor] <= 0;
        end

        // Acende LEDs Verde e Vermelho
        LEDG <= 8'b10111011;
        LEDR <= 8'b10111011;
    end
    else
    begin
        // Apaga as LEDs Verde e Vermelho, exceto [4]
        LEDG <= 8'b00010000;
        LEDR <= 8'b00010000;
    end

    // Adiciona entulho leve
    if (Entradas[7])
    begin
        if (Mapa[LinhaCursor][ColunaCursor] == 0 || Mapa[LinhaCursor][ColunaCursor] > 2) begin
            Mapa[LinhaCursor][ColunaCursor] <= 3;
        end

        // Acende LEDs Verde e Vermelho
        LEDG <= 8'b11011101;
        LEDR <= 8'b11011101;
    end
    else
    begin
        // Apaga as LEDs Verde e Vermelho, exceto [4]
        LEDG <= 8'b00010000;
        LEDR <= 8'b00010000;
    end

    // Adiciona entulho medio
    if (Entradas[8])
    begin
        if (Mapa[LinhaCursor][ColunaCursor] == 0 || Mapa[LinhaCursor][ColunaCursor] > 2) begin
            Mapa[LinhaCursor][ColunaCursor] <= 4;
        end

        // Acende LEDs Verde e Vermelho
        LEDG <= 8'b11101110;
        LEDR <= 8'b11101110;
    end
    else
    begin
        // Apaga as LEDs Verde e Vermelho, exceto [4]
        LEDG <= 8'b00010000;
        LEDR <= 8'b00010000;
    end

    // Adiciona entulho pesado
    if (Entradas[9])
    begin
        if (Mapa[LinhaCursor][ColunaCursor] == 0 || Mapa[LinhaCursor][ColunaCursor] > 2) begin
            Mapa[LinhaCursor][ColunaCursor] <= 5;
        end

        // Acende LEDs Verde e Vermelho
        LEDG <= 8'b10010001;
        LEDR <= 8'b10010001;
    end
    else
    begin
        // Apaga as LEDs Verde e Vermelho, exceto [4]
        LEDG <= 8'b00010000;
        LEDR <= 8'b00010000;
    end

    // Atualiza passo, para modo de passo-a-passo
    if (Entradas[10])
    begin
        if (step_mode) begin
            btn_step <= 1;
        end

        // Acende LEDs Verde e Vermelho
        LEDG <= 8'b01100110;
        LEDR <= 8'b01100110;
    end
    else
    begin
        // Apaga as LEDs Verde e Vermelho, exceto [4]
        LEDG <= 8'b00010000;
        LEDR <= 8'b00010000;
    end

    // Atualiza modo de execuÃ§Ã£o
    if (Entradas[11])
    begin
        step_mode <= ~step_mode;

        // Acende LEDs Verde e Vermelho
        LEDG <= 8'b11100111;
        LEDR <= 8'b11100111;
    end
    else
    begin
        // Apaga as LEDs Verde e Vermelho, exceto [4]
        LEDG <= 8'b00010000;
        LEDR <= 8'b00010000;
    end
end
endtask

task Define_Sensores;
begin
    case (Orientacao_Robo)
        N: begin
                // Definicao de head
                if (LinhaRobo == 0) // Situacao de borda do mapa
                    head = 1;
                else
                    head = (Mapa[LinhaRobo - 1][ColunaRobo] == 1) ? 1 : 0;

                // Definiacao de left
                if (ColunaRobo == 0) // Situacao de borda do mapa
                    left = 1;
                else
                    left = (Mapa[LinhaRobo][ColunaRobo - 1] == 1) ? 1 : 0;

                // Definicao de under
                under = (Mapa[LinhaRobo][ColunaRobo] == 2) ? 1 : 0;

                // DefiniÃ§Ã£o de barrier
                if (LinhaRobo == 0) // Situacao de borda do mapa
                    barrier = 0;
                else if (Mapa[LinhaRobo - 1][ColunaRobo] >= 3) begin
                    if (entulho_life == 0) begin
                    case (Mapa[LinhaRobo - 1][ColunaRobo])
                         3: entulho_life = 3; // Entulho leve
                         4: entulho_life = 6; // Entulho medio
                         5: entulho_life = 9; // Entulho pesado
                    endcase
		    end
                    barrier = 1;
                end else begin
                    barrier = 0;
                end
            end
        S: begin
                // Definicao de head
                if (LinhaRobo == 9)
                    head = 1;
                else
                    head = (Mapa[LinhaRobo + 1][ColunaRobo] == 1) ? 1 : 0;

                // Definicao de left
                if (ColunaRobo == 19)
                    left = 1;
                else
                    left = (Mapa[LinhaRobo][ColunaRobo + 1] == 1) ? 1 : 0;

                // Definicao de under
                under = (Mapa[LinhaRobo][ColunaRobo] == 2) ? 1 : 0;

                // Definicao de barrier
                if (LinhaRobo == 9)
                    barrier = 0;
                else if (Mapa[LinhaRobo + 1][ColunaRobo] >= 3) begin
                    if (entulho_life == 0) begin
                    case (Mapa[LinhaRobo + 1][ColunaRobo])
                         3: entulho_life = 3; // Entulho leve
                         4: entulho_life = 6; // Entulho medio
                         5: entulho_life = 9; // Entulho pesado
                    endcase
		    end
                    barrier = 1;
                end else begin
                    barrier = 0;
                end
            end
        L: begin
                // Definicao de head
                if (ColunaRobo == 19)
                    head = 1;
                else
                    head = (Mapa[LinhaRobo][ColunaRobo + 1] == 1) ? 1 : 0;

                // Definicao de left
                if (LinhaRobo == 0)
                    left = 1;
                else
                    left = (Mapa[LinhaRobo - 1][ColunaRobo] == 1) ? 1 : 0;

                // Definicao de under
                under = (Mapa[LinhaRobo][ColunaRobo] == 2) ? 1 : 0;

                // Definicao de barrier
                if (ColunaRobo == 19)
                    barrier = 0;
                else if (Mapa[LinhaRobo][ColunaRobo + 1] >= 3) begin
                    if (entulho_life == 0) begin
                    case (Mapa[LinhaRobo][ColunaRobo + 1])
                         3: entulho_life = 3; // Entulho leve
                         4: entulho_life = 6; // Entulho medio
                         5: entulho_life = 9; // Entulho pesado
                    endcase
		    end
                    barrier = 1;
                end else begin
                    barrier = 0;
                end
            end
        O: begin
                // Definicao de head
                if (ColunaRobo == 0)
                    head = 1;
                else
                    head = (Mapa[LinhaRobo][ColunaRobo - 1] == 1) ? 1 : 0;

                // Definicao de left
                if (LinhaRobo == 9)
                    left = 1;
                else
                    left = (Mapa[LinhaRobo + 1][ColunaRobo] == 1) ? 1 : 0;

                // Definicao de under
                under = (Mapa[LinhaRobo][ColunaRobo] == 2) ? 1 : 0;

                // Definicao de barrier
                if (ColunaRobo == 0)
                    barrier = 0;
                else if (Mapa[LinhaRobo][ColunaRobo - 1] >= 3) begin
		    if (entulho_life == 0) begin
                    case (Mapa[LinhaRobo][ColunaRobo - 1])
                         3: entulho_life = 3; // Entulho leve
                         4: entulho_life = 6; // Entulho medio
                         5: entulho_life = 9; // Entulho pesado
                    endcase
		    end
                    barrier = 1;
                end else begin
                    barrier = 0;
                end
            end
    endcase
end
endtask

task Atualiza_Posicao_Robo;
begin
    if (entulho_life > 0 && remover) begin
        entulho_life = entulho_life - 1;
        $display("Removendo entulho... %d ciclos restantes", entulho_life);
        if (entulho_life == 0) begin
	    case (Orientacao_Robo)
		N: begin
			Mapa[LinhaRobo - 1][ColunaRobo] = 0;
		end
		S: begin
			Mapa[LinhaRobo + 1][ColunaRobo] = 0;
		end
		L: begin
			Mapa[LinhaRobo][ColunaRobo + 1] = 0;
		end		
		O: begin
			Mapa[LinhaRobo][ColunaRobo - 1] = 0;
		end
		
            endcase
	for (i = 0; i < 10; i = i + 1) begin
        	for (j = 0; j < 20; j = j + 1) begin
            		$write("%h", Mapa[i][j]);
        	end
      		$write("\n");
    	end
        $display("Entulho removido.");
        end
    end else begin
        case (Orientacao_Robo)
            N: begin
                    if (avancar)
                    begin
                        LinhaRobo = LinhaRobo - 1;
                    end
                    else if (girar)
                    begin
                        Orientacao_Robo = O;
                    end
                end
            S: begin
                    if (avancar)
                    begin
                        LinhaRobo = LinhaRobo + 1;
                    end
                    else if (girar)
                    begin
                        Orientacao_Robo = L;
                    end
                end
            L: begin
                    if (avancar)
                    begin
                        ColunaRobo = ColunaRobo + 1;
                    end
                    else if (girar)
                    begin
                        Orientacao_Robo = N;
                    end
                end
            O: begin
                    if (avancar)
                    begin
                        ColunaRobo = ColunaRobo - 1;
                    end
                    else if (girar)
                    begin
                        Orientacao_Robo = S;
                    end
                end
        endcase
    end
end
endtask

task Atualiza_Tela;
begin
    // Iterar sobre cada linha do mapa
    for(i = 0; i < 11; i = i + 1) begin
        // Iterar sobre cada coluna da linha
        for(j = 0; j < 20; j = j + 1) begin
            linha_temp = {linha_temp[75:0], Mapa[i][j]}; // Concatena o valor atual com a linha convertida
        end

        // Armazena a linha convertida no registrador de saÃ­da correspondente
        case(i)
            0: LinhaSprites1 = linha_temp;
            1: LinhaSprites2 = linha_temp;
            2: LinhaSprites3 = linha_temp;
            3: LinhaSprites4 = linha_temp;
            4: LinhaSprites5 = linha_temp;
            5: LinhaSprites6 = linha_temp;
            6: LinhaSprites7 = linha_temp;
            7: LinhaSprites8 = linha_temp;
            8: LinhaSprites9 = linha_temp;
            9: LinhaSprites10 = linha_temp;
        endcase
    end
end
endtask

function Situacoes_Anomalas (input X);
begin
    Situacoes_Anomalas = 0;
    if ( (LinhaRobo < 0) || (LinhaRobo > 9) || (ColunaRobo < 0) || (ColunaRobo > 19) ) // Mapa 10 x 20 
        Situacoes_Anomalas = 1;
    else
    begin
        if (Mapa[LinhaRobo][ColunaRobo] == 1 || Mapa[LinhaRobo][ColunaRobo] >= 3)
            Situacoes_Anomalas = 1;
    end
end
endfunction

endmodule 