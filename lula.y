%{
#include <string>
#include <iostream>
#include <vector>
#include <stdio.h>
#include <stdlib.h>
#include <map>

using namespace std;

int yylex();
void yyerror( const char* st );
void erro( string msg );

// Contador de linhas de variáveis declaradas.
int nvar = 0;

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
  bool funcao_string;

  Tipo() {} // Construtor Vazio

  Tipo( string tipo) {
    tipo_base = tipo;
    ndim = BASICO;
    funcao_string = false;
  }

  Tipo( string base, int tam ) {
    tipo_base = base;
    ndim = VETOR;
    this->tam[0] = tam;
    funcao_string = false;
  }

  Tipo( string base, int tam_0, int tam_1 ) {
    tipo_base = base;
    ndim = MATRIZ;
    this->tam[0] = tam_0;
    this->tam[1] = tam_1;
    funcao_string = false;
  }

  Tipo( Tipo retorno, vector<Tipo> params ) {
    ndim = FUNCAO;
    this->retorno.push_back( retorno );
    this->params = params;
    funcao_string = false;
  }

  Tipo( Tipo retorno, vector<Tipo> params, bool funcao_string ) {
    ndim = FUNCAO;
    this->retorno.push_back( retorno );
    this->params = params;
    this->funcao_string = funcao_string;
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

  string nome_funcao_string;  // Usado nas funções que retornam string
  Tipo tipo_funcao_string;  // Usado nas funções que retornam string

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
void insere_funcao_ts( string nome_func, Tipo retorno, vector<Tipo> params, bool funcao_string );
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

string traduz_nome_tipo_lula( string tipo_lula );

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
%token TK_COMOPRINTA TK_READ TK_CSTRING TK_FUNCTION TK_WATCH TK_NEWLINE
%token TK_MOD TK_IGU TK_MENORQ TK_MAIORQ TK_MAIG TK_MEIG TK_DIF TK_IF TK_THEN TK_ELSE
%token TK_AND TK_OR TK_NOT TK_IN TK_ABREP TK_FECHAP TK_MAIS TK_MENOS TK_MULT TK_DIV
%token TK_FOR TK_SWITCH TK_CASE TK_DEFAULT TK_BREAK TK_TO TK_DO TK_ARRAY TK_DE TK_IS
%token TK_DA TK_QUE TK_EU TK_TE TK_DOU TK_OUTRA TK_WHILE TK_RETURN TK_EXIT

%nonassoc TK_MAIORQ TK_MENORQ TK_MAIG TK_MEIG TK_IGU TK_DIF
%left TK_AND TK_OR TK_NOT TK_IN
%left TK_MAIS TK_MENOS
%left TK_MULT TK_DIV TK_MOD

%nonassoc LOWER_THAN_ELSE
%nonassoc TK_ELSE

%nonassoc LOWER_THAN_CMD
%nonassoc TK_EXIT
%nonassoc TK_COMOPRINTA
%nonassoc TK_READ
%nonassoc TK_ATRIB
%nonassoc TK_WATCH
%nonassoc TK_RETURN
%nonassoc TK_BEGIN
%nonassoc TK_IF
%nonassoc TK_FOR
%nonassoc TK_WHILE
%nonassoc TK_DO
%nonassoc TK_SWITCH

%%

S : PROGRAM DECLS MAIN
    {
      cout << includes << endl;
      cout << $2.c << endl;
      cout << $3.c << endl;
      cerr << "Lula v.1.0.1 TM" << endl;
      cerr << "Compilado com sucesso." << endl;
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

DECL :  TK_VAR VARS
        {
          $$.c = $2.c;

          int count = 1;

          for (int i = 0; i < $2.lista_str.size(); i++) {
            if (stoi($2.lista_str[i]) != count) {
              erro ("Delação inconsistente. Depoimentos fora de ordem. Comece com 1, depois 2, 3, 4...");
              $$.c += $2.lista_str[i] + " ";
            }
            count++;
          }
        }
     | FUNCTION
     ;

RETURN  : TK_RETURN E
          { $$.c = $2.c +
                   "  return " + $2.v + ";\n"; }
        ;

EXIT : TK_EXIT
       { $$.c = "  exit(0);\n"; }
     ;

FUNCTION :  { empilha_ts(); }  CABECALHO ';' CORPO { desempilha_ts(); } ';'
            {
              $$.c = $2.c + " {\n" + $4.c + "}\n";
            }
         ;

CABECALHO : TK_FUNCTION TK_DE TK_ID TK_ID OPC_PARAM
            {
              Tipo tipo( traduz_nome_tipo_lula( $3.v ) );

              bool funcao_string = false;

              if ( tipo.tipo_base == "s" ) {
                tipo = Tipo( "v" );
                funcao_string = true;
                $5.lista_str.push_back( "bambam_retorno_string" );
                $5.lista_tipo.push_back( Tipo( "s" ) );
              }

              $$.c = declara_funcao( $4.v, tipo, $5.lista_str, $5.lista_tipo );
              insere_funcao_ts( $4.v, tipo, $5.lista_tipo, funcao_string ) ;
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

PARAM : TK_ID IDS
      {
        Tipo tipo = Tipo( traduz_nome_tipo_lula( $1.v ) );

        $$ = Atributos();
        $$.lista_str = $2.lista_str;

        for( int i = 0; i < $2.lista_str.size(); i++ )
          $$.lista_tipo.push_back( tipo );
      }
    | IDS ':' TK_ARRAY TK_DE '[' TK_CINT ']' TK_ID
    // (a, b) : coligação de [10] inteiros
    // coligação de [10] inteiros (a, b)
      {
        Tipo tipo = Tipo( traduz_nome_tipo_lula( $8.v ),
                          toInt( $6.v ) );

        $$ = Atributos();
        $$.lista_str = $1.lista_str;

        for( int i = 0; i < $1.lista_str.size(); i ++ )
          $$.lista_tipo.push_back( tipo );
      }
    | IDS ':' TK_ARRAY TK_DE '[' TK_CINT ']' '[' TK_CINT ']' TK_ID
      {
        Tipo tipo = Tipo( traduz_nome_tipo_lula( $11.v ),
                          toInt( $6.v ), toInt( $9.v ) );

        $$ = Atributos();
        $$.lista_str = $1.lista_str;

        for( int i = 0; i < $1.lista_str.size(); i ++ )
          $$.lista_tipo.push_back( tipo );
      }
    ;

CORPO : TK_VAR VARS BLOCO
        { $$.c = $2.c + $3.c; }
      | BLOCO
        { $$.c = $1.c; }
      ;

VARS :  TK_CINT '.' VAR ';' VARS
        {
          $$.lista_str.push_back($1.v);

          for (int i = 0; i < $5.lista_str.size(); i++) {
            $$.lista_str.push_back($5.lista_str[i]);
          }

          $$.c = $3.c + $5.c;
        }
     |
       { $$ = Atributos(); }
     ;

VAR : IDS TK_IS TK_ID
      {
        Tipo tipo = Tipo( traduz_nome_tipo_lula( $3.v ) );

        $$ = Atributos();

        for( int i = 0; i < $1.lista_str.size(); i ++ ) {
          $$.c += declara_variavel( $1.lista_str[i], tipo ) + ";\n";
          insere_var_ts( $1.lista_str[i], tipo );
        }
      }
    | IDS TK_IS TK_ARRAY TK_DE '[' TK_CINT ']' TK_ID
      {
        Tipo tipo = Tipo( traduz_nome_tipo_lula( $8.v ),
                          toInt( $6.v ));
        $$ = Atributos();

        for( int i = 0; i < $1.lista_str.size(); i ++ ) {
          $$.c += declara_variavel( $1.lista_str[i], tipo ) + ";\n";
          insere_var_ts( $1.lista_str[i], tipo );
        }
      }
    | IDS TK_IS TK_ARRAY TK_DE '[' TK_CINT ']' '[' TK_CINT ']' TK_ID
      {
        Tipo tipo = Tipo( traduz_nome_tipo_lula( $11.v ),
                          toInt( $6.v ), toInt( $9.v ) );

        $$ = Atributos();

        for( int i = 0; i < $1.lista_str.size(); i ++ ) {
          $$.c += declara_variavel( $1.lista_str[i], tipo ) + ";\n";
          insere_var_ts( $1.lista_str[i], tipo );
        }
      }
    ;

IDS : IDS ',' TK_ID
      { $$ = $1;
        $$.lista_str.push_back( $3.v ); }
    | TK_ID
      { $$ = Atributos();
        $$.lista_str.push_back( $1.v ); }
    ;

IDS_LEIA  : TK_ID ',' IDS_LEIA
          {
            $$ = $3;
            $$.c += $1.c;
            $$.lista_str.push_back( $3.v );
            $$.lista_tipo.push_back( $3.t.tipo_base );
          }
          | TK_ID '[' E ']' ',' IDS_LEIA
          {
            $$ = $6;

            string var = gera_nome_var_temp( $3.t.tipo_base );

            $$.c += $3.c +
                   var + " = " + $3.v + ";\n";

            $$.lista_str.push_back( $1.v + "[" + var + "]" );
            $$.lista_tipo.push_back( $3.t.tipo_base );
          }
          | TK_ID '[' E ']'
          {
            $$ = Atributos();

            string var = gera_nome_var_temp( $3.t.tipo_base );

            $$.c = $3.c +
                   var + " = " + $3.v + ";\n";

            $$.lista_str.push_back( $1.v + "[" + var + "]" );
            $$.lista_tipo.push_back( $1.t.tipo_base );
           }
           | TK_ID
           {
              $$ = Atributos();
              $$.lista_str.push_back( $1.v );
              $$.lista_tipo.push_back( $1.t.tipo_base );
          }
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
/*
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
*/

CMDS : CMD_ONELINE ';' CMDS
       { $$.c = $1.c + $3.c; }
     | CMD_BLOCO CMDS
       { $$.c = $1.c + $2.c; }
     | %prec LOWER_THAN_CMD
       { $$.c = ""; }
     ;


CMD_ONELINE : COMOPRINTA
            | LEIA
            | ATRIB
            | CMD_WATCH
            | RETURN
            | EXIT
            | E
            ;

CMD_BLOCO : BLOCO
          | CMD_IF
          | CMD_FOR
          | CMD_WHILE
          | CMD_DO_WHILE
          | CMD_SWITCH
          ;

CMD_WATCH : TK_WATCH TK_ID
          {
            $$ = Atributos();
            $$.c = "cout << \"";
            $$.c += $2.v;
            $$.c += "\";\n";
            $$.c += "cout << \" vale \";\n";
            $$.c += "cout << " + $2.v + ";\n";
            $$.c += "cout << endl;\n";
          }

CMD_SWITCH : TK_SWITCH TK_ABREP TK_ID TK_FECHAP SWITCH_BLOCO
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

LEIA :  TK_READ IDS_LEIA
        {
          $$.c = $2.c;

          for( int i = (int) $2.lista_str.size() - 1; i >= 0 ; i-- ) {
            string nome_var;

            if ($2.lista_str[i].find('[') == string::npos) {
              nome_var = $2.lista_str[i];
            } else {
              nome_var = $2.lista_str[i].substr(0, $2.lista_str[i].find('['));
            }

            Tipo tipo = consulta_ts( nome_var );

            if ( tipo.ndim == VETOR ) {
              if ( tipo.tipo_base == "s") {
                // var é o nome da variável com []s.
                string var = $2.lista_str[i];
                string idx = "";

                for (int i = var.find('[') + 1; var[i] != ']'; i++) {
                  idx += var[i];
                }

                string arr_str_nome = var.substr(0, var.find('['));
                string str_tmp = gera_nome_var_temp("s");
                $$.c += "  cin >> " + str_tmp + ";\n";

                string lower = gera_nome_var_temp("i");
                $$.c += lower + " = " + idx + " * 256;\n";

                string i = gera_nome_var_temp("i");
                $$.c += i + " = " + lower + ";\n";

                string ii = gera_nome_var_temp("i");
                $$.c += ii + " = " + "0;\n";

                string inicio_leitura = gera_label("leitura_array_string_inicio");
                string fim_leitura = gera_label("leitura_array_string_fim");

                string dsadqwe = gera_nome_var_temp("i");

                $$.c += inicio_leitura + ":\n";
                $$.c += dsadqwe + " = " + ii + " >= 256;\n";
                $$.c += "if (" + dsadqwe + ") goto " + fim_leitura + ";\n";

                string qweqwe = gera_nome_var_temp("c");
                $$.c += qweqwe + " = " + str_tmp + "["+ ii +"];\n";

                $$.c += arr_str_nome + "[" + i + "] = " + qweqwe + ";\n";
                $$.c += i + " = " + i + " + 1;\n";
                $$.c += ii + " = " + ii + " + 1;\n";


                $$.c += "goto " + inicio_leitura + ";\n";
                $$.c += fim_leitura + ":\n";
              } else {
                // var é o nome da variável com []s.
               string var = $2.lista_str[i];
                string arr_nome = var.substr(0, var.find('['));
                string tmp = gera_nome_var_temp ( "i" );
                $$.c += "cin >> " + tmp + ";\n";
                int len = var.length();
                string idx = var.substr(var.find('[') + 1, len - var.find('[')  - 2);

                $$.c += arr_nome + "[";
                $$.c += idx;
                $$.c += "] = " + tmp + ";\n";
              }
            } else {
              $$.c += "  cin >> " + $2.lista_str[i] + ";\n";
            }
          }
        }

CMD_WHILE : TK_DA E TK_QUE TK_EU TK_TE TK_DOU TK_OUTRA CMD_ONELINE ';'
            {
              string label_inicio = gera_label( "inicio_while" );
              string label_fim = gera_label( "fim_while" );

              string condicao = gera_nome_var_temp ( "b" );
              //condicao.c = label_inicio + ":;\n" + $2.c + "  " +

              $$.c =  label_inicio + ":;\n" + $2.c + condicao + " = !" + $2.v + ";\n" +
                      "if ( " + condicao + " ) goto " + label_fim + ";\n" +
                      $8.c +
                      + "goto " + label_inicio + ";\n" +
                      label_fim + ":;\n";
              }
          | TK_DA E TK_QUE TK_EU TK_TE TK_DOU TK_OUTRA CMD_BLOCO
            {
              string label_inicio = gera_label( "inicio_while" );
              string label_fim = gera_label( "fim_while" );

              string condicao = gera_nome_var_temp ( "b" );
              //condicao.c = label_inicio + ":;\n" + $2.c + "  " +

              $$.c =  label_inicio + ":;\n" + $2.c + condicao + " = !" + $2.v + ";\n" +
                      "if ( " + condicao + " ) goto " + label_fim + ";\n" +
                      $8.c +
                      + "goto " + label_inicio + ";\n" +
                      label_fim + ":;\n";
            }
        ;

CMD_DO_WHILE : TK_DO CMD_BLOCO TK_WHILE E
               {
                 string label_inicio = gera_label( "inicio_while" );

                    $$.c =  label_inicio + ":\n" +
                            $2.c +
                            $4.c +
                            "if (" + $4.v + ") goto " + label_inicio + ";\n";
               }
             | TK_DO CMD_ONELINE ';' TK_WHILE E
               {
                 string label_inicio = gera_label( "inicio_while" );

                    $$.c =  label_inicio + ":\n" +
                            $2.c +
                            $5.c +
                            "if (" + $5.v + ") goto " + label_inicio + ";\n";
               }
             ;


CMD_FOR : TK_FOR NOME_VAR TK_ATRIB E TK_TO E TK_DO CMD_BLOCO
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
        | TK_FOR NOME_VAR TK_ATRIB E TK_TO E TK_DO CMD_ONELINE ';'
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

CMD_IF : TK_IF E TK_THEN CMD_BLOCO CMD_ELSE
         { $$ = gera_codigo_if( $2, $4.c, $5.c ); }
       | TK_IF E TK_THEN CMD_ONELINE ';' CMD_ELSE
         { $$ = gera_codigo_if( $2, $4.c, $6.c ); }
       ;

CMD_ELSE : TK_ELSE CMD_ONELINE ';'
           { $$.c = $2.c; }
         | TK_ELSE CMD_BLOCO
           { $$.c = $2.c; }
         | %prec LOWER_THAN_ELSE
           { $$ = Atributos(); }
         ;

COMOPRINTA : TK_COMOPRINTA E
          { $$.c = $2.c +
                   "  cout << " + $2.v + ";\n";
          }
        | TK_COMOPRINTA E TK_NEWLINE
          { $$.c = $2.c +
                   "  cout << " + $2.v + ";\n"
                   "  cout << endl;\n";
          }
        | TK_COMOPRINTA TK_NEWLINE
          { $$.c = "  cout << endl;\n"; }
        ;

ATRIB : TK_ID TK_ATRIB FUNCTION_CALL
        {
          Tipo tipo_s3 = consulta_ts( $3.v );

          if ( tipo_s3.funcao_string ) {
            $$.c = $3.c + "  strncpy( " + $1.v + ", " + $3.nome_funcao_string + ", 256 );\n";
          }
        }
        | TK_ID TK_ATRIB E
        { // Falta verificar se pode atribuir (perde ponto se não fizer).

          $1.t = consulta_ts( $1.v ) ;

          if(( $1.t.tipo_base == "i" and $3.t.tipo_base == "d" ) or ( $1.t.tipo_base == "d" and $3.t.tipo_base == "i" )) {
            // Pior tratamento de erro que já fiz na minha vida.
          } else if( $1.t.tipo_base != $3.t.tipo_base )
            erro( "Tipos incompatíveis na atribuição " + $1.t.tipo_base + ", " +  $3.t.tipo_base + " " );

          if( $1.t.tipo_base == "s" )
            $$.c = $3.c + "  strncpy( " + $1.v + ", " + $3.v + ", 256 );\n";
          else
            $$.c = $3.c + "  " + $1.v + " = " + $3.v + ";\n";

          debug( "ATRIB : TK_ID TK_ATRIB E ';'", $$ );


        }
      | TK_ID '[' E ']' TK_ATRIB E
        { // Falta testar: tipo, limite do array, e se a variável existe
          Tipo tipoArray = consulta_ts( $1.v );
          $$.t = Tipo( tipoArray.tipo_base );

          if( tipoArray.ndim != 1 )
            erro( "Variável " + $1.v + " não é array de uma dimensão" );

          if( $3.t.ndim != 0 || $3.t.tipo_base != "i" )
            erro( "Indice de array deve ser integer de zero dimensão: " +
                  $3.t.tipo_base + "/" + toString( $3.t.ndim ) );

          if( $6.t.ndim != 0 || $6.t.tipo_base != tipoArray.tipo_base )
            erro( "Valor de tipo diferente sendo atribuido ao vetor " + $1.v );

          $$.c = $3.c + $6.c;
          if ( tipoArray.tipo_base == "s" ) {
            $$.c += "  strncpy( " + $1.v + " + " + $3.v + " * 256, " + $6.v + ", 256 );\n";
          } else {
             $$.c += "  " + $1.v + "[" + $3.v + "] = " + $6.v + ";\n";
           }
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

        string var1 = gera_nome_var_temp( "i" );
        string var2 = gera_nome_var_temp( "i" );

        int m = tipoArray.tam[1];

        $$.c =  $3.c + $6.c + gera_teste_limite_array( $3.v, $6.v, tipoArray ) +
                var1 + " = " + $3.v + " * " + toString(m) + ";\n" +
                var2 + " = " + var1 + " + " + $6.v + ";\n" +
                $1.v + "[" + var2 + "] = " + $9.v + ";\n";

        }
      ;

E : E TK_MAIS E
    { $$ = gera_codigo_operador( $1, "+", $3 ); }
  | E TK_MENOS E
    { $$ = gera_codigo_operador( $1, "-", $3 ); }
  | TK_MENOS E %prec TK_MULT
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
      $$.c = tipoArray.tipo_base;
      $$.t = Tipo( tipoArray.tipo_base );
      if( tipoArray.ndim != 1 )
        erro( "Variável " + $1.v + " não é array de uma dimensão" );

      if( $3.t.ndim != 0 || $3.t.tipo_base != "i" )
        erro( "Indice de array deve ser integer de zero dimensão: " +
              $3.t.tipo_base + "/" + toString( $3.t.ndim ) );

      $$.v = gera_nome_var_temp( $$.t.tipo_base );

      if ($$.t.tipo_base == "s") {
        $$.c = $3.c + gera_teste_limite_array( $3.v, tipoArray );

        string idx = $3.v;

        string lower = gera_nome_var_temp("i");
        $$.c += lower + " = " + idx + " * 256;\n";

        string i = gera_nome_var_temp("i");
        $$.c += i + " = " + lower + ";\n";

        string ii = gera_nome_var_temp("i");
        $$.c += ii + " = " + "0;\n";

        string output = gera_nome_var_temp("s");

        string inicio_print_leitura = gera_label("print_array_string_inicio");
        string fim_print_label = gera_label("print_array_string_fim");

        string cond = gera_nome_var_temp("i");
        $$.c += inicio_print_leitura + ":\n";
        $$.c += cond + " = " + ii + " >= 256;\n";
        $$.c += "if (" + cond + ") goto " + fim_print_label + ";\n";

        string qweqwe = gera_nome_var_temp("c");
        $$.c += qweqwe + " = " + $1.v + "["+ i +"];\n";

        $$.c += output + "[" + ii + "] = " + qweqwe + ";\n";
        $$.c += i + " = " + i + " + 1;\n";
        $$.c += ii + " = " + ii + " + 1;\n";

        $$.c += "goto " + inicio_print_leitura + ";\n";
        $$.c += fim_print_label + ":\n";

        $$.v = output;
      } else {
        $$.c = $3.c +
               gera_teste_limite_array( $3.v, tipoArray ) +
               "  " + $$.v + " = " + $1.v + "[" + $3.v + "];\n";
      }
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
      string var1 = gera_nome_var_temp( "i" );
      string var2 = gera_nome_var_temp( "i" );
      int m = tipoArray.tam[1];

      $$.c =  $3.c + $6.c + gera_teste_limite_array( $3.v, $6.v, tipoArray ) +
              var1 + " = " + $3.v + " * " + toString(m) + ";\n" +
              var2 + " = " + var1 + " + " + $6.v + ";\n" +
              $$.v + " = " + $1.v + "[" + var2 + "];\n";
    }
  | TK_ID
    { $$.v = $1.v; $$.t = consulta_ts( $1.v ); $$.c = $1.c; }
  | TK_ID TK_ABREP EXPRSL TK_FECHAP
    {

      /*
        f( bla );

        char var_temp[256];
        f ( bla, var_temp );
        strncpy ( x, var_temp, 256 ); 
      */

      Tipo tipo_func = consulta_ts( $1.v );

      if ( tipo_func.funcao_string ) {

      $$.t = tipo_func.retorno[0].tipo_base;
        if ( tipo_func.params.size() != $3.lista_str.size() + 1 )
          erro( "Quantidade errada de parâmetros" );

          $$.v = gera_nome_var_temp( "s" );
          $$.c = $3.c + "  " + $1.v + "( ";

          for( int i = 0; i < (int) $3.lista_str.size() - 1; i++ ) {
            if ( $3.lista_tipo[i].tipo_base != tipo_func.params[i].tipo_base )
              erro( "Parâmetro de tipo imcompatível" );
            $$.c += $3.lista_str[i] + ", ";
          }
          if ( $3.lista_str.size() > 0 )
            $$.c += $3.lista_str[$3.lista_str.size() - 1];
          $$.c += ", " + $$.v + " );\n";
      } else {

        if ( tipo_func.params.size() != $3.lista_str.size() )
          erro( "Quantidade errada de parâmetros" );

        if ( tipo_func.retorno.size() == 0 )
          erro( "Função não tem valor de retorno." );

        $$.t = tipo_func.retorno[0].tipo_base;

        $$.v = gera_nome_var_temp( $$.t.tipo_base );
        $$.c = $3.c + "  " + $$.v + " = " + $1.v + "( ";

        for( int i = 0; i < (int) $3.lista_str.size() - 1; i++ ) {
          if ( $3.lista_tipo[i].tipo_base != tipo_func.params[i].tipo_base )
            erro( "Parâmetro de tipo imcompatível" );
          $$.c += $3.lista_str[i] + ", ";
        }
        if ( $3.lista_str.size() > 0 )
          $$.c += $3.lista_str[$3.lista_str.size() - 1];
        $$.c += " );\n";
      }
    }
  ;



EXPRSL  : EXPRS
          { $$ = $1; }
        | { $$ = Atributos(); }
        ;


EXPRS : EXPRS ',' E
        { $$ = Atributos();
          $$.c = $1.c + $3.c;
          $$.lista_str = $1.lista_str;
          $$.lista_str.push_back( $3.v );
          $$.lista_tipo = $1.lista_tipo;
          $$.lista_tipo.push_back( $3.t ); }
      | E
        { $$ = Atributos();
          $$.c = $1.c;
          $$.lista_str.push_back( $1.v );
          $$.lista_tipo.push_back( $1.t ); }
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
  tipo_opr["s+i"] = "s";
  tipo_opr["i+s"] = "s";
  tipo_opr["s+d"] = "s";
  tipo_opr["d+s"] = "s";

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
                       Tipo retorno, vector<Tipo> params, bool funcao_string = false ) {
  if( ts[ts.size()-2].find( nome_func ) != ts[ts.size()-2].end() )
    erro( "Função já declarada: " + nome_func );

  ts[ts.size()-2][ nome_func ] = Tipo( retorno, params, funcao_string );
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

  if ( tipo == "v" )
    erro( "Declaração inválida de variável do tipo \"vento\"." );

  var_temp[var_temp.size()-1] += declara_variavel( nome, Tipo( tipo ) ) + ";\n";

  return nome;
}

string gera_label( string label ) {
  static int n = 0;
  string nome = "l_" + label + "_" + toString( ++n );

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
  else if ( t1.ndim == 0 && t3.ndim == 1 ) {
    if ( opr == "in" ) {
      if ( t1.tipo_base == t3.tipo_base )
        return Tipo( "b" );
      else
        erro( "O operador in não está definido para o tipo '" + t1.tipo_base
              + "' e array de '" + t3.tipo_base + "'." );
    }
  } else if ( t1.ndim == 1 && t3.ndim == 1 ) {
    if ( opr == "==" || opr == "!=" ) {
      return Tipo( "b" );
    }
  }
  return Tipo();
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
    } else if ( opr == "+" ) {
       // concatenação de arrays.
    }
  }

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
  if( s1.t.tipo_base == "s" && s3.t.tipo_base == "s" ) {
    if ( opr == "+" ) {
      ss.c = s1.c + s3.c +
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
  } else if ( ( s1.t.tipo_base == "s" && s3.t.tipo_base == "i" ) ||
              ( s1.t.tipo_base == "i" && s3.t.tipo_base == "s" ) ) {
    if ( opr == "+" ) {
      string str_aux = gera_nome_var_temp( "s" );

      // caso s3 seja int
      string sto_string = s3.v;
      string s1v = s1.v;
      string s3v = str_aux;
      if ( s1.t.tipo_base == "i" ) {
        sto_string = s1.v;
        s1v = str_aux;
        s3v = s3.v;
      }

      ss.c = s1.c + s3.c +
             "  sprintf( " + str_aux + ", \"%d\", " + sto_string + " );\n" +
             "  strncpy( " + ss.v + ", " + s1v + ", 256 );\n" +
             "  strncat( " + ss.v + ", " + s3v + ", 256 );\n";

      return ss;
    }


  } else if ( ( s1.t.tipo_base == "s" && s3.t.tipo_base == "d" ) ||
              ( s1.t.tipo_base == "d" && s3.t.tipo_base == "s" ) ) {
    if ( opr == "+" ) {
      string str_aux = gera_nome_var_temp( "s" );

      // caso s3 seja int
      string sto_string = s3.v;
      string s1v = s1.v;
      string s3v = str_aux;
      if ( s1.t.tipo_base == "d" ) {
        sto_string = s1.v;
        s1v = str_aux;
        s3v = s3.v;
      }

      ss.c = s1.c + s3.c +
             "  sprintf( " + str_aux + ", \"%lf\", " + sto_string + " );\n" +
             "  strncpy( " + ss.v + ", " + s1v + ", 256 );\n" +
             "  strncat( " + ss.v + ", " + s3v + ", 256 );\n";

      return ss;
    }


  } else if ( s1.t.tipo_base == "s" && s3.t.tipo_base == "c" )
    ;
  else if ( s1.t.tipo_base == "c" && s3.t.tipo_base == "s" )
    ;
  else {
    ss.c = s1.c + s3.c +
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


string traduz_nome_tipo_lula( string tipo_lula ) {

  // deixando as letras minúsculas para comparação
  for (auto& c: tipo_lula) c |= 32;

  if( tipo_lula == "integro" || tipo_lula == "integros" )
    return "i";
  else if( tipo_lula == "bool" || tipo_lula == "bools" )
    return "b";
  else if( tipo_lula == "corrupto" || tipo_lula == "corruptos" )
    return "d";
  else if( tipo_lula == "detento" || tipo_lula == "detentos" )
    return "c";
  else if( tipo_lula == "cadeia" || tipo_lula == "cadeias" )
    return "s";
  else if( tipo_lula == "vento" )
    return "v";
  else
    erro( "Tipo inválido: " + tipo_lula );
}

map<string, string> inicializaMapEmC() {
  map<string, string> aux;
  aux["i"] = "int ";
  aux["b"] = "int ";
  aux["d"] = "double ";
  aux["c"] = "char ";
  aux["s"] = "char ";
  aux["v"] = "void ";
  return aux;
}

string declara_funcao( string nome, Tipo tipo,
                       vector<string> nomes, vector<Tipo> tipos ) {
  static map<string, string> em_C = inicializaMapEmC();

  if( em_C[ tipo.tipo_base ] == "" )
    erro( "Tipo inválido: " + tipo.tipo_base );

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
            "  printf( \"Limite de array ultrapassado: 0 <= %d <= %d\", " +
            indice_1 + ", " + toString( tipoArray.tam[0]-1 ) + " );\n" +
            "  cout << endl;\n" +
            "  exit( 1 );\n" +
            "  " + label_end + ":;\n";

  return codigo;
}

string gera_teste_limite_array( string indice_1, string indice_2, Tipo tipoArray ) {
  string var_teste_inicio_1 = gera_nome_var_temp( "b" );
  string var_teste_fim_1 = gera_nome_var_temp( "b" );
  string var_teste_inicio_2 = gera_nome_var_temp( "b" );
  string var_teste_fim_2 = gera_nome_var_temp( "b" );
  string var_teste = gera_nome_var_temp( "b" );
  string label_end = gera_label( "limite_array_ok" );

  string codigo = "  " + var_teste_inicio_1 + " = " + indice_1 + " >= 0;\n" +
                  "  " + var_teste_fim_1 + " = " + indice_1 + " < " + toString( tipoArray.tam[0] ) + ";\n" +
                  "  " + var_teste_inicio_2 + " = " + indice_2 + " >= 0;\n" +
                  "  " + var_teste_fim_2 + " = " + indice_2 + " < " + toString( tipoArray.tam[1] ) + ";\n" +
                  "  " + var_teste + " = " + var_teste_inicio_1 + " && " + var_teste_fim_1 + ";\n" +
                  "  " + var_teste + " = " + var_teste + " && " + var_teste_inicio_2 + ";\n" +
                  "  " + var_teste + " = " + var_teste + " && " + var_teste_fim_2 + ";\n";

  codigo += "  if( " + var_teste + " ) goto " + label_end + ";\n" +
            "  printf( \"Limite de matriz ultrapassado. Deveria ter 0 <= %d <= %d e 0 <= %d <= %d \", " +
            indice_1 + ", " + toString( tipoArray.tam[0]-1 ) + ", " +
            indice_2 + ", " + toString( tipoArray.tam[1]-1 ) + " );\n" +
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
