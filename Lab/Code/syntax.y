%{
#include "lex.yy.c"
#ifndef YYSTYPE
#define YYSTYPE Node*
#endif
#define YYERROR_VERBOSE 1
Node* head=NULL;
void m_yyerror(char* msg,int lineno);
char message[100];
%}
%locations
/*1 Tokens*/
%token SEMI COMMA ASSIGNOP RELOP 
%token PLUS MINUS STAR DIV 
%token AND OR DOT NOT TYPE 
%token LP RP LB RB LC RC 
%token STRUCT RETURN IF ELSE WHILE
%token ID INT FLOAT
/*优先级，结合性*/
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE
%right ASSIGNOP
%left OR
%left AND
%left RELOP
%left PLUS MINUS
%left STAR DIV
%right NOT
%left DOT LP RP LB RB
%%
/*2 High-level Definitions*/
Program : ExtDefList {$$=create_node(Program);construct($$,1,$1);head=$$;}
	;
ExtDefList : ExtDef ExtDefList {$$=create_node(ExtDefList);construct($$,2,$1,$2);}
	| /* empty */ {$$=create_node(ExtDefList);construct($$,1,create_node(None));}
	;
ExtDef : Specifier ExtDecList SEMI {$$=create_node(ExtDef);construct($$,3,$1,$2,$3);}
	| Specifier SEMI {$$=create_node(ExtDef);construct($$,2,$1,$2);}
	| Specifier FunDec CompSt {$$=create_node(ExtDef);construct($$,3,$1,$2,$3);}
	| Specifier error SEMI {$$=create_node(ExtDef);construct($$,3,$1,create_node(None),$3);
							m_yyerror("something wrong with ExtDecList before \";\"",@2.last_line);}
	| error SEMI {$$=create_node(ExtDef);construct($$,2,create_node(None),$2);
					m_yyerror("something wrong with Specifier before \";\"",@1.last_line);}
	;
ExtDecList : VarDec {$$=create_node(ExtDecList);construct($$,1,$1);}
	| VarDec COMMA ExtDecList {$$=create_node(ExtDecList);construct($$,3,$1,$2,$3);}
	;
/*3 Specifiers*/
Specifier : TYPE {$$=create_node(Specifier);construct($$,1,$1);}
	| StructSpecifier {$$=create_node(Specifier);construct($$,1,$1);}
	;
StructSpecifier : STRUCT OptTag LC DefList RC {$$=create_node(StructSpecifier);construct($$,5,$1,$2,$3,$4,$5);}
	| STRUCT Tag {$$=create_node(StructSpecifier);construct($$,2,$1,$2);}
	;
OptTag : ID {$$=create_node(OptTag);construct($$,1,$1);}
	| /* empty */ {$$=create_node(OptTag);construct($$,1,create_node(None));}
	;
Tag : ID {$$=create_node(Tag);construct($$,1,$1);}
	;
/*4 Declarators*/
VarDec : ID {$$=create_node(VarDec);construct($$,1,$1);}
	| VarDec LB INT RB {$$=create_node(VarDec);construct($$,4,$1,$2,$3,$4);}
	| VarDec LB error RB {$$=create_node(VarDec);construct($$,4,$1,$2,create_node(None),$4);
							m_yyerror("missing a integer between []",@3.last_line);}
	;
FunDec : ID LP VarList RP {$$=create_node(FunDec);construct($$,4,$1,$2,$3,$4);}
	| ID LP RP {$$=create_node(FunDec);construct($$,3,$1,$2,$3);}
	| ID LP error RP {$$=create_node(FunDec);construct($$,4,$1,$2,create_node(None),$4);
						m_yyerror("something wrong with VarList between ()",@3.last_line);}
	| ID error RP {$$=create_node(FunDec);construct($$,3,$1,create_node(None),$3);
					m_yyerror("missing \"(\"",@2.last_line);}
	;
VarList : ParamDec COMMA VarList {$$=create_node(VarList);construct($$,3,$1,$2,$3);}
	| ParamDec {$$=create_node(VarList);construct($$,1,$1);}
	| error COMMA VarList {$$=create_node(VarList);construct($$,3,create_node(None),$2,$3);
							m_yyerror("something wrong with ParamDec",@1.last_line);}
	;
ParamDec : Specifier VarDec {$$=create_node(ParamDec);construct($$,2,$1,$2);}
	;
/*5 Statements*/
CompSt : LC DefList StmtList RC {$$=create_node(CompSt);construct($$,4,$1,$2,$3,$4);}
	| error RC {$$=create_node(CompSt);construct($$,2,create_node(None),$2);
				m_yyerror("Missing \"{\"",@1.first_line);}
	;
StmtList : Stmt StmtList {$$=create_node(StmtList);construct($$,2,$1,$2);}
	| /* empty */ {$$=create_node(StmtList);construct($$,1,create_node(None));}
	;
Stmt : Exp SEMI {$$=create_node(Stmt);construct($$,2,$1,$2);}
	| error SEMI {$$=create_node(Stmt);construct($$,2,create_node(None),$2);
					m_yyerror("something wrong with expression before \";\"",@1.last_line);}
	| CompSt {$$=create_node(Stmt);construct($$,1,$1);}
	| RETURN Exp SEMI {$$=create_node(Stmt);construct($$,3,$1,$2,$3);}
	| RETURN error SEMI {$$=create_node(Stmt);construct($$,3,$1,create_node(None),$3);
						m_yyerror("something wrong with expression before \";\"",@2.last_line);}
	| IF LP Exp RP Stmt %prec LOWER_THAN_ELSE {$$=create_node(Stmt);construct($$,5,$1,$2,$3,$4,$5);}
	| IF LP error RP Stmt %prec LOWER_THAN_ELSE{$$=create_node(Stmt);construct($$,5,$1,$2,create_node(None),$4,$5);
												m_yyerror("something wrong with expression between ()",@3.last_line);}
	| IF LP Exp RP Stmt ELSE Stmt {$$=create_node(Stmt);construct($$,7,$1,$2,$3,$4,$5,$6,$7);}
	| IF LP Exp RP error ELSE Stmt {$$=create_node(Stmt);construct($$,7,$1,$2,$3,$4,create_node(None),$6,$7);
									m_yyerror("Missing \";\"",@5.last_line);}
	| IF LP error RP Stmt ELSE Stmt {$$=create_node(Stmt);construct($$,7,$1,$2,create_node(None),$4,$5,$6,$7);
									m_yyerror("something wrong with expression between ()",@3.last_line);}
	| WHILE LP Exp RP Stmt {$$=create_node(Stmt);construct($$,5,$1,$2,$3,$4,$5);}
	| WHILE LP error RP Stmt {$$=create_node(Stmt);construct($$,5,$1,$2,create_node(None),$4,$5);
							m_yyerror("something wrong with expression between ()",@3.last_line);}
	| IF error RP Stmt %prec LOWER_THAN_ELSE {$$=create_node(Stmt);construct($$,4,$1,create_node(None),$3,$4);
												m_yyerror("missing \"(\"",@2.last_line);}
	| IF error RP Stmt ELSE Stmt {$$=create_node(Stmt);construct($$,6,$1,create_node(None),$3,$4,$5,$6);
									m_yyerror("missing \"(\"",@2.last_line);}
	| WHILE error RP Stmt {$$=create_node(Stmt);construct($$,4,$1,create_node(None),$3,$4);
							m_yyerror("missing \"(\"",@2.last_line);}
	;
/*6 Local Definitions*/
DefList : Def DefList {$$=create_node(DefList);construct($$,2,$1,$2);}
	| /* empty */ {$$=create_node(DefList);construct($$,1,create_node(None));}
	;
Def : Specifier DecList SEMI {$$=create_node(Def);construct($$,3,$1,$2,$3);}
	| Specifier error SEMI {$$=create_node(Def);construct($$,3,$1,create_node(None),$3);
							m_yyerror("unnecessary \",\"",@2.last_line);}
	;
DecList : Dec {$$=create_node(DecList);construct($$,1,$1);}
	| Dec COMMA DecList {$$=create_node(DecList);construct($$,3,$1,$2,$3);}
	| error COMMA DecList {$$=create_node(DecList);construct($$,3,create_node(None),$2,$3);
							m_yyerror("something wrong with declaration",@1.last_line);}
	;
Dec : VarDec {$$=create_node(Dec);construct($$,1,$1);}
	| VarDec ASSIGNOP Exp {$$=create_node(Dec);construct($$,3,$1,$2,$3);}
	| error ASSIGNOP Exp {$$=create_node(Dec);construct($$,3,create_node(None),$2,$3);
							m_yyerror("missing the variable",@1.last_line);}
	;
/*7 Expressions*/
Exp : Exp ASSIGNOP Exp {$$=create_node(Exp);construct($$,3,$1,$2,$3);}
	| Exp AND Exp {$$=create_node(Exp);construct($$,3,$1,$2,$3);}
	| Exp OR Exp {$$=create_node(Exp);construct($$,3,$1,$2,$3);}
	| Exp RELOP Exp {$$=create_node(Exp);construct($$,3,$1,$2,$3);}
	| Exp PLUS Exp {$$=create_node(Exp);construct($$,3,$1,$2,$3);}
	| Exp MINUS Exp {$$=create_node(Exp);construct($$,3,$1,$2,$3);}
	| Exp STAR Exp {$$=create_node(Exp);construct($$,3,$1,$2,$3);}
	| Exp DIV Exp {$$=create_node(Exp);construct($$,3,$1,$2,$3);}
	| LP Exp RP {$$=create_node(Exp);construct($$,3,$1,$2,$3);}
	| MINUS Exp %prec NOT {$$=create_node(Exp);construct($$,2,$1,$2);}
	| NOT Exp {$$=create_node(Exp);construct($$,2,$1,$2);}
	| ID LP Args RP {$$=create_node(Exp);construct($$,4,$1,$2,$3,$4);}
	| ID LP RP {$$=create_node(Exp);construct($$,3,$1,$2,$3);}
	| Exp LB Exp RB {$$=create_node(Exp);construct($$,4,$1,$2,$3,$4);}
	| Exp DOT ID {$$=create_node(Exp);construct($$,3,$1,$2,$3);}
	| ID {$$=create_node(Exp);construct($$,1,$1);}
	| INT {$$=create_node(Exp);construct($$,1,$1);}
	| FLOAT {$$=create_node(Exp);construct($$,1,$1);}
	| error RP {$$=create_node(Exp);construct($$,2,create_node(None),$2);
				m_yyerror("missing \"(\"",@1.last_line);}
	| Exp LB error RB {$$=create_node(Exp);construct($$,4,$1,$2,create_node(None),$4);
				m_yyerror("missing \"]\"",@3.last_line);}
	| ID error RP {$$=create_node(Exp);construct($$,3,$1,create_node(None),$3);
				m_yyerror("missing \"(\"",@2.last_line);}
	;
Args : Exp COMMA Args {$$=create_node(Args);construct($$,3,$1,$2,$3);}
	| Exp {$$=create_node(Args);construct($$,1,$1);}
	| error COMMA Args {$$=create_node(Args);construct($$,3,create_node(None),$2,$3);
						m_yyerror("something wrong with your expression",@1.last_line);}
	;
%%
int main(int argc,char** argv)
{
	if(argc!=2)
	{
		printf("请输入且仅输入一个文件。\n");
		return 1;
	}
	FILE* f=fopen(argv[1],"r");
	if (f==NULL)
	{
		printf("无法打开文件 %s\n",argv[1]);
		return 1;
	}
	yyrestart(f);
	if(yyparse()==0 && !error_occured)
		print_tree(head);
	destroy_tree(head);
	fclose(f);
	return 0;
}
yyerror(char* msg) {
strcpy(message,msg+14);
error_occured=true;
}
void m_yyerror(char* msg,int lineno) {
printf("Error type B at Line %d: %s, maybe %s.\n",lineno,message,msg);
error_occured=true;
}