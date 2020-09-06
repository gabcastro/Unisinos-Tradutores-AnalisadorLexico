%option noyywrap

%{
    #include <math.h>
%}

DIGITO [0-9]
ID [a-zA-Z][a-zA-Z0-9_]*"[]"?
COMENTARIO [//]
STRING ["].*["]

PALAVRA_RESERVADA_MIN int|float|string|#include|void|printf|scanf|if|return|for|while|else|break|null
PALAVRA_RESERVADA_MAI INT|FLOAT|STRING|#INCLUDE|VOID|PRINTF|SCANF|IF|RETURN|FOR|WHILE|ELSE|BREAK|NULL
PALAVRA_RESERVADA {PALAVRA_RESERVADA_MAI}|{PALAVRA_RESERVADA_MIN}

OP_REL "<"|"<="|"=="|"!="|">="|">"
OP_LOG "||"|"&&"
OP_ARI "+"|"-"|"/"|"*"|"++"|"--"

ATRIBUICAO "="
L_PAREN "("
R_PAREN ")"
L_CHAVE "{"
R_CHAVE "}"
VIRGULA ","
SEMICOLON ";"

PONTEIRO "*"" "?[(]?{ID}[)]?

%%
{PONTEIRO}      printf("ponteiro => %s\n", yytext);
{ATRIBUICAO}    printf("caracter de atribuicao => %s\n", yytext);
{L_PAREN}       printf("parenteses esquerdo => %s\n", yytext);
{R_PAREN}       printf("parenteses direito => %s\n", yytext);
{L_CHAVE}       printf("abertura bloco de codigo => %s\n", yytext);
{R_CHAVE}       printf("fechamento bloco de codigo => %s\n", yytext);
{VIRGULA}       printf("virgula => %s\n", yytext);
{SEMICOLON}     printf("ponto e virgula => %s\n", yytext);
{COMENTARIO}.*
{DIGITO}+               printf("num inteiro => %s\n", yytext);
{DIGITO}+"."{DIGITO}*   printf("num decimal => %s\n", yytext);
{STRING}                printf("string => %s\n", yytext);
{PALAVRA_RESERVADA}     printf("palavra reservada => %s\n", yytext);
{ID}                    printf("id => %s\n", yytext);
{OP_REL}                printf("operador relacional => %s\n", yytext);
{OP_LOG}                printf("operador logico => %s\n", yytext);
{OP_ARI}                printf("operador aritmetico => %s\n", yytext);

[ \t\n]+

.   printf("desconhecido => %s\n", yytext);

%%

int main(int argc, char *argv[]) {
    printf("\n**********************************************\n");
    yyin = fopen(argv[1], "r");
    yylex();
    fclose(yyin);
    printf("**********************************************\n\n");
    return 0;    
}