%{

/* Declarations section */
#include <stdio.h>
void showToken(char *);

%}

%option yylineno
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
letter  		([a-zA-Z])
null			"null"
whitespace		([\t\n ])



%%

{obj}												showToken("OBJ");
{endobj}											showToken("ENDOBJ");
{lbrace}											showToken("LBRACE");
{rbrace}											showToken("RBRACE");
{ldict}												showToken("LDICT");
{rdict}												showToken("RDICT");
{comment}(.*)										showToken("COMMENT");
{true}												showToken("TRUE");
{false}												showToken("FALSE");
[+-]{digit}+          								showToken("INTEGER");
[+-]?({digit}*)\.({digit}*)							showToken("REAL");
[+-]?({digit}*)\.({digit}*){letter}+				showToken("STRING");
\/(({digit}*{letter}*)*)							showToken("NAME");

{null}												showToken("NULL");

.		printf("Lex doesn't know what that is!\n");

%%

void showToken(char * name)
{
        printf("Lex found a %s, the lexeme is %s and its length is %d\n", name, yytext, yyleng);
}

