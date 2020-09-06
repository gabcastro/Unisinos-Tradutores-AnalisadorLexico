# Analisador Léxico #

## Conteúdo

- [Sobre](#about)
- [Como executar](#getting_started)
- [Referências](#refs)

## Sobre <a name = "about"></a> ##

Criação de um analisador léxico que tem como objetivo identificar os seguintes padrões:

- **Variáveis ou identificadores:** reconhecer variáveis, funções, parâmetros de funções. Exemplo:
```
// trecho de código
int x = 7;
int y;

// tokens gerados
[reserved word, int] [id, 1] [equal_op, =] [num, 7]
[reserved word, int] [id, 2]
```

- **Constantes numéricas (números inteiros):** reconhecer um número inteiro qualquer e convertê-lo para os respectivos tokens:
```
// trecho de código
int x = 7 + 25 * 52;

// tokens gerados
[reserved word, int] [id, 1] [equal_op, =] [num, 7] [arith_op, +] [num, 25] [arith_op, *] [num, 52]
```

- **Palavras reservadas:** reconhecer palavras reservadas. Por exemplo: *do, while, if, else, switch, for, return, null, int, float, double, string, bool, break, case, etc* e convertê-las para os respectivos tokens:
```
// trecho de código
if (x == 10)

// token gerado
[reserved word, if] [id, 1] [relational_op, ==] [num, 10]
```

- **Operadores relacionais:** reconhecer os operadores relacionais: `<, <=, ==, !=, >=, >` e convertê-los para os respectivos tokens:
```
// Trecho de código
while( x != 0)

// Tokens gerados:
[reserved_word, while] [id, 1] [Relational_Op, !=] [num, 0]
```

- **Números de ponto flutuante (números reais):** reconhecer números reais quaisquer e convertê-los para os respectivos tokens:
```
// Trecho de código
int x = 7.15 - 2.13;

// Tokens gerados
[reserved_word, int] [id, 1] [Equal_Op, =] [num, 7.15] [Arith_Op, -] [num, 2.13]
```

- **Remoção de espaços em branco e comentários:** reconhecer espaços em branco e comentários no código fonte e removê-los (ignorá-los)
```
// Trecho de código

// Comentário 1
/* Comentário 2 */
```

- **Strings:** reconhecer os strings e convertê-las para seus respectivos tokens:
```
// Trecho de código
String sexo = “masculino”;

// Tokens gerados:
[reserved_word, String] [id, 1] [equal, =] [string_literal, masculino]
```

- **Operadores lógicos:** reconhecer os operadores lógicos: `|| &&` e convertê-los para os respectivos tokens:
```
// Trecho de código
if(idade > 70 && sexo == “masculino”)

//Tokens gerados
[reserved_word, if] [id, 1] [Relational_Op, >] [num, 70] [logic_op, &&] [id, 2] [Relational_Op, ==] [Relational_Op, string_literal]
```

- **Demais caracteres:** reconhecer os caracteres: `= ( ) { } , ;` e convertê-los para seus respectivos tokens:
```
[equal, =] [l_paren, (] [r_paren, )] [l_bracket, {] [r_bracket, }] [r_bracket, }] [comma, ,] [semicolon, ;]
```

## Como executar <a name = "getting_started"></a> ##

Após a criação do código em `.lex`, é necessário executar o programa Flex Tools para a criação do arquivo C.

`$ (Flex/GnuWin32/bin): flex.exe identificador_lexico.lex`

Posteriormente gerar o executável através do gcc, e por último executar passando o arquivo de entrada.

Pode ser realizado os três comando executando o `.bat` que está na raiz.

## Referências <a name = "refs"></a> ##

- [Lex - A Lexical Analyzer Generator](http://dinosaur.compilertools.net/lex/index.html)
- [ASCII](https://pt.wikipedia.org/wiki/ASCII)