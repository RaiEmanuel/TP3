%{
/* analisador sintático para uma calculadora */
/* com suporte a definição de variáveis */
#include <iostream>
#include <cstring>
#include <sstream>
#include <cmath>
#include <unordered_map>

using std::string;
using std::unordered_map;
using std::cout;
using std::endl;
using std::stringstream;
using std::strcpy;

/* protótipos das funções especiais */
int yylex(void);
int yyparse(void);
void yyerror(const char *);

/* tabela de símbolos */
unordered_map<string,double> variables;
%}

%union {
	double num;
	char id[21];
	char string[51];
}

%token <id>  ID
%token <num> NUM
%token <num> PRINT
%token <string>  STRING
%token SQRT
%token POW
%token IF

%type <num> expr
%type <string> element
%type <string> args

%right '='
%left  "==" "!="
%left  '<' "<=" '>' ">="
%left  '+' '-'
%left  '*' '/'
%nonassoc PRINT
%nonassoc SQRT
%nonassoc POW
%nonassoc IF
%nonassoc UMINUS

%%

math: math calc '\n'
	| calc '\n'
	;

calc: ID '=' expr 							{ variables[$1] = $3; } 
	| IF '(' expr ')' PRINT '(' args ')'  	{ if($3){
												cout << $7 << endl;
											  }
											}
	| IF '(' expr ')' ID '=' expr			{ if($3){
												variables[$5] = $7;
											  }
											}
	| PRINT '(' args ')'					{ cout << $3 << "\n"; }
	; 

args: element ',' args {
		stringstream ss;
		ss << $1 << $3;
		strcpy($$, ss.str().c_str());
    }
	| element { strcpy($$, $1); };

element: STRING { strcpy($$, $1); }
	| expr {
		stringstream ss;
		ss << $1;
		strcpy($$, ss.str().c_str());
	};

expr: expr '+' expr			{ $$ = $1 + $3; }
	| expr '-' expr   		{ $$ = $1 - $3; }
	| expr '*' expr			{ $$ = $1 * $3; }
	| expr '/' expr			
	{ 
		if ($3 == 0){
			yyerror("divisão por zero");
			return EXIT_SUCCESS;
		}else
			$$ = $1 / $3;
	}
	| '(' expr ')'				{ $$ = $2; }
	| '-' expr %prec UMINUS 	{ $$ = - $2; }
	| expr '<' expr				{ $$ = ($1 < $3); }
	| expr '<''=' expr			{ $$ = ($1 <= $4); }
	| expr '>' expr				{ $$ = ($1 > $3); }
	| expr '>''=' expr			{ $$ = ($1 >= $4); }
	| expr '=''=' expr			{ $$ = ($1 == $4);}
	| expr '!''=' expr			{ $$ = ($1 != $4);}
	| SQRT '(' expr ')'				{ $$ = sqrt($3); }
	| POW  '(' expr ',' expr ')'	{ $$ = pow($3, $5); }
	| ID							{ $$ = variables[$1]; }
	| ID '=' expr					{ variables[$1] = $3; $$ = variables[$1];}
	| NUM
	;
%%
/*
n1 = 9.0
n2 = 7.5
n3 = 6.5
parcial = (n1*4 + n2*5 + n3*6) / 15
if (parcial >= 7) print("aprovado")
total = 3
if (parcial < 5) total = total + 1
print(total)
r = sqrt(2)
print("raiz de 2 = ", r)
print(pow(r, 2))
*/
int main()
{
	yyparse();
}

void yyerror(const char * s)
{
	/* variáveis definidas no analisador léxico */
	extern int yylineno;    
	extern char * yytext;   

	/* mensagem de erro exibe o símbolo que causou erro e o número da linha */
    cout << "Erro (" << s << "): símbolo [" << yytext << "] (linha " << yylineno << ")\n";
}
