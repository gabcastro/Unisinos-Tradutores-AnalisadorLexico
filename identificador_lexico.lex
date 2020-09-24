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
    int ultimo_hash = -1;

    char* vetor[100];

    struct lista_no {
        char lexema[TAM_LEXEMA];
        char endereco[TAM_LEXEMA];
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
    void concat_comandos_id (char* prefix, char* name, char* pipe, char* endereco, char* sufix);
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

{ponteiro}      return PONTEIRO;
{atribuicao}    return ATRIBUICAO;
{l_paren}       return L_PAREN;
{r_paren}       return R_PAREN;
{l_chave}       return L_CHAVES;
{r_chave}       return R_CHAVES;
{virgula}       return VIRGULA;
{semicolon}     return SEMICOLON;

{comentario}.*
"/*"([^*]|\*+[^*/])*\*+"/"

{digito}+               return DIGITO_INTEIRO;
{digito}+"."{digito}*   return DIGITO_DECIMAL;
{string}                return STRING;
{palavra_reservada}     return PALAVRA_RESERVADA;
{op_rel}                return OP_REL;
{op_log}                return OP_LOG;
{op_ari}                return OP_ARI;
{libs}                  return INCLUDES;
{id}                    return IDENTIFICADOR;
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
            
            if ((ultimo_hash == -1) && (tab[0]->prox == NULL)) {
                printf("ultimo_hash  primeira posicao: %d\n", ultimo_hash);
                concat_comandos_id("[id, (", yytext, " | ", tab[0]->endereco, ")] ");
            } 
            else if ((ultimo_hash == -1) && (tab[0]->prox != NULL)) {
                for (int i = 1; i < QTD_SLOT; i++) {
                    if ((tab[i] != NULL) && (strcmp(tab[i]->lexema, yytext) == 0) && (strcmp(tab[i]->hash, "@-1") == 0)) {
                        printf("ultimo_hash  nova funcao: %d\n", ultimo_hash);
                        concat_comandos_id("[id, (", yytext, " | ", tab[i]->lexema, ")] ");
                        break;
                    }
                }
            }
            else {
                for (int i = 1; i < QTD_SLOT; i++) {
                    if ((tab[i] != NULL) && (strcmp(tab[i]->lexema, yytext) == 0) && (strcmp(vec_hash[ultimo_hash]->hash, tab[i]->hash) == 0)) {
                        concat_comandos_id("[id, (", yytext, " | ", tab[i]->endereco, ")] ");
                        break;
                    }
                }
            }
        }
        else if (nextToken == L_CHAVES) {
            
            concat_comandos("[l_chaves, ", yytext, "] ");

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
                    ultimo_hash++;
                    break;
                } 
            }       
        }
        else if (nextToken == R_CHAVES) {
            
            concat_comandos("[r_chaves, ", yytext, "] ");

            for (int i = 0; i < QTD_HASH; i++) {
                if (vec_hash[i] == NULL) {
                    vec_hash[i-1] = NULL;
                    ultimo_hash--;
                    break;
                }
            }
        }
        else if (nextToken == L_PAREN)                      concat_comandos("[l_paren, ", yytext, "] ");
        else if (nextToken == R_PAREN)                      concat_comandos("[r_paren, ", yytext, "] ");
        else if (nextToken == VIRGULA)                      concat_comandos("[virgula, ", yytext, "] ");
        else if (nextToken == SEMICOLON)                    concat_comandos("[ponto&virgula, ", yytext, "] ");
        else if (nextToken == ATRIBUICAO)                   concat_comandos("[atribuicao, ", yytext, "] ");
        else if (nextToken == DIGITO_INTEIRO)               concat_comandos("[num_inteiro, ", yytext, "] ");
        else if (nextToken == DIGITO_DECIMAL)               concat_comandos("[num_dec, ", yytext, "] ");
        else if (nextToken == STRING)                       concat_comandos("[char, ", yytext, "] ");
        else if (nextToken == PALAVRA_RESERVADA)            concat_comandos("[palavra reservada, ", yytext, "] ");    
        else if (nextToken == OP_REL)                       concat_comandos("[op_rel, ", yytext, "] ");
        else if (nextToken == OP_LOG)                       concat_comandos("[op_log, ", yytext, "] ");
        else if (nextToken == OP_ARI)                       concat_comandos("[op_ari, ", yytext, "] ");
        else if (nextToken == PONTEIRO)                     concat_comandos("[ponteiro, ", yytext, "] ");
        else if (nextToken == INCLUDES)                     concat_comandos("[lib, ", yytext, "] ");
        else if (nextToken == NOVA_LINHA)                   ultima_linha++;
    }    

    fclose(yyin);
 
    printf("\n**********************************************\n\n");

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
                strcpy(colisao->endereco, criar_hash());

                char* hash_escopo = retorna_ultimo_hash();
                /* if (strcmp(hash_escopo, "@") != 0)  */
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
        strcpy(colisao->endereco, criar_hash());
        
        char* hash_escopo = retorna_ultimo_hash();
        /* if (strcmp(hash_escopo, "@") != 0)  */
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
            return vec_hash[i-1]->hash;
        }
        else if ((vec_hash[i] == NULL) && (i == 0)) return "@-1";
    }

    return "@-1";
}


void concat_comandos (char* prefix, char* name, char* sufix) {
    
    const char* comandos_linha_atual;
    char* concat_comando;

    if (vetor[ultima_linha] != NULL) 
        comandos_linha_atual = vetor[ultima_linha];

    concat_comando = malloc(strlen(comandos_linha_atual) + strlen(endereco) + strlen(prefix) + strlen(name) + strlen(sufix)); 
    
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

void concat_comandos_id (char* prefix, char* name, char* pipe, char* endereco, char* sufix) {

    const char* comandos_linha_atual;
    char* concat_comando;

    if (vetor[ultima_linha] != NULL) 
        comandos_linha_atual = vetor[ultima_linha];

    concat_comando = malloc(strlen(comandos_linha_atual) + strlen(endereco) + strlen(pipe) + strlen(prefix) + strlen(name) + strlen(sufix)); 
    
    if (vetor[ultima_linha] != NULL) {
        strcpy(concat_comando, comandos_linha_atual);
        strcat(concat_comando, prefix);
    }
    else 
        strcpy(concat_comando, prefix);
    
    strcat(concat_comando, name);
    strcat(concat_comando, pipe);
    strcat(concat_comando, endereco);
    strcat(concat_comando, sufix);
            
    vetor[ultima_linha] = concat_comando;
}