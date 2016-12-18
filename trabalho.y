%{
#include <iostream>
#include <string>
#include <vector>
#include <stdio.h>
#include <stdlib.h>
#include <map>

using namespace std;

int yylex();
void yyerror( const char* st );
void erro( string msg );

// Faz o mapeamento dos tipos dos operadores
map< string, string > tipo_opr;

// Pilha de variáveis temporárias para cada bloco
vector< string > var_temp;

#define MAX_DIM 2

enum TIPO { FUNCAO = -1, BASICO = 0, VETOR = 1, MATRIZ = 2 };

struct Tipo {
  string tipo_base;
  TIPO ndim;
  int tam[MAX_DIM];
  vector<Tipo> retorno; // usando vector por dois motivos:
  // 1) Para não usar ponteiros
  // 2) Para ser genérico. Algumas linguagens permitem mais de um valor
  //    de retorno.
  vector<Tipo> params;

  Tipo() {} // Construtor Vazio

  Tipo( string tipo ) {
    tipo_base = tipo;
    ndim = BASICO;
  }

  Tipo( string base, int tam ) {
    tipo_base = base;
    ndim = VETOR;
    this->tam[0] = tam;
  }

  Tipo( string base, int tam_0, int tam_1 ) {
    tipo_base = base;
    ndim = MATRIZ;
    this->tam[0] = tam_0;
    this->tam[1] = tam_1;
  }

  Tipo( Tipo retorno, vector<Tipo> params ) {
    ndim = FUNCAO;
    this->retorno.push_back( retorno );
    this->params = params;
  }
};

struct Atributos {
  string v, c; // Valor, tipo e código gerado.
  Tipo t;
  vector<string> lista_str; // Uma lista auxiliar de strings.
  vector<Tipo> lista_tipo; // Uma lista auxiliar de tipos.
  vector<string> switch_labels; // Usado no switch-case.
  vector<string> switch_code; // Usado no switch-case.
  vector<int> tem_break; // Usado no switch-case.
  string default_label; // Usado no switch-case.
  string default_code; // Usado no switch-case.

  Atributos() {} // Constutor vazio
  Atributos( string valor ) {
    v = valor;
  }

  Atributos( string valor, Tipo tipo ) {
    v = valor;
    t = tipo;
  }
};

// Declarar todas as funções que serão usadas.
void insere_var_ts( string nome_var, Tipo tipo );
void insere_funcao_ts( string nome_func, Tipo retorno, vector<Tipo> params );
Tipo consulta_ts( string nome_var );
string declara_variavel( string nome, Tipo tipo );
string declara_funcao( string nome, Tipo retorno,
                       vector<string> nomes, vector<Tipo> tipos );

void empilha_ts();
void desempilha_ts();

string gera_nome_var_temp( string tipo );
string gera_label( string tipo );
string gera_teste_limite_array( string indice_1, Tipo tipoArray );
string gera_teste_limite_array( string indice_1, string indice_2,
                                Tipo tipoArray );

void debug( string producao, Atributos atr );
int toInt( string valor );
string toString( int n );

Atributos gera_codigo_operador( Atributos s1, string opr, Atributos s3 );
Atributos gera_codigo_if( Atributos expr, string cmd_then, string cmd_else );

string traduz_nome_tipo_pascal( string tipo_pascal );

string includes =
"#include <iostream>\n"
"#include <cstdio>\n"
"#include <cstdlib>\n"
"#include <cstring>\n"
"\n"
"using namespace std;\n";


#define YYSTYPE Atributos

%}

%token TK_ID TK_CINT TK_CDOUBLE TK_VAR TK_PROGRAM TK_BEGIN TK_END TK_ATRIB
%token TK_WRITELN TK_READ TK_CSTRING TK_FUNCTION
%token TK_MOD TK_IGU TK_MENORQ TK_MAIORQ TK_MAIG TK_MEIG TK_DIF TK_IF TK_THEN TK_ELSE TK_AND TK_OR TK_NOT TK_IN TK_ABREP TK_FECHAP TK_MAIS TK_MENOS TK_MULT TK_DIV TK_REST
%token TK_FOR TK_WHILE TK_SWITCH TK_CASE TK_DEFAULT TK_BREAK TK_TO TK_DO TK_ARRAY TK_OF TK_PTPT TK_IS

%nonassoc TK_MAIORQ TK_MENORQ TK_MAIG TK_MEIG TK_IGU TK_DIF
%left TK_AND TK_OR TK_NOT TK_IN
%left TK_MAIS TK_MENOS
%left TK_MULT TK_DIV TK_REST TK_MOD

%%

S : PROGRAM DECLS MAIN
    {
      cout << includes << endl;
      cout << $2.c << endl;
      cout << $3.c << endl;
    }
  ;
PROGRAM : TK_PROGRAM '.'
          { $$.c = "";
            empilha_ts(); }
        ;

DECLS : DECL DECLS
        { $$.c = $1.c + $2.c; }
      |
        { $$.c = ""; }
      ;

DECL : TK_VAR VARS
       { $$.c = $2.c; }
     | FUNCTION
     ;

FUNCTION : { empilha_ts(); }  CABECALHO ';' CORPO { desempilha_ts(); } ';'
           { $$.c = $2.c + " {\n" + $4.c +
                    "  return Result;\n}\n"; }
         ;

CABECALHO : TK_FUNCTION TK_ID OPC_PARAM ':' TK_ID
            {
              Tipo tipo( traduz_nome_tipo_pascal( $5.v ) );

              $$.c = declara_funcao( $2.v, tipo, $3.lista_str, $3.lista_tipo );
            }
          ;

OPC_PARAM : TK_ABREP PARAMS TK_FECHAP
            { $$ = $2; }
          |
            { $$ = Atributos(); }
          ;

PARAMS : PARAM ';' PARAMS
         { $$.c = $1.c + $3.c;
           // Concatenar as listas.
           $$.lista_tipo = $1.lista_tipo;
           $$.lista_tipo.insert( $$.lista_tipo.end(),
                                 $3.lista_tipo.begin(),
                                 $3.lista_tipo.end() );
           $$.lista_str = $1.lista_str;
           $$.lista_str.insert( $$.lista_str.end(),
                                $3.lista_str.begin(),
                                $3.lista_str.end() );
         }
       | PARAM
       ;

PARAM : IDS ':' TK_ID
      {
        Tipo tipo = Tipo( traduz_nome_tipo_pascal( $3.v ) );

        $$ = Atributos();
        $$.lista_str = $1.lista_str;

        for( int i = 0; i < $1.lista_str.size(); i ++ )
          $$.lista_tipo.push_back( tipo );
      }
    | IDS ':' TK_ARRAY '[' TK_CINT TK_PTPT TK_CINT ']' TK_OF TK_ID
      {
        Tipo tipo = Tipo( traduz_nome_tipo_pascal( $10.v ),
                          toInt( $5.v ), toInt( $7.v ) );

        $$ = Atributos();
        $$.lista_str = $1.lista_str;

        for( int i = 0; i < $1.lista_str.size(); i ++ )
          $$.lista_tipo.push_back( tipo );
      }
    | IDS ':' TK_ARRAY '[' TK_CINT TK_PTPT TK_CINT ']' '[' TK_CINT TK_PTPT TK_CINT ']' TK_OF TK_ID
      {
        // Refactor
        Tipo tipo = Tipo( traduz_nome_tipo_pascal( $15.v ),
                          toInt( $7.v ), toInt( $12.v ) );

        $$ = Atributos();
        $$.lista_str = $1.lista_str;

        for( int i = 0; i < $1.lista_str.size(); i ++ )
          $$.lista_tipo.push_back( tipo );
      }
    ;

CORPO : TK_VAR VARS BLOCO
        { $$.c = declara_variavel( "Result", consulta_ts( "Result" ) ) + ";\n" +
                 $2.c + $3.c; }
      | BLOCO
        { $$.c = declara_variavel( "Result", consulta_ts( "Result" ) ) + ";\n" +
                 $1.c; }
      ;

VARS : TK_CINT '.' VAR ';' VARS
       { $$.c = $3.c + $5.c; }
     |
       { $$ = Atributos(); }
     ;

VAR : IDS TK_IS TK_ID
      {
        Tipo tipo = Tipo( traduz_nome_tipo_pascal( $3.v ) );

        $$ = Atributos();

        for( int i = 0; i < $1.lista_str.size(); i ++ ) {
          $$.c += declara_variavel( $1.lista_str[i], tipo ) + ";\n";
          insere_var_ts( $1.lista_str[i], tipo );
        }
      }
    | IDS TK_IS TK_ARRAY TK_OF '[' TK_CINT ']' TK_ID
      {
        Tipo tipo = Tipo( traduz_nome_tipo_pascal( $8.v ),
                          toInt( $6.v ));
        $$ = Atributos();

        for( int i = 0; i < $1.lista_str.size(); i ++ ) {
          $$.c += declara_variavel( $1.lista_str[i], tipo ) + ";\n";
          insere_var_ts( $1.lista_str[i], tipo );
        }
      }
    | IDS TK_IS TK_ARRAY '[' TK_CINT ']' '[' TK_CINT ']' TK_OF TK_ID
      {
        // Refactor
        Tipo tipo = Tipo( traduz_nome_tipo_pascal( $11.v ),
                          toInt( $5.v ), toInt( $8.v ) );

        $$ = Atributos();

        for( int i = 0; i < $1.lista_str.size(); i ++ ) {
          $$.c += declara_variavel( $1.lista_str[i], tipo ) + ";\n";
          insere_var_ts( $1.lista_str[i], tipo );
        }
      }
    ;

IDS : IDS ',' TK_ID
      { $$  = $1;
        $$.lista_str.push_back( $3.v ); }
    | TK_ID
      { $$ = Atributos();
        $$.lista_str.push_back( $1.v ); }
    ;

MAIN : BLOCO '.'
       { $$.c = "int main() { \n" + $1.c + "  return 0;\n}\n"; }
     ;

BLOCO : TK_BEGIN { var_temp.push_back( "" );} CMDS TK_END
        { string vars = var_temp[var_temp.size()-1];
          var_temp.pop_back();
          if ( $$.v == "{" ) {
            var_temp[var_temp.size()-1] += vars;
            $$.c = $3.c;
          } else {
            $$.c = vars + $3.c;
          }
        }
      ;

CMDS : CMD ';' CMDS
       { $$.c = $1.c + $3.c; }
     | CMD_IF CMDS
       { $$.c = $1.c + $2.c; }
     | CMD_FOR CMDS
       { $$.c = $1.c + $2.c; }
     | CMD_WHILE CMDS
       { $$.c = $1.c + $2.c; }
     | { $$.c = ""; }
     ;

CMD : WRITELN
    | LEIA
    | ATRIB
    | CMD_IF
    | BLOCO
    | CMD_FOR
    | CMD_WHILE
    | CMD_DO_WHILE
    | CMD_SWITCH
    ;

CMD_SWITCH  : TK_SWITCH '(' TK_ID ')' SWITCH_BLOCO
            {
              $$.c = "";
              string fim_label = gera_label("fim_switch");

              // Gerando as variáveis para comparação.
              for (int i = $5.lista_str.size() - 1; i >= 0; i--) {
                  string var = gera_nome_var_temp( "b" );
                  $$.c += var + " = " + $3.v + " == " + $$.lista_str[i] + ";\n";
                  $$.c += "if (" + var + ") goto " + $$.switch_labels[i] + ";\n";
              }
              $$.c += "\n";

              // Se houver default.
              if ($5.default_label != "") {
                $$.c += "goto " + $5.default_label + ";\n\n";
              }

              // Para cada case.
              for (int i = $5.lista_str.size() - 1; i >= 0; i--) {
                $$.c += $5.switch_labels[i] + ":\n";
                $$.c += $5.switch_code[i] + "\n";
                if ($5.tem_break[i]) $$.c += "goto " + fim_label + ";\n";
              }

              // Se houver default.
              if ($5.default_label != "") {
                $$.c += $5.default_label + ":\n";
                $$.c += $5.default_code + "\n";
              }

              // Marcador final.
              $$.c += fim_label + ":\n";
            }

SWITCH_BLOCO  : TK_CASE F ':' CMDS SWITCH_BLOCO
              {
                $$ = $5;
                $$.lista_str.push_back($2.v);
                $$.switch_labels.push_back(gera_label("case_switch"));
                $$.switch_code.push_back($4.c);
                $$.tem_break.push_back(0);
                $$.default_label = $5.default_label;
                $$.default_code = $5.default_code;
              }
              | TK_CASE F ':' CMDS TK_BREAK ';' SWITCH_BLOCO
              {
                $$ = $7;
                $$.lista_str.push_back($2.v);
                $$.switch_labels.push_back(gera_label("case_switch"));
                $$.switch_code.push_back($4.c);
                $$.tem_break.push_back(1);
                $$.default_label = $7.default_label;
                $$.default_code = $7.default_code;
              }
              | TK_DEFAULT ':' CMDS
              {
                $$ = Atributos();
                $$.default_label = gera_label("default_switch");
                $$.default_code = $3.c;
              }
              |

LEIA :  TK_READ IDS
        {
          for( int i = 0; i < $2.lista_str.size(); i ++ ) {
            $$.c += "cin >> " + $2.lista_str[i] + ";\n";
          }
        }

CMD_WHILE : TK_WHILE E CMD
          {
            string label_inicio = gera_label( "inicio_while" );
            string label_fim = gera_label( "fim_while" );

            string condicao = gera_nome_var_temp ( "b" );
            //condicao.c = label_inicio + ":;\n" + $2.c + "  " +

            $$.c =  label_inicio + ":;\n" + $2.c + condicao + " = !" + $2.v + ";\n" +
                    "if ( " + condicao + " ) goto " + label_fim + ";\n" +
                    $3.c +
                    + "goto " + label_inicio + ";\n" +
                    label_fim + ":;\n";
          }
        ;

CMD_DO_WHILE : TK_DO CMD TK_WHILE E
          {
            string label_inicio = gera_label( "inicio_while" );

            $$.c =  label_inicio + ":\n" +
                    $2.c +
                    "if (" + $2.v + ") goto " + label_inicio + ";\n";
          }
        ;


CMD_FOR : TK_FOR NOME_VAR TK_ATRIB E TK_TO E TK_DO CMD
          {
            string var_fim = gera_nome_var_temp( $2.t.tipo_base );
            string label_teste = gera_label( "teste_for" );
            string label_fim = gera_label( "fim_for" );
            string condicao = gera_nome_var_temp( "b" );

            // Falta verificar os tipos... perde ponto se não o fizer.
            $$.c =  $4.c + $6.c +
                    "  " + $2.v + " = " + $4.v + ";\n" +
                    "  " + var_fim + " = " + $6.v + ";\n" +
                    label_teste + ":;\n" +
                    "  " +condicao+" = "+$2.v + " > " + var_fim + ";\n" +
                    "  " + "if( " + condicao + " ) goto " + label_fim +
                    ";\n" +
                    $8.c +
                    "  " + $2.v + " = " + $2.v + " + 1;\n" +
                    "  goto " + label_teste + ";\n" +
                    label_fim + ":;\n";
          }
        ;

CMD_IF : TK_IF E TK_THEN CMD ';' CMD_ELSE
         { $$ = gera_codigo_if( $2, $4.c, $6.c ); }
       | TK_IF E TK_THEN BLOCO CMD_ELSE
         { $$ = gera_codigo_if( $2, $4.c, $5.c ); }
       ;

CMD_ELSE : TK_ELSE CMD
           { $$.c = $2.c; }
         |
           { $$.c = ""; }
         ;

WRITELN : TK_WRITELN E
          { $$.c = $2.c +
                   "  cout << " + $2.v + ";\n"
                   "  cout << endl;\n";
          }
        ;

ATRIB : TK_ID TK_ATRIB E
        { // Falta verificar se pode atribuir (perde ponto se não fizer).
          $1.t = consulta_ts( $1.v ) ;

          if( $1.t.tipo_base == "s" )
            $$.c = $3.c + "  strncpy( " + $1.v + ", " + $3.v + ", 256 );\n";
          else
            $$.c = $3.c + "  " + $1.v + " = " + $3.v + ";\n";

          debug( "ATRIB : TK_ID TK_ATRIB E ';'", $$ );
        }
      | TK_ID '[' E ']' TK_ATRIB E
        { // Falta testar: tipo, limite do array, e se a variável existe
          //cerr << $3.v << endl;
          Tipo tipoArray = consulta_ts( $1.v );
          $$.t = Tipo( tipoArray.tipo_base );

          if( tipoArray.ndim != 1 )
            erro( "Variável " + $1.v + " não é array de uma dimensão" );

          if( $3.t.ndim != 0 || $3.t.tipo_base != "i" )
            erro( "Indice de array deve ser integer de zero dimensão: " +
                  $3.t.tipo_base + "/" + toString( $3.t.ndim ) );

          if( $6.t.ndim != 0 || $6.t.tipo_base != tipoArray.tipo_base ) {
            cerr << $6.v << endl;
            cerr << $6.t.tipo_base << ' ' << tipoArray.tipo_base << endl;
            erro( "Valor de tipo diferente sendo atribuido ao vetor " + $1.v );
          }

          $$.c = $3.c + $6.c;
          if ( tipoArray.tipo_base == "s" )
            $$.c += "  strncpy( " + $1.v + ", " + $3.v + ", 256 );\n";
          else
           $$.c += "  " + $1.v + "[" + $3.v + "] = " + $6.v + ";\n";
        }
      | TK_ID '[' E ']' '[' E ']' TK_ATRIB E
        {
        // Falta testar: tipo, limite do array, e se a variável existe
        // Não sei mais se falta. Codei, mas ignorei o comentário acima.
        Tipo tipoArray = consulta_ts( $1.v );
        $$.t = Tipo( tipoArray.tipo_base );

        if( tipoArray.ndim != 2 )
          erro( "Variável " + $1.v + " não é array de duas dimensões" );

        if( $3.t.ndim != 0 || $3.t.tipo_base != "i" )
          erro( "Indice de array deve ser integer de zero dimensão: " +
                $3.t.tipo_base + "/" + toString( $3.t.ndim ) );

        if( $6.t.ndim != 0 || $6.t.tipo_base != "i" )
          erro( "Indice de array deve ser integer de zero dimensão: " +
                $6.t.tipo_base + "/" + toString( $6.t.ndim ) );

        string var1 = gera_nome_var_temp( $$.t.tipo_base );
        string var2 = gera_nome_var_temp( $$.t.tipo_base );

        int m = tipoArray.tam[1];

        $$.c =  $3.c +
                $6.c +
                var1 + " = " + $3.v + " * " + to_string(m) + ";\n" +
                var2 + " = " + var1 + " + " + $6.v + ";\n" +
                $1.v + "[" + var2 + "] = " + $9.v + ";\n";

//        $$.c = $3.c +
  //             gera_teste_limite_array( $3.v, $6.v, tipoArray ) +
    //           "  " + $$.v + " = " + $1.v + "[" + to_string(idx) + "];\n";
        }
      ;

E : E TK_MAIS E
    { $$ = gera_codigo_operador( $1, "+", $3 ); }
  | E TK_MENOS E
    { $$ = gera_codigo_operador( $1, "-", $3 ); }
  | TK_MENOS E %prec  TK_MULT
    { $$ = gera_codigo_operador( Atributos( "0", Tipo ("i") ), "-", $2 ); }
  | E TK_MULT E
    { $$ = gera_codigo_operador( $1, "*", $3 ); }
  | E TK_MOD E
    { $$ = gera_codigo_operador( $1, "%", $3 ); }
  | E TK_DIV E
    { $$ = gera_codigo_operador( $1, "/", $3 ); }
  | E TK_MENORQ E
    { $$ = gera_codigo_operador( $1, "<", $3 ); }
  | E TK_MAIORQ E
    { $$ = gera_codigo_operador( $1, ">", $3 ); }
  | E TK_MEIG E
    { $$ = gera_codigo_operador( $1, "<=", $3 ); }
  | E TK_MAIG E
    { $$ = gera_codigo_operador( $1, ">=", $3 ); }
  | E TK_IGU E
    { $$ = gera_codigo_operador( $1, "==", $3 ); }
  | E TK_DIF E
    { $$ = gera_codigo_operador( $1, "!=", $3 ); }
  | E TK_AND E
    { $$ = gera_codigo_operador( $1, "&&", $3 ); }
  | E TK_OR E
    { $$ = gera_codigo_operador( $1, "||", $3 ); }
  | E TK_IN E
    { $$ = gera_codigo_operador( $1, "in", $3 ); }
  | TK_ABREP E TK_FECHAP
    { $$ = $2; }
  | F
  ;

F : TK_CINT
    { $$.v = $1.v; $$.t = Tipo( "i" ); $$.c = $1.c; }
  | TK_CDOUBLE
    { $$.v = $1.v; $$.t = Tipo( "d" ); $$.c = $1.c; }
  | TK_CSTRING
    { $$.v = $1.v; $$.t = Tipo( "s" ); $$.c = $1.c; }
  | TK_ID '[' E ']'
    {
      Tipo tipoArray = consulta_ts( $1.v );
      $$.t = Tipo( tipoArray.tipo_base );
      if( tipoArray.ndim != 1 )
        erro( "Variável " + $1.v + " não é array de uma dimensão" );

      if( $3.t.ndim != 0 || $3.t.tipo_base != "i" )
        erro( "Indice de array deve ser integer de zero dimensão: " +
              $3.t.tipo_base + "/" + toString( $3.t.ndim ) );

      $$.v = gera_nome_var_temp( $$.t.tipo_base );
      $$.c = $3.c +
             gera_teste_limite_array( $3.v, tipoArray ) +
             "  " + $$.v + " = " + $1.v + "[" + $3.v + "];\n";
    }
  | TK_ID '[' E ']' '[' E ']'
    {
      // Implementar: vai criar uma temporaria int para o índice e
      // outra do tipoBase do array para o valor recuperado.
      Tipo tipoArray = consulta_ts( $1.v );
      $$.t = Tipo( tipoArray.tipo_base );
      if( tipoArray.ndim != 2 )
        erro( "Variável " + $1.v + " não é array de duas dimensões" );

      if( $3.t.ndim != 0 || $3.t.tipo_base != "i" )
        erro( "Indice de array deve ser integer de zero dimensão: " +
              $3.t.tipo_base + "/" + toString( $3.t.ndim ) );

      if( $6.t.ndim != 0 || $6.t.tipo_base != "i" )
        erro( "Indice de array deve ser integer de zero dimensão: " +
              $6.t.tipo_base + "/" + toString( $6.t.ndim ) );

      $$.v = gera_nome_var_temp( $$.t.tipo_base );
      string var1 = gera_nome_var_temp( $$.t.tipo_base );
      string var2 = gera_nome_var_temp( $$.t.tipo_base );
      int m = tipoArray.tam[1];

      $$.c =  $3.c +
              $6.c +
              var1 + " = " + $3.v + " * " + to_string(m) + ";\n" +
              var2 + " = " + var1 + " + " + $6.v + ";\n" +
              $$.v + " = " + $1.v + "[" + var2 + "];\n";
    }
  | TK_ID
    { $$.v = $1.v; $$.t = consulta_ts( $1.v ); $$.c = $1.c; }
  | TK_ID '(' EXPRS ')'
    { $$.t = Tipo( "i" ); // consulta_ts( $1.v );
    // Falta verficar o tipo da função e os parametros.
      $$.v = gera_nome_var_temp( $$.t.tipo_base );
      $$.c = $3.c + "  " + $$.v + " = " + $1.v + "( ";

      for( int i = 0; i < $3.lista_str.size() - 1; i++ )
        $$.c += $3.lista_str[i] + ", ";

      $$.c += $3.lista_str[$3.lista_str.size()-1] + " );\n";
    }
  ;


EXPRS : EXPRS ',' E
        { $$ = Atributos();
          $$.c = $1.c + $3.c;
          $$.lista_str = $1.lista_str;
          $$.lista_str.push_back( $3.v ); }
      | E
        { $$ = Atributos();
          $$.c = $1.c;
          $$.lista_str.push_back( $1.v ); }
      ;

NOME_VAR : TK_ID
           { $$.v = $1.v; $$.t = consulta_ts( $1.v ); $$.c = $1.c; }
         ;

%%
int nlinha = 1;

#include "lex.yy.c"

int yyparse();

void debug( string producao, Atributos atr ) {
/*
  cerr << "Debug: " << producao << endl;
  cerr << "  t: " << atr.t << endl;
  cerr << "  v: " << atr.v << endl;
  cerr << "  c: " << atr.c << endl;
*/
}

void yyerror( const char* st )
{
  printf( "%s", st );
  printf( "Linha: %d, \"%s\"\n", nlinha, yytext );
}

void erro( string msg ) {
  cerr << "Erro: " << msg << endl;
  fprintf( stderr, "Linha: %d, [%s]\n", nlinha, yytext );
  exit(1);
}

void inicializa_operadores() {
  // Resultados para o operador "+"
  tipo_opr["i+i"] = "i";
  tipo_opr["i+d"] = "d";
  tipo_opr["d+i"] = "d";
  tipo_opr["d+d"] = "d";
  tipo_opr["s+s"] = "s";
  tipo_opr["c+s"] = "s";
  tipo_opr["s+c"] = "s";
  tipo_opr["c+c"] = "s";

  // Resultados para o operador "-"
  tipo_opr["i-i"] = "i";
  tipo_opr["i-d"] = "d";
  tipo_opr["d-i"] = "d";
  tipo_opr["d-d"] = "d";

  // Resultados para o operador "*"
  tipo_opr["i*i"] = "i";
  tipo_opr["i*d"] = "d";
  tipo_opr["d*i"] = "d";
  tipo_opr["d*d"] = "d";

  // Resultados para o operador "/"
  tipo_opr["i/i"] = "d";
  tipo_opr["i/d"] = "d";
  tipo_opr["d/i"] = "d";
  tipo_opr["d/d"] = "d";

  // Resultados para o operador "%"
  tipo_opr["i%i"] = "i";

  // Resultados para o operador "<"
  tipo_opr["i<i"] = "b";
  tipo_opr["i<d"] = "b";
  tipo_opr["d<i"] = "b";
  tipo_opr["d<d"] = "b";
  tipo_opr["c<c"] = "b";
  tipo_opr["i<c"] = "b";
  tipo_opr["c<i"] = "b";
  tipo_opr["c<s"] = "b";
  tipo_opr["s<c"] = "b";
  tipo_opr["s<s"] = "b";

  // Resultados para o operador ">"
  tipo_opr["i>i"] = "b";
  tipo_opr["i>d"] = "b";
  tipo_opr["d>i"] = "b";
  tipo_opr["d>d"] = "b";
  tipo_opr["c>c"] = "b";
  tipo_opr["i>c"] = "b";
  tipo_opr["c>i"] = "b";
  tipo_opr["c>s"] = "b";
  tipo_opr["s>c"] = "b";
  tipo_opr["s>s"] = "b";

  // Resultados para o operador "<="
  tipo_opr["i<=i"] = "b";
  tipo_opr["i<=d"] = "b";
  tipo_opr["d<=i"] = "b";
  tipo_opr["d<=d"] = "b";
  tipo_opr["c<=c"] = "b";
  tipo_opr["i<=c"] = "b";
  tipo_opr["c<=i"] = "b";
  tipo_opr["c<=s"] = "b";
  tipo_opr["s<=c"] = "b";
  tipo_opr["s<=s"] = "b";

  // Resultados para o operador ">="
  tipo_opr["i>=i"] = "b";
  tipo_opr["i>=d"] = "b";
  tipo_opr["d>=i"] = "b";
  tipo_opr["d>=d"] = "b";
  tipo_opr["c>=c"] = "b";
  tipo_opr["i>=c"] = "b";
  tipo_opr["c>=i"] = "b";
  tipo_opr["c>=s"] = "b";
  tipo_opr["s>=c"] = "b";
  tipo_opr["s>=s"] = "b";

  // Resultados para o operador "And"
  tipo_opr["b&&b"] = "b";

  // Resultados para o operador "=="
  tipo_opr["i==i"] = "b";
  tipo_opr["i==d"] = "b";
  tipo_opr["d==i"] = "b";
  tipo_opr["d==d"] = "b";
  tipo_opr["c==c"] = "b";
  tipo_opr["s==s"] = "b";

  // Resultados para o operador "!="
  tipo_opr["i!=i"] = "b";
  tipo_opr["i!=d"] = "b";
  tipo_opr["d!=i"] = "b";
  tipo_opr["d!=d"] = "b";
  tipo_opr["c!=c"] = "b";
  tipo_opr["s!=s"] = "b";
}

// Uma tabela de símbolos para cada escopo
vector< map< string, Tipo > > ts;

void empilha_ts() {
  map< string, Tipo > novo;
  ts.push_back( novo );
}

void desempilha_ts() {
  ts.pop_back();
}

Tipo consulta_ts( string nome_var ) {
  for( int i = ts.size()-1; i >= 0; i-- )
    if( ts[i].find( nome_var ) != ts[i].end() )
      return ts[i][ nome_var ];

  erro( "Variável não declarada: " + nome_var );

  return Tipo();
}

void insere_var_ts( string nome_var, Tipo tipo ) {
  if( ts[ts.size()-1].find( nome_var ) != ts[ts.size()-1].end() )
    erro( "Variável já declarada: " + nome_var +
          " (" + ts[ts.size()-1][ nome_var ].tipo_base + ")" );

  ts[ts.size()-1][ nome_var ] = tipo;
}

void insere_funcao_ts( string nome_func,
                       Tipo retorno, vector<Tipo> params ) {
  if( ts[ts.size()-2].find( nome_func ) != ts[ts.size()-2].end() )
    erro( "Função já declarada: " + nome_func );

  ts[ts.size()-2][ nome_func ] = Tipo( retorno, params );
}

string toString( int n ) {
  char buff[100];

  sprintf( buff, "%d", n );

  return buff;
}

int toInt( string valor ) {
  int aux = -1;

  if( sscanf( valor.c_str(), "%d", &aux ) != 1 )
    erro( "Numero inválido: " + valor );

  return aux;
}
string gera_nome_var_temp( string tipo ) {
  static int n = 0;
  string nome = "t" + tipo + "_" + toString( ++n );

  var_temp[var_temp.size()-1] += declara_variavel( nome, Tipo( tipo ) ) + ";\n";

  return nome;
}

string gera_label( string tipo ) {
  static int n = 0;
  string nome = "l_" + tipo + "_" + toString( ++n );

  return nome;
}

Tipo tipo_resultado( Tipo t1, string opr, Tipo t3 ) {
  if( t1.ndim == 0 && t3.ndim == 0 ) {
    string aux = tipo_opr[ t1.tipo_base + opr + t3.tipo_base ];

    if( aux == "" )
      erro( "O operador " + opr + " não está definido para os tipos '" +
            t1.tipo_base + "' e '" + t3.tipo_base + "'.");

    return Tipo( aux );
  }
  else { // Testes para os operadores de comparacao de array
    if ( t1.ndim == 0 && t3.ndim == 1 ) {

      if ( opr == "in" ) {
        if ( t1.tipo_base == t3.tipo_base )
          return Tipo( "b" );
        else
          erro( "O operador in não está definido para o tipo '" + t1.tipo_base
                + "' e array de '" + t3.tipo_base + "'." );
      }
    } else if ( t1.ndim == 1 && t3.ndim == 1 ) {
      if ( opr == "==" ) {
        return Tipo( "b" );
      }
      else if ( opr == "!=" ) {
        return Tipo( "b" );
      }

    }
    return Tipo();
  }
}

Atributos gera_codigo_operador( Atributos s1, string opr, Atributos s3 ) {

  Atributos ss;

  ss.t = tipo_resultado( s1.t, opr, s3.t );
  ss.v = gera_nome_var_temp( ss.t.tipo_base );

  if ( s1.t.ndim == 1 && s3.t.ndim == 1) {
    if ( opr == "==" || opr == "!" ) {
      if ( ( s1.t.tipo_base == s3.t.tipo_base ) && ( s1.t.tam[0] == s3.t.tam[0] ) ){

          string label_inicio = gera_label( "inicio_for" );
          string label_fim = gera_label( "fim_for" );
          string label_atrib_ss = gera_label( "atrib_ss" );
          string label_meio_for = gera_label( "meio_for" );
          string condicao_for = gera_nome_var_temp( "b" );
          string condicao_if = gera_nome_var_temp( "b" );

          string ind_for = gera_nome_var_temp( "i" );
          string temp_1 = gera_nome_var_temp( s1.t.tipo_base );
          string temp_2 = gera_nome_var_temp( s3.t.tipo_base );

          string init = opr == "==" ? "1" : "0";
          string compare = opr == "==" ? "!=" : "==";
          string atrib = opr == "==" ? "0" : "1";

          ss.c =  s1.c + s3.c +
                  "  " + ss.v + " = " + init + ";\n" +
                  "  " + ind_for + " = 0;\n" +
                  label_inicio + ":;\n" +
                  "  " + condicao_for + " = " + ind_for + " >= " + toString( s3.t.tam[0] ) + ";\n" +
                  "  " + "if( " + condicao_for + " ) goto " + label_fim + ";\n" +
                  "  " + temp_1 + " = " + s1.v + "[" + ind_for + "];\n" +
                  "  " + temp_2 + " = " + s3.v + "[" + ind_for + "];\n" +
                  "  " + condicao_if + " = " + temp_1 + " " + compare + " " + temp_2 + ";\n" +
                  "  " + "if( " + condicao_if + " ) goto " + label_atrib_ss + ";\n" +
                  label_meio_for + ":;\n" +
                  "  " + ind_for + " = " + ind_for + " + 1;\n" +
                  "  goto " + label_inicio + ";\n" +
                  label_atrib_ss + ":;\n" +
                  "    " + ss.v + " = " + atrib + ";\n" +
                  "  goto " + label_meio_for + ";\n" +
                  label_fim + ":;\n";
                  return ss;

      } else {
        ss.c = s1.c + s3.c + "  " + ss.v + " = " + (opr == "==" ? "0" : "1") + ";\n";
        return ss;
      }
    }
  }

/*
  ss.v = 1;
  i = 0;
label_inicio_for_1:
  cond_for = i >= tam;
  if (cond_for) goto label_fim_for_2;
  tmp1 = v1[i];
  tmp2 = v2[i];
  cond_if = tmp1 != tmp2;
  if (cond_if) goto label_atrib_3;
label_meio_for_4:
  i = i + 1;
  goto label_inicio_for_1;
label_atrib_3:
  ss.v = 0;
  goto label_meio_for_4;
label_fim_for_2:
*/


  // verificar tipos !!!
  // tratar strings separadamente !!!
  if ( opr == "in" ) {
    string label_inicio = gera_label( "inicio_for" );
    string label_fim = gera_label( "fim_for" );
    string label_atrib_ss = gera_label( "atrib_ss" );
    string label_meio_for = gera_label( "meio_for" );
    string condicao_for = gera_nome_var_temp( "b" );
    string condicao_if = gera_nome_var_temp( "b" );

    string ind_for = gera_nome_var_temp( "i" );
    string var_temp_aux = gera_nome_var_temp( s1.t.tipo_base );

    ss.c =  s1.c + s3.c +
            "  " + ss.v + " = 0;\n" +
            "  " + ind_for + " = 0;\n" +
            label_inicio + ":;\n" +
            "  " + condicao_for + " = " + ind_for + " >= " + toString( s3.t.tam[0] ) + ";\n" +
            "  " + "if( " + condicao_for + " ) goto " + label_fim + ";\n" +
            "  " + var_temp_aux + " = " + s3.v + "[" + ind_for + "];\n" +
            "  " + condicao_if + " = " + var_temp_aux + " == " + s1.v + ";\n" +
            "  " + "if( " + condicao_if + " ) goto " + label_atrib_ss + ";\n" +
            label_meio_for + ":;\n" +
            "  " + ind_for + " = " + ind_for + " + 1;\n" +
            "  goto " + label_inicio + ";\n" +
            label_atrib_ss + ":;\n" +
            "    " + ss.v + " = 1;\n" +
            "  goto " + label_meio_for + ";\n" +
            label_fim + ":;\n";
            return ss;
  }
/*
  ss.v = 0;
  i = 0;
label_inicio_for_1:
  cond_for = i >= tam;
  if (cond_for) goto label_fim_for_2;
  tmp = v[i];
  cond_if = tmp == s1.v;
  if (cond_if) goto label_atrib_3;
label_meio_for_4:
  i = i + 1;
  goto label_inicio_for_1;
label_atrib_3:
  ss.v = 1;
  goto label_meio_for_4;
label_fim_for_2:
*/

  if( s1.t.tipo_base == "s" && s3.t.tipo_base == "s" ) {
    // falta testar se é o operador "+"
    if ( opr == "+" ) {
      ss.c = s1.c + s3.c + // Codigo das expressões dos filhos da arvore.
             "  strncpy( " + ss.v + ", " + s1.v + ", 256 );\n" +
             "  strncat( " + ss.v + ", " + s3.v + ", 256 );\n";
    }
    if (opr == "<" || opr == ">" || opr == "<=" || opr == ">=" || opr == "==" || opr == "!=" ) {
      Atributos temp;
      temp.t = Tipo( "i" );
      temp.v = gera_nome_var_temp( temp.t.tipo_base );
      temp.c = s1.c + s3.c +
             "  " + temp.v + " = " + "strcmp( " + s1.v + ", " + s3.v + " );\n";
      ss.c = temp.c +
             "  " + ss.v + " = " + temp.v + " " + opr + " 0;\n";
    }
  } else if( s1.t.tipo_base == "s" && s3.t.tipo_base == "c" )
    ;
  else if( s1.t.tipo_base == "c" && s3.t.tipo_base == "s" )
    ;
  else {
    ss.c = s1.c + s3.c + // Codigo das expressões dos filhos da arvore.
           "  " + ss.v + " = " + s1.v + " " + opr + " " + s3.v + ";\n";
  }

  debug( "E: E " + opr + " E", ss );
  return ss;
}

Atributos gera_codigo_if( Atributos expr, string cmd_then, string cmd_else ) {
  Atributos ss;
  string label_else = gera_label( "else" );
  string label_end = gera_label( "end" );

  ss.c = expr.c +
         "  " + expr.v + " = !" + expr.v + ";\n\n" +
         "  if( " + expr.v + " ) goto " + label_else + ";\n" +
         cmd_then +
         "  goto " + label_end + ";\n" +
         label_else + ":;\n" +
         cmd_else +
         label_end + ":;\n";

  return ss;
}


string traduz_nome_tipo_pascal( string tipo_pascal ) {
  // No caso do Pascal, a comparacao deveria ser case-insensitive

  if( tipo_pascal == "Integer" )
    return "i";
  else if( tipo_pascal == "Boolean" )
    return "b";
  else if( tipo_pascal == "Real" )
    return "d";
  else if( tipo_pascal == "Char" )
    return "c";
  else if( tipo_pascal == "String" )
    return "s";
  else
    erro( "Tipo inválido: " + tipo_pascal );
}

map<string, string> inicializaMapEmC() {
  map<string, string> aux;
  aux["i"] = "int ";
  aux["b"] = "int ";
  aux["d"] = "double ";
  aux["c"] = "char ";
  aux["s"] = "char ";
  return aux;
}

string declara_funcao( string nome, Tipo tipo,
                       vector<string> nomes, vector<Tipo> tipos ) {
  static map<string, string> em_C = inicializaMapEmC();

  if( em_C[ tipo.tipo_base ] == "" )
    erro( "Tipo inválido: " + tipo.tipo_base );

  insere_var_ts( "Result", tipo );

  if( nomes.size() != tipos.size() )
    erro( "Bug no compilador! Nomes e tipos de parametros diferentes." );

  string aux = "";

  for( int i = 0; i < nomes.size(); i++ ) {
    aux += declara_variavel( nomes[i], tipos[i] ) +
           (i == nomes.size()-1 ? " " : ", ");
    insere_var_ts( nomes[i], tipos[i] );
  }

  return em_C[ tipo.tipo_base ] + " " + nome + "(" + aux + ")";
}

string declara_variavel( string nome, Tipo tipo ) {
  static map<string, string> em_C = inicializaMapEmC();

  if( em_C[ tipo.tipo_base ] == "" )
    erro( "Tipo inválido: " + tipo.tipo_base );

  string indice;

  switch( tipo.ndim ) {
    case 0: indice = (tipo.tipo_base == "s" ? "[256]" : "");
            break;

    case 1: indice = "[" + toString(
                  tipo.tam[0] * (tipo.tipo_base == "s" ? 256 : 1)
                  ) + "]";
            break;

    case 2: indice = "[" +  toString(
                              tipo.tam[0] * tipo.tam[1]
                            ) + "]";
            break;

    default:
       erro( "Bug muito sério..." );
  }

  return em_C[ tipo.tipo_base ] + nome + indice;
}

string gera_teste_limite_array( string indice_1, Tipo tipoArray ) {
  string var_teste_inicio = gera_nome_var_temp( "b" );
  string var_teste_fim = gera_nome_var_temp( "b" );
  string var_teste = gera_nome_var_temp( "b" );
  string label_end = gera_label( "limite_array_ok" );

  string codigo = "  " + var_teste_inicio + " = " + indice_1 + " >= 0;\n" +
                  "  " + var_teste_fim + " = " + indice_1 + " <= " +
                  toString( tipoArray.tam[0]-1 ) + ";\n" +
                  "  " + var_teste + " = " + var_teste_inicio + " && " +
                                             var_teste_fim + ";\n";

  codigo += "  if( " + var_teste + " ) goto " + label_end + ";\n" +
            "  printf( \"Limite de array ultrapassado: %d <= %d <= %d\", " +
               "0 ," + indice_1 + ", " +
               toString( tipoArray.tam[0]-1 ) + " );\n" +
               "  cout << endl;\n" +
               "  exit( 1 );\n" +
            "  " + label_end + ":;\n";

  return codigo;
}

string gera_teste_limite_array( string indice_1, string indice_2, Tipo tipoArray ) {
  // Implementar! Perde ponto se não fizer
  return "";
  string var_teste_inicio = gera_nome_var_temp( "b" );
  string var_teste_fim = gera_nome_var_temp( "b" );
  string var_teste = gera_nome_var_temp( "b" );
  string label_end = gera_label( "limite_array_ok" );

  string codigo = "  " + var_teste_inicio + " = " + indice_1 + " >= 0;\n" +
                  "  " + var_teste_fim + " = " + indice_1 + " <= " +
                  toString( tipoArray.tam[0]-1 ) + ";\n" +
                  "  " + var_teste + " = " + var_teste_inicio + " && " +
                                             var_teste_fim + ";\n";

  codigo += "  if( " + var_teste + " ) goto " + label_end + ";\n" +
            "  printf( \"Limite de array ultrapassado: %d <= %d <= %d\", " +
               "0 ," + indice_1 + ", " +
               toString( tipoArray.tam[0]-1 ) + " );\n" +
               "  cout << endl;\n" +
               "  exit( 1 );\n" +
            "  " + label_end + ":;\n";

  return codigo;
}

int main( int argc, char* argv[] )
{
  inicializa_operadores();
  yyparse();
}
