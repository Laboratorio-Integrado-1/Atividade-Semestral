module VGA_GRAPHS(
    reset,
    clock_50,
    clock_25,
    display_on,
    Linha, Coluna,
    LinhaSprites1, LinhaSprites2, LinhaSprites3, LinhaSprites4, LinhaSprites5, LinhaSprites6, LinhaSprites7, LinhaSprites8, LinhaSprites9, LinhaSprites10,
    RGB
);
    input reset, clock_50, clock_25;
    input display_on;
    input [9:0] Linha, Coluna;
    input [79:0] LinhaSprites1, LinhaSprites2, LinhaSprites3, LinhaSprites4, LinhaSprites5, LinhaSprites6, LinhaSprites7, LinhaSprites8, LinhaSprites9, LinhaSprites10;

    output reg [23:0] RGB;

    reg [7:0] VetorPixels [0:19]; // Vetor de 20 pixels (pode ser ajustado conforme necessário)
    reg [47:0] Sprites [0:127]; // Array de 128 posições para diferentes sprites
    reg [2:0] EstadoAtual, EstadoFuturo;
    reg [3:0] IndicePixel, DeslocamentoLinha;
    reg [79:0] LinhaSpriteTemp;

    integer i;
    integer contadorLinha;

    parameter   CODIGO_TRANSPARENTE = 3'b000,
                CODIGO_AZUL = 3'b001,                        
                CODIGO_BRANCO = 3'b010, 
                CODIGO_CIANO = 3'b011,
                CODIGO_LARANJA = 3'b100,
                CODIGO_PRETO = 3'b101,
                CODIGO_VERDE = 3'b110,
                CODIGO_VERMELHO = 3'b111; 
        
    parameter   COR_TRANSPARENTE = 24'h000000, 
                COR_AZUL = 24'h0000FF,                        
                COR_BRANCO = 24'hFFFFFF,
                COR_CIANO = 24'h00FFFF,
                COR_LARANJA = 24'hFFA500,
                COR_PRETO = 24'h000000,
                COR_VERDE = 24'h00FF00,
                COR_VERMELHO = 24'hFF0000;

    // Definição de estados
    parameter PROCESSAR_METADE_1 = 1'b00,
              PROCESSAR_METADE_2 = 1'b01,
              ATUALIZAR_LINHA = 1'b10;

    // Definição Sprites
    initial
    begin
        Sprites[0] = 48'b000000111111111111111111111111111111111111000000;
        Sprites[1] = 48'b000000111100100100100100100100100100100111000000;
        Sprites[2] = 48'b000000111100101101100100100100101101100111000000;
        Sprites[3] = 48'b000000111100100100100100100100100100100111000000;
        Sprites[4] = 48'b000000111100001001100001001100001001100111000000;
        Sprites[5] = 48'b000111111111111111111111111111111111111111111000;
        Sprites[6] = 48'b111110110110110110110110110110110110110110110111;
        Sprites[7] = 48'b111110100100100101101100100101101100100100110111;
        Sprites[8] = 48'b111111111111111101100100100100101111111111111111;
        Sprites[9] = 48'b111111111111111101100100100100101111111111111111;
        Sprites[10] = 48'b111110100100100101101100100101101100100100110111;
        Sprites[11] = 48'b111110100100100100100100100100100100100100110111;
        Sprites[12] = 48'b111110110110110110110110110110110110110110110111;
        Sprites[13] = 48'b000111111111111111111111111111111111111111111000;
        Sprites[14] = 48'b000000111110110110111000000111110110110111000000;
        Sprites[15] = 48'b000000111111111111111000000111111111111111000000;

        Sprites[16] = 48'b111111111111111111111111111111111111111111111111;
        Sprites[17] = 48'b111000000000000000000000000000000000000000000111;
        Sprites[18] = 48'b111000000000000000000000000000000000000000000111;
        Sprites[19] = 48'b111000000000000000000000000000000000000000000111;
        Sprites[20] = 48'b111000000000000000000000000000000000000000000111;
        Sprites[21] = 48'b111000000000000000000000000000000000000000000111;
        Sprites[22] = 48'b111000000000000000000000000000000000000000000111;
        Sprites[23] = 48'b111000000000000000000000000000000000000000000111;
        Sprites[24] = 48'b111000000000000000000000000000000000000000000111;
        Sprites[25] = 48'b111000000000000000000000000000000000000000000111;
        Sprites[26] = 48'b111000000000000000000000000000000000000000000111;
        Sprites[27] = 48'b111000000000000000000000000000000000000000000111;
        Sprites[28] = 48'b111000000000000000000000000000000000000000000111;
        Sprites[29] = 48'b111000000000000000000000000000000000000000000111;
        Sprites[30] = 48'b111000000000000000000000000000000000000000000111;
        Sprites[31] = 48'b111111111111111111111111111111111111111111111111;

        Sprites[32] = 48'b000000000000000000000000000000000000000000000000;
        Sprites[33] = 48'b000000000000000000000000000000000000000000000000;
        Sprites[34] = 48'b000000000000000000000000000000000000000000000000;
        Sprites[35] = 48'b000000000000000000000000000000000000000000000000;
        Sprites[36] = 48'b000000000000000000000111111111001000000000000000;
        Sprites[37] = 48'b000000000000000001101101101101001101000000000000;
        Sprites[38] = 48'b000000000000101101101001101101101101101000000000;
        Sprites[39] = 48'b000000000000000101101101101101101101001000000000;
        Sprites[40] = 48'b000000000000000000001101101001101101101000000000;
        Sprites[41] = 48'b000000000000000000110111111101101110000000000000;
        Sprites[42] = 48'b000000000000000000000101111111000000000000000000;
        Sprites[43] = 48'b000000000000000000000000000000000000000000000000;
        Sprites[44] = 48'b000000000000000000000000000000000000000000000000;
        Sprites[45] = 48'b000000000000000000000000000000000000000000000000;
        Sprites[46] = 48'b000000000000000000000000000000000000000000000000;
        Sprites[47] = 48'b000000000000000000000000000000000000000000000000;

        Sprites[48] = 48'b000000000000000000000000000000000000000000000000;
        Sprites[49] = 48'b000000000000000000000000000000000000000000000000;
        Sprites[50] = 48'b000000000000000000000000000000000000000000000000;
        Sprites[51] = 48'b000000000000000000000001001001001000000000000000;
        Sprites[52] = 48'b000000000000000000001111111111001001000000000000;
        Sprites[53] = 48'b000000000000000001101101101101001101000000000000;
        Sprites[54] = 48'b000000000000101101101001101101101101101000000000;
        Sprites[55] = 48'b000000000000001101101101101101101101001000000000;
        Sprites[56] = 48'b000000000000000001001101101001101101101000000000;
        Sprites[57] = 48'b000000000000000001110111111101101110001000000000;
        Sprites[58] = 48'b000000000000000000001101111111001001000000000000;
        Sprites[59] = 48'b000000000000000000000000001001001000000000000000;
        Sprites[60] = 48'b000000000000000000000000000000000000000000000000;
        Sprites[61] = 48'b000000000000000000000000000000000000000000000000;
        Sprites[62] = 48'b000000000000000000000000000000000000000000000000;
        Sprites[63] = 48'b000000000000000000000000000000000000000000000000;

        Sprites[64] = 48'b000000000000000000000000000000000000000000000000;
        Sprites[65] = 48'b000000000000000000000000000000000000000000000000;
        Sprites[66] = 48'b000000000000000000111001001111000000000000000000;
        Sprites[67] = 48'b000000000000000111001001001001001001111000000000;
        Sprites[68] = 48'b000000000000000001001111111111001001001111000000;
        Sprites[69] = 48'b000000000000111001101101101101001101001111000000;
        Sprites[70] = 48'b000000000111101101101001101101101101101111000000;
        Sprites[71] = 48'b000000000111001101101101101101101101111111000000;
        Sprites[72] = 48'b000000000111001001001101101001101101101000000000;
        Sprites[73] = 48'b000000000000111001110111111101101110001111000000;
        Sprites[74] = 48'b000000000000000001001101111111001001111000000000;
        Sprites[75] = 48'b000000000000000111001001001001001111000000000000;
        Sprites[76] = 48'b000000000000000000111001001001000000000000000000;
        Sprites[77] = 48'b000000000000000000000000000000000000000000000000;
        Sprites[78] = 48'b000000000000000000000000000000000000000000000000;
        Sprites[79] = 48'b000000000000000000000000000000000000000000000000;

        Sprites[80] = 48'b101101101101101101101101101101101101101101101101;
        Sprites[81] = 48'b101010010010010010010010010010010010010010010101;
        Sprites[82] = 48'b101010010010010010010010010010010010010010010101;
        Sprites[83] = 48'b101010010010010010010010010010010010010010010101;
        Sprites[84] = 48'b101010010010010010010010010010010010010010010101;
        Sprites[85] = 48'b101010010010010010010010010010010010010010010101;
        Sprites[86] = 48'b101010010010010010010010010010010010010010010101;
        Sprites[87] = 48'b101010010010010010010010010010010010010010010101;
        Sprites[88] = 48'b101010010010010010010010010010010010010010010101;
        Sprites[89] = 48'b101010010010010010010010010010010010010010010101;
        Sprites[90] = 48'b101010010010010010010010010010010010010010010101;
        Sprites[91] = 48'b101010010010010010010010010010010010010010010101;
        Sprites[92] = 48'b101010010010010010010010010010010010010010010101;
        Sprites[93] = 48'b101010010010010010010010010010010010010010010101;
        Sprites[94] = 48'b101010010010010010010010010010010010010010010101;
        Sprites[95] = 48'b101101101101101101101101101101101101101101101101;

        Sprites[96] = 48'b101101101101101101101101101101101101101101101101;
        Sprites[97] = 48'b101011011011011011011011011011011011011011011101;
        Sprites[98] = 48'b101011011011011011011011011011011011011011011101;
        Sprites[99] = 48'b101011011011011011011011011011011011011011011101;
        Sprites[100] = 48'b101011011011011011011011011011011011011011011101;
        Sprites[101] = 48'b101011011011011011011011011011011011011011011101;
        Sprites[102] = 48'b101011011011011011011011011011011011011011011101;
        Sprites[103] = 48'b101011011011011011011011011011011011011011011101;
        Sprites[104] = 48'b101011011011011011011011011011011011011011011101;
        Sprites[105] = 48'b101011011011011011011011011011011011011011011101;
        Sprites[106] = 48'b101011011011011011011011011011011011011011011101;
        Sprites[107] = 48'b101011011011011011011011011011011011011011011101;
        Sprites[108] = 48'b101011011011011011011011011011011011011011011101;
        Sprites[109] = 48'b101011011011011011011011011011011011011011011101;
        Sprites[110] = 48'b101011011011011011011011011011011011011011011101;
        Sprites[111] = 48'b101101101101101101101101101101101101101101101101;

        Sprites[112] = 48'b101101101101101101101101101101101101101101101101;
        Sprites[113] = 48'b101101101101101101101101101101101101101101101101;
        Sprites[114] = 48'b101101101101101101101101101101101101101101101101;
        Sprites[115] = 48'b101101101101101101101101101101101101101101101101;
        Sprites[116] = 48'b101101101101101101101101101101101101101101101101;
        Sprites[117] = 48'b101101101101101101101101101101101101101101101101;
        Sprites[118] = 48'b101101101101101101101101101101101101101101101101;
        Sprites[119] = 48'b101101101101101101101101101101101101101101101101;
        Sprites[120] = 48'b101101101101101101101101101101101101101101101101;
        Sprites[121] = 48'b101101101101101101101101101101101101101101101101;
        Sprites[122] = 48'b101101101101101101101101101101101101101101101101;
        Sprites[123] = 48'b101101101101101101101101101101101101101101101101;
        Sprites[124] = 48'b101101101101101101101101101101101101101101101101;
        Sprites[125] = 48'b101101101101101101101101101101101101101101101101;
        Sprites[126] = 48'b101101101101101101101101101101101101101101101101;
        Sprites[127] = 48'b101101101101101101101101101101101101101101101101;
    end

    // Bloco always para gerenciamento de estados e construção do vetor de pixels
    always @(posedge clock_50) 
    begin
        if(reset) begin
            contadorLinha = 0;
            LinhaSpriteTemp = LinhaSprites1; 
            EstadoAtual = ATUALIZAR_LINHA;
        end 

        else 
        begin
            EstadoAtual <= EstadoFuturo;
            case (EstadoFuturo)
                ATUALIZAR_LINHA: 
                begin
                    case(contadorLinha)
                        0: LinhaSpriteTemp = LinhaSprites1;
                        1: LinhaSpriteTemp = LinhaSprites2;
                        2: LinhaSpriteTemp = LinhaSprites3;
                        3: LinhaSpriteTemp = LinhaSprites4;
                        4: LinhaSpriteTemp = LinhaSprites5;
                        5: LinhaSpriteTemp = LinhaSprites6;
                        6: LinhaSpriteTemp = LinhaSprites7;
                        7: LinhaSpriteTemp = LinhaSprites8;
                        8: LinhaSpriteTemp = LinhaSprites9;
                        9: LinhaSpriteTemp = LinhaSprites10;
                    endcase

                    if(contadorLinha > 9)
                        contadorLinha = 0;
                    else
                        contadorLinha = contadorLinha + 1;
                    
                    EstadoFuturo = PROCESSAR_METADE_1;
                end

                PROCESSAR_METADE_1: 
                begin
                    // Processar a primeira metade da linha (pixels 0 a 9)
                    for (i = 0; i < 10; i = i + 1)
                    begin
                        // Sprite Robo
                        if (LinhaSpriteTemp[79 - (i * 3) -: 3] == 4'b0000)
                        begin
                            VetorPixels[i] = Sprites[i * 16 + DeslocamentoLinha];
                        end
                        // Sprite Cursor
                        else if (LinhaSpriteTemp[79 - (i * 3) -: 3] == 4'b0001)
                        begin
                            VetorPixels[i] = Sprites[i * 16 + DeslocamentoLinha];
                        end
                        // Sprite Lixo 1
                        else if (LinhaSpriteTemp[79 - (i * 3) -: 3] == 4'b0010)
                        begin
                            VetorPixels[i] = Sprites[i * 16 + DeslocamentoLinha];
                        end
                        // Sprite Lixo 2
                        else if (LinhaSpriteTemp[79 - (i * 3) -: 3] == 4'b0011)
                        begin
                            VetorPixels[i] = Sprites[i * 16 + DeslocamentoLinha];
                        end
                        // Sprite Lixo 3
                        else if (LinhaSpriteTemp[79 - (i * 3) -: 3] == 4'b0100)
                        begin
                            VetorPixels[i] = Sprites[i * 16 + DeslocamentoLinha];
                        end
                        // Sprite Sem Cano
                        else if (LinhaSpriteTemp[79 - (i * 3) -: 3] == 4'b0101)
                        begin
                            VetorPixels[i] = Sprites[i * 16 + DeslocamentoLinha];
                        end
                        // Sprite Cano
                        else if (LinhaSpriteTemp[79 - (i * 3) -: 3] == 4'b0110)
                        begin
                            VetorPixels[i] = Sprites[i * 16 + DeslocamentoLinha];
                        end
                        // Sprite Célula Preta
                        else if (LinhaSpriteTemp[79 - (i * 3) -: 3] == 4'b0111)
                        begin
                            VetorPixels[i] = Sprites[i * 16 + DeslocamentoLinha];
                        end
                    end
                    
                    EstadoFuturo = PROCESSAR_METADE_2;
                end

                PROCESSAR_METADE_2: 
                begin
                    // Processar a segunda metade da linha (pixels 10 a 19)
                    for (i = 10; i < 20; i = i + 1)
                    begin
                        // Sprite Robo
                        if (LinhaSpriteTemp[79 - ((i - 10) * 3) -: 3] == 4'b0000)
                        begin
                            VetorPixels[i] = Sprites[i * 16 + DeslocamentoLinha];
                        end
                        // Sprite Cursor
                        else if (LinhaSpriteTemp[79 - ((i - 10) * 3) -: 3] == 4'b0001)
                        begin
                            VetorPixels[i] = Sprites[i * 16 + DeslocamentoLinha];
                        end
                        // Sprite Lixo 1
                        else if (LinhaSpriteTemp[79 - ((i - 10) * 3) -: 3] == 4'b0010)
                        begin
                            VetorPixels[i] = Sprites[i * 16 + DeslocamentoLinha];
                        end
                        // Sprite Lixo 2
                        else if (LinhaSpriteTemp[79 - ((i - 10) * 3) -: 3] == 4'b0011)
                        begin
                            VetorPixels[i] = Sprites[i * 16 + DeslocamentoLinha];
                        end
                        // Sprite Lixo 3
                        else if (LinhaSpriteTemp[79 - ((i - 10) * 3) -: 3] == 4'b0100)
                        begin
                            VetorPixels[i] = Sprites[i * 16 + DeslocamentoLinha];
                        end
                        // Sprite Sem Cano
                        else if (LinhaSpriteTemp[79 - ((i - 10) * 3) -: 3] == 4'b0101)
                        begin
                            VetorPixels[i] = Sprites[i * 16 + DeslocamentoLinha];
                        end
                        // Sprite Cano
                        else if (LinhaSpriteTemp[79 - ((i - 10) * 3) -: 3] == 4'b0110)
                        begin
                            VetorPixels[i] = Sprites[i * 16 + DeslocamentoLinha];
                        end
                        // Sprite Célula Preta
                        else if (LinhaSpriteTemp[79 - ((i - 10) * 3) -: 3] == 4'b0111)
                        begin
                            VetorPixels[i] = Sprites[i * 16 + DeslocamentoLinha];
                        end
                    end
                        
                        EstadoFuturo = ATUALIZAR_LINHA;
                end
            endcase
        end
    end

    always @ (posedge clock_25)
    begin
        if (reset || display_on == 0 || IndicePixel == 31)
        begin
            IndicePixel <= 0;
        end
        else 
        begin
            IndicePixel <= IndicePixel + 1;
        end
    end

    always @ (*) begin
        if (!display_on) begin
            RGB = COR_PRETO;
        end else begin
            // Corrigido para não redefinir os parâmetros
            case (VetorPixels[IndicePixel])            
                CODIGO_AZUL:        RGB = COR_AZUL;
                CODIGO_BRANCO:      RGB = COR_BRANCO;
                CODIGO_CIANO:       RGB = COR_CIANO;
                CODIGO_LARANJA:     RGB = COR_LARANJA;
                CODIGO_PRETO:       RGB = COR_PRETO;
                CODIGO_VERDE:       RGB = COR_VERDE;
                CODIGO_VERMELHO:    RGB = COR_VERMELHO;            
                default:            RGB = COR_PRETO; 
            endcase        
        end
    end

endmodule
