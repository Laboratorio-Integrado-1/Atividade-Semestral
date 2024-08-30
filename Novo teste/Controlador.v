module Controlador (Clock50, reset, Entradas, v_sync, avancar, head, left, under, barrier ,girar, remover, LEDG, LEDR, ColunasSprites, LinhasSprites, OrientacaoRobo, AtivaRobo);

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
output reg AtivaRobo;

wire [3:0] Mapa [0:9][0:19];
wire [79:0] MapaTemp [0:10];

integer entulho_life; // Vida do entulho, representa quantas iteracoes sÃ£o necessarias para remove-lo

reg [4:0] ColunaCelulaPreta, ColunaRobo, ColunaCursor;
reg [3:0] LinhaCelulaPreta, LinhaRobo, LinhaCursor;

reg [3:0] Orientacao_Hex; 
reg [1:0] Orientacao_Robo;

reg [5:0] ContadorFrames, ContadorFramesRobo;

reg [4:0] ColunaEntulhoLeve, ColunaEntulhoMedio, ColunaEntulhoPesado;
reg [3:0] LinhaEntulhoLeve, LinhaEntulhoMedio, LinhaEntulhoPesado;

reg IteracaoRobo, HabilitaNovaLeitura, FlagAtualizaPosicao;

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

// Assign MapaTemp values
assign MapaTemp[0] = 80'h55555555555555555555;
assign MapaTemp[1] = 80'h56665666666666665555;
assign MapaTemp[2] = 80'h56565656555555565555;
assign MapaTemp[3] = 80'h56565656666666666665;
assign MapaTemp[4] = 80'h56565656555555565555;
assign MapaTemp[5] = 80'h56566656555555565555;
assign MapaTemp[6] = 80'h56565556555555565555;
assign MapaTemp[7] = 80'h56565556555555565555;
assign MapaTemp[8] = 80'h56565556555555565555;
assign MapaTemp[9] = 80'h56666666666666665555;

// Use assign statements to extract 4-bit segments
assign Mapa[0][0]  = MapaTemp[0][79:76];
assign Mapa[0][1]  = MapaTemp[0][75:72];
assign Mapa[0][2]  = MapaTemp[0][71:68];
assign Mapa[0][3]  = MapaTemp[0][67:64];
assign Mapa[0][4]  = MapaTemp[0][63:60];
assign Mapa[0][5]  = MapaTemp[0][59:56];
assign Mapa[0][6]  = MapaTemp[0][55:52];
assign Mapa[0][7]  = MapaTemp[0][51:48];
assign Mapa[0][8]  = MapaTemp[0][47:44];
assign Mapa[0][9]  = MapaTemp[0][43:40];
assign Mapa[0][10] = MapaTemp[0][39:36];
assign Mapa[0][11] = MapaTemp[0][35:32];
assign Mapa[0][12] = MapaTemp[0][31:28];
assign Mapa[0][13] = MapaTemp[0][27:24];
assign Mapa[0][14] = MapaTemp[0][23:20];
assign Mapa[0][15] = MapaTemp[0][19:16];
assign Mapa[0][16] = MapaTemp[0][15:12];
assign Mapa[0][17] = MapaTemp[0][11:8];
assign Mapa[0][18] = MapaTemp[0][7:4];
assign Mapa[0][19] = MapaTemp[0][3:0];

assign Mapa[1][0]  = MapaTemp[1][79:76];
assign Mapa[1][1]  = MapaTemp[1][75:72];
assign Mapa[1][2]  = MapaTemp[1][71:68];
assign Mapa[1][3]  = MapaTemp[1][67:64];
assign Mapa[1][4]  = MapaTemp[1][63:60];
assign Mapa[1][5]  = MapaTemp[1][59:56];
assign Mapa[1][6]  = MapaTemp[1][55:52];
assign Mapa[1][7]  = MapaTemp[1][51:48];
assign Mapa[1][8]  = MapaTemp[1][47:44];
assign Mapa[1][9]  = MapaTemp[1][43:40];
assign Mapa[1][10] = MapaTemp[1][39:36];
assign Mapa[1][11] = MapaTemp[1][35:32];
assign Mapa[1][12] = MapaTemp[1][31:28];
assign Mapa[1][13] = MapaTemp[1][27:24];
assign Mapa[1][14] = MapaTemp[1][23:20];
assign Mapa[1][15] = MapaTemp[1][19:16];
assign Mapa[1][16] = MapaTemp[1][15:12];
assign Mapa[1][17] = MapaTemp[1][11:8];
assign Mapa[1][18] = MapaTemp[1][7:4];
assign Mapa[1][19] = MapaTemp[1][3:0];

assign Mapa[2][0]  = MapaTemp[2][79:76];
assign Mapa[2][1]  = MapaTemp[2][75:72];
assign Mapa[2][2]  = MapaTemp[2][71:68];
assign Mapa[2][3]  = MapaTemp[2][67:64];
assign Mapa[2][4]  = MapaTemp[2][63:60];
assign Mapa[2][5]  = MapaTemp[2][59:56];
assign Mapa[2][6]  = MapaTemp[2][55:52];
assign Mapa[2][7]  = MapaTemp[2][51:48];
assign Mapa[2][8]  = MapaTemp[2][47:44];
assign Mapa[2][9]  = MapaTemp[2][43:40];
assign Mapa[2][10] = MapaTemp[2][39:36];
assign Mapa[2][11] = MapaTemp[2][35:32];
assign Mapa[2][12] = MapaTemp[2][31:28];
assign Mapa[2][13] = MapaTemp[2][27:24];
assign Mapa[2][14] = MapaTemp[2][23:20];
assign Mapa[2][15] = MapaTemp[2][19:16];
assign Mapa[2][16] = MapaTemp[2][15:12];
assign Mapa[2][17] = MapaTemp[2][11:8];
assign Mapa[2][18] = MapaTemp[2][7:4];
assign Mapa[2][19] = MapaTemp[2][3:0];

assign Mapa[3][0]  = MapaTemp[3][79:76];
assign Mapa[3][1]  = MapaTemp[3][75:72];
assign Mapa[3][2]  = MapaTemp[3][71:68];
assign Mapa[3][3]  = MapaTemp[3][67:64];
assign Mapa[3][4]  = MapaTemp[3][63:60];
assign Mapa[3][5]  = MapaTemp[3][59:56];
assign Mapa[3][6]  = MapaTemp[3][55:52];
assign Mapa[3][7]  = MapaTemp[3][51:48];
assign Mapa[3][8]  = MapaTemp[3][47:44];
assign Mapa[3][9]  = MapaTemp[3][43:40];
assign Mapa[3][10] = MapaTemp[3][39:36];
assign Mapa[3][11] = MapaTemp[3][35:32];
assign Mapa[3][12] = MapaTemp[3][31:28];
assign Mapa[3][13] = MapaTemp[3][27:24];
assign Mapa[3][14] = MapaTemp[3][23:20];
assign Mapa[3][15] = MapaTemp[3][19:16];
assign Mapa[3][16] = MapaTemp[3][15:12];
assign Mapa[3][17] = MapaTemp[3][11:8];
assign Mapa[3][18] = MapaTemp[3][7:4];
assign Mapa[3][19] = MapaTemp[3][3:0];

assign Mapa[4][0]  = MapaTemp[4][79:76];
assign Mapa[4][1]  = MapaTemp[4][75:72];
assign Mapa[4][2]  = MapaTemp[4][71:68];
assign Mapa[4][3]  = MapaTemp[4][67:64];
assign Mapa[4][4]  = MapaTemp[4][63:60];
assign Mapa[4][5]  = MapaTemp[4][59:56];
assign Mapa[4][6]  = MapaTemp[4][55:52];
assign Mapa[4][7]  = MapaTemp[4][51:48];
assign Mapa[4][8]  = MapaTemp[4][47:44];
assign Mapa[4][9]  = MapaTemp[4][43:40];
assign Mapa[4][10] = MapaTemp[4][39:36];
assign Mapa[4][11] = MapaTemp[4][35:32];
assign Mapa[4][12] = MapaTemp[4][31:28];
assign Mapa[4][13] = MapaTemp[4][27:24];
assign Mapa[4][14] = MapaTemp[4][23:20];
assign Mapa[4][15] = MapaTemp[4][19:16];
assign Mapa[4][16] = MapaTemp[4][15:12];
assign Mapa[4][17] = MapaTemp[4][11:8];
assign Mapa[4][18] = MapaTemp[4][7:4];
assign Mapa[4][19] = MapaTemp[4][3:0];
 
assign Mapa[5][0]  = MapaTemp[5][79:76];
assign Mapa[5][1]  = MapaTemp[5][75:72];
assign Mapa[5][2]  = MapaTemp[5][71:68];
assign Mapa[5][3]  = MapaTemp[5][67:64];
assign Mapa[5][4]  = MapaTemp[5][63:60];
assign Mapa[5][5]  = MapaTemp[5][59:56];
assign Mapa[5][6]  = MapaTemp[5][55:52];
assign Mapa[5][7]  = MapaTemp[5][51:48];
assign Mapa[5][8]  = MapaTemp[5][47:44];
assign Mapa[5][9]  = MapaTemp[5][43:40];
assign Mapa[5][10] = MapaTemp[5][39:36];
assign Mapa[5][11] = MapaTemp[5][35:32];
assign Mapa[5][12] = MapaTemp[5][31:28];
assign Mapa[5][13] = MapaTemp[5][27:24];
assign Mapa[5][14] = MapaTemp[5][23:20];
assign Mapa[5][15] = MapaTemp[5][19:16];
assign Mapa[5][16] = MapaTemp[5][15:12];
assign Mapa[5][17] = MapaTemp[5][11:8];
assign Mapa[5][18] = MapaTemp[5][7:4];
assign Mapa[5][19] = MapaTemp[5][3:0];

assign Mapa[6][1]  = MapaTemp[6][75:72];
assign Mapa[6][0]  = MapaTemp[6][79:76];
assign Mapa[6][2]  = MapaTemp[6][71:68];
assign Mapa[6][3]  = MapaTemp[6][67:64];
assign Mapa[6][4]  = MapaTemp[6][63:60];
assign Mapa[6][5]  = MapaTemp[6][59:56];
assign Mapa[6][6]  = MapaTemp[6][55:52];
assign Mapa[6][7]  = MapaTemp[6][51:48];
assign Mapa[6][8]  = MapaTemp[6][47:44];
assign Mapa[6][9]  = MapaTemp[6][43:40];
assign Mapa[6][10] = MapaTemp[6][39:36];
assign Mapa[6][11] = MapaTemp[6][35:32];
assign Mapa[6][12] = MapaTemp[6][31:28];
assign Mapa[6][13] = MapaTemp[6][27:24];
assign Mapa[6][14] = MapaTemp[6][23:20];
assign Mapa[6][15] = MapaTemp[6][19:16];
assign Mapa[6][16] = MapaTemp[6][15:12];
assign Mapa[6][17] = MapaTemp[6][11:8];
assign Mapa[6][18] = MapaTemp[6][7:4];
assign Mapa[6][19] = MapaTemp[6][3:0];

assign Mapa[7][0]  = MapaTemp[7][79:76];
assign Mapa[7][1]  = MapaTemp[7][75:72];
assign Mapa[7][2]  = MapaTemp[7][71:68];
assign Mapa[7][3]  = MapaTemp[7][67:64];
assign Mapa[7][4]  = MapaTemp[7][63:60];
assign Mapa[7][5]  = MapaTemp[7][59:56];
assign Mapa[7][6]  = MapaTemp[7][55:52];
assign Mapa[7][7]  = MapaTemp[7][51:48];
assign Mapa[7][8]  = MapaTemp[7][47:44];
assign Mapa[7][9]  = MapaTemp[7][43:40];
assign Mapa[7][10] = MapaTemp[7][39:36];
assign Mapa[7][11] = MapaTemp[7][35:32];
assign Mapa[7][12] = MapaTemp[7][31:28];
assign Mapa[7][13] = MapaTemp[7][27:24];
assign Mapa[7][14] = MapaTemp[7][23:20];
assign Mapa[7][15] = MapaTemp[7][19:16];
assign Mapa[7][16] = MapaTemp[7][15:12];
assign Mapa[7][17] = MapaTemp[7][11:8];
assign Mapa[7][18] = MapaTemp[7][7:4];
assign Mapa[7][19] = MapaTemp[7][3:0];

assign Mapa[8][1]  = MapaTemp[8][75:72];
assign Mapa[8][0]  = MapaTemp[8][79:76];
assign Mapa[8][2]  = MapaTemp[8][71:68];
assign Mapa[8][3]  = MapaTemp[8][67:64];
assign Mapa[8][4]  = MapaTemp[8][63:60];
assign Mapa[8][5]  = MapaTemp[8][59:56];
assign Mapa[8][6]  = MapaTemp[8][55:52];
assign Mapa[8][7]  = MapaTemp[8][51:48];
assign Mapa[8][8]  = MapaTemp[8][47:44];
assign Mapa[8][9]  = MapaTemp[8][43:40];
assign Mapa[8][10] = MapaTemp[8][39:36];
assign Mapa[8][11] = MapaTemp[8][35:32];
assign Mapa[8][12] = MapaTemp[8][31:28];
assign Mapa[8][13] = MapaTemp[8][27:24];
assign Mapa[8][14] = MapaTemp[8][23:20];
assign Mapa[8][15] = MapaTemp[8][19:16];
assign Mapa[8][16] = MapaTemp[8][15:12];
assign Mapa[8][17] = MapaTemp[8][11:8];
assign Mapa[8][18] = MapaTemp[8][7:4];
assign Mapa[8][19] = MapaTemp[8][3:0];

assign Mapa[9][0]  = MapaTemp[9][79:76];
assign Mapa[9][1]  = MapaTemp[9][75:72];
assign Mapa[9][2]  = MapaTemp[9][71:68];
assign Mapa[9][3]  = MapaTemp[9][67:64];
assign Mapa[9][4]  = MapaTemp[9][63:60];
assign Mapa[9][5]  = MapaTemp[9][59:56];
assign Mapa[9][6]  = MapaTemp[9][55:52];
assign Mapa[9][7]  = MapaTemp[9][51:48];
assign Mapa[9][8]  = MapaTemp[9][47:44];
assign Mapa[9][9]  = MapaTemp[9][43:40];
assign Mapa[9][10] = MapaTemp[9][39:36];
assign Mapa[9][11] = MapaTemp[9][35:32];
assign Mapa[9][12] = MapaTemp[9][31:28];
assign Mapa[9][13] = MapaTemp[9][27:24];
assign Mapa[9][14] = MapaTemp[9][23:20];
assign Mapa[9][15] = MapaTemp[9][19:16];
assign Mapa[9][16] = MapaTemp[9][15:12];
assign Mapa[9][17] = MapaTemp[9][11:8];
assign Mapa[9][18] = MapaTemp[9][7:4];
assign Mapa[9][19] = MapaTemp[9][3:0];

always @(posedge Clock50)
begin
	if (reset)
	begin		
		  
        // Inicializacao dos valores
        LinhaRobo <= 4'h03;
        ColunaRobo <= 5'h12;
        LinhaCelulaPreta <= 4'h03;
        ColunaCelulaPreta <= 5'h12;
        Orientacao_Robo <= L;

        LinhaEntulhoLeve <= 4'h03;
        ColunaEntulhoLeve <= 5'h10;
        LinhaEntulhoMedio <= 4'h5;
        ColunaEntulhoMedio <= 5'h0F;
        LinhaEntulhoPesado <= 4'h14;
        ColunaEntulhoPesado <= 5'h14;

        ColunaCursor <= 5'h0A;
        LinhaCursor <= 4'h03;

	    HabilitaNovaLeitura <= 1;
        IteracaoRobo <= 0;
        FlagAtualizaPosicao <= 0;
        ContadorFramesRobo <= 0;
        ContadorFrames <= 0;
        AtivaRobo <= 0;

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
    else
    begin
        if (HabilitaNovaLeitura && Flag)
        begin
            HabilitaNovaLeitura <= 0;
            ContadorFrames <= 0;		
            Le_Inputs;
        end

        if (IteracaoRobo && Flag)
        begin
            IteracaoRobo <= 0;
            ContadorFramesRobo <= 0;
            FlagAtualizaPosicao <= 1;
            Define_Sensores;
            AtivaRobo <= 1;
        end

        if (FlagAtualizaPosicao && Flag)
        begin
            $display ("H = %b L = %b U = %b B = %b", head, left, under, barrier);
            $display ("Linha = %d Coluna = %d Orientacao = %d", LinhaRobo, ColunaRobo, Orientacao_Robo);
            if (step_mode && btn_step) begin
                Atualiza_Posicao_Robo;
                btn_step <= 0;
            end
            
            if(!step_mode) begin
                Atualiza_Posicao_Robo;
            end
	        FlagAtualizaPosicao <= 0;
            AtivaRobo <= 0;
        end

        if (Situacoes_Anomalas(1)) begin
            $display("Estado Anomalo Detectado. Aguardando reset...");
            @ (negedge reset);
            $break;
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

    // Atualiza modo de execucao
    if (Entradas[6])
    begin
        step_mode <= ~step_mode;
        // Acende LEDs Verde e Vermelho
        LEDG <= 8'b10111011;
        LEDR <= 8'b10111011;
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
                head <= (Mapa[LinhaRobo + 1][ColunaRobo] == Parede) ? 1 : 0;

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
                barrier <= 1;
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
        $display("Removendo entulho... %d ciclos restantes", entulho_life);
        if (entulho_life == 1) begin
            $display("Entulho removido.");
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
    for (i = 0; i < 10; i = i + 1) begin
        for (j = 0; j < 20; j = j + 1) begin
                if (i == LinhaRobo && j == ColunaRobo) begin
                    $write("%s", "R");
                end else if (i == CelulaPreta && j == ColunaCelulaPreta) begin
                    $write("%h", 4'h8);
                end else if (i == LinhaEntulhoLeve && j == ColunaEntulhoLeve) begin
                    $write("%h", 4'h2);
                end else if (i == LinhaEntulhoMedio && j == ColunaEntulhoMedio) begin
                    $write("%h", 4'h3);
                end else if (i == LinhaEntulhoPesado && j == ColunaEntulhoPesado) begin
                    $write("%h", 4'h4);
                end else begin
                    $write("%h", Mapa[i][j]);
                end
            end
    $write("\n");
    end
    $write("\n");
    $write("\n");
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