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
    #define L_PAREN 4
    #define R_PAREN 5
    #define VIRGULA 6
    #define SEMICOLON 7
    #define ATRIBUICAO 8

    #define DIGITO_INTEIRO 9
    #define DIGITO_DECIMAL 10
    #define STRING 11
    #define PALAVRA_RESERVADA 12

    #define OP_REL 13
    #define OP_LOG 14
    #define OP_ARI 15

    #define PONTEIRO 16

    #define INCLUDES 17

    #define NOVA_LINHA 18

    int id_atual;
    int ultima_linha = 0;

    char* vetor[100];

    struct lista_no {
        char lexema[TAM_LEXEMA];
        int num_lexema;
        char hash[10];
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
    char* retorna_ultimo_hash ();
    void concat_comandos (char* prefix, char* name, char* sufix);
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

libs "<"([^ \n\t\r])*([a-zA-Z][a-zA-Z0-9_])*".h>"

%%

{ponteiro}      printf("ponteiro => %s\n", yytext);
{atribuicao}    printf("caracter de atribuicao => %s\n", yytext);
{l_paren}       printf("parenteses esquerdo => %s\n", yytext);    
{r_paren}       printf("parenteses direito => %s\n", yytext);

{l_chave} {
    printf("abertura bloco de codigo => %s\n", yytext);
    return L_CHAVES;
}
{r_chave} {
    printf("fechamento bloco de codigo => %s\n", yytext);
    return R_CHAVES;
}      

{virgula}       printf("virgula => %s\n", yytext);
{semicolon}     printf("ponto e virgula => %s\n", yytext);

{comentario}.*
"/*"([^*]|\*+[^*/])*\*+"/"

{digito}+               printf("num inteiro => %s\n", yytext);
{digito}+"."{digito}*   printf("num decimal => %s\n", yytext);
{string}                printf("string => %s\n", yytext);
{palavra_reservada}     return PALAVRA_RESERVADA;
{op_rel}                printf("operador relacional => %s\n", yytext);
{op_log}                printf("operador logico => %s\n", yytext);
{op_ari}                printf("operador aritmetico => %s\n", yytext);

{libs}                  return INCLUDES;

{id} {
    printf("ID => %s\n", yytext);
    return IDENTIFICADOR;
}

[\n]                    return NOVA_LINHA;
[ \t]+ 
.                       printf("desconhecido => %s\n", yytext);

%%

int main(int argc, char *argv[]) {

    printf("\n**********************************************\n");

    int nextToken = -1;
    id_atual = 0;

    yyin = fopen(argv[1], "r");

    for (int i = 0; i < QTD_SLOT; i++) {
        tab[i] = NULL;
    }

    for (int i = 0; i < QTD_HASH; i++) {
        vec_hash[i] = NULL;
    }

    while (nextToken = yylex()) {
        
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
        }
        else if (nextToken == L_CHAVES) {
            
            bool recriar_hash = true;
            char* _hash;
            
            _hash = criar_hash();
            
            while (recriar_hash) {
                recriar_hash = false;
                for (int i = 0; i < QTD_HASH; i++) {
                    if ((vec_hash[i] != NULL) && (strcmp(vec_hash[i]->hash, _hash) == 0)) {
                        recriar_hash = true;
                        break;
                    }
                }
                if (recriar_hash) _hash = criar_hash();
            }

            for (int i = 0; i < QTD_HASH; i++) {
                if (vec_hash[i] == NULL) {
                    HASH *newhash = NULL;
                    newhash = (HASH*)malloc(sizeof(HASH));
                    strcpy(newhash->hash, _hash);
                    vec_hash[i] = newhash;
                    break;
                } 
                else if (vec_hash[i]->proximo == NULL) {
                    HASH *newhash = NULL;
                    newhash = (HASH*)malloc(sizeof(HASH));
                    newhash->proximo = NULL;
                    strcpy(newhash->hash, _hash);
                    vec_hash[i]->proximo = newhash;
                    break;
                }
            }            
        }
        else if (nextToken == R_CHAVES) {

            for (int i = 0; i < QTD_HASH; i++) {
                if (vec_hash[i] == NULL) {
                    vec_hash[i-1] = NULL;
                    break;
                }
            }

        }
        else if (nextToken == L_PAREN) {}
        else if (nextToken == R_PAREN) {}
        else if (nextToken == VIRGULA) {}
        else if (nextToken == SEMICOLON) {}
        else if (nextToken == ATRIBUICAO) {}
        else if (nextToken == DIGITO_INTEIRO) {}
        else if (nextToken == DIGITO_DECIMAL) {}
        else if (nextToken == STRING) {}
        else if (nextToken == PALAVRA_RESERVADA) {
            if (strcmp(yytext, "#include") == 0) 
                concat_comandos("[reservado, ", yytext, "] ");    
        }
        else if (nextToken == OP_REL) {}
        else if (nextToken == OP_LOG) {}
        else if (nextToken == OP_ARI) {}
        else if (nextToken == PONTEIRO) {}
        else if (nextToken == INCLUDES) {
            char* prefix = "[lib, ";
            char* name = yytext;
            char* sufix = "] ";
            concat_comandos(prefix, name, sufix);
        }
        else if (nextToken == NOVA_LINHA) {
            ultima_linha++;
        }
    }    

    fclose(yyin);
 
    printf("\n**********************************************\n\n");

    /* for (int i = 0; i < QTD_HASH; i++) {
        if (vec_hash[i] != NULL) printf("[SLOT %d] %s \n", i, vec_hash[i]->hash);
    }


    for (int i = 0; i < QTD_SLOT; i++) {
        if (tab[i] != NULL) printf("[SLOT %d] %s \t\t (id_atual, %d) \t (hash, %s)\n", i, tab[i]->lexema, tab[i]->num_lexema, tab[i]->hash);
    } */

    for (int i = 0; i < 100; i++) {
        if (vetor[i] != NULL) printf("[%d]: %s \n", i, vetor[i]);
    }


    return 0;    
}

void inserirID (int slot, char* lexema) {
    
    LISTA *slot_atual = tab[slot];
    LISTA *slot_anterior = NULL; /* aponta para lista anterior */
    LISTA *colisao = NULL;
    int index = slot;

    if (slot_atual != NULL) {
        while (slot_atual != NULL) {
            if ((strcmp(slot_atual->lexema, lexema) == 0) && (strcmp(slot_atual->hash, retorna_ultimo_hash()) == 0)) {
                printf(" --> [AVISO] Lexema [%s] ja existe na tabela de simbolos \n", lexema);
                break;
            }
            if (slot_atual->prox == NULL) {

                printf(" --> [AVISO else dentro do while] Inserindo o lexema [%s] no SLOT vazio da tabela de simbolos \n", lexema);
                colisao = (LISTA*)malloc(sizeof(LISTA));
                colisao->prox = NULL;
                colisao->num_lexema = id_atual++;

                char* hash_escopo = retorna_ultimo_hash();
                if (strcmp(hash_escopo, "@") != 0) 
                    strcpy(colisao->hash, hash_escopo);

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
        colisao->num_lexema = id_atual++;
        
        char* hash_escopo = retorna_ultimo_hash();
        if (strcmp(hash_escopo, "@") != 0) 
            strcpy(colisao->hash, hash_escopo);

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

char* retorna_ultimo_hash () {

    for (int i = 0; i < QTD_HASH; i++) {
        if ((vec_hash[i] == NULL) && (i > 0)) {
            return vec_hash[i - 1]->hash;
        }
        else if ((vec_hash[i] == NULL) && (i == 0)) return "@";
    }

    return "@";
}


void concat_comandos (char* prefix, char* name, char* sufix) {
    
    const char* comandos_linha_atual;

    if (vetor[ultima_linha] != NULL) 
        comandos_linha_atual = vetor[ultima_linha];
            
    char* concat_comando;
    concat_comando = malloc(strlen(comandos_linha_atual) + strlen(prefix) + strlen(name) + strlen(sufix)); 
    if (vetor[ultima_linha] != NULL) {
        strcpy(concat_comando, comandos_linha_atual);
        strcat(concat_comando, prefix);
    }
    else 
        strcpy(concat_comando, prefix);
    
    strcat(concat_comando, name);
    strcat(concat_comando, sufix);
            
    vetor[ultima_linha] = concat_comando;

}