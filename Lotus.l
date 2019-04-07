%option yylineno
%{
#include <stdio.h>
#include <string.h>
#include "Lotus_table.h"
#include "Lotus.tab.h"

extern hashTable *st;

%}
delim       [ \t\n]
ws          {delim}+
letter      [A-Za-z]
digit       [0-9]
id          {letter}({letter}|{digit})*
integer     {digit}+
comment     \/\/(.)*\n
%%
{comment}   { /* no action and no return */ }
{ws}        { /* no action and no return */ }

"+"         {return (PLUS);}
"-"         {return (MINUS);}
"*"         {return (ASTERISK);}
"/"         {return (DIV);}
"%"         {return (MOD);}
"=="        {return (EQ);}
"!="        {return (NE);}
">"         {return (GT);}
">="        {return (GE);}
"<"         {return (LT);}
"<="        {return (LE);}
"&&"        {return (AND);}
"||"        {return (OR);}
"!"         {return (NOT);}
"="         {return (ASSIGN);}
";"         {return (SEMICOLON);}
","         {return (COMMA);}
"("         {return (LPAREN);}
")"         {return (RPAREN);}
"{"         {return (LBRACE);}
"}"         {return (RBRACE);}

{id}        {
            keyword *k = findKeyword(yytext, st);
            if(k)
                return(k->token);
            if(!yylval.sval){
                free(yylval.sval);
            }
            yylval.sval = (char*)malloc(sizeof(char)*strlen(yytext));
            strcpy(yylval.sval, yytext);
            return(ID);
            }
{integer}   {yylval.ival = install_integer();return (INTEGER);}
.           {error_handle();}
%%
