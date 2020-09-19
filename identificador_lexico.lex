%option noyywrap

%{
    #include <math.h>
    #include <string.h>
    #include <stdbool.h>
    #include <stdlib.h>

    #define QTD_SLOT 100
    #define TAM_LEXEMA 100
    #define QTD_HASH 10

    #define IDENTIFICADOR 1
    #define L_CHAVES 2
    #define R_CHAVES 3

    struct lista_no {
        char lexema[TAM_LEXEMA];
        struct lista_no *prox;
    };
    typedef struct lista_no LISTA;
    LISTA *tab[QTD_SLOT];

    struct vetor_hash {
        char hash[10];
        struct vetor_hash *proximo;
    };
    typedef struct vetor_hash HASH;
    HASH *vec_hash[QTD_HASH];

    // declaração das funções utilizadas
    void inserirID (int slot, char* lexema);
    char* criar_hash ();
%}

digito [0-9]
palavra [a-zA-Z][a-zA-Z0-9_]*"[]"?

comentario [//]

string ["].*["]

palavra_reservada_min int|float|string|#include|void|printf|scanf|if|return|for|while|else|break|null
palavra_reservada_mai INT|FLOAT|STRING|#INCLUDE|VOID|PRINTF|SCANF|IF|RETURN|FOR|WHILE|ELSE|BREAK|NULL
palavra_reservada {palavra_reservada_mai}|{palavra_reservada_min}

op_rel "<"|"<="|"=="|"!="|">="|">"
op_log "||"|"&&"
op_ari "+"|"-"|"/"|"*"|"++"|"--"

atribuicao "="
l_paren "("
r_paren ")"
l_chave "{"
r_chave "}"
virgula ","
semicolon ";"

ponteiro "*"" "?[(]?{palavra}[)]?

id {ponteiro}|{palavra}

libs "<"([^\n\t\r])*([a-zA-Z][a-zA-Z0-9_])*".h>"

%%

{ponteiro}      printf("ponteiro => %s\n", yytext);
{atribuicao}    printf("caracter de atribuicao => %s\n", yytext);
{l_paren}       printf("parenteses esquerdo => %s\n", yytext);    
{r_paren}       printf("parenteses direito => %s\n", yytext);

{l_chave} {
    printf("abertura bloco de codigo => %s\n", yytext);
    return L_CHAVES;
}

{r_chave}       printf("fechamento bloco de codigo => %s\n", yytext);
{virgula}       printf("virgula => %s\n", yytext);
{semicolon}     printf("ponto e virgula => %s\n", yytext);
{comentario}.*
"/*"([^*]|\*+[^*/])*\*+"/"
{digito}+               printf("num inteiro => %s\n", yytext);
{digito}+"."{digito}*   printf("num decimal => %s\n", yytext);
{string}                printf("string => %s\n", yytext);
{palavra_reservada}     printf("palavra reservada => %s\n", yytext);
{op_rel}                printf("operador relacional => %s\n", yytext);
{op_log}                printf("operador logico => %s\n", yytext);
{op_ari}                printf("operador aritmetico => %s\n", yytext);
{libs}                  printf("reconhecimento de biblioteca => %s\n", yytext);

{id} {
    printf("ID => %s\n", yytext);
    return IDENTIFICADOR;
}

[ \t\n]+

.   printf("desconhecido => %s\n", yytext);

%%

int main(int argc, char *argv[]) {

    printf("\n**********************************************\n");

    int nextToken = -1;
    LISTA *p;
    bool recriar_hash = true;

    yyin = fopen(argv[1], "r");

    for (int i = 0; i < QTD_SLOT; i++) {
        tab[i] = NULL;
    }

    for (int i = 0; i < QTD_HASH; i++) {
        vec_hash[i] = NULL;
    }

    while (nextToken = yylex()) {
        printf("\n --> [nextToken]: %s \n", yytext);

        if (nextToken == -1) {
            break;
        } 
        else if (nextToken == -2) {
            printf("\n [ERRO] Lexema invalido \n");
        }
        else if (yyleng > TAM_LEXEMA) {
            printf("\n [ERRO] Lexema com tamanho superior ao setado \n");
        }
        else if (yyleng == 0) {
            printf("\n [ERRO] Lexema nao pertence a linguagem \n");
        }
        else if (nextToken == IDENTIFICADOR) {

            inserirID(nextToken -1, yytext);

            for (int i = 0; i < QTD_SLOT; i++) {
                if (tab[i] != NULL) printf("[SLOT %d] %s \n", i, tab[i]->lexema);
            }
        }
        else if (nextToken == L_CHAVES) {
            
            char* new_hash = criar_hash();
            
            printf("***** hash: %s\n", new_hash);
            
            while (recriar_hash) {
                recriar_hash = false;
                for (int i = 0; i < QTD_HASH; i++) {
                    if ((vec_hash[i] != NULL) && (strcmp(vec_hash[i]->hash, new_hash) == 0)) {
                        recriar_hash = true;
                        break;
                    }
                }
                /* if (recriar_hash) _hash = '#' + (1000 + ( rand() % 8999 )); */
            }
            /* printf("hash: %s\n", _hash); */
        }
    }    

    fclose(yyin);
 
    printf("\n**********************************************\n\n");
    return 0;    
}

void inserirID (int slot, char* lexema) {
    
    LISTA *slot_atual = tab[slot];
    LISTA *slot_anterior = NULL; /* aponta para lista anterior */
    LISTA *colisao = NULL;
    int index = slot;

    if (slot_atual != NULL) {
        while (slot_atual != NULL) {
            if (strcmp(slot_atual->lexema, lexema) == 0) {
                printf(" --> [AVISO] Lexema [%s] ja existe na tabela de simbolos \n", lexema);
                break;
            }
            if (slot_atual->prox == NULL) {
                printf(" --> [AVISO else dentro do while] Inserindo o lexema [%s] no SLOT vazio da tabela de simbolos \n", lexema);
                colisao = (LISTA*)malloc(sizeof(LISTA));
                colisao->prox = NULL;
                strcpy(colisao->lexema, lexema);
                slot_atual->prox = colisao;

                tab[index] = slot_atual;
                tab[index + 1] = colisao;
                break;
            }

            index++;
            slot_anterior = slot_atual;
            slot_atual = slot_atual->prox;
        }
    }
    else if (slot_atual == NULL) {
        printf(" --> [AVISO] Inserindo o lexema [%s] no SLOT vazio da tabela de simbolos [TABELA VAZIA] \n", lexema);
        colisao = (LISTA*)malloc(sizeof(LISTA));
        colisao->prox = NULL;
        strcpy(colisao->lexema, lexema);

        tab[slot] = colisao;
    }
}

char* criar_hash () {
    int rand_value = (1000 + ( rand() % 8999 ));
    char str_rand[6];
    char _hash[2] = "#";
    sprintf(str_rand, "%d", rand_value);
    strcat(_hash, str_rand);

    char *hs = _hash;
    char *new_hash;
    new_hash = (char*)malloc(sizeof(hs));
    strcpy(new_hash, hs);

    return new_hash;
}