`timescale 1ns/1ns

module Robo_TB;

parameter N = 2'b00, S = 2'b01, L = 2'b10, O = 2'b11;

reg clock, reset, head, left, under, barrier;
reg step_mode; // Registrador para modo de execução
wire avancar, girar, remover;

reg [3:0] Mapa [0:10][0:19]; // Atualização para 10 linhas e 20 colunas
reg [3:0] Linha_Robo;
reg [3:0] Coluna_Robo;
reg [2:0] Orientacao_Robo;
reg [39:0] String_Orientacao_Robo;
integer entulho_life; // Vida do entulho, representa quantas iterações são necessárias para removê-lo

// Instância do módulo de controle
// O controle inicialmente prevê 3 botões
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

    $readmemh("Mapa.txt", Mapa); // Leitura do arquivo em formato decimal

    // Configuração do mapa 
    // 0: Caminho Livre -	Célula onde o robô pode se mover livremente.
    // 1: Parede - Obstáculo que impede o movimento do robô.
    // 2: Célula Preta - Célula que indica o inicio ou final de uma tubulação.
    // 3: Entulho Leve - Entulho que requer 3 ciclos para ser removido.
    // 4: Entulho Médio - Entulho que requer 6 ciclos para ser removido.
    // 5: Entulho Pesado - Entulho que requer 9 ciclos para ser removido.
    
    // A primeira linha do mapa representa dados de inicialização do robô 
    Linha_Robo = Mapa[0][0]; 
    Coluna_Robo = Mapa[0][1];
    Orientacao_Robo = Mapa[0][2];
    $display ("Linha = %d Coluna = %d Orientacao = %s", Linha_Robo, Coluna_Robo, String_Orientacao_Robo);

    if (Situacoes_Anomalas(1)) $stop;

    #100 @ (negedge clock) reset = 0; // sincroniza com borda de descida

    forever
    begin
        // Processar comandos do controle
        if (btn_reset) begin
            reset = ~reset; // Induz o reset ou sai do modo reset
        end
        if (btn_mode) begin
            step_mode = ~step_mode; // Alternar modo de execução
        end
        if (btn_step && step_mode) begin
            $display("Passo-a-passo: Pressione Enter para próximo passo...");
        end
        @ (negedge clock);
        if (reset) begin
            // Recomeça o loop ao apertar o botão reset
            reset = 0;
        end else begin
            Define_Sensores;
            $display ("H = %b L = %b U = %b B = %b", head, left, under, barrier);
            @ (negedge clock);
            if (entulho_life > 0) begin
                entulho_life = entulho_life - 1;
                $display("Removendo entulho... %d ciclos restantes", entulho_life);
                if (entulho_life == 0) begin
                    Mapa[Linha_Robo][Coluna_Robo] = 0;
                    $display("Entulho removido.");
                end
            end else begin
                Atualiza_Posicao_Robo;
            end
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
end

function Situacoes_Anomalas (input X);
begin
    Situacoes_Anomalas = 0;
    if ( (Linha_Robo < 0) || (Linha_Robo > 9) || (Coluna_Robo < 0) || (Coluna_Robo > 19) ) // Mapa 10 x 20 
        Situacoes_Anomalas = 1;
    else
    begin
        if (Mapa[Linha_Robo][Coluna_Robo] == 1)
            Situacoes_Anomalas = 1;
    end
end
endfunction

task Define_Sensores;
begin
    case (Orientacao_Robo)
        N: begin
                // Definição de head
                if (Linha_Robo == 0) // Situação de borda do mapa
                    head = 1;
                else
                    head = (Mapa[Linha_Robo - 1][Coluna_Robo] == 1) ? 1 : 0;

                // Definição de left
                if (Coluna_Robo == 0) // Situação de borda do mapa
                    left = 1;
                else
                    left = (Mapa[Linha_Robo][Coluna_Robo - 1] == 1) ? 1 : 0;

                // Definição de under
                under = (Mapa[Linha_Robo][Coluna_Robo] == 2) ? 1 : 0;

                // Definição de barrier
                if (Linha_Robo == 0) // Situação de borda do mapa
                    barrier = 0;
                else
                    barrier = (Mapa[Linha_Robo - 1][Coluna_Robo] >= 3) ? 1 : 0;
            end
        S: begin
                // Definição de head
                if (Linha_Robo == 9)
                    head = 1;
                else
                    head = (Mapa[Linha_Robo + 1][Coluna_Robo] == 1) ? 1 : 0;

                // Definição de left
                if (Coluna_Robo == 19)
                    left = 1;
                else
                    left = (Mapa[Linha_Robo][Coluna_Robo + 1] == 1) ? 1 : 0;

                // Definição de under
                under = (Mapa[Linha_Robo][Coluna_Robo] == 2) ? 1 : 0;

                // Definição de barrier
                if (Linha_Robo == 9)
                    barrier = 0;
                else
                    barrier = (Mapa[Linha_Robo + 1][Coluna_Robo] >= 3) ? 1 : 0;
            end
        L: begin
                // Definição de head
                if (Coluna_Robo == 19)
                    head = 1;
                else
                    head = (Mapa[Linha_Robo][Coluna_Robo + 1] == 1) ? 1 : 0;

                // Definição de left
                if (Linha_Robo == 0)
                    left = 1;
                else
                    left = (Mapa[Linha_Robo - 1][Coluna_Robo] == 1) ? 1 : 0;

                // Definição de under
                under = (Mapa[Linha_Robo][Coluna_Robo] == 2) ? 1 : 0;

                // Definição de barrier
                if (Coluna_Robo == 19)
                    barrier = 0;
                else
                    barrier = (Mapa[Linha_Robo][Coluna_Robo + 1] >= 3) ? 1 : 0;
            end
        O: begin
                // Definição de head
                if (Coluna_Robo == 0)
                    head = 1;
                else
                    head = (Mapa[Linha_Robo][Coluna_Robo - 1] == 1) ? 1 : 0;

                // Definição de left
                if (Linha_Robo == 9)
                    left = 1;
                else
                    left = (Mapa[Linha_Robo + 1][Coluna_Robo] == 1) ? 1 : 0;

                // Definição de under
                under = (Mapa[Linha_Robo][Coluna_Robo] == 2) ? 1 : 0;

                // Definição de barrier
                if (Coluna_Robo == 0)
                    barrier = 0;
                else
                    barrier = (Mapa[Linha_Robo][Coluna_Robo - 1] >= 3) ? 1 : 0;
            end
    endcase
end
endtask

task Atualiza_Posicao_Robo;
begin
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
                else if (remover && Mapa[Linha_Robo - 1][Coluna_Robo] >= 3)
                begin
                    case (Mapa[Linha_Robo - 1][Coluna_Robo])
                        3: entulho_life = 3; // Entulho leve
                        4: entulho_life = 6; // Entulho médio
                        5: entulho_life = 9; // Entulho pesado
                    endcase
                end
            end
        // Definições para S, L e O são similares
        S: begin
                if (avancar)
                begin
                    Linha_Robo = Linha_Robo + 1;
                end
                else if (girar)
                begin
                    Orientacao_Robo = L;
                end
                else if (remover && Mapa[Linha_Robo + 1][Coluna_Robo] >= 3)
                begin
                    case (Mapa[Linha_Robo + 1][Coluna_Robo])
                        3: entulho_life = 3; // Entulho leve
                        4: entulho_life = 6; // Entulho médio
                        5: entulho_life = 9; // Entulho pesado
                    endcase
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
                else if (remover && Mapa[Linha_Robo][Coluna_Robo + 1] >= 3)
                begin
                    case (Mapa[Linha_Robo][Coluna_Robo + 1])
                        3: entulho_life = 3; // Entulho leve
                        4: entulho_life = 6; // Entulho médio
                        5: entulho_life = 9; // Entulho pesado
                    endcase
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
                else if (remover && Mapa[Linha_Robo][Coluna_Robo - 1] >= 3)
                begin
                    case (Mapa[Linha_Robo][Coluna_Robo - 1])
                        3: entulho_life = 3; // Entulho leve
                        4: entulho_life = 6; // Entulho médio
                        5: entulho_life = 9; // Entulho pesado
                    endcase
                end
            end
    endcase
end
endtask

endmodule
