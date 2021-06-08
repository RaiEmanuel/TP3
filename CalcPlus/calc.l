%{ 
/* analisador léxico para uma calculadora */
/* com suporte a definição de variáveis */
#include "parser.h"
#include <string>
char texto[100];
%}

%option yylineno
%option noyywrap

%x TEXT

digito	[0-9]
letra_	[a-zA-Z_]
pontdig {digito}*"."?{digito}+
digpont {digito}+"."

numero  {pontdig}|{digpont}
id		{letra_}({letra_}|{digito})*

%%
"print"             { return PRINT;}
"sqrt"              { return SQRT;}
"pow"               { return POW;}
"if"                { return IF;}
\"                  { BEGIN TEXT;}
<TEXT>[^\"]*        { strcpy(yylval.string, yytext);}
<TEXT>\"            { BEGIN INITIAL; return STRING;}
[\t ]+		        { ;/* ignora espaço em branco */ }
{numero}            { yylval.num = atof(yytext); return NUM; }
{id}		        { strcpy(yylval.id, yytext); return ID; }
.|\n		        { return yytext[0]; }

%%
