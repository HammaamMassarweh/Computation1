%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#define MAX_LEN 2048
void showToken(char *);
void showError();
char* removeUnprintableChars(char*);
void removeAll(char *, char *);
bool isUnprintable(char);
void printIllegalChar(char ch);
void handleHexaCase();
void handleNameTokenCase();
void handleStringNonHexaCase();


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
stream			"stream"
endstream		"endstream"

%%

{obj}														showToken("OBJ");
{endobj}													showToken("ENDOBJ");
{lbrace}													showToken("LBRACE");
{rbrace}													showToken("RBRACE");
{ldict}														showToken("LDICT");
{rdict}														showToken("RDICT");
{comment}(.*)												showToken("COMMENT");
{true}														showToken("TRUE");
{false}														showToken("FALSE");
[+-]?{digit}+          										showToken("INTEGER");
[+-]?({digit}*)\.({digit}*)									showToken("REAL");
((\(([^\(\)\\\n](\\\\)*(\\\n)*(\\n)*(\\r)*(\\{octal}{octal}{octal}{letter})*(\\t)*(\\b)*(\\f)*(\\\()*(\\\))*)*\))+)|((<(({hexa}{hexa})*[\t\n ]*)*>)+)							showToken("STRING");
\/(({digit}*{letter}*)*)									showToken("NAME");
stream\n((\n)*.*(\n)*)*\nendstream							showToken("STREAM");
{null}														showToken("NULL");
{whitespace}												printf("%s", yytext);									

.															showError();

%%

bool startsWith(const char *pre, const char *str)
{
    size_t lenpre = strlen(pre),
           lenstr = strlen(str);
    return lenstr < lenpre ? false : strncmp(pre, str, lenpre) == 0;
}


void printIllegalChar(char ch){
	
	printf("Error %c\n",ch);
}


void handleHexaCase(){
	
	int i = 1;
		char* hexa = yytext + 1;
		while(i < yyleng){
			
			if((hexa[i] >= 'a' && hexa[i] <= 'f') || (hexa[i] >= 'A' && hexa[i] <= 'F') || (hexa[i] >= '0' && hexa[i] <= '9')){
				i++;
			}
			else{
				printIllegalChar(hexa[i]);
				exit(0);
			}
				
		}
		if(yytext[yyleng - 1] != '>'){
			printf("Error unclosed string\n");
		}
		else{
			//if the error neither a bad char nor a non-closed string, so it's just an incomplete byte error !
				printf("Error incomplete byte\n");
		}
	
	
	
}

void handleStringNonHexaCase(){
	
}

void handleNameTokenCase(){
	int i;
	for( i = 1;i<yyleng;i++){
		if((yytext[i] >= 'a' && yytext[i] <= 'z') || (yytext[i] >= 'A' && yytext[i] <= 'Z') || (yytext[i] >= '0' && yytext[i] <= '9'))
			continue;
		else{
			printIllegalChar(yytext[i]);
				break;
		}
	}
}
void showError(){
	
	if(startsWith("<",yytext)){
		handleHexaCase();
			
	}else{
		if(startsWith("(",yytext)){
			//HAMMAM please complete this case , it is a STRING token error case(note that I've handled above the hexa case)
			//here the string may contain a bad char such as an undefined escape sequence or simply the string not enclosed)
			handleStringNonHexaCase();
		}
		else{
			if(startsWith("stream",yytext)){
				//simply there's no other error in this case!
				printf("Error unclosed stream\n");
			}else{
				if(startsWith("\/",yytext)){
					handleNameTokenCase();
				}else{
					//TO BE CONTINUED WITH THE OTHER CASES
					
				}
				
			}
			
			
			
		}
		
		
		
	}
	
	exit(0);
}

bool isUnprintable(char ch){
	
	int dec_val = (int)ch;
	return (dec_val >= 0 && dec_val <= 31);
	
}
char* removeUnprintableChars(char* str){
	
	int i,j=0,stop = 0;
	char* revisedStr = malloc(sizeof(MAX_LEN));

	for(i=6;i<MAX_LEN;i++){

	     if(str[i] == 'e' && str[i+1] == 'n' && str[i+2] == 'd' && str[i+3] == 's' && str[i+4] == 't' && str[i+5] == 'r' && str[i+6] == 'e' && str[i+7] == 'a' && str[i+8] == 'm')
			break;
		 
       	 if(isUnprintable(str[i]))
			continue;
	
	     if(str[i] == '\0')		// may include this in isUnprintable
	     	continue;
	     
	     revisedStr[j++] = str[i];
	}

	revisedStr[j] = '\0';

	return revisedStr;
}


void showToken(char * name)
{
	if(strcmp(name,"STREAM") == 0){
		
		char* revised = removeUnprintableChars(yytext);
		printf("%d %s %s",yylineno,name,revised);
		return;
	}
	
    printf("%d %s %s",yylineno,name,yytext);
}



















