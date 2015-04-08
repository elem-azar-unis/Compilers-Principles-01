%{
#include "tree.h"
#include <stdbool.h>
#define YYSTYPE Node*
#include "syntax.tab.h"
int yycolumn = 1;
#define YY_USER_ACTION \
	yylloc.first_line = yylloc.last_line = yylineno; \
	yylloc.first_column = yycolumn; \
	yylloc.last_column = yycolumn + yyleng - 1; \
	yycolumn += yyleng;
int get_value(const char* p);
bool error_occured=false;
%}
%option yylineno
blanks [ \r\t]+
letter_ [_A-Za-z]
digit [0-9]
int [1-9]{digit}*|0[0-7]+|0[Xx][0-9A-Fa-f]+|0
float {digit}+\.{digit}+
id {letter_}({letter_}|{digit})*
illOctInt 0[0-9]+
illHexInt 0[Xx][0-9A-Za-z]+
illID {digit}({letter_}|{digit})*
%%
{blanks} {}
\n {yycolumn=1;}
";" {yylval=create_node(_SEMI);yylval->line=yylineno;return SEMI;}
"," {yylval=create_node(_COMMA);yylval->line=yylineno;return COMMA;}
"=" {yylval=create_node(_ASSIGNOP);yylval->line=yylineno;return ASSIGNOP;}
">"|"<"|">="|"<="|"=="|"!=" {yylval=create_node(_RELOP);yylval->line=yylineno;return RELOP;}
"+" {yylval=create_node(_PLUS);yylval->line=yylineno;return PLUS;}
"-" {yylval=create_node(_MINUS);yylval->line=yylineno;return MINUS;} 
"*" {yylval=create_node(_STAR);yylval->line=yylineno;return STAR;}
"/" {yylval=create_node(_DIV);yylval->line=yylineno;return DIV;}
"&&" {yylval=create_node(_AND);yylval->line=yylineno;return AND;}
"||" {yylval=create_node(_OR);yylval->line=yylineno;return OR;}
"." {yylval=create_node(_DOT);yylval->line=yylineno;return DOT;}
"!" {yylval=create_node(_NOT);yylval->line=yylineno;return NOT;}
"int"|"float" {yylval=create_node(_TYPE);yylval->line=yylineno;strcpy(yylval->name,yytext);return TYPE;}
"(" {yylval=create_node(_LP);yylval->line=yylineno;return LP;}
")" {yylval=create_node(_RP);yylval->line=yylineno;return RP;}
"[" {yylval=create_node(_LB);yylval->line=yylineno;return LB;}
"]" {yylval=create_node(_RB);yylval->line=yylineno;return RB;}
"{" {yylval=create_node(_LC);yylval->line=yylineno;return LC;}
"}" {yylval=create_node(_RC);yylval->line=yylineno;return RC;}
"struct" {yylval=create_node(_STRUCT);yylval->line=yylineno;return STRUCT;}
"return" {yylval=create_node(_RETURN);yylval->line=yylineno;return RETURN;}
"if" {yylval=create_node(_IF);yylval->line=yylineno;return IF;}
"else" {yylval=create_node(_ELSE);yylval->line=yylineno;return ELSE;}
"while" {yylval=create_node(_WHILE);yylval->line=yylineno;return WHILE;}
{int} {yylval=create_node(_INT);yylval->line=yylineno;yylval->value_i=get_value(yytext);return INT;}
{float} {yylval=create_node(_FLOAT);yylval->line=yylineno;yylval->value_f=strtof(yytext,NULL);return FLOAT;}
{id} {yylval=create_node(_ID);yylval->line=yylineno;strcpy(yylval->name,yytext);return ID;}
{illHexInt} {printf("Error type A at Line %d: Illegal hexadecimal number \"%s\"\n",yylineno,yytext);
			error_occured=true;yylval=create_node(None);return INT;}
{illOctInt} {printf("Error type A at Line %d: Illegal octal number \"%s\"\n",yylineno,yytext);
			error_occured=true;yylval=create_node(None);return INT;}
{illID} {printf("Error type A at Line %d: Illegal identifier name \"%s\"\n",yylineno,yytext);
		error_occured=true;yylval=create_node(None);return ID;}
. {printf("Error type A at Line %d: Mysterious character \"%s\"\n",yylineno,yytext);error_occured=true;}
%%
int get_value(const char* p)
{
	long value;
	if(p[0]!='0')
		value=strtol(p,NULL,10);
	else if(p[1]=='x'||p[1]=='X')
		value=strtol(p,NULL,16);
	else value=strtol(p,NULL,8);
	return (int)value;
}