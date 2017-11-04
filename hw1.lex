%{

/*
*******************************************************************************************************************
************************************************ DECLARATION SECTION **********************************************
*******************************************************************************************************************
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define MAX_LEN 2048
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
/*
*******************************************************************************************************************
************************************************ RULES SECTION ***************************************************
*******************************************************************************************************************
*/

{obj}														showToken("OBJ");
{endobj}													showToken("ENDOBJ");
{lbrace}													showToken("LBRACE");
{rbrace}													showToken("RBRACE");
{ldict}														showToken("LDICT");
{rdict}														showToken("RDICT");
{comment}(.*)												showToken("COMMENT");
{true}														showToken("TRUE");
{false}														showToken("FALSE");
[+-]{digit}+          										showToken("INTEGER");
[+-]?({digit}*)\.({digit}*)									showToken("REAL");
((\(([^\(\)\\\n](\\\\)*(\\\n)*(\\n)*(\\r)*(\\{octal}{octal}{octal}{letter})*(\\t)*(\\b)*(\\f)*(\\\()*(\\\))*)*\))+)|
((<(({hexa}{hexa})*[\t\n ]*)*>)+)							showToken("STRING");
\/(({digit}*{letter}*)*)									showToken("NAME");
(stream\n((\n)*(?!stream|endstream).*(\n)*)*\nendstream)	showToken("STREAM");
{null}														showToken("NULL");

.		printf("Lex doesn't know what that is!\n");

%%

/*
*******************************************************************************************************************
************************************************ C-CODE SECTION ***************************************************
*******************************************************************************************************************
*/

void removeAll(char * str, char * toRemove)
{
    int i, j, stringLen, toRemoveLen;
    int found;

    stringLen   = strlen(str);      // Length of string
    toRemoveLen = strlen(toRemove); // Length of word to remove


    for(i=0; i <= stringLen - toRemoveLen; i++)
    {
        /* Match word with string */
        found = 1;
        for(j=0; j<toRemoveLen; j++)
        {
            if(str[i + j] != toRemove[j])
            {
                found = 0;
                break;
            }
        }

        /* If it is not a word */
        if(str[i + j] != ' ' && str[i + j] != '\t' && str[i + j] != '\n' && str[i + j] != '\0') 
        {
            found = 0;
        }

        /*
         * If word is found then shift all characters to left
         * and decrement the string length
         */
        if(found == 1)
        {
            for(j=i; j<=stringLen - toRemoveLen; j++)
            {
                str[j] = str[j + toRemoveLen];
            }

            stringLen = stringLen - toRemoveLen;
        }
    }
}

int isUnprintable(char ch){
	
	int i;
	for(i = 1 ; i < 38;i++){
	    if(ch == "\\" + i)
			return 1;
	}
	
	return 0;
	
}
char* removeUnprintableChars(char* str){
	
	int i,j=0,stop = 0;
	char* revisedStr = malloc(sizeof(MAX_LEN));
	
	for(i=0;i<MAX_LEN;i++){

	     if(str[i] == 'e' && str[i+1] == 'n' && str[i+2] == 'd' && str[i+3] == 's' && str[i+4] == 't' && str[i+5] == 'r' && str[i+6] == 'e' && str[i+7] == 'a' && str[i+8] == 'm'){
			stop = 1;
	     }
		 
       	 if(isUnprintable(str[i]))
			continue;
	
	     if(str[i] == '\0'){
	     	if(stop)
	     	 break;
		 
	     	else
	     	 continue;
	     }
	     revisedStr[j++] = str[i];
	}

	revisedStr[j] = '\0';

	return revisedStr;
}


void showToken(char * name)
{
	if(strcmp(name,"STREAM") == 0){
		
		char* revised = removeUnprintableChars(yytext);
		removeAll(revised,"endstream");
		removeAll(revised,"stream");
	}
		
    printf("%d %s %s",yylineno,name,yytext);
}



















