#include <fstream>
#include <chrono>
#include <array>
#include <random>
#include <algorithm>


// mt19937 é mais eficiente e gera aleatórios de até 64-bits (usando 32 por precaução, questões de arquitetura)
std::mt19937 rng(std::chrono::system_clock::now().time_since_epoch().count());


// Definindo as direções -> Esquerda, baixo, direita, cima
const int dx[] = {0, 1, 0, -1}, dy[] = {-1, 0, 1, 0};


// Pré-definindo as direções, as quais serão embaralhadas durante a busca, para garantir um mapa mais "uniforme"
int direcoes[4] = {0, 1, 2, 3}, orientacoes[4] = {2, 3, 1, 0};


// Parâmetros: máximo de curvas e entulhos, tamanho máximo do caminho, altura e largura do mapa
const int N = 20, ENT = 8, TAM_MAX = 8;
const int H = 11, W = 20;


int mapa[H][W];


bool dfs(int x, int y, std::array<int, N>& arestas, int n, int dir){
    if(n == arestas.size()) return true;
    int tam = arestas[n];
    std::shuffle(direcoes, direcoes+4, rng);
    for(int i: direcoes){
        int nx = x + tam*dx[i], ny = y + tam*dy[i];
        if((i+2) % 4 == dir || nx < 1 || ny < 0 || nx >= H || ny >= W) continue;
        if(i & 1){
            int a_x = x, b_x = nx;
            if(a_x > b_x) std::swap(a_x, b_x);
            for(int j = a_x; j <= b_x; ++j) mapa[j][y] = 0;
            if(dfs(nx, ny, arestas, n+1, i)) return true;
            for(int j = a_x; j <= b_x; ++j) mapa[j][y] = 1;
        }
        else{
            int a_y = y, b_y = ny;
            if(a_y > b_y) std::swap(a_y, b_y);
            for(int j = a_y; j <= b_y; ++j) mapa[x][j] = 0;
            if(dfs(nx, ny, arestas, n+1, i)) return true;
            for(int j = a_y; j <= b_y; ++j) mapa[x][j] = 1;
        }
    }
    return false;
}


// Gerador de números aleatórios
int aleatorio(int a, int b){
    return a + rng() % (b-a+1);
}


void adicionarParams(int entrada_x, int entrada_y, int dir){
    mapa[0][0] = entrada_x/16, mapa[0][1] = entrada_x % 16;
    mapa[0][2] = entrada_y/16, mapa[0][3] = entrada_y % 16;
    mapa[0][4] = orientacoes[dir];
}


int main(){
    int entulhos = aleatorio(1, ENT); // Gerando um número aleatório de entulhos dentro do máximo especificado
    std::array<int, N> arestas;
    std::fill(mapa[0], mapa[0]+H*W, 1);

    /* Solução mais simples para evitar "tubulações duplas" é inserindo apenas arestas com valores pares.
    No entanto, caso seja necessário, é possível modificar algumas coisas na dfs para inserir ímpares. */

    for(int& aresta: arestas){
        aresta = 2*aleatorio(1, TAM_MAX/2);
    }

    // Adicionando os caminhos

    bool valido = 0;
    while(!valido){
        int entrada_x = aleatorio(1, H-1), entrada_y = aleatorio(0, W-1), rnd = aleatorio(0, 3);
        rnd & 2 ? entrada_x = 1 + (H-2)*(rnd & 1) : entrada_y = (W-1)*(rnd & 1);
        adicionarParams(entrada_x, entrada_y, rnd);
        valido = dfs(entrada_x, entrada_y, arestas, 0, -1);
        mapa[entrada_x][entrada_y] = valido << 1;
    }

    // Adicionando os entulhos

    while(entulhos--){
        int x = aleatorio(1, H-1), y = aleatorio(0, W-1);
        while(mapa[x][y]) x = aleatorio(1, H-1), y = aleatorio(0, W-1);
        mapa[x][y] = aleatorio(3, 5);
    }

    // Inserindo o conteúdo no txt

    std::ofstream gerador;
    gerador.open("Mapa.txt");

    for(int j = 0; j < W; ++j){
        j < 4 ? gerador << std::hex << std::uppercase << mapa[0][j] : gerador << mapa[0][j];
    }
    gerador << '\n';
    for(int i = 1; i < H; ++i){
        for(int j = 0; j < W; ++j){
            gerador << mapa[i][j];
        }
        gerador << '\n';
    }

    gerador.close();

    return 0;
}

