module Controlador (Clock50, reset, Entradas, v_sync, avancar, head, left, under, barrier ,girar, remover, LEDG, LEDR, ColunasSprites, LinhasSprites, OrientacaoRobo);

parameter N = 2'b00, S = 2'b01, L = 2'b10, O = 2'b11;

parameter CaminhoLivre = 3'b110,
          Parede = 3'b101,
          CelulaPreta = 3'b100;

input Clock50, reset, v_sync;
input [11:0] Entradas;

input avancar, girar, remover;
output reg head, left, under, barrier;

output reg [7:0] LEDG;
output reg [7:0] LEDR;
output reg [29:0] ColunasSprites;
output reg [23:0] LinhasSprites;
output reg [1:0] OrientacaoRobo;

reg [3:0] Mapa [0:9][0:19];

reg [79:0] MapaTemp [0:10];

integer entulho_life; // Vida do entulho, representa quantas iteracoes sÃ£o necessarias para remove-lo

reg [4:0] ColunaCelulaPreta, ColunaRobo, ColunaCursor;
reg [3:0] LinhaCelulaPreta, LinhaRobo, LinhaCursor;

reg [3:0] Orientacao_Hex; 
reg [1:0] Orientacao_Robo;

reg [5:0] ContadorFrames, ContadorFramesRobo;

reg [4:0] ColunaEntulhoLeve, ColunaEntulhoMedio, ColunaEntulhoPesado;
reg [3:0] LinhaEntulhoLeve, LinhaEntulhoMedio, LinhaEntulhoPesado;

reg IteracaoRobo, HabilitaNovaLeitura;

reg [79:0] temp [0:10];
integer i, j;

reg step_mode;
reg btn_step;

// Flag baseado na deteccao de borda de subida de v_sync
reg v_sync_Primeiro_FlipFLop, v_sync_Segundo_FlipFLop;
wire Flag;

task taskLerMapa
	begin
		 /*
		 MapaTemp[0] = 80'h11111111111111111111;
		 MapaTemp[1] = 80'h10001000000000001111;
		 MapaTemp[2] = 80'h10101010111111101111;
		 MapaTemp[3] = 80'h10101010000000000001;
		 MapaTemp[4] = 80'h10101010111111101111;
		 MapaTemp[5] = 80'h10100010111111101111;
		 MapaTemp[6] = 80'h10101110111111101111;
		 MapaTemp[7] = 80'h10101110111111101111;
		 MapaTemp[8] = 80'h10101110111111101111;
		 MapaTemp[9] = 80'h10000000000000001111;
		 */

		 MapaTemp[0] = 80'h55555555555555555555;
		 MapaTemp[1] = 80'h56665666666666665555;
		 MapaTemp[2] = 80'h56565656555555565555;
		 MapaTemp[3] = 80'h56565656666666666665;
		 MapaTemp[4] = 80'h56565656555555565555;
		 MapaTemp[5] = 80'h56566656555555565555;
		 MapaTemp[6] = 80'h56565556555555565555;
		 MapaTemp[7] = 80'h56565556555555565555;
		 MapaTemp[8] = 80'h56565556555555565555;
		 MapaTemp[9] = 80'h56666666666666665555;

		 for (i = 0; i < 10; i = i + 1) begin
			  for (j = 0; j < 20; j = j + 1) begin
					Mapa[i][j] = MapaTemp[i][79 - j*4 -: 4];
			  end
		 end
	end
endtask

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

        /*
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
        */		
		  
		  taskLerMapa;

        // Inicializacao dos valores
        LinhaRobo <= 4'h03;
        ColunaRobo <= 5'h12;
        LinhaCelulaPreta <= 4'h03;
        ColunaCelulaPreta <= 5'h12;
        Orientacao_Robo <= L;

        LinhaEntulhoLeve <= 4'h14;
        ColunaEntulhoLeve <= 5'h14;
        LinhaEntulhoMedio <= 4'h5;
        ColunaEntulhoMedio <= 5'h0F;
        LinhaEntulhoPesado <= 4'h03;
        ColunaEntulhoPesado <= 5'h11;

        ColunaCursor <= 5'h0A;
        LinhaCursor <= 4'h03;

	    HabilitaNovaLeitura <= 1;
        IteracaoRobo <= 1;

	    LEDG <= 8'b00010000;
        LEDR <= 8'b00010000;
        head <= 0;
        left <= 0;
        under <= 0;
        barrier <= 0;
        step_mode <= 0;
        btn_step <= 0; 
        entulho_life <= 0; // Inicializa a vida do entulho como 0
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
        if (Mapa[LinhaCursor][ColunaCursor] == CaminhoLivre) begin
            ColunaRobo <= ColunaCursor;
            LinhaRobo <= LinhaCursor;
        end
        else if (LinhaCursor == LinhaCelulaPreta && ColunaCursor == ColunaCelulaPreta)
        begin
            ColunaRobo <= ColunaCursor;
            LinhaRobo <= LinhaCursor;
        end
    end

    // Atualiza posiÃ§Ã£o do cursor (Saida_Up)
    if (Entradas[0])
    begin
        if (LinhaCursor == 0)
        begin
            LinhaCursor <= 9;
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
        if (LinhaCursor == 9)
        begin
            LinhaCursor <= 0;
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
        if (ColunaCursor == 0)
        begin
            ColunaCursor <= 19;
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
        if (ColunaCursor == 19)
        begin
            ColunaCursor <= 0;
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
        if (Mapa[LinhaCursor][ColunaCursor] == CaminhoLivre)
        begin
            LinhaCelulaPreta <= LinhaCursor;
            ColunaCelulaPreta <= ColunaCursor;
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
        if (LinhaCursor == LinhaEntulhoLeve && ColunaCursor == ColunaEntulhoLeve) begin
            ColunaEntulhoLeve <= 20;
            LinhaEntulhoLeve <= 20;
        end
        else if (LinhaCursor == LinhaEntulhoMedio && ColunaCursor == ColunaEntulhoMedio) begin
            ColunaEntulhoMedio <= 20;
            LinhaEntulhoMedio <= 20;
        end
        else if (LinhaCursor == LinhaEntulhoPesado && ColunaCursor == ColunaEntulhoPesado) begin
            ColunaEntulhoPesado <= 20;
            LinhaEntulhoPesado <= 20;
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
        if (Mapa[LinhaCursor][ColunaCursor] == CaminhoLivre && LinhaEntulhoLeve == 20 & ColunaEntulhoLeve == 20) begin
            LinhaEntulhoLeve <= LinhaCursor;
            ColunaEntulhoLeve <= ColunaCursor;
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
        if (Mapa[LinhaCursor][ColunaCursor] == CaminhoLivre && LinhaEntulhoMedio == 20 & ColunaEntulhoMedio == 20) begin
            LinhaEntulhoMedio <= LinhaCursor;
            ColunaEntulhoMedio <= ColunaCursor;
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
        if (Mapa[LinhaCursor][ColunaCursor] == CaminhoLivre && LinhaEntulhoPesado == 20 & ColunaEntulhoPesado == 20) begin
            LinhaEntulhoPesado <= LinhaCursor;
            ColunaEntulhoPesado <= ColunaCursor;
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
                head <= 1;
            else
                head <= (Mapa[LinhaRobo - 1][ColunaRobo] == Parede) ? 1 : 0;

            // Definiacao de left
            if (ColunaRobo == 0) // Situacao de borda do mapa
                left <= 1;
            else
                left <= (Mapa[LinhaRobo][ColunaRobo - 1] == Parede) ? 1 : 0;

            // Definicao de under
            under <= (LinhaRobo == LinhaCelulaPreta && ColunaRobo == ColunaCelulaPreta) ? 1 : 0;

            // Definicao de barrier
            if (LinhaRobo == 0)// Situacao de borda do mapa
                barrier <= 0;
            else if(LinhaRobo - 1 == LinhaEntulhoLeve && ColunaRobo == ColunaEntulhoLeve) begin
                if (entulho_life == 0) begin
                    entulho_life <= 3; // Entulho leve
                end
                barrier <= 1;
            end else if(LinhaRobo - 1 == LinhaEntulhoMedio && ColunaRobo == ColunaEntulhoMedio) begin
                if (entulho_life == 0) begin
                    entulho_life <= 6; // Entulho medio
                end
                barrier <= 1;
            end else if(LinhaRobo - 1 == LinhaEntulhoPesado && ColunaRobo == ColunaEntulhoPesado) begin
                if (entulho_life == 0) begin
                    entulho_life <= 9; // Entulho pesado
                end
                barrier <= 1;
            end else begin
                barrier <= 0;
            end
            end
        S: begin
            // Definicao de head
            if (LinhaRobo == 9)
                head <= 1;
            else
                head = (Mapa[LinhaRobo + 1][ColunaRobo] == Parede) ? 1 : 0;

            // Definicao de left
            if (ColunaRobo == 19)
                left <= 1;
            else
                left <= (Mapa[LinhaRobo][ColunaRobo + 1] == Parede) ? 1 : 0;

            // Definicao de under
            under <= (LinhaRobo == LinhaCelulaPreta && ColunaRobo == ColunaCelulaPreta) ? 1 : 0;

            // Definicao de barrier
            if (LinhaRobo == 9) // Situacao de borda do mapa
                barrier <= 0;
            else if(LinhaRobo + 1 == LinhaEntulhoLeve && ColunaRobo == ColunaEntulhoLeve) begin
                if (entulho_life == 0) begin
                    entulho_life <= 3; // Entulho leve
                end
                barrier <= 1;
            end else if(LinhaRobo + 1 == LinhaEntulhoMedio && ColunaRobo == ColunaEntulhoMedio) begin
                if (entulho_life == 0) begin
                    entulho_life <= 6; // Entulho medio
                end
                barrier <= 1;
            end else if(LinhaRobo + 1 == LinhaEntulhoPesado && ColunaRobo == ColunaEntulhoPesado) begin
                if (entulho_life == 0) begin
                    entulho_life <= 9; // Entulho pesado
                end
                barrier = 1;
            end else begin
                barrier <= 0;
            end
            end
        L: begin
            // Definicao de head
            if (ColunaRobo == 19)
                head <= 1;
            else
                head <= (Mapa[LinhaRobo][ColunaRobo + 1] == Parede) ? 1 : 0;

            // Definicao de left
            if (LinhaRobo == 0)
                left = 1;
            else
                left <= (Mapa[LinhaRobo - 1][ColunaRobo] == Parede) ? 1 : 0;

            // Definicao de under
            under <= (LinhaRobo == LinhaCelulaPreta && ColunaRobo == ColunaCelulaPreta) ? 1 : 0;

            // Definicao de barrier
            if (ColunaRobo == 19)
                barrier <= 0;
            else if(LinhaRobo == LinhaEntulhoLeve && ColunaRobo + 1 == ColunaEntulhoLeve) begin
                if (entulho_life == 0) begin
                    entulho_life <= 3; // Entulho leve
                end
                barrier <= 1;
            end else if(LinhaRobo == LinhaEntulhoMedio && ColunaRobo + 1 == ColunaEntulhoMedio) begin
                if (entulho_life == 0) begin
                    entulho_life <= 6; // Entulho medio
                end
                barrier <= 1;
            end else if(LinhaRobo == LinhaEntulhoPesado && ColunaRobo + 1 == ColunaEntulhoPesado) begin
                if (entulho_life == 0) begin
                    entulho_life <= 9; // Entulho pesado
                end
                barrier <= 1;
            end else begin
                barrier <= 0;
            end
        end
        O: begin
            // Definicao de head
            if (ColunaRobo == 0)
                head <= 1;
            else
                head <= (Mapa[LinhaRobo][ColunaRobo - 1] == Parede) ? 1 : 0;

            // Definicao de left
            if (LinhaRobo == 9)
                left <= 1;
            else
                left <= (Mapa[LinhaRobo + 1][ColunaRobo] == Parede) ? 1 : 0;

            // Definicao de under
            under <= (LinhaRobo == LinhaCelulaPreta && ColunaRobo == ColunaCelulaPreta) ? 1 : 0;

            if (ColunaRobo == 0)
                barrier <= 0;
            else if(LinhaRobo == LinhaEntulhoLeve && ColunaRobo - 1 == ColunaEntulhoLeve) begin
                if (entulho_life == 0) begin
                    entulho_life <= 3; // Entulho leve
                end
                barrier <= 1;
            end else if(LinhaRobo == LinhaEntulhoMedio && ColunaRobo - 1 == ColunaEntulhoMedio) begin
                if (entulho_life == 0) begin
                    entulho_life <= 6; // Entulho medio
                end
                barrier <= 1;
            end else if(LinhaRobo == LinhaEntulhoPesado && ColunaRobo - 1 == ColunaEntulhoPesado) begin
                if (entulho_life == 0) begin
                    entulho_life <= 9; // Entulho pesado
                end
                barrier <= 1;
            end else begin
                barrier <= 0;
            end
        end
    endcase
end
endtask

task Atualiza_Posicao_Robo;
begin
    if (entulho_life > 0 && remover) begin
        entulho_life <= entulho_life - 1;
        if (entulho_life == 0) begin
            case (Orientacao_Robo)
                N: begin
                    if(LinhaRobo - 1 == LinhaEntulhoLeve && ColunaRobo == ColunaEntulhoLeve) begin
                        LinhaEntulhoLeve <= 20;
                        ColunaEntulhoLeve <= 20;
                    end
                    else if(LinhaRobo - 1 == LinhaEntulhoMedio && ColunaRobo == ColunaEntulhoMedio) begin
                        LinhaEntulhoMedio <= 20;
                        ColunaEntulhoMedio <= 20;
                    end
                    else if(LinhaRobo - 1 == LinhaEntulhoPesado && ColunaRobo == ColunaEntulhoPesado) begin
                        LinhaEntulhoPesado <= 20;
                        ColunaEntulhoPesado <= 20;
                    end
                end
                S: begin
                    if(LinhaRobo + 1 == LinhaEntulhoLeve && ColunaRobo == ColunaEntulhoLeve) begin
                        LinhaEntulhoLeve <= 20;
                        ColunaEntulhoLeve <= 20;
                    end
                    else if(LinhaRobo + 1 == LinhaEntulhoMedio && ColunaRobo == ColunaEntulhoMedio) begin
                        LinhaEntulhoMedio <= 20;
                        ColunaEntulhoMedio <= 20;
                    end
                    else if(LinhaRobo + 1 == LinhaEntulhoPesado && ColunaRobo == ColunaEntulhoPesado) begin
                        LinhaEntulhoPesado <= 20;
                        ColunaEntulhoPesado <= 20;
                    end
                end
                L: begin
                    if(LinhaRobo == LinhaEntulhoLeve && ColunaRobo + 1 == ColunaEntulhoLeve) begin
                        LinhaEntulhoLeve <= 20;
                        ColunaEntulhoLeve <= 20;
                    end
                    else if(LinhaRobo == LinhaEntulhoMedio && ColunaRobo + 1 == ColunaEntulhoMedio) begin
                        LinhaEntulhoMedio <= 20;
                        ColunaEntulhoMedio <= 20;
                    end
                    else if(LinhaRobo == LinhaEntulhoPesado && ColunaRobo + 1 == ColunaEntulhoPesado) begin
                        LinhaEntulhoPesado <= 20;
                        ColunaEntulhoPesado <= 20;
                    end
                end		
                O: begin
                    if(LinhaRobo == LinhaEntulhoLeve && ColunaRobo - 1 == ColunaEntulhoLeve) begin
                        LinhaEntulhoLeve <= 20;
                        ColunaEntulhoLeve <= 20;
                    end
                    else if(LinhaRobo == LinhaEntulhoMedio && ColunaRobo - 1 == ColunaEntulhoMedio) begin
                        LinhaEntulhoMedio <= 20;
                        ColunaEntulhoMedio <= 20;
                    end
                    else if(LinhaRobo == LinhaEntulhoPesado && ColunaRobo - 1 == ColunaEntulhoPesado) begin
                        LinhaEntulhoPesado <= 20;
                        ColunaEntulhoPesado <= 20;
                    end
                end
            endcase
        end
    end
    case (Orientacao_Robo)
        N: begin
                if (avancar)
                begin
                    LinhaRobo <= LinhaRobo - 1;
                end
                else if (girar)
                begin
                    Orientacao_Robo <= O;
                end
            end
        S: begin
                if (avancar)
                begin
                    LinhaRobo <= LinhaRobo + 1;
                end
                else if (girar)
                begin
                    Orientacao_Robo <= L;
                end
            end
        L: begin
                if (avancar)
                begin
                    ColunaRobo <= ColunaRobo + 1;
                end
                else if (girar)
                begin
                    Orientacao_Robo <= N;
                end
            end
        O: begin
                if (avancar)
                begin
                    ColunaRobo <= ColunaRobo - 1;
                end
                else if (girar)
                begin
                    Orientacao_Robo <= S;
                end
            end
    endcase
end
endtask

function Situacoes_Anomalas (input X);
begin
    Situacoes_Anomalas = 0;
    if ( (LinhaRobo < 0) || (LinhaRobo > 9) || (ColunaRobo < 0) || (ColunaRobo > 19) ) begin
        Situacoes_Anomalas = 1;
    end
    else
    begin
        if (Mapa[LinhaRobo][ColunaRobo] == Parede) begin
            Situacoes_Anomalas = 1;
        end else if (LinhaRobo == LinhaEntulhoLeve && ColunaRobo == ColunaEntulhoLeve) begin
            Situacoes_Anomalas = 1;
        end else if (LinhaRobo == LinhaEntulhoMedio && ColunaRobo == ColunaEntulhoMedio) begin
            Situacoes_Anomalas = 1;
        end else if (LinhaRobo == LinhaEntulhoPesado && ColunaRobo == ColunaEntulhoPesado) begin
            Situacoes_Anomalas = 1;
        end
    end
end
endfunction

always @(negedge Clock50)
begin
    if (!reset)
    begin
         // Atribuição individual de cada campo de ColunasSprites
        ColunasSprites[29:25] <= ColunaCelulaPreta + 5'b00001;
        ColunasSprites[24:20] <= ColunaEntulhoLeve + 5'b00001;
        ColunasSprites[19:15] <= ColunaEntulhoMedio + 5'b00001;
        ColunasSprites[14:10] <= ColunaEntulhoPesado + 5'b00001;
        ColunasSprites[9:5]   <= ColunaRobo + 5'b00001;
        ColunasSprites[4:0]   <= ColunaCursor + 5'b00001;

        // Atribuição individual de cada campo de LinhasSprites
        LinhasSprites[23:20] <= LinhaCelulaPreta + 4'b0001;
        LinhasSprites[19:16] <= LinhaEntulhoLeve + 4'b0001;
        LinhasSprites[15:12] <= LinhaEntulhoMedio + 4'b0001;
        LinhasSprites[11:8]  <= LinhaEntulhoPesado + 4'b0001;
        LinhasSprites[7:4]   <= LinhaRobo + 4'b0001;
        LinhasSprites[3:0]   <= LinhaCursor + 4'b0001;
        OrientacaoRobo <= Orientacao_Robo;
    end
end
endmodule 