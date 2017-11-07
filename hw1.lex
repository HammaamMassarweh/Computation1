%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#define MAX_LEN 2048
void showToken(char *);
void showError();
void saveText();
char* removeUnprintableChars();
void removeAll(char *, char *);
void showStringToken(char*);
char *substring(char *,int , int);
void printIllegalChar(char ch);
void handleHexaCase();
void handleNameTokenCase();
bool lengthIsOdd(char* str);
void deleteWhiteSpaces(char*,char*);
bool unclosedString(char* str,int);
%}

%option yylineno
%option noyywrap
%x ENDSTREAM 

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
whitespace		([\t\n ]|(\r\n))
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
((\(([^\(\)\\\n](\\\\)*(\\\n)*(\\n)*(\\r)*(\\{octal}{octal}{octal}{letter})*(\\t)*(\\b)*(\\f)*(\\\()*(\\\))*)*[\)]?)+)|((<({whitespace}*(.*)*)*([>]?))+)							showStringToken("STRING");
\/(({digit}*{letter}*)*)									showToken("NAME");
stream BEGIN(ENDSTREAM);
<ENDSTREAM>(.)|([\n\r])										saveText();
<ENDSTREAM>([\n])endstream 									{showToken("STREAM"); BEGIN(INITIAL);}
{null}														showToken("NULL");
{whitespace}												printf("%s", yytext);									
.															showError();//printf("ERROR");

%%

char text[MAX_LEN];
int text_index = 0;

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
	
	if(startsWith("<",yytext) || startsWith("(",yytext)){
		//STRING CASES ALREADY HANDLED IN showStringToken method.

	}else{
		
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
	
	exit(0);
}

bool isUnprintable(char ch){
	
	int dec_val = (int)ch;
	return (dec_val >= 0 && dec_val <= 31);
	
}

char* removeUnprintableChars(){
	
	int i,j=0,stop = 0;
	char* revisedStr = malloc(sizeof(MAX_LEN));
	
	char* str = text;
	for(i=0;i<text_index;i++){

       	 if(isUnprintable(str[i]))
			continue;
	
	    /* if(str[i] == '\0')		// may include this in isUnprintable
	     	continue; */
	     
	     revisedStr[j++] = str[i];
	}

	revisedStr[j] = '\0';

	return revisedStr;
}

void saveText(){
	
	text[text_index++] = *yytext;
	text[text_index] = '\0';
}

void showToken(char * name)
{
	if(strcmp(name,"STREAM") == 0){
		
		//char * revisedStr = removeUnprintableChars();
		printf("%d %s %s\n",yylineno,name,text+2);
		text_index = 0;

	}
	else{
		printf("%d %s %s\n",yylineno,name,yytext);
	}
}

char *substring(char *string, int index, int length)
{
    int counter = length - index;

    //printf("\n%d\n", counter);
    char* array = malloc(sizeof(char) * counter);
    if(array != NULL)
    {
        int i = index;
		while(i < length)
		{
			array[i - index] = string[i];
			i++;
		}
    }
    else
        puts("Dynamic allocations failed\n");
    return array;
}   



unsigned int hexToInt(const char hex)
{
	if (hex > 47 && hex < 58)
	  return (hex - 48);
	else if (hex > 64 && hex < 71)
	  return (hex - 55);
	else if (hex > 96 && hex < 103)
	  return (hex - 87);
}

  int hex_to_ascii(char c, char d)
{
	int high = hexToInt(c) * 16;
	int low = hexToInt(d);
	return high+low;
}

bool notHexaText(char* hexa){
	
	while(*hexa){
		if((*hexa >= 'a' && *hexa <= 'f') || (*hexa >= 'A' && *hexa <= 'F') || (*hexa >= '0' && *hexa <= '9'))
			hexa++;
		else{
			printIllegalChar(*hexa);
			return true;
		}
	}
	return false;
}
bool unclosedString(char* str,int len){

	
	if(str[0] == '(' && str[len-1] == ')')
		return false;
	if(str[0] == '<' && str[len-1] == '>')
		return false;

	return true;
} 
char* HandleHexaInput(char* hexaInput)
{
		
	char* revisedStr = malloc(sizeof(hexaInput));
	deleteWhiteSpaces(hexaInput,revisedStr);

	char* revisedStrWithNoBrackets = substring(revisedStr, 1, strlen(revisedStr)-1);
	
	if(notHexaText(revisedStrWithNoBrackets)){
		return NULL;
	}
	if(unclosedString(revisedStr,strlen(revisedStr))){
		printf("Error unclosed string\n");
		return NULL;
	}
	if(lengthIsOdd(revisedStrWithNoBrackets)){
		printf("Error incomplete byte\n");
		return NULL;
	}

	revisedStr = revisedStrWithNoBrackets;
	char* hexToText = malloc(sizeof(char) * ((strlen(revisedStr)/2) + 1));
	int nextCharIndex = 0;
	int i = 0;
	for(i = 0; i < strlen(revisedStr); i++){
		if(revisedStr[i] == '\t' || revisedStr[i] == '\n' || revisedStr[i] == '\r' || revisedStr[i] == ' ')
			continue;
		else
		{
			hexToText[nextCharIndex] = hex_to_ascii(revisedStr[i],revisedStr[i+1]);
			i++;
			nextCharIndex++;
		}
    }
	return hexToText;
}

void deleteWhiteSpaces(char src[], char dst[]){
   // src is supposed to be zero ended
   // dst is supposed to be large enough to hold src
  int s, d=0;
  for (s=0; src[s] != 0; s++)
    if (src[s] != ' ' && src[s] != '\n' && src[s] != '\t' && src[s] != '\r') {
       dst[d] = src[s];
       d++;
    }
  dst[d] = 0;
}
bool lengthIsOdd(char* str){
	
	return ((strlen(str) % 2) == 1);
	
}
void handleNonHexaInputErrors(char* text){
	
}
void showStringToken(char* name)
{

	char* newText = malloc(sizeof(char) * (strlen(yytext)-2));
	newText = substring(yytext, 1, strlen(yytext)-1);
	if(yytext[0] == '<')
	{
		newText = HandleHexaInput(yytext);
		if(newText == NULL)
			exit(0);
	}
	else
	{
		handleNonHexaInputErrors(newText);
		char* newAsciiText = malloc(sizeof(char) * (strlen(newText)));
		int i,nextCharAdd = 0;
		for( i=0; i< strlen(newText); i++)
		{
			if( newText[i] == '\\' && (newText[i+1] == '\n' || newText[i+1] == '\n'))
			{
				i++;
				continue;
			}
			
			newAsciiText[nextCharAdd] = newText[i];
			nextCharAdd++;
		}
		
		newText = newAsciiText;
	}
    printf("%d %s %s\n",yylineno,name,newText);
	//free(newText);
	
}










