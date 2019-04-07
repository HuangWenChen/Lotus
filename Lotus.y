%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "Lotus_table.h"

int print_info = 0;
hashTable *st;

int reg_stack_loc = 0;
int reg_stack[10] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
int bool_not = 0, bool_and = 0, bool_or = 0;
int tmp_label;
int getReg();
void putReg();
int newLabel(int take);

extern int yylex();
extern int yylineno;
void yyerror(const char *s);

%}

%code requires{
    struct Label{
        int True;
        int False;
        int tmp;
    };
}

%union{
    int ival;
    char *sval;
    struct Label L;
}

%token IF
%token ELSE
%token EXIT
%token INT
%token READ
%token RETURN
%token WHILE
%token WRITE
%token INTEGER
%token ID

%token PLUS
%token MINUS
%token ASTERISK
%token DIV
%token MOD
%token EQ
%token NE
%token GT
%token GE
%token LT
%token LE
%token AND
%token OR
%token NOT
%token ASSIGN
%token SEMICOLON
%token COMMA
%token LPAREN
%token RPAREN
%token LBRACE
%token RBRACE

%type <sval> ID
%type <ival> arith_expression arith_term arith_factor arith_primary INTEGER
%type <L> bool_primary bool_factor bool_term bool_expression bool_mark while_mark

%nonassoc EQ NE GT GE LT LE
%left PLUS MINUS
%left ASTERISK DIV MOD
%right UMINUS

%start program
%%
program : ID LPAREN RPAREN function_body{
        if(print_info) printf("program -> Identifier ( ) function_body\n");}
        ;
function_body : LBRACE {printf("\t.data\n");} variable_declarations {printf("\n\n\t.text\n");printf("main:\n");} statements RBRACE{
              if(print_info) printf("function_body -> { variable_declarations statements }\n");}
              ;
variable_declarations :  {if(print_info) printf("variable_declarations -> empty\n");}
                      | variable_declarations variable_declaration{
                      if(print_info) printf("variable_declarations -> variable_declarations variable_declaration\n");}
                      ;
variable_declaration : INT ID SEMICOLON{
                     printf("%s:\t.word 0\n", $2);
                     if(print_info) printf("variable_declaration -> int Identifier ;\n");}
                     ;
statements :  {if(print_info) printf("statements -> empty\n");}
           | statements statement{
           if(print_info) printf("statements -> statements statement\n");}
           ;
statement : assignment_statement{
          if(print_info) printf("statement -> assignment_statement\n");}
          | compound_statement{
          if(print_info) printf("statement -> compound_statement\n");}
          | if_statement{
          if(print_info) printf("statement -> if_statement\n");}
          | while_statement{
          if(print_info) printf("statement -> while_statement\n");}
          | exit_statement{
          if(print_info) printf("statement -> exit_statement\n");}
          | read_statement{
          if(print_info) printf("statement -> read_statement\n");}
          | write_statement{
          if(print_info) printf("statement -> write_statement\n");}
          ;
assignment_statement : ID ASSIGN arith_expression SEMICOLON{
                     int tmp = getReg();
                     printf("\tla\t$t%d, %s\n", tmp, $1);
                     printf("\tsw\t$t%d, 0($t%d)\n", $3, tmp);
                     putReg(tmp); putReg($3);
                     if(print_info) printf("assignment_statement -> Identifier = arith_expression ;\n");}
                     ;
compound_statement : LBRACE statements RBRACE{
                   if(print_info) printf("compound_statement -> { statements }\n");}
                   ;
if_statement : IF LPAREN bool_mark RPAREN statement{
             printf("L%d:\n", $3.False);
             if(print_info) printf("if_statement -> if ( bool_expression ) statement\n");}
             | IF LPAREN bool_mark RPAREN statement ELSE {
             $3.tmp = newLabel(1);
             printf("\tb\tL%d\n", $3.tmp);
             printf("L%d:\n", $3.False);
             } statement{
             printf("L%d:\n", $3.tmp);
             if(print_info) printf("if_statement -> if ( bool_expression ) statement else statement\n");}
             ;
while_statement : while_mark LPAREN bool_expression RPAREN {
                printf("L%d:\n", $3.True);
                }statement{
                printf("\tb\tL%d\n", $1.tmp);
                printf("L%d:\n", $3.False);
                if(print_info) printf("while_statement -> while ( bool_expression ) statement\n");}
                ;
while_mark : WHILE {printf("L%d:\n", newLabel(1)); $$.tmp = newLabel(0);}
                ;
exit_statement : EXIT SEMICOLON{
               printf("\tli\t$v0, 10\n");
               printf("\tsyscall\n");
               if(print_info) printf("exit_statement -> exit ;\n");}
               ;
read_statement : READ ID SEMICOLON{
               int read_reg = getReg();
               printf("\tli\t$v0, 5\n");
               printf("\tsyscall\n");
               printf("\tla\t$t%d, %s\n", read_reg, $2);
               printf("\tsw\t$v0, 0($t%d)\n", read_reg);
               putReg(read_reg);
               if(print_info) printf("read_statement -> read Identifier ;\n");}
               ;
write_statement : WRITE arith_expression SEMICOLON{
                printf("\tmove\t$a0, $t%d\n", $2);
                printf("\tli\t$v0, 1\n");
                printf("\tsyscall\n");
                putReg($2);
                if(print_info) printf("write_statement -> write arith_expression ;\n");}
                ;
bool_mark : bool_expression{
          $$ = $1;
          printf("L%d:\n", $1.True);
          }
          ;
bool_expression : bool_term{
                printf("L%d\n", bool_not ? $1.False : $1.True);
                printf("\tb\tL%d\n", bool_not ? $1.True : $1.False);
                $$ = $1;
                bool_and = 0;
                if(print_info) printf("bool_expression -> bool_term\n");}
                | bool_expression OR {
                bool_or = 1;
                printf("L%d:\n", $1.False);
                } bool_term{
                if(bool_and){
                    printf("L%d\n", bool_not ? $4.False : $1.True);
                    printf("\tb\tL%d\n", bool_not ? $1.True : $4.False);
                }else{
                    printf("L%d\n", bool_not ? $4.True : $1.True);
                    printf("\tb\tL%d\n", bool_not ? $1.True : $4.True);
                }
                $$.True = $1.True;
                $$.False = bool_and ? $4.False : $4.True;
                bool_and = 0;
                bool_or = 0;
                newLabel(2);
                if(print_info) printf("bool_expression -> bool_expression || bool_term\n");}
                ;
bool_term : bool_factor{
          $$ = $1;
          if(print_info) printf("bool_term -> bool_factor\n");}
          | bool_term AND {
          printf("L%d\n", bool_not ? $1.False : $1.True);
          printf("\tb\tL%d\n", bool_not ? $1.True : $1.False);
          printf("L%d:\n", $1.True);
          bool_and = 1;
          } bool_factor{
          $$.True = $4.True;
          $$.False = $1.False;
          newLabel(2);

          if(print_info) printf("bool_term -> bool_term && bool_factor\n");}
          ;
bool_factor : bool_primary{
        bool_not = 0;
        $$ = $1;
        if(print_info) printf("bool_factor -> bool_primary\n");}
        | NOT bool_primary{
        bool_not = 1;
        $$ = $2;
        if(print_info) printf("bool_factor -> ! bool_primary\n");}
        ;
bool_primary : arith_expression EQ arith_expression{
         $$.True = newLabel(1);
         $$.False = newLabel(1);
         printf("\tbeq\t$t%d, $t%d, ", $1, $3);
         putReg($3); 
         putReg($1);
             if(print_info) printf("bool_primary -> arith_expression = arith_expression\n");}
             | arith_expression NE arith_expression{
             $$.True = newLabel(1);
             $$.False = newLabel(1);
             printf("\tbne\t$t%d, $t%d, ", $1, $3);
             putReg($3); 
             putReg($1);
             if(print_info) printf("bool_primary -> arith_expression != arith_expression\n");}
             | arith_expression GT arith_expression{
             $$.True = newLabel(1);
             $$.False = newLabel(1);
             printf("\tbgt\t$t%d, $t%d, ", $1, $3);
             putReg($3); putReg($1);
             if(print_info) printf("bool_primary -> arith_expression > arith_expression\n");}
             | arith_expression GE arith_expression{
             $$.True = newLabel(1);
             $$.False = newLabel(1);
             printf("\tbge\t$t%d, $t%d, ", $1, $3);
             putReg($3); 
             putReg($1);
             if(print_info) printf("bool_primary -> arith_expression >= arith_expression\n");}
             | arith_expression LT arith_expression{
             $$.True = newLabel(1);
             $$.False = newLabel(1);
             printf("\tblt\t$t%d, $t%d, ", $1, $3);
             putReg($3); 
             putReg($1);
             if(print_info) printf("bool_primary -> arith_expression < arith_expression\n");}
             | arith_expression LE arith_expression{
             $$.True = newLabel(1);
             $$.False = newLabel(1);
             printf("\tble\t$t%d, $t%d, ", $1, $3);
             putReg($3); 
             putReg($1);
             if(print_info) printf("bool_primary -> arith_expression <= arith_expression\n");}
             ;
arith_expression : arith_term{
                 $$ = $1;
                 if(print_info) printf("arith_expression -> arith_term\n");}
                 | arith_expression PLUS arith_term{
                 printf("\tadd\t$t%d, $t%d, $t%d\n", $1, $1, $3);
                 $$ = $1;
                 putReg($3);
                 if(print_info) printf("arith_expression -> arith_expression + arith_term\n");}
                 | arith_expression MINUS arith_term{
                 printf("\tsub\t$t%d, $t%d, $t%d\n", $1, $1, $3);
                 $$ = $1;
                 putReg($3);
                 if(print_info) printf("arith_expression -> arith_expression - arith_term\n");}
                 ;
arith_term : arith_factor{
           $$ = $1;
           if(print_info) printf("arith_term -> arith_factor\n");}
           | arith_term ASTERISK arith_factor{
           printf("\tmul\t$t%d, $t%d, $t%d\n", $1, $1, $3);
           $$ = $1;
           putReg($3);
           if(print_info) printf("arith_term -> arith_term * arith_factor\n");}
           | arith_term DIV arith_factor{
           printf("\tdiv\t$%d, $t%d, $t%d\n", $1, $1, $3);
           $$ = $1;
           putReg($3);
           if(print_info) printf("arith_term -> arith_term / arith_factor\n");}
           | arith_term MOD arith_factor{
           printf("\trem\t$t%d, $t%d, $%d\n", $1, $1, $3);
           $$ = $1;
           putReg($3);
           if(print_info) printf("arith_term -> arith_term %% arith_factor\n");}
           ;
arith_factor : arith_primary{
             $$ = $1;
             if(print_info) printf("arith_factor -> arith_primary\n");}
             | MINUS arith_primary %prec UMINUS{
             printf("\tneg\t$t%d, $t%d\n", $2, $2);
             $$ = $2;
             if(print_info) printf("arith_factor -> - arith_primary\n");}
             ;
arith_primary : INTEGER{
              $$ = getReg();
              printf("\tli\t$t%d, %d\n", $$, $1);
              if(print_info) printf("arith_primary -> Integer\n");}
              | ID{
              $$ = getReg();
              printf("\tla\t$t%d, %s\n", $$, $1);
              printf("\tlw\t$t%d, 0($t%d)\n", $$, $$);
              if(print_info) printf("arith_primary -> Identifier\n");}
              | LPAREN arith_expression RPAREN{
              $$ = $2;
              if(print_info) printf("arith_primary -> ( arith_expression )\n");}
              ;
%%
void main(int argc, char **argv){
    char *kw[] = {"if", "else", "exit", "int", 
                "read", "return", "while", "write"};
    int token[] = {IF, ELSE, EXIT, INT, READ, RETURN, WHILE, WRITE};
    
    //check if "-p" argument exist
    while(*(++argv)){
        print_info = !strcmp("-p", *argv);
    }
    
    //create hash table
    st = createHashTable();
    int row = sizeof(kw) / sizeof(kw[0]);
    for(int i = 0; i < row; i++){
        append(kw[i], token[i], st);
    }
    
    //parser 
    yyparse();
}

void yyerror(const char *s){
    fprintf(stderr, "Syntax error: line %d\n", yylineno);
}

int getReg(){
    if(reg_stack_loc > 9){
        fprintf(stderr, "no temporary register\n");
    }
    
    return reg_stack[reg_stack_loc++];
}

void putReg(int reg){
    reg_stack[--reg_stack_loc] = reg;
}

int newLabel(int take){
    static int number = 0;
    if(!take){
        return number;
    }else if(take == 2){
        return --number;
    }
    return ++number;
}
