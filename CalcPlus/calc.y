%{
/* analisador sintático para uma calculadora */
/* com suporte a definição de variáveis */
#include <iostream>
#include <string>
#include <cmath>
#include <unordered_map>

using std::string;
using std::unordered_map;
using std::cout;

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
	| expr									{ }
	| IF '(' expr ')' PRINT '(' ID ')'  	{ if($3){
												cout << $7 << " = " << variables[$7] << "\n";
											  }
											}
	| PRINT '(' values ')'					{ }
	| PRINT '(' STRING ')'					{ cout << "STRING = "<< "\n"; }
	| PRINT '(' ID ')'						{ cout << $3 << " = " << variables[$3] << "\n"; }
	; 

values: expr ','' ' values  { cout << $1 << ", "; }
	  | expr				{ cout << $1 << '\n'; }

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
	| NUM
	;
%%
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
