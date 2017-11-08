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
void handleNameTokenCase();
bool lengthIsOdd(char* str);
void saveStringText();
bool notHexaText(char* c);
void deleteWhiteSpaces(char*,char*);
bool unclosedString(char* str,int);
void printStringTokenLine();
void printPropriateHexError();
void saveStringText_Hex();
%}

%option yylineno
%option noyywrap
%x ENDSTREAM 
%x STRING
%x HEXASTRING

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
e_o_f			(\z)
hexa			([0-9a-fA-F])
letter  		([a-zA-Z])

null			"null"
whitespace		([\t\n\r ])
%%


\(\\\(\\\)\)																{printf("%d STRING ()\n",yylineno);}

\( 																BEGIN(STRING);
<STRING>([^\(\)]({whitespace})*(\\\n)*(\\\))*(\\\r)*(\\n)*(\\r)*(\\\\)*(\\{octal}{octal}{octal}{letter})*({letter})*({digit})*(\\t)*(\\b)*(\\f)*(\\\()*(\\\))*)*   {saveStringText();}
<STRING>\)														{printStringTokenLine();BEGIN(INITIAL);}
<STRING><<EOF>>													{printf("Error unclosed string\n"); exit(0);BEGIN(INITIAL);}

\<\>																	printf("%d STRING \n",yylineno);

\<																	BEGIN(HEXASTRING);
<HEXASTRING>({whitespace}*([^>])*{whitespace}*)*  					saveStringText_Hex();
<HEXASTRING>\>														{showStringToken("STRING");BEGIN(INITIAL);}
<HEXASTRING><<EOF>>													{printPropriateHexError();BEGIN(INITIAL);}

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
\/(({digit}*{letter}*)*)									showToken("NAME");

(stream[\r\n])|(stream[\n][\r]) BEGIN(ENDSTREAM);
<ENDSTREAM>((.)|{whitespace})										saveText();
<ENDSTREAM>'(0)'														;
<ENDSTREAM>(([\r][\n])|([\n\r]))endstream 									{showToken("STREAM"); BEGIN(INITIAL);}
<ENDSTREAM><<EOF>>											{printf("Error unclosed stream\n");exit(0);}

{null}														showToken("NULL");
{whitespace}												;//printf("%s", yytext);

<<EOF>>														showToken("EOF");
.															showError();//printf("ERROR");

%%

char text[MAX_LEN];
int text_index = 0;

char string_text[MAX_LEN];
int string_text_len = 0;

char string_text_hex[MAX_LEN];
int string_text_len_hex = 0;

int powerr(int b,int f)
{
	int sum = 1;
	int i=0;
	for(i=0; i<f; i++)
	{
		sum *= b;
	}
	
	return sum;
}

void printPropriateHexError(){
	
	char* revisedStr = malloc(sizeof(string_text_hex));
	deleteWhiteSpaces(string_text_hex,revisedStr);
	
	if(notHexaText(revisedStr)){
		exit(0);
	}
	
	printf("Error unclosed string\n"); 
	exit(0);
}

long long convertOctalToDecimal(int octalNumber)
{
    int decimalNumber = 0, i = 0;

    while(octalNumber != 0)
    {
        decimalNumber += (octalNumber%10) * powerr(8,i);
        ++i;
        octalNumber/=10;
    }

    i = 1;

    return decimalNumber;
}

void printStringTokenLine(){
	printf("%d STRING %s\n",yylineno,string_text);
	string_text[0] = '\0';
	string_text_len = 0;
}

void saveStringText(){
	//printf("In: %s\n",yytext);
	char* newText = yytext;
	int i,nextCharAdd = 0;
	int size = strlen(newText);
	
	for( i=0; i< size; i++)
	{
		if( newText[i] == '\\')
		{
			switch(newText[i+1])
			{
				case '\n':
				case '\r':
					i+=1;
					continue;
				case 't':
					string_text[nextCharAdd++] = '\t';
					i++;
					continue;
				case 'n':
					string_text[nextCharAdd++] = '\n';
					i++;
					continue;
				case 'r':
					string_text[nextCharAdd++] = '\r';
					i++;
					continue;
				case 'b':
					string_text[nextCharAdd++] = '\b';
					i++;
					continue;
				case 'f':
					string_text[nextCharAdd++] = '\f';
					i++;
					continue;
				case '\\':
					string_text[nextCharAdd++] = '\\';
					i++;
					continue;
				case ')':
					string_text[nextCharAdd++] = ')';
					i++;
					continue;
				case '(':
					string_text[nextCharAdd++] = '(';
					i++;
					continue;
				default :
					printf("Error undefined escape sequence %c\n",newText[i+1]);
					exit(0);
					break;
				 
			}	
		}
		
		if(newText[i] == '\\' && '0' <= newText[i+1] <= '7' && '0' <= newText[i+2] <= '7' && '0' <= newText[i+3] <= '7')
		{
			int octaldigits = (newText[i+1] - '0')*100 + (newText[i+2] - '0')*10 + (newText[i+3] - '0');
			string_text[nextCharAdd++] = convertOctalToDecimal(octaldigits);
			i+=3;
			continue;
		}
		
		if(newText[i] == ')'){
			//string_text[nextCharAdd++] = newText[i];
			break;
		}
		
		if(newText[i] == '\n' || newText[i] == '\r'){
			printIllegalChar('\n');
			exit(0);
		}
				
		string_text[nextCharAdd++] = newText[i];
	}
	
	string_text[nextCharAdd] = '\0';
	string_text_len = nextCharAdd;
	//strcpy(string_text,yytext);
	//printf("++++++++++++++++++++++++++++++\n");
	//printf("%s\n",yytext);
	//printf("------------------------------\n");
	//printf("%s\n",string_text);
	//printf("++++++++++++++++++++++++++++++\n");
}

void saveStringText_Hex(){
	//printf("In: %s\n",yytext);
	char* newText = yytext;
	int i,nextCharAdd = 0;
	for( i=0; i< strlen(newText); i++)
	{
		string_text_hex[nextCharAdd++] = newText[i];
	}
	
	string_text_hex[nextCharAdd] = '\0';
	string_text_len_hex = nextCharAdd;
	//strcpy(string_text,yytext);
	//printf("++++++++++++++++++++++++++++++\n");
	//printf("%s\n",yytext);
	//printf("------------------------------\n");
	//printf("%s\n",string_text);
	//printf("++++++++++++++++++++++++++++++\n");
}

bool startsWith(const char *pre, const char *str)
{
    size_t lenpre = strlen(pre),
           lenstr = strlen(str);
    return lenstr < lenpre ? false : strncmp(pre, str, lenpre) == 0;
}


void printIllegalChar(char ch){
	
	printf("Error %c\n",ch);
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
	
	//printf("I'm in show error");
	if(startsWith("<",yytext) || startsWith("(",yytext)){
		//STRING CASES ALREADY HANDLED IN showStringToken method.

	}else{

		if(startsWith("\/",yytext)){
			handleNameTokenCase();
		}else{
			//TO BE CONTINUED WITH THE OTHER CASES
			printIllegalChar(yytext[0]);
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
		printf("%d STREAM %s\n",yylineno,text);
		text_index = 0;
		text[text_index] = '\0';

	/*	int i;
		for(i = 2 ; i < text_index;i++){
			printf("%c",text[i]);
		}
		printf("\n");*/

	}
	else{
		printf("%d %s %s\n",yylineno,name,yytext);
	}
	
	if(strcmp(name,"EOF") == 0)
	   exit(0);
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
	//printf("I'm in HandleHexaInput");	
	char* revisedStr = malloc(string_text_len_hex);
	deleteWhiteSpaces(hexaInput,revisedStr);
	
	if(notHexaText(revisedStr)){
		return NULL;
	}
	
	if(lengthIsOdd(revisedStr)){
		printf("Error incomplete byte\n");
		return NULL;
	}

	//printf("----------------\n");
	//printf("I got a -=>   %s\n",revisedStr);
	//printf("----------------\n");
	
	char* hexToText = malloc(MAX_LEN);
	int i,nextCharIndex = 0;
	for(i = 0; i < string_text_len_hex ; i+=2){
		
			char asciiChar = hex_to_ascii(revisedStr[i],revisedStr[i+1]);
			hexToText[nextCharIndex++] = asciiChar;
		
    }
	hexToText[nextCharIndex] = '\0';
	nextCharIndex++;
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

void showStringToken(char* name)
{

	char* newText = string_text_hex;
	newText = HandleHexaInput(string_text_hex);
	if(newText == NULL)
		exit(0);
	
	printf("%d %s %s\n",yylineno,name,newText);
	string_text_hex[0] = '\0';
	string_text_len_hex = 0;
}










