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
#include "y.tab.h"
using namespace std;


SymbolInfo* tempSI;
string token;
string type;
string lexeme;
string temp;
string multicomm;
ofstream coutf("1805006_log2.txt");
ofstream coutt("1805006_token2.txt");
ofstream couterr("1805006_error.txt");
extern ofstream coutf2;
extern SymbolTable* ST; 
extern bool notexists;
extern int begfuncline;
extern int endfuncline;
int errcount = 0;
string str = "";

void yyerror(char *);
extern YYSTYPE yylval;

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
    couterr<<"Syntax Error at Line no "<<yylineno-countnewline<< ": ";
    couterr<<"Unterminated comment "<<multicomm<<endl<<endl;
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
        couterr<<"Syntax Error at line no "<<yylineno<< ": ";
        couterr<<"Unrecognized Ascii character present in lexeme "<<yytext<<endl<<endl;
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
    couterr<<"Syntax Error at line no "<<yylineno<< ": ";
    couterr<<"Unterminated string "<< yytext<<endl<<endl;
    errcount++;
}





"if" 				{
                    	coutf<<"Line no "<<yylineno<< ": Token <" << "IF"<< "> Lexeme "<< "if" <<" found"<<endl<<endl;
                        coutt<<"<IF> ";
                        return IF;
					}
"else" 				{
                    	coutf<<"Line no "<<yylineno<< ": Token <" << "ELSE"<< "> Lexeme "<< "else" <<" found"<<endl<<endl;
                        coutt<<"<ELSE> ";
                        return ELSE;
					}
"for"  				{
                    	coutf<<"Line no "<<yylineno<< ": Token <" << "FOR"<< "> Lexeme "<< "for" <<" found"<<endl<<endl;
                        coutt<<"<FOR> ";
                        return FOR;
					}
"while" 			{
                    	coutf<<"Line no "<<yylineno<< ": Token <" << "WHILE"<< "> Lexeme "<< "while" <<" found"<<endl<<endl;
                        coutt<<"<WHILE> ";
                        return WHILE;
					}
"do"  				{
                    	coutf<<"Line no "<<yylineno<< ": Token <" << "DO"<< "> Lexeme "<< "do" <<" found"<<endl<<endl;
                        coutt<<"<DO> ";
                        return DO;
					}	
"break" 			{
                    	coutf<<"Line no "<<yylineno<< ": Token <" << "BREAK"<< "> Lexeme "<< "break" <<" found"<<endl<<endl;
                        coutt<<"<BREAK> ";
                        return BREAK;
					}
"int"  				{
                    	coutf<<"Line no "<<yylineno<< ": Token <" << "INT"<< "> Lexeme "<< "int" <<" found"<<endl<<endl;
                        coutt<<"<INT> ";
                        return INT;
					}
"char" 				{
                    	coutf<<"Line no "<<yylineno<< ": Token <" << "CHAR"<< "> Lexeme "<< "char" <<" found"<<endl<<endl;
                        coutt<<"<CHAR> ";
                        return CHAR;
					}
"float"  			{
                    	coutf<<"Line no "<<yylineno<< ": Token <" << "FLOAT"<< "> Lexeme "<< "float" <<" found"<<endl<<endl;
                        coutt<<"<FLOAT> ";
                        return FLOAT;
					}
"double" 			{
                    	coutf<<"Line no "<<yylineno<< ": Token <" << "DOUBLE"<< "> Lexeme "<< "double" <<" found"<<endl<<endl;
                        coutt<<"<DOUBLE> ";
                        return DOUBLE;
					}
"void"  			{
                    	coutf<<"Line no "<<yylineno<< ": Token <" << "VOID"<< "> Lexeme "<< "void" <<" found"<<endl<<endl;
                        coutt<<"<VOID> ";
                        return VOID;
					}	
"return" 			{
                    	coutf<<"Line no "<<yylineno<< ": Token <" << "RETURN"<< "> Lexeme "<< "return" <<" found"<<endl<<endl;
                        coutt<<"<RETURN> ";
                        return RETURN;
					}
"switch"  			{
                    	coutf<<"Line no "<<yylineno<< ": Token <" << "SWITCH"<< "> Lexeme "<< "switch" <<" found"<<endl<<endl;
                        coutt<<"<SWITCH> ";
                        return SWITCH;
					}
"case" 				{
                    	coutf<<"Line no "<<yylineno<< ": Token <" << "CASE"<< "> Lexeme "<< "case" <<" found"<<endl<<endl;
                        coutt<<"<CASE> ";
                        return CASE;
					}
"default"  			{
                    	coutf<<"Line no "<<yylineno<< ": Token <" << "DEFAULT"<< "> Lexeme "<< "default" <<" found"<<endl<<endl;
                        coutt<<"<DEFAULT> ";
                        return DEFAULT;
					}
"continue" 			{
                    	coutf<<"Line no "<<yylineno<< ": Token <" << "CONTINUE"<< "> Lexeme "<< "continue" <<" found"<<endl<<endl;
                        coutt<<"<CONTINUE> ";
                        return CONTINUE;
					}
"println" 			{
                    	coutf<<"Line no "<<yylineno<< ": Token <" << "PRINTLN"<< "> Lexeme "<< "println" <<" found"<<endl<<endl;
                        coutt<<"<PRINTLN> ";
                        return PRINTLN;
					}
[ \t\r\n]+ {}



{numBegin}"."({digit}*)"."("."|{digit})* {
    couterr<<"Syntax Error at line no "<<yylineno<< ": ";
    couterr<<"Too many decimal points "<< yytext<<endl<<endl;
    errcount++;
}
{numBegin}("."({digit}*))(E)({firstOp}{numBegin})"."({digit})* {
    couterr<<"Syntax Error at line no "<<yylineno<< ": "; 
    couterr<<"Ill formed Number "<< yytext <<endl<<endl;
    errcount++;
}
{numBegin}(E)({firstOp}{numBegin})"."({digit})* {
    couterr<<"Syntax Error at line no "<<yylineno<< ": "; 
    couterr<<"Ill formed Number "<< yytext <<endl<<endl;
    errcount++;
}
{numBegin} {
    token = "CONST_INT";
    coutf<<"Line no "<<yylineno<<": ";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found"<<endl<<endl;
    tempSI =  new SymbolInfo(yytext, token);

    tempSI->setVal(yytext);
    
    coutt<<"<"<<token<<", "<< yytext<<"> ";
    yylval.SI =  tempSI;
    return CONST_INT;
}
[0-9]+"."[0-9]*"E"[+-]?[0-9]+ {
    token = "CONST_FLOAT";
    coutf<<"Line no "<<yylineno<<": ";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found"<<endl<<endl;
    tempSI =  new SymbolInfo(yytext, token);
    
    tempSI->setVal(yytext);

    coutt<<"<"<<token<<", "<< yytext<<"> ";
    yylval.SI =  tempSI;
    return CONST_FLOAT;
}
[0-9]+"E"[+-]?[0-9]+ {
    token = "CONST_FLOAT";
    coutf<<"Line no "<<yylineno<<": ";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found"<<endl<<endl;
    tempSI =  new SymbolInfo(yytext, token);
    
    tempSI->setVal(yytext);

    coutt<<"<"<<token<<", "<< yytext<<"> ";
    yylval.SI =  tempSI;
    return CONST_FLOAT;
}
[0-9]+"."[0-9]* {
    token = "CONST_FLOAT";
    coutf<<"Line no "<<yylineno<<": ";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found"<<endl<<endl;
    tempSI =  new SymbolInfo(yytext, token);
    
    tempSI->setVal(yytext);

    coutt<<"<"<<token<<", "<< yytext<<"> ";
    yylval.SI =  tempSI;
    return CONST_FLOAT;
}
"."[0-9]+"E"[+-]?[0-9]+ {
    token = "CONST_FLOAT";
    coutf<<"Line no "<<yylineno<<": ";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found"<<endl<<endl;
    tempSI =  new SymbolInfo(yytext, token);
    
    tempSI->setVal(yytext);

    coutt<<"<"<<token<<", "<< yytext<<"> ";
    yylval.SI =  tempSI;
    return CONST_FLOAT;
}
"."[0-9]+ {
    token = "CONST_FLOAT";
    coutf<<"Line no "<<yylineno<<": ";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found"<<endl<<endl;
    tempSI =  new SymbolInfo(yytext, token);
    
    tempSI->setVal(yytext);

    coutt<<"<"<<token<<", "<< yytext<<"> ";
    yylval.SI =  tempSI;
    return CONST_FLOAT;
}
{numBegin}["."]?({Alpha})+({AlphaNumeric}|".")* {
    couterr<<"Syntax Error at line no "<<yylineno<< ": ";
    couterr<<"Invalid prefix on ID or invalid suffix on Number "<< yytext <<endl<<endl;
    errcount++;
}
[0-9]+"."[0-9]*"E"[+-]?[0-9]+["."]?({Alpha})+({AlphaNumeric}|".")* {
    couterr<<"Syntax Error at line no "<<yylineno<< ": ";
    couterr<<"Invalid prefix on ID or invalid suffix on Number "<< yytext <<endl<<endl;
    errcount++;
}
[0-9]+"."[0-9]*["."]?({Alpha})+({AlphaNumeric}|".")* {
    couterr<<"Syntax Error at line no "<<yylineno<< ": ";
    couterr<<"Invalid prefix on ID or invalid suffix on Number "<< yytext <<endl<<endl;
    errcount++;
}
"."[0-9]+"E"[+-]?[0-9]+["."]?({Alpha})+({AlphaNumeric}|".")* {
    couterr<<"Syntax Error at line no "<<yylineno<< ": ";
    couterr<<"Invalid prefix on ID or invalid suffix on Number "<< yytext <<endl<<endl;
    errcount++;
}
"."[0-9]+["."]?({Alpha})+({AlphaNumeric}|".")* {
    couterr<<"Syntax Error at line no "<<yylineno<< ": ";
    couterr<<"Invalid prefix on ID or invalid suffix on Number "<< yytext <<endl<<endl;
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

    yylval.SI =  tempSI;
    return CONST_CHAR;

    
    
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

    yylval.SI =  tempSI;
    return CONST_CHAR;
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

    yylval.SI =  tempSI;
    return CONST_CHAR;
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

    yylval.SI =  tempSI;
    return CONST_CHAR;
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

    yylval.SI =  tempSI;
    return CONST_CHAR;
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

    yylval.SI =  tempSI;
    return CONST_CHAR;
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

    yylval.SI =  tempSI;
    return CONST_CHAR;
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

    yylval.SI =  tempSI;
    return CONST_CHAR;
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

    yylval.SI =  tempSI;
    return CONST_CHAR;
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

    yylval.SI =  tempSI;
    return CONST_CHAR;
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

    yylval.SI =  tempSI;
    return CONST_CHAR;
}
'' {
    couterr<<"Syntax Error at line no "<<yylineno<< ": ";
    couterr<<"Empty character constant error "<<yytext<<endl<<endl;
    errcount++;
}
'\\[^\\'ntafrbv0]' {
    couterr<<"Syntax Error at line no "<<yylineno<< ": ";
    couterr<<"No corresponding ASCII hex code for "<<yytext<<endl<<endl;
    errcount++;
}
'[^'\\][^'\n]+' {
    couterr<<"Syntax Error at line no "<<yylineno<< ": ";
    couterr<<"Multi character constant error "<<yytext<<endl<<endl;
    errcount++;
}
'[^'\\][^'\n]* {
    couterr<<"Syntax Error at line no "<<yylineno<< ": ";
    couterr<<"Unterminated character "<<yytext<<endl<<endl;
    errcount++;
}

'\\'[^'\n]* {
    couterr<<"Syntax Error at line no "<<yylineno<< ": ";
    couterr<<"Unterminated character "<<yytext<<endl<<endl;
    errcount++;
}
'\\[^'\n]* {
    couterr<<"Syntax Error at line no "<<yylineno<< ": ";
    couterr<<"Unterminated character "<<yytext<<endl<<endl;
    errcount++;
}
'\\[^'\n]*' {
    couterr<<"Syntax Error at line no "<<yylineno<< ": ";
    couterr<<"Multi character constant error "<<yytext<<endl<<endl;
    errcount++;
}
'[ -~]? {
    couterr<<"Syntax Error at line no "<<yylineno<< ": ";
    couterr<<"Unfinished Character "<<yytext<<endl<<endl;
    errcount++;
}





"++" {
    coutf<<"Line no "<<yylineno<<": ";
    token = "INCOP";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found "<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
    tempSI = new SymbolInfo(yytext, token);
    yylval.SI =  tempSI;
    return INCOP;
}
"--" {
    coutf<<"Line no "<<yylineno<<": ";
    token = "DECOP";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found "<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
    tempSI = new SymbolInfo(yytext, token);
    yylval.SI =  tempSI;
    return DECOP;
}
"<="|">="|"=="|"!="|">"|"<" {
    coutf<<"Line no "<<yylineno<<": ";
    token = "RELOP";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found "<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
    tempSI = new SymbolInfo(yytext, token);
    yylval.SI =  tempSI;
    return RELOP;
}
"&&"|"||" {
    coutf<<"Line no "<<yylineno<<": ";
    token = "LOGICOP";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found "<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
    tempSI = new SymbolInfo(yytext, token);
    yylval.SI =  tempSI;
    return LOGICOP;
}
"+"|"-" {
    coutf<<"Line no "<<yylineno<<": ";
    token = "ADDOP";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found "<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
    tempSI = new SymbolInfo(yytext, token);
    yylval.SI =  tempSI;
    return ADDOP;
}
"*"|"/"|"%" {
    coutf<<"Line no "<<yylineno<<": ";
    token = "MULOP";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found "<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
    tempSI = new SymbolInfo(yytext, token);
    yylval.SI =  tempSI;
    return MULOP;
}
"=" {
    coutf<<"Line no "<<yylineno<<": ";
    token = "ASSIGNOP";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found "<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
    
    return ASSIGNOP;
}
"!" {
    coutf<<"Line no "<<yylineno<<": ";
    token = "NOT";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found "<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
    return NOT;
}
"(" {
    coutf<<"Line no "<<yylineno<<": ";
    token = "LPAREN";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found "<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
    return LPAREN;
}
")" {
    coutf<<"Line no "<<yylineno<<": ";
    token = "RPAREN";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found "<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
    return RPAREN;
}
"[" {
    coutf<<"Line no "<<yylineno<<": ";
    token = "LTHIRD";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found "<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
    return LTHIRD;
}
"]" {
    coutf<<"Line no "<<yylineno<<": ";
    token = "RTHIRD";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found "<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
    return RTHIRD;
}
"," {
    coutf<<"Line no "<<yylineno<<": ";
    token = "COMMA";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found "<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
    tempSI = new SymbolInfo(yytext, token);
    return COMMA;
}
";" {
    coutf<<"Line no "<<yylineno<<": ";
    token = "SEMICOLON";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found "<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
    tempSI = new SymbolInfo(yytext, token);
    return SEMICOLON;
}
"{" {
    coutf<<"Line no "<<yylineno<<": ";
    token = "LCURL";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found "<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
    
    tempSI = new SymbolInfo(yytext, token);
    
    return LCURL;
}
"}" {
    coutf<<"Line no "<<yylineno<<": ";
    token = "RCURL";
    coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found "<<endl<<endl;
    coutt<<"<"<<token<<", "<< yytext<<"> ";
    
    tempSI = new SymbolInfo(yytext, token);
    
    return RCURL;
}











{IDbegin}({AlphaNumeric}|_)* 	{
                                token = "ID";
                                coutf<<"Line no "<<yylineno<<": ";
                                coutf<<"Token <"<< token <<"> Lexeme "<< yytext <<" found"<<endl<<endl;
                                tempSI =  new SymbolInfo(yytext, token);

                                coutt<<"<"<<token<<", "<< yytext<<"> ";



                                yylval.SI =  tempSI;
                            
                                return ID;
                            }
                            
[0-9]+({AlphaNumeric}|_)* 	{
                                couterr<<"Syntax Error at Line no "<<yylineno<<": ";
                                couterr<<"Invalid ID: "<<yytext<<endl<<endl;
                            }
                            





<<EOF>>               {
    
    ST->printAll2(coutf);
    return 0;
    }
. {
    couterr<<"Syntax Error at line no "<<yylineno<< ": ";
    couterr<<"Unrecognized character "<<yytext <<endl<<endl;
    errcount++;
}

%%

/*
int yywrap(void)
{
	return 1;
}
*/
/*
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
*/