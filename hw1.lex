%{

/* Declarations section */
#include <stdio.h>
void showToken(char *);

%}

%option yylineno
%option yytext
%option noyywrap

obj				"obj"
endobj			"endobj"
lbrace			"["
rbrace			"]"
ldict			"<<"
rdict			">>"
rbrace			"]"
comment			"%"
true			"true"
false			"false"
digit   		([0-9])
octal			([0-7])
hexa			([0-9a-fA-F])
letter  		([a-zA-Z])
null			"null"
whitespace		([\t\n ])



%%

{obj}													showToken("OBJ");
{endobj}												showToken("ENDOBJ");
{lbrace}												showToken("LBRACE");
{rbrace}												showToken("RBRACE");
{ldict}													showToken("LDICT");
{rdict}													showToken("RDICT");
{comment}(.*)											showToken("COMMENT");
{true}													showToken("TRUE");
{false}													showToken("FALSE");
[+-]{digit}+          									showToken("INTEGER");
[+-]?({digit}*)\.({digit}*)								showToken("REAL");
((\(([^\(\)\\\n](\\\\)*(\\\n)*(\\n)*(\\r)*(\\{octal}{octal}{octal}{letter})*(\\t)*(\\b)*(\\f)*(\\\()*(\\\))*)*\))+)|
((<(({hexa}{hexa})*[\t\n ]*)*>)+)						showToken("STRING");
\/(({digit}*{letter}*)*)								showToken("NAME");
stream\n((\n)*(?!stream|endstream).*(\n)*)*\nendstream	showToken("STREAM");
{null}													showToken("NULL");

.		printf("Lex doesn't know what that is!\n");

%%



void showToken(char * name)
{
        printf("%d %s %s",yylineno,name,yytext);
}
























