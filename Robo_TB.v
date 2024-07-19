`timescale 1ns/1ns

module Robo_TB;

parameter N = 2'b00, S = 2'b01, L = 2'b10, O = 2'b11;

reg clock, reset, head, left, under, barrier;
reg step_mode; // Registrador para modo de execucao
wire avancar, girar, remover;

reg [3:0] Mapa [0:10][0:19]; // Atualizacao para 10 linhas e 20 colunas
reg [7:0] Linha_Robo;
reg [7:0] Coluna_Robo;
reg [3:0] Orientacao_Hex; 
reg [7:0] Orientacao_Robo;
reg [39:0] String_Orientacao_Robo;
integer entulho_life; // Vida do entulho, representa quantas iteracoes são necessarias para remove-lo
reg [7:0] Celula_Mapa;

// Inicializa parametros do robo a partir da primeira linha do arquivo
reg [79:0] temp [0:10]; // Array temporario para armazenar linhas lidas
integer i, j;

// Instância do modulo de controle
// O controle inicialmente preve 3 botoes
wire btn_reset, btn_mode, btn_step;
Controle control (
    .clock(clock),
    .reset(reset),
    .btn_reset(btn_reset),
    .btn_mode(btn_mode),
    .btn_step(btn_step)
);

Robo DUV (.clock(clock), .reset(reset), .head(head), .left(left), .under(under), .barrier(barrier), .avancar(avancar), .girar(girar), .recolher_entulho(remover));

always
    #50 clock = !clock;

initial
begin
    clock = 0;
    reset = 1;
    head = 0;
    left = 0;
    under = 0;
    barrier = 0;
    step_mode = 0; // Inicializa no modo contínuo
    entulho_life = 0; // Inicializa a vida do entulho como 0

    // Configuração do mapa 
    // 0: Caminho Livre -	Celula onde o robô pode se mover livremente.
    // 1: Parede - Obstaculo que impede o movimento do robô.
    // 2: Celula Preta - Célula que indica o inicio ou final de uma tubulacao.
    // 3: Entulho Leve - Entulho que requer 3 ciclos para ser removido.
    // 4: Entulho Medio - Entulho que requer 6 ciclos para ser removido.
    // 5: Entulho Pesado - Entulho que requer 9 ciclos para ser removido.

    $readmemh("Mapa.txt", temp);

    Linha_Robo = temp[0][79:72]; //  (0º linha, 0-1 caracteres)
    Coluna_Robo = temp[0][71:64]; // (0º linha, 2-3 caracteres)
    Orientacao_Hex = temp[0][63:60]; // (0º linha, 4º caractere)
    
    // Converter o valor hexadecimal da orientacao para a string correspondente
    case (Orientacao_Hex)
      4'h0: Orientacao_Robo = N; // 0 -> N
      4'h1: Orientacao_Robo = O; // 1 -> O
      4'h2: Orientacao_Robo = S; // 2 -> S
      4'h3: Orientacao_Robo = L; // 3 -> L
      default: Orientacao_Robo = "X"; // Valor desconhecido
    endcase

    // Preencher a matriz com os valores restantes
    for (i = 0; i < 10; i = i + 1) begin
      for (j = 0; j < 20; j = j + 1) begin
        Mapa[i][j] = temp[i+1][79 - j*4 -: 4]; // Preencher a matriz ignorando a primeira linha
      end
    end

    // Print dos parametros iniciais

    $display ("Linha = %h Coluna = %h Orientacao = %s", Linha_Robo, Coluna_Robo, Orientacao_Robo);

    // Print do mapa

    for (i = 0; i < 10; i = i + 1) begin
        for (j = 0; j < 20; j = j + 1) begin
            $write("%h", Mapa[i][j]);
        end
      $write("\n");
    end

    Celula_Mapa = Mapa[Linha_Robo][Coluna_Robo];

    if (Situacoes_Anomalas(1)) begin
	$display("Celula Mapa : %h", Mapa[Linha_Robo][Coluna_Robo]);
	$stop;
    end

    #100 @ (negedge clock) reset = 0; // sincroniza com borda de descida

    forever
    begin
        // Processar comandos do controle
        if (btn_reset) begin
            reset = ~reset; // Induz o reset ou sai do modo reset
        end
        if (btn_mode) begin
            step_mode = ~step_mode; // Alternar modo de execucão
        end
        if (btn_step && step_mode) begin
            $display("Passo-a-passo: Pressione Enter para próximo passo...");
        end
	    // @ (negedge clock);
            Define_Sensores;
            $display ("H = %b L = %b U = %b B = %b", head, left, under, barrier);
            @ (negedge clock);
            Atualiza_Posicao_Robo;
            case (Orientacao_Robo)
                N: String_Orientacao_Robo = "Norte";
                S: String_Orientacao_Robo = "Sul  ";
                L: String_Orientacao_Robo = "Leste";
                O: String_Orientacao_Robo = "Oeste";
            endcase
            $display ("Linha = %d Coluna = %d Orientacao = %s", Linha_Robo, Coluna_Robo, String_Orientacao_Robo);
            if (Situacoes_Anomalas(1)) begin
                $display("Estado Anômalo Detectado. Aguardando Reset...");
                @ (negedge reset);
            end 
    end
end

function Situacoes_Anomalas (input X);
begin
    Situacoes_Anomalas = 0;
    if ( (Linha_Robo < 0) || (Linha_Robo > 9) || (Coluna_Robo < 0) || (Coluna_Robo > 19) ) // Mapa 10 x 20 
        Situacoes_Anomalas = 1;
    else
    begin
        if (Mapa[Linha_Robo][Coluna_Robo] == 1 || Mapa[Linha_Robo][Coluna_Robo] >= 3)
            Situacoes_Anomalas = 1;
    end
end
endfunction

task Define_Sensores;
begin
    case (Orientacao_Robo)
        N: begin
                // Definicao de head
                if (Linha_Robo == 0) // Situacao de borda do mapa
                    head = 1;
                else
                    head = (Mapa[Linha_Robo - 1][Coluna_Robo] == 1) ? 1 : 0;

                // Definiacao de left
                if (Coluna_Robo == 0) // Situacao de borda do mapa
                    left = 1;
                else
                    left = (Mapa[Linha_Robo][Coluna_Robo - 1] == 1) ? 1 : 0;

                // Definicao de under
                under = (Mapa[Linha_Robo][Coluna_Robo] == 2) ? 1 : 0;

                // Definição de barrier
                if (Linha_Robo == 0) // Situacao de borda do mapa
                    barrier = 0;
                else if (Mapa[Linha_Robo - 1][Coluna_Robo] >= 3) begin
                    if (entulho_life == 0) begin
                    case (Mapa[Linha_Robo - 1][Coluna_Robo])
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
                if (Linha_Robo == 9)
                    head = 1;
                else
                    head = (Mapa[Linha_Robo + 1][Coluna_Robo] == 1) ? 1 : 0;

                // Definicao de left
                if (Coluna_Robo == 19)
                    left = 1;
                else
                    left = (Mapa[Linha_Robo][Coluna_Robo + 1] == 1) ? 1 : 0;

                // Definicao de under
                under = (Mapa[Linha_Robo][Coluna_Robo] == 2) ? 1 : 0;

                // Definicao de barrier
                if (Linha_Robo == 9)
                    barrier = 0;
                else if (Mapa[Linha_Robo + 1][Coluna_Robo] >= 3) begin
                    if (entulho_life == 0) begin
                    case (Mapa[Linha_Robo + 1][Coluna_Robo])
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
                if (Coluna_Robo == 19)
                    head = 1;
                else
                    head = (Mapa[Linha_Robo][Coluna_Robo + 1] == 1) ? 1 : 0;

                // Definicao de left
                if (Linha_Robo == 0)
                    left = 1;
                else
                    left = (Mapa[Linha_Robo - 1][Coluna_Robo] == 1) ? 1 : 0;

                // Definicao de under
                under = (Mapa[Linha_Robo][Coluna_Robo] == 2) ? 1 : 0;

                // Definicao de barrier
                if (Coluna_Robo == 19)
                    barrier = 0;
                else if (Mapa[Linha_Robo][Coluna_Robo + 1] >= 3) begin
                    if (entulho_life == 0) begin
                    case (Mapa[Linha_Robo][Coluna_Robo + 1])
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
                if (Coluna_Robo == 0)
                    head = 1;
                else
                    head = (Mapa[Linha_Robo][Coluna_Robo - 1] == 1) ? 1 : 0;

                // Definicao de left
                if (Linha_Robo == 9)
                    left = 1;
                else
                    left = (Mapa[Linha_Robo + 1][Coluna_Robo] == 1) ? 1 : 0;

                // Definicao de under
                under = (Mapa[Linha_Robo][Coluna_Robo] == 2) ? 1 : 0;

                // Definicao de barrier
                if (Coluna_Robo == 0)
                    barrier = 0;
                else if (Mapa[Linha_Robo][Coluna_Robo - 1] >= 3) begin
		    if (entulho_life == 0) begin
                    case (Mapa[Linha_Robo][Coluna_Robo - 1])
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
			Mapa[Linha_Robo - 1][Coluna_Robo] = 0;
		end
		S: begin
			Mapa[Linha_Robo + 1][Coluna_Robo] = 0;
		end
		L: begin
			Mapa[Linha_Robo][Coluna_Robo + 1] = 0;
		end		
		O: begin
			Mapa[Linha_Robo][Coluna_Robo - 1] = 0;
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
                        Linha_Robo = Linha_Robo - 1;
                    end
                    else if (girar)
                    begin
                        Orientacao_Robo = O;
                    end
                end
            S: begin
                    if (avancar)
                    begin
                        Linha_Robo = Linha_Robo + 1;
                    end
                    else if (girar)
                    begin
                        Orientacao_Robo = L;
                    end
                end
            L: begin
                    if (avancar)
                    begin
                        Coluna_Robo = Coluna_Robo + 1;
                    end
                    else if (girar)
                    begin
                        Orientacao_Robo = N;
                    end
                end
            O: begin
                    if (avancar)
                    begin
                        Coluna_Robo = Coluna_Robo - 1;
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

endmodule

