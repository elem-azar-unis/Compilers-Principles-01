%{
#include "lex.yy.c"
#ifndef YYSTYPE
#define YYSTYPE Node*
#endif
%}
%token SEMI COMMA ASSIGNOP RELOP 
%token PLUS MINUS STAR DIV 
%token AND OR DOT NOT TYPE 
%token LP RP LB RB LC RC 
%token STRUCT RETURN IF ELSE WHILE
%token ID INT FLOAT
%%
%%