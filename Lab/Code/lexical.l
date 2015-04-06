%{
#include "syntax.tab.h"
#include "tree.h"
#define YY_USER_ACTION \
	yylloc.first_line = yylloc.last_line = yylineno; \
	yylloc.first_column = yycolumn; \
	yylloc.last_column = yycolumn + yyleng - 1; \
	yycolumn += yyleng;
int get_value(const char* p);
int yycolumn = 1;
%}
%option yylineno
blanks [ \r\t]+
letter_ [_A-Za-z]
digit [0-9]
int [1-9]{digit}*|0[0-7]+|0[Xx][0-9A-Fa-f]+|0
float {digit}+\.{digit}+
id {letter_}({letter_}|{digit})*
%%
{blanks} {}
"\n" {yycolumn=1;}
";" {return SEMI;}
"," {return COMMA;}
"=" {return ASSIGNOP;}
">"|"<"|">="|"<="|"=="|"!=" {return RELOP;}
"+" {return PLUS;}
"-" {return MINUS;} 
"*" {return STAR;}
"/" {return DIV;}
"&&" {return AND;}
"||" {return OR;}
"." {return DOT;}
"!" {return NOT;}
"int"|"float" {return TYPE;}
"(" {return LP;}
")" {return RP;}
"[" {return LB;}
"]" {return RB;}
"{" {return LC;}
"}" {return RC;}
"struct" {return STRUCT;}
"return" {return RETURN;}
"if" {return IF;}
"else" {return ELSE;}
"while" {return WHILE;}
{int} {yylval=get_value(yytext);return INT;}
{float} {yylval=strtof(yytext,NULL);return FLOAT;}
{id} {return ID;}
. {printf("Error type A at Line %d: Mysterious characters \'%s\'\n",yylineno, yytext);}
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