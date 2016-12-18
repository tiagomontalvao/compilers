%{

char* troca_aspas( char* lexema );

%}

DELIM   [\t ]
LINHA   [\n]
NUMERO  [0-9]
LETRA   [A-Za-z_çÇãÃ]
INT     {NUMERO}+
DOUBLE  {NUMERO}+("."{NUMERO}+)?
ID      {LETRA}({LETRA}|{NUMERO})*
CSTRING "'"([^\n']|"''")*"'"

COMMENT "(*"([^*]|"*"[^)])*"*)"

%%

{LINHA}    { nlinha++; }
{DELIM}    {}
{COMMENT}  {}

"Depoimentos"	{ yylval = Atributos( yytext ); return TK_VAR; }
"é"        		{ yylval = Atributos( yytext ); return TK_IS; }
"Que Deus tenha misericórdia desta nação" { yylval = Atributos( yytext ); return TK_PROGRAM; }
"Príncipe"   	{ yylval = Atributos( yytext ); return TK_BEGIN; }
"{"   			{ yylval = Atributos( yytext ); return TK_BEGIN; }
"Suíço"      	{ yylval = Atributos( yytext ); return TK_END; }
"}"   			{ yylval = Atributos( yytext ); return TK_END; }
"Como printa, deputado?"  { yylval = Atributos( yytext ); return TK_WRITELN; }
"Mas o que é isso aqui?"  { yylval = Atributos( yytext ); return TK_WATCH; }
"Leia" 			{ yylval = Atributos( yytext ); return TK_READ; }
"If"       		{ yylval = Atributos( yytext ); return TK_IF; }
"Then"     		{ yylval = Atributos( yytext ); return TK_THEN; }
"Else"     		{ yylval = Atributos( yytext ); return TK_ELSE; }
"For"      		{ yylval = Atributos( yytext ); return TK_FOR; }
"While"      	{ yylval = Atributos( yytext ); return TK_WHILE; }
"Switch"		{ yylval = Atributos( yytext ); return TK_SWITCH; }
"Caso"			{ yylval = Atributos( yytext ); return TK_CASE; }
"Default"		{ yylval = Atributos( yytext ); return TK_DEFAULT; }
"Bessias"		{ yylval = Atributos( yytext ); return TK_BREAK; }
"To"       		{ yylval = Atributos( yytext ); return TK_TO; }
"Do"       		{ yylval = Atributos( yytext ); return TK_DO; }
"Coligação"    	{ yylval = Atributos( yytext ); return TK_ARRAY; }
"de"       		{ yylval = Atributos( yytext ); return TK_OF; }
"Function" 		{ yylval = Atributos( yytext ); return TK_FUNCTION; }


".."       		{ yylval = Atributos( yytext ); return TK_PTPT; }
":="       		{ yylval = Atributos( yytext ); return TK_ATRIB; }
"="       		{ yylval = Atributos( yytext ); return TK_ATRIB; }
"recebe"   		{ yylval = Atributos( yytext ); return TK_ATRIB; }

"<"       		{ yylval = Atributos( yytext ); return TK_MENORQ; }
">"       		{ yylval = Atributos( yytext ); return TK_MAIORQ; }
"<="       		{ yylval = Atributos( yytext ); return TK_MEIG; }
">="       		{ yylval = Atributos( yytext ); return TK_MAIG; }
"=="       		{ yylval = Atributos( yytext ); return TK_IGU; }
"!="       		{ yylval = Atributos( yytext ); return TK_DIF; }

"And"      		{ yylval = Atributos( yytext ); return TK_AND; }
"Or"      		{ yylval = Atributos( yytext ); return TK_OR; }
"Not"      		{ yylval = Atributos( yytext ); return TK_NOT; }

"foi citado em" { yylval = Atributos( yytext ); return TK_IN; }

"(" 			{ yylval = Atributos( yytext ); return TK_ABREP; }
")" 			{ yylval = Atributos( yytext ); return TK_FECHAP; }

"+" 			{ yylval = Atributos( yytext ); return TK_MAIS; }
"-" 			{ yylval = Atributos( yytext ); return TK_MENOS; }

"*" 			{ yylval = Atributos( yytext ); return TK_MULT; }
"/" 			{ yylval = Atributos( yytext ); return TK_DIV; }
"mod"			{ yylval = Atributos( yytext ); return TK_MOD; }
"%" 			{ yylval = Atributos( yytext ); return TK_REST; }


{CSTRING}  		{ yylval = Atributos( troca_aspas( yytext ), Tipo( "string" ) );
             			return TK_CSTRING; }
{ID}       		{ yylval = Atributos( yytext ); return TK_ID; }
{INT}      		{ yylval = Atributos( yytext, Tipo( "int" ) ); return TK_CINT; }
{DOUBLE}   		{ yylval = Atributos( yytext, Tipo( "double" ) ); return TK_CDOUBLE; }

.          		{ yylval = Atributos( yytext ); return *yytext; }

%%

char* troca_aspas( char* lexema ) {
  int n = strlen( lexema );
  lexema[0] = '"';
  lexema[n-1] = '"';

  return lexema;
}
