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