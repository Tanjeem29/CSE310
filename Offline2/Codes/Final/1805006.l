%option noyywrap
%option yylineno
%x MULCOMM

%{
#include <bits/stdc++.h>
#include "1805006SymbolInfo.h"
#include "1805006Hash.h"
#include "1805006ScopeTable.h"
#include "1805006SymbolTable.h"
#include <fstream>
using namespace std;


SymbolInfo* tempSI;
string token;
string type;
string lexeme;
string temp;
string multicomm;
ofstream coutf("1805006_log.txt");
ofstream coutt("1805006_token.txt");
SymbolTable* ST = new SymbolTable(7); 
int errcount = 0;
string str = "";
%}



AlphaNumeric [a-zA-Z0-9]
IDbegin [a-zA-Z_]
Alpha [a-zA-Z]
allASCII [ -~]

digit [0-9]
digits {digit}+
firstOp [+-]?
deci (.{digits})?
expo ("E"[+-]?{digits})?
numBegin ({digits})
newline (\r\n|\n)
nostar [^*]
starnoslash \*[^/]
noslash [^\]
specials [ntafrbv0\'\"\\]



%%
(\/\*) {
    multicomm = "";
    multicomm += yytext;
    BEGIN MULCOMM;
}

<MULCOMM>(({nostar})*|({starnoslash})*)* {
    multicomm += yytext;
} 
<MULCOMM>(\*\/) {
    multicomm += yytext;
    char s3[multicomm.length()+1];  
    strcpy(s3,multicomm.c_str());
    char *s2 = s3;
    int countnewline = 0;
    while(*s2!='\0'){
        if(*s2 == '\n'){
            countnewline++;
        }
        s2++;
    }
    token = "COMMENT";
    coutf<<"Line no "<<yylineno-countnewline<< ": ";
    coutf<<"Token <"<< token <<"> Lexeme "<< multicomm <<" found"<<endl<<endl;
    BEGIN INITIAL;
}
<MULCOMM><<EOF>> {
    char s3[multicomm.length()+1];  
    strcpy(s3,multicomm.c_str());
    char *s2 = s3;
    int countnewline = 0;
    while(*s2!='\0'){
        if(*s2 == '\n'){
            countnewline++;
        }
        s2++;
    }
    coutf<<"Error at Line no "<<yylineno-countnewline<< ": ";
    coutf<<"Unterminated comment "<<multicomm<<endl<<endl;
    errcount++;
    ST->printAll2(coutf);
    return 0;
}


\/\/([^\n]*(\\{newline})?)* {
    char *s2 = yytext;
    int countnewline = 0;
    while(*s2!='\0'){
        if(*s2 == '\n'){
            countnewline++;
        }
        s2++;
    }
    if(*(s2-1) == 13){
        *(s2-1) = '\0';
    }
    token = "COMMENT";
    coutf<<"Line no "<<yylineno-countnewline<< ": ";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found"<<endl<<endl;
}




(\")([^\\\n\"]*(\\(({newline})|({AlphaNumeric})|[\\\"\']))*)*(\") {
    char *s2 = yytext;
    int countnewline = 0;
    while(*s2!='\0'){
        if(*s2 == '\n'){
            countnewline++;
        }
        s2++;
    }
    
    int fl=0;
    char *s = yytext;
    char *ans = new char[10000];
    char *res = ans;
    string temp = yytext;
    for(int i=0;i<temp.length();i++){
        while(*s){
            if(*s == '\\'){
                if(*(s+1) == 'n'){
                    s++;
                    *ans = '\n';
                }
                else if(*(s+1) == 't'){
                    s++;
                    *ans = '\t';
                }
                else if(*(s+1) == 'a'){
                    s++;
                    *ans = '\a';
                }
                else if(*(s+1) == 'f'){
                    s++;
                    *ans = '\f';
                }
                else if(*(s+1) == 'b'){
                    s++;
                    *ans = '\b';
                }
                else if(*(s+1) == 'v'){
                    s++;
                    *ans = '\v';
                }
                else if(*(s+1) == 'r'){
                    s++;
                    *ans = '\r';
                }
                else if(*(s+1) == '\"'){
                    s++;
                    *ans = '\"';
                }
                else if(*(s+1) == '\\'){
                    s++;
                    *ans = '\\';
                }
                else if(*(s+1) == '\''){
                    s++;
                    *ans = '\'';
                }
                else if(*(s+1) == '\n'){
                    ans--;
                }
                else if(*(s+1) == '\r'){
                    ans--;
                }
                else{
                    fl++;
                }

            }
            else{
                if(*s == 10 || *s == 13){
                    
                    ans--;
                    if(*ans == '\r'){
                        ans--;
                    }
                }
                else{
                    
                    *ans = *s;
                }
            }
            ans++;
            s++;
        }
    }
    *ans = '\0';
    if(fl!=0){
        coutf<<"Error at line no "<<yylineno<< ": ";
        coutf<<"Unrecognized Ascii character present in lexeme "<<yytext<<endl<<endl;
        errcount++;
    }
    else{
        temp = res;
        coutf<<"Line no "<<yylineno-countnewline<< ": ";
        coutf<<"Token <STRING> Lexeme "<< yytext <<" found --> ";
        coutf<<"<STRING, "<< temp<<">"<<endl<<endl;
        coutt<<"<STRING, "<< temp<<"> ";

    }

}
(\")([^\\\n\"]*(\\(({newline})|({AlphaNumeric}|[\\\"\'])))*)* {
    coutf<<"Error at line no "<<yylineno<< ": ";
    coutf<<"Unterminated string "<< yytext<<endl<<endl;
    errcount++;
}





"if" 				{
                    	coutf<<"Line no "<<yylineno<< ": Token <" << "IF"<< "> Lexeme "<< "if" <<" found"<<endl<<endl;
                        coutt<<"<IF> ";
					}
"else" 				{
                    	coutf<<"Line no "<<yylineno<< ": Token <" << "ELSE"<< "> Lexeme "<< "else" <<" found"<<endl<<endl;
                        coutt<<"<ELSE> ";
					}
"for"  				{
                    	coutf<<"Line no "<<yylineno<< ": Token <" << "FOR"<< "> Lexeme "<< "for" <<" found"<<endl<<endl;
                        coutt<<"<FOR> ";
					}
"while" 			{
                    	coutf<<"Line no "<<yylineno<< ": Token <" << "WHILE"<< "> Lexeme "<< "while" <<" found"<<endl<<endl;
                        coutt<<"<WHILE> ";
					}
"do"  				{
                    	coutf<<"Line no "<<yylineno<< ": Token <" << "DO"<< "> Lexeme "<< "do" <<" found"<<endl<<endl;
                        coutt<<"<DO> ";
					}	
"break" 			{
                    	coutf<<"Line no "<<yylineno<< ": Token <" << "BREAK"<< "> Lexeme "<< "break" <<" found"<<endl<<endl;
                        coutt<<"<BREAK> ";
					}
"int"  				{
                    	coutf<<"Line no "<<yylineno<< ": Token <" << "INT"<< "> Lexeme "<< "int" <<" found"<<endl<<endl;
                        coutt<<"<INT> ";
					}
"char" 				{
                    	coutf<<"Line no "<<yylineno<< ": Token <" << "CHAR"<< "> Lexeme "<< "char" <<" found"<<endl<<endl;
                        coutt<<"<CHAR> ";
					}
"float"  			{
                    	coutf<<"Line no "<<yylineno<< ": Token <" << "FLOAT"<< "> Lexeme "<< "float" <<" found"<<endl<<endl;
                        coutt<<"<FLOAT> ";
					}
"double" 			{
                    	coutf<<"Line no "<<yylineno<< ": Token <" << "DOUBLE"<< "> Lexeme "<< "double" <<" found"<<endl<<endl;
                        coutt<<"<DOUBLE> ";
					}
"void"  			{
                    	coutf<<"Line no "<<yylineno<< ": Token <" << "VOID"<< "> Lexeme "<< "void" <<" found"<<endl<<endl;
                        coutt<<"<VOID> ";
					}	
"return" 			{
                    	coutf<<"Line no "<<yylineno<< ": Token <" << "RETURN"<< "> Lexeme "<< "return" <<" found"<<endl<<endl;
                        coutt<<"<RETURN> ";
					}
"switch"  			{
                    	coutf<<"Line no "<<yylineno<< ": Token <" << "SWITCH"<< "> Lexeme "<< "switch" <<" found"<<endl<<endl;
                        coutt<<"<SWITCH> ";
					}
"case" 				{
                    	coutf<<"Line no "<<yylineno<< ": Token <" << "CASE"<< "> Lexeme "<< "case" <<" found"<<endl<<endl;
                        coutt<<"<CASE> ";
					}
"default"  			{
                    	coutf<<"Line no "<<yylineno<< ": Token <" << "DEFAULT"<< "> Lexeme "<< "default" <<" found"<<endl<<endl;
                        coutt<<"<DEFAULT> ";
					}
"continue" 			{
                    	coutf<<"Line no "<<yylineno<< ": Token <" << "CONTINUE"<< "> Lexeme "<< "continue" <<" found"<<endl<<endl;
                        coutt<<"<CONTINUE> ";
					}
[ \t\r\n]+ {}



{numBegin}"."({digit}*)"."("."|{digit})* {
    coutf<<"Error at line no "<<yylineno<< ": ";
    coutf<<"Too many decimal points "<< yytext<<endl<<endl;
    errcount++;
}
{numBegin}("."({digit}*))(E)({firstOp}{numBegin})"."({digit})* {
    coutf<<"Error at line no "<<yylineno<< ": "; 
    coutf<<"Ill formed Number "<< yytext <<endl<<endl;
    errcount++;
}
{numBegin}(E)({firstOp}{numBegin})"."({digit})* {
    coutf<<"Error at line no "<<yylineno<< ": "; 
    coutf<<"Ill formed Number "<< yytext <<endl<<endl;
    errcount++;
}
{numBegin} {
    token = "CONST_INT";
    coutf<<"Line no "<<yylineno<<": ";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found"<<endl<<endl;
    tempSI =  new SymbolInfo(yytext, token);
    ST->Insert(tempSI,coutf);
    coutt<<"<"<<token<<", "<< yytext<<"> ";
}
[0-9]+"."[0-9]*"E"[+-]?[0-9]+ {
    token = "CONST_FLOAT";
    coutf<<"Line no "<<yylineno<<": ";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found"<<endl<<endl;
    tempSI =  new SymbolInfo(yytext, token);
    ST->Insert(tempSI,coutf);
    coutt<<"<"<<token<<", "<< yytext<<"> ";
}
[0-9]+"E"[+-]?[0-9]+ {
    token = "CONST_FLOAT";
    coutf<<"Line no "<<yylineno<<": ";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found"<<endl<<endl;
    tempSI =  new SymbolInfo(yytext, token);
    ST->Insert(tempSI,coutf);
    coutt<<"<"<<token<<", "<< yytext<<"> ";
}
[0-9]+"."[0-9]* {
    token = "CONST_FLOAT";
    coutf<<"Line no "<<yylineno<<": ";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found"<<endl<<endl;
    tempSI =  new SymbolInfo(yytext, token);
    ST->Insert(tempSI,coutf);
    coutt<<"<"<<token<<", "<< yytext<<"> ";
}
"."[0-9]+"E"[+-]?[0-9]+ {
    token = "CONST_FLOAT";
    coutf<<"Line no "<<yylineno<<": ";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found"<<endl<<endl;
    tempSI =  new SymbolInfo(yytext, token);
    ST->Insert(tempSI,coutf);
    coutt<<"<"<<token<<", "<< yytext<<"> ";
}
"."[0-9]+ {
    token = "CONST_FLOAT";
    coutf<<"Line no "<<yylineno<<": ";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found"<<endl<<endl;
    tempSI =  new SymbolInfo(yytext, token);
    ST->Insert(tempSI,coutf);
    coutt<<"<"<<token<<", "<< yytext<<"> ";
}
{numBegin}["."]?({Alpha})+({AlphaNumeric}|".")* {
    coutf<<"Error at line no "<<yylineno<< ": ";
    coutf<<"Invalid prefix on ID or invalid suffix on Number "<< yytext <<endl<<endl;
    errcount++;
}
[0-9]+"."[0-9]*"E"[+-]?[0-9]+["."]?({Alpha})+({AlphaNumeric}|".")* {
    coutf<<"Error at line no "<<yylineno<< ": ";
    coutf<<"Invalid prefix on ID or invalid suffix on Number "<< yytext <<endl<<endl;
    errcount++;
}
[0-9]+"."[0-9]*["."]?({Alpha})+({AlphaNumeric}|".")* {
    coutf<<"Error at line no "<<yylineno<< ": ";
    coutf<<"Invalid prefix on ID or invalid suffix on Number "<< yytext <<endl<<endl;
    errcount++;
}
"."[0-9]+"E"[+-]?[0-9]+["."]?({Alpha})+({AlphaNumeric}|".")* {
    coutf<<"Error at line no "<<yylineno<< ": ";
    coutf<<"Invalid prefix on ID or invalid suffix on Number "<< yytext <<endl<<endl;
    errcount++;
}
"."[0-9]+["."]?({Alpha})+({AlphaNumeric}|".")* {
    coutf<<"Error at line no "<<yylineno<< ": ";
    coutf<<"Invalid prefix on ID or invalid suffix on Number "<< yytext <<endl<<endl;
    errcount++;
}






'[^'\\\a\n\r\b\v\t\f\0]' {
    coutf<<"Line no "<<yylineno<<": ";
    token = "CONST_CHAR";
    
    str = yytext;

    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found ";
    yytext[0] = yytext[1];
    yytext[1] = '\0';
    coutf<<"--> <"<<token<<", "<<yytext<<">"<<endl<<endl;

    coutt<<"<"<<token<<", "<< yytext<<"> ";

    tempSI =  new SymbolInfo(str, token);
    ST->Insert(tempSI,coutf);

    
    
}

'\\\\' {
    coutf<<"Line no "<<yylineno<<": ";
    token = "CONST_CHAR";
    str = yytext;

    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found ";

    yytext[0] = yytext[2];
    yytext[1] = '\0';
    
    coutf<<"--> <"<<token<<", "<<yytext<<">"<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
    tempSI =  new SymbolInfo(str, token);
    ST->Insert(tempSI,coutf);
}
'\\\'' {
    coutf<<"Line no "<<yylineno<<": ";
    token = "CONST_CHAR";
    str = yytext;

    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found ";
    yytext[0] = yytext[2];
    yytext[1] = '\0';
    coutf<<"--> <"<<token<<", "<<yytext<<">"<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
    tempSI =  new SymbolInfo(str, token);
    ST->Insert(tempSI,coutf);
}

'\\n' {
    coutf<<"Line no "<<yylineno<<": ";
    token = "CONST_CHAR";
    str = yytext;

    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found ";
    yytext[0] = '\n';
    yytext[1] = '\0';
    coutf<<"--> <"<<token<<", "<<yytext<<">"<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
    tempSI =  new SymbolInfo(str, token);
    ST->Insert(tempSI,coutf);
}
'\\t' {
    coutf<<"Line no "<<yylineno<<": ";
    token = "CONST_CHAR";
    str = yytext;

    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found ";
    yytext[0] = '\t';
    yytext[1] = '\0';
    coutf<<"--> <"<<token<<", "<<yytext<<">"<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
    tempSI =  new SymbolInfo(str, token);
    ST->Insert(tempSI,coutf);
}
'\\a' {
    coutf<<"Line no "<<yylineno<<": ";
    token = "CONST_CHAR";
    str = yytext;
    
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found ";
    yytext[0] = '\a';
    yytext[1] = '\0';
    coutf<<"--> <"<<token<<", "<<yytext<<">"<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
    tempSI =  new SymbolInfo(str, token);
    ST->Insert(tempSI,coutf);
}
'\\f' {
    coutf<<"Line no "<<yylineno<<": ";
    token = "CONST_CHAR";
    str = yytext;

    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found ";
    yytext[0] = '\f';
    yytext[1] = '\0';
    coutf<<"--> <"<<token<<", "<<yytext<<">"<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
    tempSI =  new SymbolInfo(str, token);
    ST->Insert(tempSI,coutf);
}
'\\r' {
    coutf<<"Line no "<<yylineno<<": ";
    token = "CONST_CHAR";
    str = yytext;

    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found ";
    yytext[0] = '\r';
    yytext[1] = '\0';
    coutf<<"--> <"<<token<<", "<<yytext<<">"<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
    tempSI =  new SymbolInfo(str, token);
    ST->Insert(tempSI,coutf);
}
'\\b' {
    coutf<<"Line no "<<yylineno<<": ";
    token = "CONST_CHAR";
    str = yytext;
    
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found ";
    yytext[0] = '\b';
    yytext[1] = '\0';
    coutf<<"--> <"<<token<<", "<<yytext<<">"<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
    tempSI =  new SymbolInfo(str, token);
    ST->Insert(tempSI,coutf);
}
'\\v' {
    coutf<<"Line no "<<yylineno<<": ";
    token = "CONST_CHAR";
    str = yytext;

    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found ";
    yytext[0] = '\v';
    yytext[1] = '\0';
    coutf<<"--> <"<<token<<", "<<yytext<<">"<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
    tempSI =  new SymbolInfo(str, token);
    ST->Insert(tempSI,coutf);
}
'\\0' {
    coutf<<"Line no "<<yylineno<<": ";
    token = "CONST_CHAR";
    str = yytext;

    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found ";
    yytext[0] = '\0';
    yytext[1] = '\0';
    coutf<<"--> <"<<token<<", "<<yytext<<">"<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
    tempSI =  new SymbolInfo(str, token);
    ST->Insert(tempSI,coutf);
}
'' {
    coutf<<"Error at line no "<<yylineno<< ": ";
    coutf<<"Empty character constant error "<<yytext<<endl<<endl;
    errcount++;
}
'\\[^\\'ntafrbv0]' {
    coutf<<"Error at line no "<<yylineno<< ": ";
    coutf<<"No corresponding ASCII hex code for "<<yytext<<endl<<endl;
    errcount++;
}
'[^'\\][^'\n]+' {
    coutf<<"Error at line no "<<yylineno<< ": ";
    coutf<<"Multi character constant error "<<yytext<<endl<<endl;
    errcount++;
}
'[^'\\][^'\n]* {
    coutf<<"Error at line no "<<yylineno<< ": ";
    coutf<<"Unterminated character "<<yytext<<endl<<endl;
    errcount++;
}

'\\'[^'\n]* {
    coutf<<"Error at line no "<<yylineno<< ": ";
    coutf<<"Unterminated character "<<yytext<<endl<<endl;
    errcount++;
}
'\\[^'\n]* {
    coutf<<"Error at line no "<<yylineno<< ": ";
    coutf<<"Unterminated character "<<yytext<<endl<<endl;
    errcount++;
}
'\\[^'\n]*' {
    coutf<<"Error at line no "<<yylineno<< ": ";
    coutf<<"Multi character constant error "<<yytext<<endl<<endl;
    errcount++;
}
'[ -~]? {
    coutf<<"Error at line no "<<yylineno<< ": ";
    coutf<<"Unfinished Character "<<yytext<<endl<<endl;
    errcount++;
}





"++"|"--" {
    coutf<<"Line no "<<yylineno<<": ";
    token = "INCOP";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found "<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
}
"<="|">="|"=="|"!="|">"|"<" {
    coutf<<"Line no "<<yylineno<<": ";
    token = "RELOP";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found "<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
}
"&&"|"||" {
    coutf<<"Line no "<<yylineno<<": ";
    token = "LOGICOP";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found "<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
}
"+"|"-" {
    coutf<<"Line no "<<yylineno<<": ";
    token = "ADDOP";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found "<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
}
"*"|"/"|"%" {
    coutf<<"Line no "<<yylineno<<": ";
    token = "MULOP";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found "<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
}
"=" {
    coutf<<"Line no "<<yylineno<<": ";
    token = "ASSIGNOP";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found "<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
}
"!" {
    coutf<<"Line no "<<yylineno<<": ";
    token = "NOT";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found "<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
}
"(" {
    coutf<<"Line no "<<yylineno<<": ";
    token = "LPAREN";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found "<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
}
")" {
    coutf<<"Line no "<<yylineno<<": ";
    token = "RPAREN";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found "<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
}
"[" {
    coutf<<"Line no "<<yylineno<<": ";
    token = "LTHIRD";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found "<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
}
"]" {
    coutf<<"Line no "<<yylineno<<": ";
    token = "RTHIRD";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found "<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
}
"," {
    coutf<<"Line no "<<yylineno<<": ";
    token = "COMMA";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found "<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
}
";" {
    coutf<<"Line no "<<yylineno<<": ";
    token = "SEMICOLON";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found "<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
}
"{" {
    coutf<<"Line no "<<yylineno<<": ";
    token = "LCURL";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found "<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
    ST->enterScope();
}
"}" {
    coutf<<"Line no "<<yylineno<<": ";
    token = "RCURL";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found "<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
    ST->deleteScope(coutf);
}











{IDbegin}({AlphaNumeric}|_)* 	{
                                token = "ID";
                                coutf<<"Line no "<<yylineno<<": ";
                                coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found"<<endl<<endl;
                                tempSI =  new SymbolInfo(yytext, token);
                                ST->Insert(tempSI,coutf);
                                coutt<<"<"<<token<<", "<< yytext<<"> ";
                            }
                            
[0-9]+({AlphaNumeric}|_)* 	{
                                coutf<<"Error at Line no "<<yylineno<<": ";
                                coutf<<"Invalid ID"<<endl;
                            }
                            





<<EOF>>               {
    
    ST->printAll2(coutf);
    return 0;}
. {
    coutf<<"Error at line no "<<yylineno<< ": ";
    coutf<<"Unrecognized character "<<yytext <<endl<<endl;
    errcount++;
}

%%
int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	

	yyin= fin;
    yylineno = 1;
	yylex();
    coutf<<"Total lines: "<<yylineno<<endl;
    coutf<<"Total errors: "<<errcount<<endl;
	fclose(yyin);
    coutf.close();
    coutt.close();
	return 0;
}
