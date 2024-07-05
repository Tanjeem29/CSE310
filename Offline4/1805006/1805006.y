%{
#include <bits/stdc++.h>
#include "1805006SymbolInfo.h"
#include "1805006Hash.h"
#include "1805006ScopeTable.h"
#include "1805006SymbolTable.h"
#include <fstream>
//#define YYSTYPE SymbolInfo*

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
extern int yylineno;
extern int errcount;
bool notexists;
SymbolInfo* check;
SymbolTable *ST = new SymbolTable(7);
string non_token = "";
SymbolInfo* returnType = new SymbolInfo("","");

vector<SymbolInfo*> varstore;
vector<SymbolInfo*> paramstore;
vector<SymbolInfo*> paramstoretemp;
vector<SymbolInfo*> argstore;
vector<SymbolInfo*> incOpVar;
vector<SymbolInfo*> decOpVar;
SymbolInfo* tempSI2;
int begfuncline;
int endfuncline;

//ICG
int labelCount=0;
int tempCount=0;
int notCount=0;
int relOpCount = 0;
int logicOpCount = 0;
int ifCount = -1; //will be 0 indexed
int loopCount = -1; //will be 0 indexed
int paramOffset=2;
int argOffset=0; //for refreshing arguments
int varOffset = 0;
int spVarOffset = 0;
int retVal = 0;
int isConst = 0;
int wasAssigned = 0;
string* cd = new string("");
string* cd2 = new string("");
string funcName;
vector<string> ifLabels;
vector<string> loopLabels;
string recurFuncName;
string codeCom;

//Optimize
vector<vector<string>> strings;
vector<string> linevect;


ofstream coutf2("1805006_log.txt");
//ofstream couterr("1805006_error.txt");
ofstream coutdummy("1805006_dummy.txt");
ofstream code("1805006_code3.txt");
ofstream code2("1805006_code2.txt");





extern ofstream couterr;
void yyerror(char *s)
{
	//write your code
}
string newLabel()
{
	string lb = "L";
	//strcpy(lb,"L");
	lb = lb + to_string(labelCount);
	labelCount++;
	return lb;
}
// string newNot()
// {
// 	string lb = "L";
// 	//strcpy(lb,"L");
// 	lb = lb + to_string(labelCount);
// 	labelCount++;
// 	return lb;
// }

string newTemp()
{
	string t = "t";
	//strcpy(lb,"L");
	t = t + to_string(tempCount);
	tempCount++;
	return t;
}
void loadVar(SymbolInfo * temp){// to BX
	cd = new string("");
	*cd += ("MOV BX , [BP+" + to_string(temp->getStackPos()) + "]\t\t\t; loading Variable "+temp->getName() +"\n");
	code<<*cd;
	//return cd;
}
void loadVar(SymbolInfo * temp, string str){
	cd = new string("");
	*cd += ("MOV "+str+", [BP+" + to_string(temp->getStackPos()) + "]\t\t\t; loading Variable "+temp->getName() +"\n");
	code<<*cd;
	//return cd;
}

//Optimize

void mySplit(string s, char delim, char delim2, int lineno)
{
    int cIdx = 0;
    int i = 0;
    int sIdx = 0;
    int eIdx = 0;
    linevect.clear();
    while (i <= s.length())
    {
        if (s[i] == delim || s[i] == delim2 || i == s.length())
        {
            eIdx = i;
            string sub = "";
            sub.append(s, sIdx, eIdx - sIdx);
            //strings.push_back();
            //strings[lineno].push_back(subStr);
            linevect.push_back(sub);
            cIdx += 1;
            sIdx = eIdx + 1;
        }
        i++;
    }
    strings.push_back(linevect);
}

%}
%union{
	SymbolInfo *SI;
} 

%token <SI> IF ELSE FOR WHILE ID LPAREN RPAREN SEMICOLON COMMA LCURL RCURL DOUBLE CHAR MAIN INT FLOAT VOID LTHIRD CONST_INT CONST_CHAR RTHIRD PRINTLN RETURN ASSIGNOP LOGICOP RELOP ADDOP MULOP CONST_FLOAT NOT INCOP DECOP 
%token <SI> SWITCH CASE DEFAULT DO BREAK CONTINUE


%type <SI> start program unit var_declaration func_declaration func_definition type_specifier parameter_list compound_statement statements declaration_list statement expression_statement expression variable logic_expression rel_expression simple_expression term unary_expression factor argument_list arguments dummy_if

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : { 
	//ICG
	codeCom = ";";
	codeCom += ("Line: " + to_string(yylineno)+ " - ");
	codeCom += "start : program";
	codeCom += "\n";
	code<<codeCom;


	cd = new string("");
	*cd += ".CODE\n";
	code<<*cd;

	//Global
	codeCom = ";";
	codeCom += ("Line: " + to_string(yylineno)+ " - ");
	codeCom += "Initializations";
	codeCom += "\n";
	code2<<codeCom;


	cd2 = new string("");
	*cd2 += ".MODEL SMALL\n";
	*cd2 += ".STACK 1000H\n";
	*cd2 += ".DATA\n\n";

	*cd2 += "CR EQU 0DH\n";	
	*cd2 += "LF EQU 0AH\n\n";	

	*cd2 += "OUTPUT_STRING DB '00000$'\n";	
	*cd2 += "PRINTNEGFLAG DW ? ; PRINTNEGFLAG\n\n";
	

	code2<<*cd2;


	//ICG, define println
	codeCom = ";";
	codeCom += ("Line: " + to_string(yylineno)+ " - ");
	codeCom += "func definition : println";
	codeCom += "\n";
	code<<codeCom;

	cd = new string("");
		*cd += "println PROC\n";
		*cd += "PUSH BP\n";
		*cd += "MOV BP , SP\n";
		*cd += "MOV AX , [BP+4]\n";

		*cd+= ("MOV PRINTNEGFLAG , 0\n"); 
    	*cd+= ("LEA SI , OUTPUT_STRING\n");
    	*cd+= ("ADD SI , 5\n");
    	*cd+= ("CMP AX , 0\n");
    	*cd+= ("JGE PRINT_LOOP\n");
    	*cd+= ("INC PRINTNEGFLAG\n");
    	*cd+= ("NEG AX\n");
    
    	*cd+= ("PRINT_LOOP:\n");
        *cd+= ("DEC SI\n");
        
        *cd+= ("MOV DX , 0\n");
        //; DX:AX = 0000:AX
        
        *cd+= ("MOV CX , 10\n");
        *cd+= ("DIV CX\n");
        
        *cd+= ("ADD DL , '0'\n");
        *cd+= ("MOV [SI] , DL\n");
        
        *cd+= ("CMP AX , 0\n");
        *cd+= ("JNE PRINT_LOOP\n");
    
    *cd+= ("CMP PRINTNEGFLAG , 0\n");
    *cd+= ("JE PRINTNUM\n");
    *cd+= ("MOV DX , '-'\n");
    *cd+= ("MOV AH , 2\n");
    *cd+= ("INT 21H\n");
    
    *cd+= ("PRINTNUM:\n");
    *cd+= ("MOV DX , SI\n");
    *cd+= ("MOV AH , 9\n");
    *cd+= ("INT 21H\n");
    
	//NEWLINE
	*cd+= ("MOV AH , 2\n");
	*cd+= ("MOV DL , CR\n");
	*cd+= ("INT 21H\n");
	*cd+= ("MOV DL , LF\n");
	*cd+= ("INT 21H\n");
	


		*cd += "POP BP\n";
		//*cd += "POP DX\n";	//NOSTACKTHEN COMMENT
		//*cd += "PUSH CX\n";	//NOSTACKTHEN COMMENT
		//*cd += "PUSH DX\n";	//NOSTACKTHEN COMMENT
		*cd += "RET 0\n";
		//*cd += "PUSH CX\n";				//NOSTACKTHEN UNCOMMENT
		*cd += ("println ENDP\n");
		code<<*cd;

} program
	{
		//write your code in this block in all the similar blocks below
		$$ = new SymbolInfo($2->getName() + " ", non_token);
		
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"start : program "<<endl<<endl;
		//coutf2<<$$->getName()<<endl<<endl;

		ST->printAll2(coutf2);  ///CHANGE TO PRINTALL2
		coutf2<<"Total lines: "<<yylineno<<endl<<endl;	
		coutf2<<"Total errors: "<<errcount<<endl<<endl;

		//coutf2<<"This is lineno "<<yylineno<<" ";
		//coutf2<<(string)$1<<endl<<endl;
	}
	;

program : program unit 	{
		$$ = new SymbolInfo($1->getName()+ " \n" + $2->getName(), non_token);

		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"program : program unit "<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
		//coutf2<<$1->getName()<<endl<<endl;
		//coutf2<<$3->getName()<<endl<<endl;
	}
	| unit {
		$$ = new SymbolInfo($1->getName(), non_token);

		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"program : unit "<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
	}
	;
	
unit : var_declaration	{
		$$ = new SymbolInfo($1->getName(), non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"unit : var_declaration "<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
	}	
    | func_declaration	{
		$$ = new SymbolInfo($1->getName(), non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"unit : func_declaration "<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
	}
    | func_definition	{
		$$ = new SymbolInfo($1->getName()+ "\n", non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"unit : func_definition "<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
	}
    ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
		//coutf2<<"GENJAAAAAM"<<endl<<endl;
		
		// cout<<"------"<<endl<<endl;
		// for(auto x: paramstore){
		// x->print();
		// }
		// cout<<"++++++"<<endl<<endl;
		string funcdatatype = $1->getName();
		tempSI2 = new SymbolInfo($2->getName(), "ID");
		tempSI2->setDataType(funcdatatype);		//int/float/void
		tempSI2->setVarType(2);					//2 for Func Declaration
		for(int i=0;i<paramstore.size();i++){
				tempSI2->addParam(paramstore[i]);
			}
			//cout<<paramstore.size()<<endl<<endl;
			//paramstore[0]->print();
		check = ST->LookUpBig(tempSI2->getName());
		if(check!=nullptr){
			 
			 couterr<<"Error at line "<<yylineno<<": Multiple declaration of "<< tempSI2->getName() <<endl<<endl;
			 coutf2<<"Error at line "<<yylineno<<": Multiple declaration of "<< tempSI2->getName() <<endl<<endl;
			 
			errcount++;
		}
		else{
			//tempSI2->print();
			ST->Insert(tempSI2, coutdummy);
			//tempSI2->print();
			//tempSI2 = ST->LookUpBig(tempSI2->getName());
			//tempSI2->print();
		}
		paramstore.clear();
		paramstoretemp.clear();




		$$ = new SymbolInfo($1->getName() + " " + $2->getName() + "(" + $4->getName() + ");" , non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
		
	}
		| type_specifier ID LPAREN RPAREN SEMICOLON							{
		//coutf2<<"GENJAAAAM2"<<endl<<endl;

		string funcdatatype = $1->getName();
		tempSI2 = new SymbolInfo($2->getName(), "ID");
		tempSI2->setDataType(funcdatatype);		//int/float/void
		tempSI2->setVarType(2);					//2 for Func Declaration
		//tempSI2->addParam(new SymbolInfo("void", non_token));
		check = ST->LookUpBig(tempSI2->getName());
		if(check!=nullptr){
			 
			 couterr<<"Error at line "<<yylineno<<": Multiple declaration of "<< tempSI2->getName() <<endl<<endl;
			 coutf2<<"Error at line "<<yylineno<<": Multiple declaration of "<< tempSI2->getName() <<endl<<endl;
			errcount++;
		}
		else{
			
			ST->Insert(tempSI2, coutdummy);
			//tempSI2->print();
		}
		paramstore.clear();

		$$ = new SymbolInfo($1->getName() + " "+ $2->getName() +"();" , non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
		paramstore.clear();
		paramstoretemp.clear();
	}
	//ERRORRECOVERY
	| type_specifier ID LPAREN error RPAREN SEMICOLON{
				yyclearin; /* discard lookahead */
 				yyerrok;
				errcount++;
				couterr<<"Syntax Error at line no "<<yylineno<<": in parameter list of function declaration" <<endl<<endl;
				coutf2<<"Syntax Error at line no "<<yylineno<<": in parameter list of function declaration" <<endl<<endl;
				//couterr<<"Line no: "<<yylineno<<"Error in Compound statement"<<endl;
		$$ = new SymbolInfo($1->getName() + " " + $2->getName() + "( *** );" , non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
		paramstore.clear();
		paramstoretemp.clear();
	}
		;

func_definition : type_specifier ID LPAREN parameter_list RPAREN 
	{
		//ICG!!!!
		
		// for(int i=0;i<paramstore.size();i++){
		// 		paramstore[i]->print();
		// }
		codeCom = ";";
		codeCom += ("Line: " + to_string(yylineno)+ " - ");
		codeCom += "func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement";
		codeCom += "\n";
		code<<codeCom;

		cd = new string("");
		*cd += $2->getName() + " PROC\n";
		*cd += "PUSH BP\n";
		*cd += "MOV BP , SP\n";
		if($2->getName() == "main"){
			*cd += "MOV AX , @DATA\n";
			*cd += "MOV DS , AX\n";
		}
		code<<*cd;
		spVarOffset = varOffset;
		varOffset = 0;
		//cout<<spVarOffset<<" "<<varOffset<<endl;
		//to be used in RETURN
		retVal = paramstore.size() * 2;
		funcName = $2->getName();
		recurFuncName = $2->getName();
		//cout<<recurFuncName<<endl;
		//cout<<retVal<<endl;
	}
	compound_statement {
		//coutf2<<"GENJAAAAAM3"<<endl<<endl;
		//$1 => typeSpec, $2 => ID, $4=> ParamList
		string funcdatatype = $1->getName(); 
		tempSI2 = new SymbolInfo($2->getName(), "ID");
		tempSI2->setDataType(funcdatatype);		//int/float/void
		tempSI2->setVarType(3);					//2 for Func Declaration
		for(int i=0;i<paramstore.size();i++){
				tempSI2->addParam(paramstore[i]);
			}

		check = ST->LookUpBig(tempSI2->getName());
		//check->print();
		//ST->printAll2(couterr);
		if(check!=nullptr){
			//check->print();
			if(check->getVarType() == 2){
				int fl = tempSI2->isUnequalFunc(check);
				//cout<<fl<<endl<<endl;
				if(fl == 0){
					ST->RemoveSymbolInfo(check);
					ST->Insert(tempSI2, coutdummy);
					
				}
				else if(fl == 1){
					 couterr<<"Error at line "<<yylineno - (endfuncline - begfuncline + 1)<<": Total number of parameters mismatch with declaration in function "<< tempSI2->getName() <<endl<<endl;
					 coutf2<<"Error at line "<<yylineno - (endfuncline - begfuncline + 1)<<": Total number of parameters mismatch with declaration in function "<< tempSI2->getName() <<endl<<endl;
					errcount++;
				}
				else if(fl == 2){
					 couterr<<"Error at line "<<yylineno - (endfuncline - begfuncline + 1)<<": Param DataType Mismatch "<< tempSI2->getName() <<endl<<endl;
					 coutf2<<"Error at line "<<yylineno - (endfuncline - begfuncline + 1)<<": Param DataType Mismatch "<< tempSI2->getName() <<endl<<endl;
					errcount++;
				}
				else if(fl == 3){
					 couterr<<"Error at line "<<yylineno - (endfuncline - begfuncline + 1)<<": Return type mismatch with function declaration in function "<< tempSI2->getName() <<endl<<endl;
					 coutf2<<"Error at line "<<yylineno - (endfuncline - begfuncline + 1)<<": Return type mismatch with function declaration in function "<< tempSI2->getName() <<endl<<endl;
					errcount++;
				}

			}
			else{
				 couterr<<"Error at line "<<yylineno - (endfuncline - begfuncline + 1)<<": Multiple declaration of "<< tempSI2->getName() <<endl<<endl;
				 coutf2<<"Error at line "<<yylineno - (endfuncline - begfuncline + 1)<<": Multiple declaration of "<< tempSI2->getName() <<endl<<endl;
				errcount++;
			}
			
		}
		else{
			if(returnType->getDataType() == tempSI2->getDataType() || (tempSI2->getDataType() == "float" && returnType->getDataType() == "int") || (tempSI2->getDataType() == "void" && returnType->getDataType() == "") ){
				ST->Insert(tempSI2, coutdummy);
				returnType ->setDataType("void");
			}
			else{
				couterr<<"Error at line "<<yylineno - (endfuncline - begfuncline + 1)<<": Return type mismatch of "<< tempSI2->getName() <<endl<<endl;
				 coutf2<<"Error at line "<<yylineno - (endfuncline - begfuncline + 1)<<": Return type mismatch of "<< tempSI2->getName() <<endl<<endl;
				errcount++;
				ST->Insert(tempSI2, coutdummy);
				cout<<returnType ->getDataType()<<endl;
				cout<<tempSI2 ->getDataType()<<endl;
				returnType ->setDataType("void");
			}
			//ST->printAll2(coutf2);
			//tempSI2->print();
		}
		paramstore.clear();
		paramstoretemp.clear();



		$$ = new SymbolInfo($1->getName() + " " + $2->getName() + "(" + $4->getName() + ")" + $7->getName() , non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;


		//ICG
		cd = new string("");
		*cd += funcName + "_exit:\n";
		*cd += "SUB SP , " + to_string(varOffset) + "\t\t\t\t\t;Popping local variables\n";
		*cd += "POP BP\n";
		*cd += "POP DX\n";	//NOSTACKTHEN COMMENT
		*cd += "PUSH CX\n";	//NOSTACKTHEN COMMENT
		*cd += "PUSH DX\n";	//NOSTACKTHEN COMMENT
		if(funcName == "main"){
			*cd += "MOV AH, 4CH\n";
			*cd += "INT 21H\n";

		}
		//*cd += "RET " + to_string(retVal) + "\n"; NOSTACKTHEN UNCOMMENT
		*cd += "RET 0\n";
		//*cd += "PUSH CX\n";				//NOSTACKTHEN UNCOMMENT
		*cd += funcName + " ENDP\n";
		if(funcName == "main"){
			*cd += "END MAIN\n";

		}
		code<<*cd;
		//varOffset = 0;
		//ST->printAll2(coutf2);
		//recurFuncName = "";
	}
		| type_specifier ID LPAREN RPAREN 
		{
			//ICG!!!!
			
			// for(int i=0;i<paramstore.size();i++){
			// 		paramstore[i]->print();
			// }
			codeCom = ";";
			codeCom += ("Line: " + to_string(yylineno)+ " - ");
			codeCom += "func_definition : type_specifier ID LPAREN RPAREN compound_statement";
			codeCom += "\n";
			code<<codeCom;


			cd = new string("");
			*cd += $2->getName() + " PROC\n";
			*cd += "PUSH BP\n";
			*cd += "MOV BP , SP\n";
			if($2->getName() == "main"){
				*cd += "MOV AX , @DATA\n";
				*cd += "MOV DS , AX\n";
			}
			code<<*cd;
			spVarOffset = varOffset;
			varOffset = 0;
			//cout<<spVarOffset<<" "<<varOffset<<endl;
			//to be used in RETURN
			retVal = paramstore.size() * 2;
			funcName = $2->getName();
			recurFuncName = $2->getName();
			//cout<<recurFuncName<<endl;
			//cout<<retVal<<endl;
		}
		compound_statement						{
		//coutf2<<"GENJAAAAAM4"<<endl<<endl;


		string funcdatatype = $1->getName();
		tempSI2 = new SymbolInfo($2->getName(), "ID");
		tempSI2->setDataType(funcdatatype);		//int/float/void
		tempSI2->setVarType(3);					//2 for Func Declaration
		for(int i=0;i<paramstore.size();i++){
				tempSI2->addParam(paramstore[i]);
			}

		check = ST->LookUpBig(tempSI2->getName());
		//check->print();
		//ST->printAll2(couterr);
		if(check!=nullptr){
			//check->print();
			if(check->getVarType() == 2){
				int fl = check->isUnequalFunc(tempSI2);
				//cout<<fl<<endl<<endl;
				if(fl == 0){
					ST->RemoveSymbolInfo(check);
					ST->Insert(tempSI2, coutdummy);
					//check->print();
				}
				else if(fl == 1){
					 couterr<<"Error at line "<<yylineno<< - (endfuncline - begfuncline + 1)<<": Total number of parameters mismatch with declaration in function "<< tempSI2->getName() <<endl<<endl;
					 coutf2<<"Error at line "<<yylineno<< - (endfuncline - begfuncline + 1)<<": Total number of parameters mismatch with declaration in function "<< tempSI2->getName() <<endl<<endl;
					errcount++;
				}
				else if(fl == 2){
					 couterr<<"Error at line "<<yylineno - (endfuncline - begfuncline + 1)<<": Param DataType Mismatch "<< tempSI2->getName() <<endl<<endl;
					 coutf2<<"Error at line "<<yylineno - (endfuncline - begfuncline + 1)<<": Param DataType Mismatch "<< tempSI2->getName() <<endl<<endl;
					errcount++;
				}
				else if(fl == 3){
					 couterr<<"Error at line "<<yylineno - (endfuncline - begfuncline + 1)<<": Return type mismatch with function declaration in function "<< tempSI2->getName() <<endl<<endl;
					 coutf2<<"Error at line "<<yylineno - (endfuncline - begfuncline + 1)<<": Return type mismatch with function declaration in function "<< tempSI2->getName() <<endl<<endl;
					errcount++;
				}

			}
			else{
				 couterr<<"Error at line "<<yylineno - (endfuncline - begfuncline + 1)<<": Multiple declaration of "<< tempSI2->getName() <<endl<<endl;
				 coutf2<<"Error at line "<<yylineno - (endfuncline - begfuncline + 1)<<": Multiple declaration of "<< tempSI2->getName() <<endl<<endl;
				errcount++;
			}
			
		}
		else{
			if(returnType->getDataType() == tempSI2->getDataType() || (tempSI2->getDataType() == "float") && (returnType->getDataType() == "int") || (tempSI2->getDataType() == "void" && returnType->getDataType() == "")){
				ST->Insert(tempSI2, coutdummy);
				returnType ->setDataType("void");
			}
			else{
				couterr<<"Error at line "<<yylineno - (endfuncline - begfuncline + 1)<<": Return type mismatch of "<< tempSI2->getName() <<endl<<endl;
				 coutf2<<"Error at line "<<yylineno - (endfuncline - begfuncline + 1)<<": Return type mismatch of "<< tempSI2->getName() <<endl<<endl;
				errcount++;
				ST->Insert(tempSI2, coutdummy);
			

				// cout<<returnType ->getDataType()<<endl;
				// cout<<tempSI2 ->getDataType()<<endl;

				returnType ->setDataType("void");
			}
			//ST->Insert(tempSI2, coutdummy);
			//tempSI2->print();
			
		}
		paramstore.clear();
		paramstoretemp.clear();


		$$ = new SymbolInfo($1->getName() + " " + $2->getName() + "()" + $6->getName(), non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"func_definition : type_specifier ID LPAREN RPAREN compound_statement"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
		ST->printAll2(coutf2);

		//ICG
		cd = new string("");
		*cd += funcName + "_exit:\n";
		*cd += "SUB SP , " + to_string(varOffset) + "\t\t\t\t\t;Popping local variables\n";
		*cd += "POP BP\n";
		*cd += "POP DX\n";
		*cd += "PUSH CX\n";
		*cd += "PUSH DX\n";
		if(funcName == "main"){
			*cd += "MOV AH, 4CH\n";
			*cd += "INT 21H\n";
		}
		//*cd += "RET " + to_string(retVal) + "\n";
		//*cd += "PUSH CX\n";
		*cd += "RET 0\n";
		*cd += funcName + " ENDP\n";
		if(funcName == "main"){
			*cd += "END MAIN\n";

		}
		code<<*cd;
		//recurFuncName = "";

	}
	//ERRORRECOVERY
	| type_specifier ID LPAREN error RPAREN compound_statement{
				yyclearin; /* discard lookahead */
 				yyerrok;
				errcount++;
				couterr<<"Syntax Error at line no "<<yylineno - (endfuncline - begfuncline + 1)<<": in parameter list of function definition" <<endl<<endl;
				coutf2<<"Syntax Error at line no "<<yylineno - (endfuncline - begfuncline + 1)<<": in parameter list of function definition" <<endl<<endl;
				//cout<<"Syntax Error at line "<<yylineno - (endfuncline - begfuncline + 1)<<": in parameter list of function definition" <<endl<<endl;
				//couterr<<"Line no: "<<yylineno<<"Error in Compound statement"<<endl;
		$$ = new SymbolInfo($1->getName() + " " + $2->getName() + "( *** )" + $6->getName(), non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"func_declaration : type_specifier ID LPAREN parameter_list RPAREN COMPOUND_STATEMENT"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
		paramstore.clear();
		paramstoretemp.clear();
	}
 		;				


parameter_list  : parameter_list COMMA type_specifier ID		{
		//coutf2<<"GENJAAAAAM7"<<endl<<endl;
		string varDataType = $3->getName();
		tempSI2 = new SymbolInfo($4->getName(), "ID");
		tempSI2->setDataType(varDataType);
		if((varDataType == "void"|| varDataType == "VOID")){
			 
			 couterr<<"Error at line "<<yylineno<<": Invalid use of <void> in parameter "<< tempSI2->getName() <<endl<<endl;
			 coutf2<<"Error at line "<<yylineno<<": Invalid use of <void> in parameter "<< tempSI2->getName() <<endl<<endl;
			errcount++;
		}
		for(int i=0;i<paramstore.size();i++){
			if(paramstore[i]->getName()==tempSI2->getName()){
				 
				 couterr<<"Error at line "<<yylineno<<": Multiple declaration of "<< tempSI2->getName()<<" in parameter" <<endl<<endl;
				 coutf2<<"Error at line "<<yylineno<<": Multiple declaration of "<< tempSI2->getName()<<" in parameter" <<endl<<endl;
				errcount++;
				break;
			}
		}
		paramstore.push_back(tempSI2);
		paramstoretemp.push_back(tempSI2);




		$$ = new SymbolInfo($1->getName() + ", " + $3->getName() + " " + $4->getName(), non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"parameter_list  : parameter_list COMMA type_specifier ID"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
		//coutf2<<"7"<<endl<<endl;
	}
		| parameter_list COMMA type_specifier					{
		//coutf2<<"GENJAAAAAM8"<<endl<<endl;

		string varDataType = $3->getName();
		tempSI2 = new SymbolInfo(" ", non_token);
		tempSI2->setDataType(varDataType);
		if(paramstore.size()>0 && (varDataType == "void"|| varDataType == "VOID")){
			 
			 couterr<<"Error at line "<<yylineno<<": parameter cannot be of type <void> when more than 1 parameters"<<endl<<endl;
			 coutf2<<"Error at line "<<yylineno<<": parameter cannot be of type <void> when more than 1 parameters"<<endl<<endl;
			errcount++;
		}
		paramstore.push_back(tempSI2);
		paramstoretemp.push_back(tempSI2);


		$$ = new SymbolInfo($1->getName() + ", " + $3->getName(), non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"parameter_list  : parameter_list COMMA type_specifier"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
	}
 		| type_specifier ID										{
		//coutf2<<"GENJAAAAAM9"<<endl<<endl;
		
		string varDataType = $1->getName();
		tempSI2 = new SymbolInfo($2->getName(), "ID");
		tempSI2->setDataType(varDataType);
		if((varDataType == "void"|| varDataType == "VOID")){
			 
			 couterr<<"Error at line "<<yylineno<<": invalid use of <void> in parameter "<< tempSI2->getName() <<endl<<endl;
			 coutf2<<"Error at line "<<yylineno<<": invalid use of <void> in parameter "<< tempSI2->getName() <<endl<<endl;
			errcount++;
		}
		for(int i=0;i<paramstore.size();i++){
			if(paramstore[i]->getName()==tempSI2->getName()){
				 
				 couterr<<"Error at line "<<yylineno<<": Multiple declaration of "<< tempSI2->getName()<<" in parameter"<<endl<<endl;
				 coutf2<<"Error at line "<<yylineno<<": Multiple declaration of "<< tempSI2->getName()<<" in parameter"<<endl<<endl;
				errcount++;
				break;
			}
		}
		paramstore.push_back(tempSI2);
		paramstoretemp.push_back(tempSI2);




		$$ = new SymbolInfo($1->getName() + " " + $2->getName(), non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"parameter_list  : type_specifier ID"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
	}
		| type_specifier										{
			//coutf2<<"GENJAAAAAM4"<<endl<<endl;

		
		string varDataType = $1->getName();
		tempSI2 = new SymbolInfo(" ", non_token);
		tempSI2->setDataType(varDataType);
		if(paramstore.size()>0 && (varDataType == "void"|| varDataType == "VOID")){
			 
			 couterr<<"Error at line "<<yylineno<<": parameter cannot be of type <void> when more than 1 parameters"<<endl<<endl;
			 coutf2<<"Error at line "<<yylineno<<": parameter cannot be of type <void> when more than 1 parameters"<<endl<<endl;
			errcount++;
		}
		paramstore.push_back(tempSI2);
		paramstoretemp.push_back(tempSI2);

		$$ = new SymbolInfo($1->getName(), non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"parameter_list  : type_specifier"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
	}				
 		;

 		
compound_statement : LCURL makescope statements RCURL		{
			$$ = new SymbolInfo("{\n" + $3->getName() + "\n}", non_token);
			coutf2<<"Line "<<yylineno<<": ";
			coutf2<<"compound_statement : LCURL statements RCURL	 "<<endl<<endl;
			coutf2<<$$->getName()<<endl<<endl;
			endfuncline = yylineno;
			ST->printAll2(coutf2);
			ST->deleteScope(coutf2);
		}
 		    | LCURL RCURL						{
			$$ = new SymbolInfo( "\n{\n}", non_token);
			ST->enterScope();
			ST->deleteScope(coutdummy);
			coutf2<<"Line "<<yylineno<<": ";
			coutf2<<"compound_statement : LCURL RCURL	 "<<endl<<endl;
			coutf2<<$$->getName()<<endl<<endl;
			begfuncline = endfuncline = yylineno;
		}	
			//ERRORRECOVERY
			//| LCURL makescope error RCURL		{
			//	yyclearin; /* discard lookahead */
 			//	yyerrok;
			//	errcount++;
			//	//couterr<<"Line no: "<<yylineno<<"Error in Compound statement"<<endl;
			//	$$ = new SymbolInfo("{\n}", non_token);
			//	coutf2<<"Line "<<yylineno<<": ";
			//	coutf2<<"compound_statement : LCURL statements RCURL	 "<<endl<<endl;
			//	coutf2<<$$->getName()<<endl<<endl;
			//	endfuncline = yylineno;
			//	ST->printAll2(coutf2);
			//	ST->deleteScope(coutf2);
			//}
 		    ;
makescope : {
							ST->enterScope();
							paramOffset = 2;
							for(int i = paramstoretemp.size()-1; i>=0 ; i--){
								paramOffset+=2;
								paramstoretemp[i]->setStackPos(paramOffset);
								//a->print();
								tempSI2 = new SymbolInfo(*(paramstoretemp[i]));
								ST->Insert(tempSI2, coutdummy);
							}
							// for(auto a : paramstoretemp){
							// 	//ICG
							// 	paramOffset+=2;
							// 	a->setStackPos(paramOffset);
							// 	//a->print();
								
							// 	ST->Insert(a, coutdummy);
								
							// }
							begfuncline = yylineno;
							//ST->printAll2(couterr);
							paramstoretemp.clear();
						
			}   
var_declaration : type_specifier declaration_list SEMICOLON	{
		$$ = new SymbolInfo($1->getName() + " " + $2->getName() + ";", non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"var_declaration : type_specifier declaration_list SEMICOLON"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
		int flag3 = 0;
		//string vardectype = "";
		string typespec = "";
		typespec = $1->getName();
		
		if(typespec == "void"){
			//vardectype = "VOID";
			 
			 couterr<<"Error at line "<<yylineno<<": Variable type cannot be void " <<endl<<endl;
			 coutf2<<"Error at line "<<yylineno<<": Variable type cannot be void " <<endl<<endl;
			errcount++;
			flag3++;
		}
		//cout<<ST->getCurrID()<<endl<<endl;
		// cout<<"------"<<endl<<endl;
		// for(auto x: varstore){
		// x->print();
		// }
		// cout<<"++++++"<<endl<<endl;
		int glb = 0;
		if(ST->getCurrID()=="1"){
			glb = 1;
		}
		int varDecSPSub = 0;
		if(ST->getCurrID()!="1"){
			codeCom = ";";
			codeCom += ("Line: " + to_string(yylineno)+ " - ");
			codeCom += "var_declaration : type_specifier declaration_list SEMICOLON (LOCAL)";
			codeCom += "\n";
			code<<codeCom;
		}
		else{
			codeCom = ";";
			codeCom += ("Line: " + to_string(yylineno)+ " - ");
			codeCom += "var_declaration : type_specifier declaration_list SEMICOLON (GLOBAL)";
			codeCom += "\n";
			code<<codeCom;
		}

		for(int i=0;i<varstore.size();i++){
			//comment()
			
			

			//SymbolInfo* tempSI3 = varstore[i];
			tempSI2 = new SymbolInfo(*varstore[i]);
			tempSI2->setDataType(typespec);
			// if(tempSI2->getVarType() <= 1 && glb == 1){	//mark as global variable/array
			// 	tempSI2->setGlobal();
			// }
			//varstore[i]->print();
			//tempSI2->print();

			int flag1 = 0, flag2 = 0;
			check = ST->LookUpCurr(tempSI2->getName());
			if(check != nullptr){
				 
				 couterr<<"Error at line "<<yylineno<<": Multiple declaration of "<< tempSI2->getName() <<endl<<endl;
				 coutf2<<"Error at line "<<yylineno<<": Multiple declaration of "<< tempSI2->getName() <<endl<<endl;
				flag1++;
				errcount++;
			}
			check = ST->LookUpBig(tempSI2->getName());
			if(check!=nullptr && flag1==0){
				if(check->getVarType() == 2 || check->getVarType() == 3){
					 
					 couterr<<"Error at line "<<yylineno<<": same name for a function "<< tempSI2->getName() <<endl<<endl;
					 coutf2<<"Error at line "<<yylineno<<": same name for a function "<< tempSI2->getName() <<endl<<endl;
					flag2++;
					errcount++;
				}
				
			}
			if(flag3==0){
				//ICG
				


				if(ST->getCurrID() == "1"){
					//GLOBAL
					

					varOffset = 0;
					tempSI2->setGlobal();
					if(tempSI2->getSize()>0) {
						cd2 = new string("");
						*cd2 += (tempSI2->getName() + " DW " + to_string(tempSI2->getSize()) + " DUP (0000H) \n");
						code2<<*cd2;
						//cout<<tempSI2->getGlobal()<<endl;
					}
					else{
						cd2 = new string("");
						*cd2 += (tempSI2->getName() + " DW " + to_string(tempSI2->getSize() + 1) + " DUP (0000H) \n");
						code2<<*cd2;
						//cout<<tempSI2->getGlobal()<<endl;
					}
				}
				else{
					
					//LOCAL


					if(tempSI2->getSize()>0) {
						varOffset -= (2*tempSI2->getSize());
						varDecSPSub += 2*tempSI2->getSize();
						//ICGOptimize
						// cd = new string("");
						// *cd += ("SUB  SP , " + to_string(2*tempSI2->getSize()) + "\t\t\t\t\t;declaring variable " + tempSI2->getName() + " \n");
						// code<<*cd;
					}
					else{
						//ICGOptimize
						varDecSPSub += 2;
						varOffset-=2;
						// cd = new string("");
						// *cd += ("SUB  SP , 2\t\t\t\t\t;declaring variable " + tempSI2->getName() + " \n");
						// code<<*cd;
					}
					tempSI2->setStackPos(varOffset);
					ST->RemoveSymbolInfo(tempSI2);
					ST->Insert(tempSI2, coutdummy);
					
					//tempSI2->print();
					//ST->LookUpCurr(tempSI2->getName())->print();
				}


				//cout<<varOffset<<endl;


				ST->Insert(tempSI2, coutdummy);
			}
			
		}
		// for(auto a: varstore){
		// 	(ST->LookUpCurr(a->getName()))->print();
		// }
		if(varDecSPSub>0){
			cd = new string("");
			*cd += ("SUB  SP , " + to_string(varDecSPSub)+ "\t\t\t\t\t\t;declaring variables  \n");
			code<<*cd;
		}
		varstore.clear();

	}
	//ERRORRECOVERY
	|	type_specifier error SEMICOLON	{
		yyclearin; /* discard lookahead */
 		yyerrok;
		couterr<<"Syntax Error at line no "<<yylineno<<" in variable declaration list " <<endl<<endl;
		coutf2<<"Syntax Error at line no "<<yylineno<<" in variable declaration list " <<endl<<endl;
		errcount++;

		$$ = new SymbolInfo($1->getName() +  " ***" + ";", non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"var_declaration : type_specifier declaration_list SEMICOLON"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
	}
 		 ;
 		 
type_specifier	: INT 	{
		$$ = new SymbolInfo("int", non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"type_specifier	: INT"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
	}
 		| FLOAT			{
		$$ = new SymbolInfo("float", non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"type_specifier	: FLOAT"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
	}
 		| VOID			{
		$$ = new SymbolInfo("void", non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"type_specifier	: VOID"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
	}
 		;
 		
declaration_list : declaration_list COMMA ID					{
		//coutf2<<"GENJAAAAAM13"<<endl<<endl;
		tempSI2 = new SymbolInfo($3->getName(), $3->getType());
		tempSI2->setVarType(0);

		// check = ST->LookUpCurr(tempSI2->getName());
		// if(check != nullptr){
		// 	 
		// 	 couterr<<"Error at line "<<yylineno<<"  Multiple declaration of "<< tempSI2->getName() <<endl<<endl;
		// }
		// check = ST->LookUpBig(tempSI2->getName());
		// if(check!=nullptr){
		// 	if(check->getVarType() == 2 || check->getVarType() == 3)
		// 	 
		// 	 couterr<<"Error at line "<<yylineno<<"  same name for a function "<< tempSI2->getName() <<endl<<endl;
		// }
		varstore.push_back(tempSI2);

		$$ = new SymbolInfo($1->getName() + ", " + $3->getName(), non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"declaration_list : declaration_list COMMA ID"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
	}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD	{
			tempSI2 = new SymbolInfo($3->getName(), $3->getType());
			tempSI2->setVarType(1);
			string szstr = $5->getName();
			tempSI2->setSize(stoi(szstr));
			varstore.push_back(tempSI2);
			//cout<<"Arraytest"<<endl<<endl;

		//coutf2<<"GENJAAAAAM14"<<endl<<endl;
		$$ = new SymbolInfo($1->getName() + ", " + $3->getName() + "[" + $5->getName() + "]", non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
	}
 		  | ID													{
			//$$ = new SymbolInfo("An ID", non_token);
			//$$ = new SymbolInfo($1->getName(), non_token);
			tempSI2 = new SymbolInfo($1->getName(), $1->getType());
			tempSI2->setVarType(0);

			// check = ST->LookUpCurr(tempSI2->getName());
			// if(check != nullptr){
			// 	 
			// 	 couterr<<"Error at line "<<yylineno<<"  Multiple declaration of "<< tempSI2->getName() <<endl<<endl;
			// }
			// check = ST->LookUpBig(tempSI2->getName());
			// if(check!=nullptr){
			// 	if(check->getVarType() == 2 || check->getVarType() == 3)
			// 	 
			// 	 couterr<<"Error at line "<<yylineno<<"  same name for a function "<< tempSI2->getName() <<endl<<endl;
			// }
			varstore.push_back(tempSI2);
		
			//coutf2<<"GENJAAAAAM15"<<endl<<endl;
			$$ = new SymbolInfo($1->getName(), non_token);
			coutf2<<"Line "<<yylineno<<": ";
			coutf2<<"declaration_list : ID"<<endl<<endl;
			coutf2<<$$->getName()<<endl<<endl;
			
			
	}
 		  | ID LTHIRD CONST_INT RTHIRD							{
			tempSI2 = new SymbolInfo($1->getName(), $1->getType());
			tempSI2->setVarType(1);
			string szstr = $3->getName();
			int sz = stoi(szstr);
			tempSI2->setSize(sz);
			varstore.push_back(tempSI2);


			//coutf2<<"GENJAAAAAM16"<<endl<<endl;
			$$ = new SymbolInfo($1->getName() + "[" + $3->getName() + "]", non_token);
			coutf2<<"Line "<<yylineno<<": ";
			coutf2<<"declaration_list : ID LTHIRD CONST_INT RTHIRD"<<endl<<endl;
			coutf2<<$$->getName()<<endl<<endl;
	}
			//ERRORRECOVERY
			//|	error COMMA ID	{
			//	yyclearin; /* discard lookahead */
 			//	yyerrok;
			//	couterr<<"Syntax Error at line "<<yylineno<<": in variable declaration list " <<endl<<endl;
			//	errcount++;
			//	tempSI2 = new SymbolInfo($3->getName(), $3->getType());
			//	tempSI2->setVarType(0);
			//	varstore.push_back(tempSI2);
			//
			//	$$ = new SymbolInfo($3->getName(), non_token);
			//	coutf2<<"Error at Line "<<yylineno<<": ";
			//	coutf2<<"declaration_list : declaration_list COMMA ID"<<endl<<endl;
			//	coutf2<<$$->getName()<<endl<<endl;
			//}
			//ERRORRECOVERY
			//|	error COMMA ID LTHIRD CONST_INT RTHIRD	{
			//	yyclearin; /* discard lookahead */
 			//	yyerrok;
			//	couterr<<"Syntax Error at line "<<yylineno<<": in variable declaration list " <<endl<<endl;
			//	errcount++;
			//	tempSI2 = new SymbolInfo($3->getName(), $3->getType());
			//	tempSI2->setVarType(1);
			//	string szstr = $5->getName();
			//	tempSI2->setSize(stoi(szstr));
			//	varstore.push_back(tempSI2);
			//	
			//	$$ = new SymbolInfo($3->getName() + "[" + $5->getName() + "]", non_token);
			//	coutf2<<"Line "<<yylineno<<": ";
			//	coutf2<<"declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD"<<endl<<endl;
			//	coutf2<<$$->getName()<<endl<<endl;
			//}
 		  ;
 		  
statements : statement 				{
		$$ = new SymbolInfo($1->getName(), non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"statements : statement"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
	}
	   | statements statement		{
		$$ = new SymbolInfo($1->getName() + " \n" + $2->getName() , non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"statements : statements statement"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
	}
	   ;
//ICG
dummy_if : IF LPAREN expression RPAREN {
		
		codeCom = ";";
		codeCom += ("Line: " + to_string(yylineno)+ " - ");
		codeCom += "IF LPAREN expression RPAREN statement";
		codeCom += "\n";
		code<<codeCom;


		ifCount++;
		ifLabels.push_back(to_string(ifCount));

		cd = new string("");
		*cd += "POP CX\t\t\t\t\t\t;loading condition into CX\n";
		*cd += "JCXZ if_false" + ifLabels.back() + " \n";
		code<<*cd;
}
statement
{
		$$ = new SymbolInfo("if(" + $3->getName() + ")\n" + $6->getName() + "\n" , non_token);
		cd = new string("");
		*cd += "JMP if_end" + ifLabels.back() +" \n";
		*cd += "if_false" + ifLabels.back() + ": \n";
		code<<*cd;
}

statement : var_declaration																	{
		$$ = new SymbolInfo($1->getName() , non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"statement : var_declaration"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
	}
	  | expression_statement																{
		$$ = new SymbolInfo($1->getName() , non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"statement : expression_statement"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
	}																						
	  | compound_statement																	{
		$$ = new SymbolInfo($1->getName() , non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"statement : compound_statement"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
	}
	  | FOR {
		loopCount++;
		loopLabels.push_back(to_string(loopCount));
		codeCom = ";";
		codeCom += ("Line: " + to_string(yylineno)+ " - ");
		codeCom += "statement : FOR LPAREN expression_statement expression RPAREN statement";
		codeCom += "\n";
		code<<codeCom;
	  }
	  LPAREN expression_statement {
		cd = new string("");
		*cd += "loop" + loopLabels.back() + ": \n";
		code<<*cd;
	  }
	  expression_statement {
		cd = new string("");
		*cd += "JCXZ loop_end" + loopLabels.back() + "\n";
		*cd += "JMP loop_stmt" + loopLabels.back() + "\n";
		*cd += "loop_mid" + loopLabels.back() + ": \n";
		code<<*cd;
	  }
	  expression RPAREN {
		cd = new string("");
		*cd += "POP CX\n";
		*cd += "JMP loop" + loopLabels.back() + "\n";
		*cd += "loop_stmt" + loopLabels.back() + ":\n";
		code<<*cd;
	  }
	  statement	{
		$$ = new SymbolInfo("for(" + $4->getName() + $6->getName() + $8->getName() + ")\n" + $11->getName()  , non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;

		cd = new string("");
		*cd += "JMP loop_mid" + loopLabels.back() + "\n";
		*cd += "loop_end" + loopLabels.back() + ":\n";
		code<<*cd;
		loopLabels.pop_back();
	}
	  | dummy_if %prec LOWER_THAN_ELSE												{
		$$ = new SymbolInfo($1->getName() , non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"statement : IF LPAREN expression RPAREN statement"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;

		//ICG
		cd = new string("");
		*cd += "if_end" + ifLabels.back() + ": \n";
		code<<*cd;
		ifLabels.pop_back();
	}
	  | dummy_if ELSE statement								{
		$$ = new SymbolInfo($1->getName() + "\nelse\n" + $3->getName() , non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"statement : IF LPAREN expression RPAREN statement ELSE statement"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;

		//ICG
		cd = new string("");
		*cd += "if_end" + ifLabels.back() + ": \n";
		code<<*cd;
		ifLabels.pop_back();

	}
	  | WHILE 					{
		//ICG
		codeCom = ";";
		codeCom += ("Line: " + to_string(yylineno)+ " - ");
		codeCom += "WHILE LPAREN expression RPAREN statement";
		codeCom += "\n";
		code<<codeCom;

		loopCount++;
		loopLabels.push_back(to_string(loopCount));
		cd = new string("");
		*cd += "loop" + loopLabels.back() + ": \n";
		code<<*cd;
	  }
	  LPAREN expression RPAREN	{
		//ICG
		cd = new string("");
		*cd += "POP CX\t\t\t\t\t\t;Checking loop Condition \n";
		*cd += "JCXZ loop_end" + loopLabels.back() + "\n";
		code<<*cd;
		
	  } 
	  statement					{
		$$ = new SymbolInfo("while(" + $3->getName() + ")\n" + $7->getName(), non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"statement : WHILE LPAREN expression RPAREN statement"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;

		cd = new string("");
		*cd += "JMP loop" + loopLabels.back() + "\n";
		*cd += "loop_end" + loopLabels.back() + ":\n";
		code<<*cd;
		loopLabels.pop_back();

	}
	  | PRINTLN LPAREN ID RPAREN SEMICOLON													{
		codeCom = ";";
		codeCom += ("Line: " + to_string(yylineno)+ " - ");
		codeCom += "PRINTLN LPAREN ID RPAREN SEMICOLON";
		codeCom += "\n";
		code<<codeCom;

		tempSI2 = ST->LookUpBig($3->getName());
		if(tempSI2 == nullptr){
			 
			 couterr<<"Error at line "<<yylineno<<": Undeclared Variable "<< $3->getName() <<endl<<endl;
			 coutf2<<"Error at line "<<yylineno<<": Undeclared Variable "<< $3->getName() <<endl<<endl;
			errcount++;
		}
		else if(tempSI2->getVarType() != 0){
			 
			 couterr<<"Error at line "<<yylineno<<": type mismatch in printf (not a single variable) "<< $1->getName() <<endl<<endl;
			 coutf2<<"Error at line "<<yylineno<<": type mismatch in printf (not a single variable) "<< $1->getName() <<endl<<endl;
			errcount++;
		}
		else{

		}
		$$ = new SymbolInfo("printf(" + $3->getName() + ");\n", non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"statement : PRINTLN LPAREN ID RPAREN SEMICOLON"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;



		//ICG
		 cd = new string("");
		
			if(tempSI2->getGlobal() == 1){		
				*cd += ("PUSH " + tempSI2->getName() + "\t\t\t\t\t\t;pushing global variable "+ tempSI2->getName() +"\n") ;
			}
			else{		
				*cd += ("PUSH [BP+" + to_string(tempSI2->getStackPos()) + "]\t\t\t\t;pushing variable "+ tempSI2->getName() +"\n") ;
			}


		 *cd += "CALL println\n";
		 //*cd += "POP CX\n";
		 *cd += "ADD SP , 2\t\t\t\t\t;removing args\n";
		 //*cd += "PUSH CX\n";
		 code<<*cd;


		 //BAAD -> POP DX , Push CX , PUSH DX at end;; initial Push CX after func end baad, Pop CX after expression auto baad
	}
	  | RETURN expression SEMICOLON															{
		$$ = new SymbolInfo("return " + $2->getName() + ";", non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"statement : RETURN expression SEMICOLON"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
		//returnType->setDataType("void");
		returnType ->setDataType($2->getDataType());


		//ICG
		codeCom = ";";
		codeCom += ("Line: " + to_string(yylineno)+ " - ");
		codeCom += "RETURN expression SEMICOLON";
		codeCom += "\n";
		code<<codeCom;



		cd = new string("");
		*cd += "POP CX\t\t\t\t\t\t;Saving return value for stack push\n";
		*cd += "JMP " + funcName + "_exit\n";
		code<<*cd;



		//TESTING
		//$2->print();
		//returnType->print();

	}
	  ;
	  
expression_statement 	: SEMICOLON		{
		$$ = new SymbolInfo(";", non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"expression_statement : SEMICOLON"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
	}			
			| expression SEMICOLON 		{
		$$ = new SymbolInfo($1->getName() + ";", non_token);
		$$->setDataType($1->getDataType());
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"expression_statement : expression SEMICOLON"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
		// if(wasAssigned){
		// 	wasAssigned = 0;
		// }
		// else{
		// 	//ICG
		// 	cd = new string("");
		// 	*cd += "POP CX\t\t\t\t\t\t Extra pop since not assigned\n ";
		// 	code<<*cd;
		// }
		//ICG
		cd = new string("");
		*cd += "POP CX\t\t\t\t\t\t;Extra pop after final expression\n";
		code<<*cd;
	}
	//ERRORRECOVERY
			| error SEMICOLON	{
		yyclearin; /* discard lookahead */
 		yyerrok;
		errcount++;
		couterr<<"Syntax Error at line no "<<yylineno<<": in expression" <<endl<<endl;
		coutf2<<"Syntax Error at line no "<<yylineno<<": in expression" <<endl<<endl;
		//couterr<<"Line no: "<<yylineno<<"Error in Compound statement"<<endl;
		$$ = new SymbolInfo("*** ;", non_token);
		//$$->setDataType($1->getDataType());
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"expression_statement : expression SEMICOLON"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
	}
			;
	  
variable : ID 							{
	//coutf2<<"---------GENJAM16"<<endl<<endl;
	$$ = new SymbolInfo($1->getName(), non_token);
		tempSI2 = ST->LookUpCurr($1->getName());
		SymbolInfo* tempSI3 = ST->LookUpBig($1->getName());
		//tempSI2->print();
		if(tempSI2 == nullptr){
			if(tempSI3 != nullptr){
				if(tempSI3->getVarType() == 0){
					// $$->setDataType(tempSI3->getDataType()); //parent scope variable
					// $$->setVarType(tempSI3->getVarType());
					// $$->setSize(tempSI3->getSize());
					$$=new SymbolInfo(*tempSI3);
					//$$->setGlobal();
					//$$->print();
				}
				else{
					 
					 couterr<<"Error at line "<<yylineno<<": Undeclared Variable "<< $1->getName() <<endl<<endl;
					 coutf2<<"Error at line "<<yylineno<<": Undeclared Variable "<< $1->getName() <<endl<<endl;
					errcount++;
				}
			}
			else{
				 
				 couterr<<"Error at line "<<yylineno<<": Undeclared Variable "<< $1->getName() <<endl<<endl;
				 coutf2<<"Error at line "<<yylineno<<": Undeclared Variable "<< $1->getName() <<endl<<endl;
				errcount++;
			}
			
		}
		else if(tempSI2->getVarType() != 0){
			// $$->setDataType(tempSI2->getDataType());
			// $$->setVarType(tempSI2->getVarType());
			// $$->setSize(tempSI2->getSize());
			$$=new SymbolInfo(*tempSI2);
			 couterr<<"Error at line "<<yylineno<<": Type Mismatch, "<< $1->getName()<<" is not a Single Variable" <<endl<<endl;
			 coutf2<<"Error at line "<<yylineno<<": Type Mismatch, "<< $1->getName()<<" is not a Single Variable" <<endl<<endl;
			errcount++;
		}
		else{
			//tempSI2->print();
			//cout<<tempSI2->getDataType()<<endl;
			// $$->setDataType(tempSI2->getDataType());
			// $$->setVarType(tempSI2->getVarType());
			// $$->setSize(tempSI2->getSize());
			$$=new SymbolInfo(*tempSI2);
			//tempSI2->print();
			//$$->print();
		}
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"variable : ID"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
		
		isConst++;
		//$$->setVal($1->getVal());
		// cout<<"TEST3"<<endl;
		// $$->print();
		//if(tempSI2!=nullptr)tempSI2->print();
		//if(tempSI3!=nullptr)tempSI3->print();
	}
	 | ID LTHIRD expression RTHIRD 		{
		//UNFINISHED
		//coutf2<<"---------GENJAM17"<<endl<<endl;
		$$ = new SymbolInfo($1->getName() + "[" + $3->getName() + "]", non_token);
		SymbolInfo* tempSI3 = ST->LookUpBig($1->getName());
		tempSI2 = ST->LookUpCurr($1->getName());
		if(tempSI2 == nullptr){
			//  
			//  couterr<<"Error at line "<<yylineno<<"  Undeclared Variable "<< $1->getName() <<endl<<endl;
			if(tempSI3 != nullptr){
				if(tempSI3->getVarType() == 1){
					// $$->setDataType(tempSI3->getDataType()); //a global variable
					// $$->setVarType(tempSI3->getVarType());
					// $$->setSize(tempSI3->getSize());
					$$=new SymbolInfo(*tempSI3);
					//$$->setGlobal();
					//$$->setGlobal();
					//$$->print();
				}
				else{
					 
					 couterr<<"Error at line "<<yylineno<<": Undeclared Variable "<< $1->getName() <<endl<<endl;
					 coutf2<<"Error at line "<<yylineno<<": Undeclared Variable "<< $1->getName() <<endl<<endl;
					errcount++;
				}
			}
			else{
				 
				 couterr<<"Error at line "<<yylineno<<": Undeclared Variable "<< $1->getName() <<endl<<endl;
				 coutf2<<"Error at line "<<yylineno<<": Undeclared Variable "<< $1->getName() <<endl<<endl;
				errcount++;
			}
		}
		else if(tempSI2->getVarType() != 1){
			 
			 couterr<<"Error at line "<<yylineno<<": Type Mismatch, "<< $1->getName()<<" is not an Array" <<endl<<endl;
			 coutf2<<"Error at line "<<yylineno<<": Type Mismatch, "<< $1->getName()<<" is not an Array" <<endl<<endl;
			errcount++;
		}
		else{
			// $$->setDataType(tempSI2->getDataType());
			// $$->setVarType(tempSI2->getVarType());
			// $$->setSize(tempSI2->getSize());
			$$=new SymbolInfo(*tempSI2);
		}
		//$$->setDataType($1->getDataType());
		if($3->getDataType()!="int"){
			 
			 couterr<<"Error at line "<<yylineno<<": Expression inside third brackets not an integer "<<endl<<endl;
			 coutf2<<"Error at line "<<yylineno<<": Expression inside third brackets not an integer "<<endl<<endl;
			errcount++;
		}
		//tempSI2->print();
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"variable : ID LTHIRD expression RTHIRD"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
	}
	//ERRORRECOVERY
	| ID LTHIRD error RTHIRD{
		yyclearin; /* discard lookahead */
 		yyerrok;
		errcount++;
		couterr<<"Syntax Error at line no "<<yylineno<<": in index" <<endl<<endl;
		coutf2<<"Syntax Error at line no "<<yylineno<<": in index" <<endl<<endl;
		$$ = new SymbolInfo($1->getName() + "[***]", non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"variable : ID LTHIRD expression RTHIRD"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
	}
	 ;
	 
expression : logic_expression					{
		$$ = new SymbolInfo($1->getName(), non_token);
		$$->setDataType($1->getDataType());
		$$->setVarType($1->getVarType());
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"expression : logic_expression"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
		if($$->getVarType()==0 && $$->getDataType()=="void"){
			 
			 couterr<<"Error at line "<<yylineno<<": Void function used in expression"<<endl<<endl;
			 coutf2<<"Error at line "<<yylineno<<": Void function used in expression"<<endl<<endl;
			errcount++;
		}
		//IGC
		//Extra Pop, no assignment
		// cd = new string("");
		// *cd = "POP CX\t\t\t\t\t\t;extra pop, since no assignment\n";
		// code<<*cd;
		//$$->setVal($1->getVal());
		//$$->print();
	}
	   | variable ASSIGNOP logic_expression 	{
		$$ = new SymbolInfo($1->getName() +  " = " + $3->getName(), non_token);
		//cout<<"Test"<<endl;
		//$1->print();
		//$3->print();
		$$->setVarType(0);
		if($1->getDataType()=="void"||$3->getDataType()=="void"){
			$$->setDataType("void");
		}
		else if($1->getDataType()== $3->getDataType()){
			$$->setDataType($1->getDataType());
		}
		else if ($1->getDataType()== "int" && $3->getDataType() == "float"){
			$$->setDataType("float");
			 
			 couterr<<"Error at line "<<yylineno<<": Type Mismatch "<<endl<<endl;
			 coutf2<<"Error at line "<<yylineno<<": Type Mismatch "<<endl<<endl;
			errcount++;
			//cout<<"Error, Type Mismatch "<<endl<<endl;
		}
		else if($1->getDataType()== "float" && $3->getDataType() == "int"){
			$$->setDataType("float");
		}
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"expression : variable ASSIGNOP logic_expression"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
		if($$->getVarType()==0 && $$->getDataType()=="void"){
			 
			 couterr<<"Error at line "<<yylineno<<": Void function used in expression"<<endl<<endl;
			 coutf2<<"Error at line "<<yylineno<<": Void function used in expression"<<endl<<endl;
			errcount++;
		}

		//$1->print();
		isConst++;
		//ICG
		//DOGLOBAL!!
		codeCom = ";";
		codeCom += ("Line: " + to_string(yylineno)+ " - ");
		codeCom += "variable ASSIGNOP logic_expression";
		codeCom += "\n";
		code<<codeCom;
		
		cd = new string("");
		*cd += ("POP CX \t\t\t\t\t\t;popping logic_expn val from RHS\n");

		if($1->getGlobal()==1){//GLOBAL
			if($1->getSize()>0){//PARTIAL
					*cd += ("POP AX\t\t\t\t\t\t;assign to array "+ $1->getName() +", AX has index\n"); //
					*cd += ("XCHG AX , CX\t\t\t; swap so that CX has index and AX has RHS value\n");
					*cd += ("SAL CX , 1\t\t\t\t\t\t;*2 since per index , 2 bytes\n");
					*cd += ("MOV BX , CX\n");
					*cd += ("MOV PTR WORD " + $1->getName() +"[BX] , AX\n");
					*cd += ("MOV CX , AX\t\t\t\t\t\t;then push CX to ensure optimization\n");
			}
			else{
				*cd += ("MOV " + ($1->getName()) + ", CX \t\t\t;assigning value to global " + $1->getName() + "\n");
			}
		}
		else{//LOCAL
			if($1->getSize()>0){
					*cd += ("POP AX\t\t\t\t\t\t;assign to array "+ $1->getName() +", AX has index\n"); //
					*cd += ("XCHG AX , CX\t\t\t; swap so that CX has index and AX has RHS value\n");
					*cd += ("PUSH BP\t\t\t\t\t\t;need to change and reference BP, [BP+CX] cannot be dereferenced \n");
					*cd += ("SAL CX , 1\t\t\t\t\t\t;*2 since per index , 2 bytes\n");
					*cd += ("ADD CX , " +to_string( $1->getStackPos()) +"\t\t\t\t;access correct byte by adding offset\n");
					*cd += ("ADD BP , CX\t\t\t\t;Change BP to point to correct array elem \n");
					*cd += ("MOV PTR WORD [BP], AX\t\t;save value at place pointed to by BP\n");
					*cd += ("POP BP\t\t\t\t\t\t;restore old BP for pointer\n");
					*cd += ("MOV CX , AX\t\t\t\t\t\t;then push CX to ensure optimization\n");
			}
			else{
				*cd += ("MOV [BP+" + to_string($1->getStackPos()) + "], CX \t\t\t;assigning value to " + $1->getName() + "\n");
			}
		}
		*cd += ("PUSH CX\t\t\t\t\t\t;store value in stack, for further use\n");
		code<<*cd;
		wasAssigned++;
		//$1->print();
		//$1->setVal($3->getVal());
		//ST->printAll2(code2);
		//ST->RemoveVal($1->getName());
		//$1->print();
		//tempSI2 = new SymbolInfo(*((SymbolInfo*)$1));
		//$1->print();
		//tempSI2->setName($1->getName());
		//$1->print();
		//temp->print();
		//ST->printAll2(code2);
		//ST->Insert(tempSI2,coutdummy);//ERRORRRR
		//temp->print();
		//$$->print();
	}
	   ;
			
logic_expression : rel_expression 					{
		$$ = new SymbolInfo($1->getName() , non_token);
		$$->setDataType($1->getDataType());
		$$->setVarType($1->getVarType());
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"logic_expression : rel_expression"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;

		//$$->setVal($1->getVal());
		//$$->print();
	}
		 | rel_expression LOGICOP rel_expression 	{
		$$ = new SymbolInfo($1->getName() + $2->getName() + $3->getName(), non_token);
		$$->setVarType(0);
		if($1->getDataType()=="void"||$3->getDataType()=="void"){
			$$->setDataType("void");
		}
		else{
			$$->setDataType("int");
		}
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"logic_expression : rel_expression LOGICOP rel_expression"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;

		string e = "LOGICOP_end" + to_string(logicOpCount);
		logicOpCount++;

		if($2->getName() == "&&"){
			//IGC
			isConst++;
			cd = new string("");
			*cd += "POP CX\t\t\t\t\t\t;starting &&\n";
			*cd += "POP AX\n";
			*cd += "JCXZ "+ e + "\n";
			*cd += "MOV CX , AX\n";
			*cd +=  e + ":\n";
			*cd += "PUSH CX\t\t\t\t\t\t;ending &&\n";
			code<<*cd;
			//$$->setVal(to_string(stoi($1->getVal())&&stoi($3->getVal())));
		}
		if($2->getName() == "||"){
			//ICG
			codeCom = ";";
			codeCom += ("Line: " + to_string(yylineno)+ " - ");
			codeCom += "logic_expression : rel_expression LOGICOP rel_expression";
			codeCom += "\n";
			code<<codeCom;
		


			isConst++;
			cd = new string("");
			*cd += "POP CX\t\t\t\t\t\t;starting ||\n";
			*cd += "POP AX\n"; 
			*cd += "CMP AX , 0\n";
			*cd += "JE "+ e + "\n"; //If AX ==0, out = CX; else out = AX = 1;
			*cd += "MOV CX , AX\n";
			*cd +=  e + ":\n";
			*cd += "PUSH CX\t\t\t\t\t\t;ending ||\n";
			code<<*cd;
			//$$->setVal(to_string(stoi($1->getVal())||stoi($3->getVal())));
		}
		isConst++;
		//$$->print();
	}
		 ;
			
rel_expression	: simple_expression 				{
		$$ = new SymbolInfo($1->getName() , non_token);
		$$->setDataType($1->getDataType());
		$$->setVarType($1->getVarType());
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"rel_expression : simple_expression"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
		
		//$$->setVal($1->getVal());
		//$$->print();
	}
		| simple_expression RELOP simple_expression	{
		$$ = new SymbolInfo($1->getName() + $2->getName() + $3->getName(), non_token);
		$$->setVarType(0);
		if($1->getDataType()=="void"||$3->getDataType()=="void"){
			$$->setDataType("void");
		}
		else{
			$$->setDataType("int");
		}
		
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"rel_expression : simple_expression RELOP simple_expression"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;

		// POP AX
		// CMP AX , CX
		// JGE relop_is_ok3
		// MOV CX , 0
		// JMP relop_end3
		// relop_is_ok3:
		// MOV CX , 1
		// relop_end3:
		//ICG
		//string ok = "RELOP_ok" + to_string(relOpCount);
		string e = "RELOP_end" + to_string(relOpCount);
		relOpCount++;

		
		string relop;
		if($2->getName() == "<="){
			relop = "JLE";
			//$$->setVal(to_string(stoi($1->getVal())<=stoi($3->getVal())));
		}
		if($2->getName() == ">="){
			relop = "JGE";
			//$$->setVal(to_string(stoi($1->getVal())>=stoi($3->getVal())));
		}
		if($2->getName() == "=="){
			relop = "JE";
			//$$->setVal(to_string(stoi($1->getVal())==stoi($3->getVal())));
		}
		if($2->getName() == "!="){
			relop = "JNE";
			//$$->setVal(to_string(stoi($1->getVal())!=stoi($3->getVal())));
		}
		if($2->getName() == ">"){
			relop = "JG";
			//$$->setVal(to_string(stoi($1->getVal())>stoi($3->getVal())));
		}
		if($2->getName() == "<"){
			relop = "JL";
			//$$->setVal(to_string(stoi($1->getVal())<stoi($3->getVal())));
		}
		
		//IGC

		isConst++;
		cd = new string("");
		*cd += "POP CX\t\t\t\t\t\t;starting "+ relop +"\n";
		*cd += "POP AX\n";
		*cd += "CMP AX , CX\n";
		*cd += "MOV CX , 1\n";
		*cd += relop + " " + e + "\n" ;
		*cd += "MOV CX , 0\n" ;
		*cd +=  e + ":\n";
		*cd += "PUSH CX\t\t\t\t\t\t;ending "+ relop +"\n";
		code<<*cd;
		//$$->print();
	}
		;
				
simple_expression : term 					{
		$$ = new SymbolInfo($1->getName() , non_token);
		$$->setDataType($1->getDataType());
		$$->setVarType($1->getVarType());
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"simple_expression : term"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
		//$$->setVal($1->getVal());
		//$$->print();
	}
		  | simple_expression ADDOP term 	{
		$$ = new SymbolInfo($1->getName() + $2->getName() + $3->getName(), non_token);
		$$->setVarType(0);
		if($1->getDataType()=="void"||$3->getDataType()=="void"){
			$$->setDataType("void");
		}
		else if($1->getDataType()=="float"||$3->getDataType()=="float"){
			$$->setDataType("float");
		}
		else{
			$$->setDataType("int");
		}
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"simple_expression : simple_expression ADDOP term"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
		//cout<<"Test"<<endl;
		//$1->print();
		//$3->print();
		codeCom = ";";
		codeCom += ("Line: " + to_string(yylineno)+ " - ");
		codeCom += "simple_expression : simple_expression ADDOP termn";
		codeCom += "\n";
		code<<codeCom;

		if($2->getName() == "+"){
			//ICG
			cd = new string("");
			*cd += ("POP CX\t\t\t\t\t\t;starting +\n");
			*cd += ("POP AX\n");
			*cd += ("ADD CX , AX\n");
			*cd += ("PUSH CX\t\t\t\t\t\t;ending +\n");
			code<<*cd;
			//$$->setVal(to_string(stoi($1->getVal())+stoi($3->getVal())));
		}
		if($2->getName() == "-"){
			cd = new string("");
			*cd += ("POP CX\t\t\t\t\t\t;starting -\n");
			*cd += ("POP AX\n");
			*cd += ("SUB AX , CX\n");
			*cd += ("MOV CX , AX\n");
			*cd += ("PUSH CX\t\t\t\t\t\t;ending -\n");
			code<<*cd;
			//$$->setVal(to_string(stoi($1->getVal())-stoi($3->getVal())));
		}
		//cout<<"Test2"<<endl;
		isConst++;
		//$$->print();
	}
		  ;
					
term :	unary_expression				{
		$$ = new SymbolInfo($1->getName() , non_token);
		$$->setDataType($1->getDataType());
		$$->setVarType($1->getVarType());
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"term : unary_expression"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
		//$$->setVal($1->getVal());
		//$$->print();
	}
     |  term MULOP unary_expression		{
		$$ = new SymbolInfo($1->getName() + $2->getName() + $3->getName(), non_token);
		$$->setVarType(0);
		if($1->getDataType()=="void"||$3->getDataType()=="void"){
			$$->setDataType("void");
		}
		else if($1->getDataType()=="float"||$3->getDataType()=="float"){	
			$$->setDataType("float");
			if($2->getName()=="%"){
				 
				 couterr<<"Error at line "<<yylineno<<": Non-Integer operand on modulus operator "<<endl<<endl;
				 coutf2<<"Error at line "<<yylineno<<": Non-Integer operand on modulus operator "<<endl<<endl;
				errcount++;
				$$->setDataType(" ");
			}
		}
		else{
			$$->setDataType("int");
		}
		codeCom = ";";
		codeCom += ("Line: " + to_string(yylineno)+ " - ");
		codeCom += "term : term MULOP unary_expression";
		codeCom += "\n";
		code<<codeCom;

		if($2->getName()=="%"){
			if(stoi($3->getName())==0){
				 
				 couterr<<"Error at line "<<yylineno<<": Modulus by 0 "<<endl<<endl;
				 coutf2<<"Error at line "<<yylineno<<": Modulus by 0 "<<endl<<endl;
				errcount++;
				$$->setDataType(" ");
			}
			else{
				//ICG
				cd = new string("");
				*cd += ("POP CX\t\t\t\t\t\t;starting %\n");
				*cd += ("POP AX\n");
				*cd += ("CWD\n");
				*cd += ("IDIV CX\n");
				*cd += ("PUSH DX\t\t\t\t\t\t;ending %\n");
				code<<*cd;
				//$$->setVal(to_string(stoi($1->getVal())%stoi($3->getVal())));
			}
		}
		

		if($2->getName()=="/"){
			if(stoi($3->getName())==0){
				
				couterr<<"Error at line "<<yylineno<<": Divide by 0 "<<endl<<endl;
				coutf2<<"Error at line "<<yylineno<<": Divide by 0 "<<endl<<endl;
				errcount++;
				$$->setDataType(" ");
			}
			else{
				//ICG
				cd = new string("");
				*cd += ("POP CX\t\t\t\t\t\t;starting /\n");
				*cd += ("POP AX\n");
				*cd += ("CWD\n");
				*cd += ("IDIV CX\n");
				*cd += ("PUSH AX\t\t\t\t\t\t;ending /\n");
				code<<*cd;
				//$$->setVal(to_string(stoi($1->getVal())/stoi($3->getVal())));
			}
		}
		if($2->getName()=="*"){
			//ICG
			cd = new string("");
			*cd += ("POP CX\t\t\t\t\t\t;starting *\n");
			*cd += ("POP AX\n");
			*cd += ("IMUL CX\n");
			*cd += ("PUSH AX\t\t\t\t\t\t;ending *\n");
			code<<*cd;
			//$$->setVal(to_string(stoi($1->getVal())*stoi($3->getVal())));
		}
		isConst++;



		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"term : term MULOP unary_expression"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
		//$$->print();
	}
     ;

unary_expression : ADDOP unary_expression  	{
		$$ = new SymbolInfo($1->getName() + $2->getName(), non_token);
		$$->setDataType($2->getDataType());
		$$->setVarType(0);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"unary_expression : ADDOP unary_expression"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;


		//ICG
		codeCom = ";";
		codeCom += ("Line: " + to_string(yylineno)+ " - ");
		codeCom += "unary_expression : ADDOP unary_expression";
		codeCom += "\n";
		code<<codeCom;

		cd = new string("");
		if($1->getName() == "-"){
			//$$->setVal(to_string(-1*stoi($2->getVal())));

			// cd = new string("");
			// *cd += ("MOV CX , [BP+" + to_string(temp->getStackPos()) + "]\t\t\t; loading Variable "+temp->getName() +"\n");
			// *cd += ("NEG CX\n");
			// code<<*cd;
			cd = new string("");
			*cd += ("POP CX\t\t\t\t\t\t;negating\n");
			*cd += ("NEG CX\n");
			*cd += ("PUSH CX\n");
			code<<*cd;
		}
		else{
			//$$->setVal($2->getVal());
		}

		//$$->print();
	}
		 | NOT unary_expression 			{
		$$ = new SymbolInfo("!" + $2->getName(), non_token);
		$$->setDataType($2->getDataType());
		$$->setVarType(0);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"unary_expression : NOT unary_expression"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;

		//ICG
		codeCom = ";";
		codeCom += ("Line: " + to_string(yylineno)+ " - ");
		codeCom += "unary_expression : NOT unary_expression";
		codeCom += "\n";
		code<<codeCom;

		string z = "NOT_Zero" + to_string(notCount);
		string e = "NOT_end" + to_string(notCount);
		notCount++;

		cd = new string("");
		*cd += "POP CX\t\t\t\t\t\t;starting NOT\n";
		*cd += "JCXZ " + z + "\n";
		*cd += "MOV CX , 0\n" ;
		*cd += "JMP " + e + "\n";
		*cd +=  z + ":\n";
		*cd += "MOV CX , 1\n" ;
		*cd +=  e + ":\n";
		*cd += "PUSH CX\t\t\t\t\t\t;ending NOT\n";
		code<<*cd;
		//$$->setVal(to_string(!stoi($2->getVal())));
		//$$->print();
	}
		 | factor 							{
		$$ = new SymbolInfo($1->getName(), non_token);
		$$->setDataType($1->getDataType());
		$$->setVarType($1->getVarType());
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"unary_expression : factor"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;

		//$$->setVal($1->getVal());
		//$$->print();
	}
		 ;
	
factor	: variable 						{
		//ICGEMERGENCY
		//ONLYFORLOCALVAR
		// codeCom = ";";
		// codeCom += ("Line: " + to_string(yylineno)+ " - ");
		// codeCom += "factor	: variable";
		// codeCom += "\n";
		// code<<codeCom;


		$$ = new SymbolInfo(*((SymbolInfo*)$1));
		//$$ = new SymbolInfo($1->getName(), non_token);
		// $$->setDataType($1->getDataType());
		// $$->setVarType($1->getVarType());
		//$1->print();
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"factor : variable"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
		
		//IGC
		cd = new string();
		//if($$->getName() == $$->getVal()){
		if($1->getGlobal() == 1){
			if($1->getSize()>0){ //for array
			//PARTIAL
				*cd += ("POP CX\t\t\t;pushing array "+ $1->getName() +", CX has index\n"); 
				*cd += ("SAL CX , 1\t\t\t\t\t\t;*2 since per index , 2 bytes\n");
				*cd += ("MOV BX , CX\n");
				*cd += ("MOV CX , PTR WORD " + $1->getName() + "[BX]\t\t\t;load global array element\n");
				*cd += ("PUSH CX\t\t\t\t\t\t;store value in stack\n");
				
			}
			else{		
				*cd += ("PUSH " + $$->getName() + "\t\t\t\t\t\t;pushing global variable "+ $$->getName() +"\n") ;
			}
			
		}
		else{
			if($1->getSize()>0){ //for array
				*cd += ("POP CX\t\t\t;pushing array "+ $1->getName() +", CX has index\n"); //
				*cd += ("PUSH BP\t\t\t\t\t\t;need to change and reference BP, [BP+CX] cannot be dereferenced \n");
				*cd += ("SAL CX , 1\t\t\t\t\t\t;*2 since per index , 2 bytes\n");
				*cd += ("ADD CX , " +to_string( $1->getStackPos()) +"\t\t\t\t;access correct byte by adding offset\n");
				*cd += ("ADD BP , CX\t\t\t\t;Change BP to point to correct array elem \n");
				*cd += ("MOV CX , PTR WORD [BP]\t\t;load value pointed to by BP\n");
				*cd += ("POP BP\t\t\t\t\t\t;restore old BP for pointer\n");
				*cd += ("PUSH CX\t\t\t\t\t\t;store value in stack\n");
				
			}
			else{		
				*cd += ("PUSH [BP+" + to_string($$->getStackPos()) + "]\t\t\t\t;pushing variable "+ $$->getName() +"\n") ;
			}
		}
		code<<*cd;
		isConst++;
		//$$->setVal($1->getVal());
	}
	| ID LPAREN argument_list RPAREN	{
		//coutf2<<"Genjam??"<<endl<<endl;
		$$ = new SymbolInfo($1->getName() + "(" + $3->getName() + ")", non_token);

		int fl = 0;
		tempSI2 = ST->LookUpBig($1->getName());
		//cout<<recurFuncName<<"***"<<endl;
		//cout<<$1->getName()<<"*****"<<endl;
		//cout<<($1->getName() != recurFuncName)<<"*****"<<endl;
		if(tempSI2 == nullptr){
			if( recurFuncName == $1->getName()){
				goto recurFuncLabel;
			}
		//if(tempSI2 == nullptr){
			 //cout<<$1->getName()<<"********"<<endl;
			 couterr<<"Error at line "<<yylineno<<": Undeclared function "<< $1->getName() <<endl<<endl;
			 coutf2<<"Error at line "<<yylineno<<": Undeclared function "<< $1->getName() <<endl<<endl;
			errcount++;
			fl++;
			$$->setDataType(" ");
		}
		else if(tempSI2->getVarType() == 3 || tempSI2->getName() == recurFuncName){
			if(tempSI2 ->funcparams.size() == 0 && argstore.size() == 1 && (argstore[0]->getDataType() == "void" || argstore[0]->getDataType() == "VOID")){
            	fl=0;
        	}
        	else if(argstore.size() == 0 && tempSI2->funcparams.size() == 1 && (tempSI2 ->funcparams[0]->getDataType() == "void" || tempSI2 ->funcparams[0]->getDataType() == "VOID")){
            	fl=0;
        	}
			else if(tempSI2 ->funcparams.size() != argstore.size()){
				 
				 couterr<<"Error at line "<<yylineno<<": Total number of arguments mismatch in function "<< $1->getName() <<endl<<endl;
				 coutf2<<"Error at line "<<yylineno<<": Total number of arguments mismatch in function "<< $1->getName() <<endl<<endl;
				errcount++;
				fl=1;
			}
			else{
				for(int i=0;i<argstore.size();i++){
					if(tempSI2 ->funcparams[i]->getDataType()!=argstore[i]->getDataType()){
						//  tempSI2->print();
						//  argstore[i]->print();
						 couterr<<"Error at line "<<yylineno<<": "<<i+1<< "th argument mismatch in function "<< $1->getName() <<endl<<endl;
						 coutf2<<"Error at line "<<yylineno<<": "<<i+1<< "th argument mismatch in function "<< $1->getName() <<endl<<endl;
						errcount++;
						fl=1;
						break;
					}
				}
			}
			if(fl==0){
				$$->setDataType(tempSI2->getDataType());
				$$->setVarType(tempSI2->getVarType());
				$$->setSize(tempSI2->getSize());
				for(int i=0;i<$1->funcparams.size();i++){
					$$->funcparams[i] = $1->funcparams[i];
				}
			}
			else{
				$$->setDataType(" ");
			}
			
			
			//$$->print();
		}
		else{
			 
			 couterr<<"Error at line "<<yylineno<<": Undefined function "<< $1->getName() <<endl<<endl;
			 coutf2<<"Error at line "<<yylineno<<": Undefined function "<< $1->getName() <<endl<<endl;
			errcount++;
			$$->setDataType(" ");
		}
		 
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"factor : ID LPAREN argument_list RPAREN"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
		



		isConst++;
		//cout<<"Debug"<<endl;


		//ICG

		recurFuncLabel:
		 cd = new string("");
		// for(int i=argstore.size()-1;i>=0;i--){
		// 	//cout<<"Debug"<<endl;
		// 	tempSI2 = ST->LookUpCurr(argstore[i]->getName());
		// 	//cout<<"Debug"<<endl;
		// 	*cd += "MOV CX , [BP+" + to_string(tempSI2->getStackPos()) + "]\t\t\t;loading args\n" ;
		// 	*cd += "PUSH CX\n";
		// }
		 *cd += "CALL " + $1->getName() + "\n";
		 *cd += "POP CX\n";
		 *cd += "ADD SP , " + to_string(argstore.size()*2)+ "\t\t\t\t\t;removing args\n";
		 *cd += "PUSH CX\n";
		 code<<*cd;

		// cout<<argstore.size()*2<<endl;


		//$$->print();


		argstore.clear();
	}
	| LPAREN expression RPAREN			{
		$$ = new SymbolInfo("(" + $2->getName() + ")", non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"factor : LPAREN expression RPAREN"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
		$$->setDataType($2->getDataType());
		$$->setVarType($2->getVarType());

		//$$->setVal($2->getVal());
	}
	| CONST_INT 						{
		tempSI2 = new SymbolInfo($1->getName(),$1->getType());
		tempSI2->setDataType("int");
		//ST->Insert(tempSI2,coutdummy);
		$$ = new SymbolInfo($1->getName(), non_token);
		$$->setDataType("int");
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"factor : CONST_INT"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;

		isConst = 0;
		//IGC
		$$->setVal(to_string(stoi($1->getVal())));
		cd = new string();
		*cd += ("PUSH " + ($$->getVal()) + "\t\t\t\t\t\t;pushing constant\n");
		code<<*cd;
		//$$->print();
	}
	| CONST_FLOAT						{
		tempSI2 = new SymbolInfo($1->getName(),$1->getType());
		tempSI2->setDataType("float");
		//ST->Insert(tempSI2,coutdummy);
		$$ = new SymbolInfo($1->getName(), non_token);
		$$->setDataType("float");
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"factor : CONST_FLOAT"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
		
		
		//FLOAT ERROR
		isConst = 0;
		//ICG
		//$$->setVal($1->getVal());
		cd = new string();
		*cd += ("PUSH " + ($$->getVal()) + "\t\t\t\t\t\t;pushing constant\n");
		code<<*cd;
		
		
		couterr<<"Error at line "<<yylineno<<": Float not supported "<< $1->getVal() <<endl<<endl;
		coutf2<<"Error at line "<<yylineno<<": Float not supported "<< $1->getVal() <<endl<<endl;
		errcount++;
		$$->setVal(to_string(stoi($1->getVal())));
		//$$->setDataType(" ");
	}
	| variable INCOP 					{
		$$ = new SymbolInfo($1->getName() + "++", non_token);
		$$->setDataType($1->getDataType());
		$$->setVarType($1->getVarType());
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"factor : variable INCOP"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
		// PUSH BP
		// SAL CX , 1
		// ADD CX , -10
		// ADD BP , CX
		// MOV CX , PTR WORD [BP]
		// MOV AX , CX
		// ADD AX , 1
		// MOV PTR WORD [BP] , AX
		// POP BP
		cd = new string("");
		if($1->getSize()>0){
			*cd += ("POP CX\t\t\t\t;incrementing array "+ $1->getName() +", CX has index\n"); //
			*cd += ("PUSH BP\t\t\t\t\t\t;need to change and reference BP, [BP+CX] cannot be dereferenced \n");
			*cd += ("SAL CX , 1\t\t\t\t\t\t;*2 since per index , 2 bytes\n");
			*cd += ("ADD CX , " +to_string( $1->getStackPos()) +"\t\t\t\t;access correct byte by adding offset\n");
			*cd += ("ADD BP , CX\t\t\t\t;Change BP to point to correct array elem \n");
			*cd += ("MOV CX , PTR WORD [BP]\t\t;load value pointed to by BP\n");
			*cd += ("MOV AX , CX\n");
			*cd += ("ADD AX , 1\n");
			*cd += ("MOV PTR WORD [BP] , AX\t\t;load value pointed to by BP\n");
			*cd += ("POP BP\t\t\t\t\t\t;restore old BP for pointer\n");
			*cd += ("PUSH CX\t\t\t\t\t\t;store value in stack\n");
		}
		else{
			// MOV CX , -2[BP]
			// MOV AX , CX
			// ADD AX , 1
			// MOV -2[BP] , AX
			*cd += ("MOV CX , [BP+" + to_string($1->getStackPos()) + "]\t\t\t;IncOp for Variable\n");
			*cd += ("MOV AX , CX\n");
			*cd += ("ADD AX , 1\n");
			*cd += ("MOV [BP+" + to_string($1->getStackPos()) + "] , AX\t\t\t;IncOp for Variable\n");
			*cd += ("PUSH CX\n");

		}
		code<<*cd;
		isConst++;
	}
	| variable DECOP					{
		$$ = new SymbolInfo($1->getName() + "--", non_token);
		$$->setDataType($1->getDataType());
		$$->setVarType($1->getVarType());
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"factor : variable DECOP"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;

		cd = new string("");
		if($1->getSize()>0){
			*cd += ("POP CX\t\t\t\t;incrementing array "+ $1->getName() +", CX has index\n"); //
			*cd += ("PUSH BP\t\t\t\t\t\t;need to change and reference BP, [BP+CX] cannot be dereferenced \n");
			*cd += ("SAL CX , 1\t\t\t\t\t\t;*2 since per index , 2 bytes\n");
			*cd += ("ADD CX , " +to_string( $1->getStackPos()) +"\t\t\t\t;access correct byte by adding offset\n");
			*cd += ("ADD BP , CX\t\t\t\t;Change BP to point to correct array elem \n");
			*cd += ("MOV CX , PTR WORD [BP]\t\t;load value pointed to by BP\n");
			*cd += ("MOV AX , CX\n");
			*cd += ("SUB AX , 1\n");
			*cd += ("MOV PTR WORD [BP] , AX\t\t;load value pointed to by BP\n");
			*cd += ("POP BP\t\t\t\t\t\t;restore old BP for pointer\n");
			*cd += ("PUSH CX\t\t\t\t\t\t;store value in stack\n");
		}
		else{
			// MOV CX , -2[BP]
			// MOV AX , CX
			// ADD AX , 1
			// MOV -2[BP] , AX
			*cd += ("MOV CX , [BP+" + to_string($1->getStackPos()) + "]\t\t\t;IncOp for Variable\n");
			*cd += ("MOV AX , CX\n");
			*cd += ("SUB AX , 1\n");
			*cd += ("MOV [BP+" + to_string($1->getStackPos()) + "] , AX\t\t\t;IncOp for Variable\n");
			*cd += ("PUSH CX\n");

		}
		code<<*cd;


		isConst++;
	}
	//ERRORRECOVERY
	| ID LPAREN error RPAREN	{
		yyclearin; /* discard lookahead */
 				yyerrok;
				errcount++;
				couterr<<"Syntax Error at line no "<<yylineno<<": in argument list of function call" <<endl<<endl;
				coutf2<<"Syntax Error at line no "<<yylineno<<": in argument list of function call" <<endl<<endl;
		$$ = new SymbolInfo($1->getName() + "( *** )", non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"factor : ID LPAREN argument_list RPAREN"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
		argstore.clear();
	
	}
	//ERRORRECOVERY
	| LPAREN error RPAREN			{
		yyclearin; /* discard lookahead */
 				yyerrok;
				errcount++;
				couterr<<"Syntax Error at line no "<<yylineno<<": in a factor" <<endl<<endl;
				coutf2<<"Syntax Error at line no "<<yylineno<<": in a factor" <<endl<<endl;
		$$ = new SymbolInfo("( *** )", non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"factor : LPAREN expression RPAREN"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
		//$$->setDataType($2->getDataType());
		//$$->setVarType($2->getVarType());
	}
	
	;
	
argument_list : arguments				{
	//coutf2<<"Genjam?20"<<endl<<endl;
		$$ = new SymbolInfo($1->getName(), non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"argument_list : arguments"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
	}
			 |  {
		tempSI2 = new SymbolInfo("", non_token);
		tempSI2->setDataType("void");
		argstore.push_back(tempSI2);
		$$ = new SymbolInfo("", non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"argument_list : "<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
	}
			  ;
	
arguments : arguments COMMA logic_expression	{
		$$ = new SymbolInfo($1->getName() + ", " + $3->getName() , non_token);
		tempSI2 = new SymbolInfo($3->getName(), non_token);
		tempSI2->setDataType($3->getDataType());
		//tempSI2->print()
		//$3->print();
		argstore.push_back(tempSI2);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"arguments : arguments COMMA logic_expression"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
	}
	      | logic_expression					{
	//coutf2<<"Genjam?21"<<endl<<endl;
		$$ = new SymbolInfo($1->getName(), non_token);
		tempSI2 = new SymbolInfo($1->getName(), non_token);
		tempSI2->setDataType($1->getDataType());
		//$1->print();
		argstore.push_back(tempSI2);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"argument_list : logic_expression"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
	}
	      ;
 

%%
int main(int argc,char *argv[])
{
	//FILE fp = new FILE("input.txt");
	
	/*
	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}

	fp2= fopen(argv[2],"w");
	fclose(fp2);
	fp3= fopen(argv[3],"w");
	fclose(fp3);
	
	fp2= fopen(argv[2],"a");
	fp3= fopen(argv[3],"a");
	

	yyin=fp;*/
	yyin=fopen(argv[1],"r");
	yyparse();
	
	//
	code.close();
	code2.close();
	ofstream code("1805006_code.txt");
	ifstream code2("1805006_code2.txt");
	ifstream code3("1805006_code3.txt"); 
  	string s;
	while(getline(code2, s)){ 
         code<<s; 
         code<<"\n";
    }
	while(getline(code3, s)){ 
         code<<s;
         code<<"\n";
    }

   
	code.close();
	code2.close();
	code3.close();





	//Optimize

	ifstream f1("1805006_code.txt");
	//ifstream f1("testcode.txt");
    ofstream f2("1805006_optimizedcode.txt");
    ofstream f3("1805006_garbage.txt");

    string temp;


    vector<string> lines;

    while(getline(f1, temp)) {
        lines.push_back(temp);
        //cout<<"---"<<temp<<endl;
    }


    for(int i=0;i<lines.size();i++){
        mySplit(lines[i],' ','\t', i);
        //cout<<endl;
    }

    f1.close();
    ifstream f4("1805006_code.txt");
	//ifstream f4("testcode.txt");
    string temp2;
    for(int i = 0; i<strings.size();i++){
		//cout<<i<<"---"<<strings.size()<<endl;
		//cout<<strings[i][0]<<endl;
        int corr = 0;
        if(strings[i][0] == "MOV"){
			corr++;
			int y = i+1;
			string t2;
			getline(f4,t2);
			//cout<<"****+++"<<t2<<endl;
			while(y<strings.size()){
				if(strings[y][0][0] == ';'){
					//cout<<"B2"<<endl;
					y++;
					getline(f4,temp2);
					f2<<temp2;
					f2<<"\n";
				} 
				else break;
			}
			if(y>=strings.size()){
				//cout<<"B3"<<endl;
				f2<<t2;
				f2<<"\n";
				i=y;
			}
			else if(strings[y][0] == "MOV" && strings[i][1] == strings[y][3] && strings[i][3] == strings[y][1]){
				//cout<<" "<<strings[y][0]<<" "<<strings[i][1]<<" "<<strings[y][3]<<" "<<strings[y][1]<<" "<<strings[i][3]<<endl;
				f2<<t2;
				f2<<"\n";
				//cout<<"****"<<t2<<endl;
				getline(f4,temp2);
				f2<<";";
				f2<<temp2<<endl;
				f2<<"\n";
				//cout<<"******"<<temp2<<endl;
				f3<<"Line "<< y <<": "<<temp2<<"\n";

				i = y;
				//corr++;
            }
			else{
				//corr++;
				i=y-1;
				f2<<t2;
				f2<<"\n";
			}
			/* if(strings[][0] == "MOV" && strings[i][1] == strings[i+1][3] && strings[i][3] == strings[i+1][1]){
                getline(f4,temp2);
                f2<<temp2;
                f2<<"\n";
                getline(f4,temp2);
                f2<<";";
                f2<<temp2;//f2 replace with f3 for garbage collect
	             f2<<"\n";
                f3<<"Line "<< i+2 <<": "<<temp2<<"\n";
                i++;
                corr++;
            } */

            

        }
        else if(strings[i][0] == "PUSH"){
			int y = i+1;
			string t2;
			getline(f4,t2);
			//cout<<"****+++"<<t2<<endl;
			corr++;
			while(y<strings.size()){
				if(strings[y][0][0] == ';'){
					y++;
					getline(f4,temp2);
					f2<<temp2;
					f2<<"\n";
				} 
				else break;
			}
			if(y>=strings.size()){
				//cout<<"B3"<<endl;
				f2<<t2;
				f2<<"\n";
				i=y;
			}
			else if(strings[y][0] == "POP" && strings[i][1] == strings[y][1]){
				
				//cout<<"-----2--------"<<endl;
				f2<<";";
				f2<<t2;
				f2<<"\n";

				f3<<"Line "<< i <<": "<<t2<<"\n";
				
				getline(f4,temp2);
				f2<<";";
				f2<<temp2;
				f2<<"\n";

				f3<<"Line "<< y <<": "<<temp2<<"\n";

				i = y;
				//corr++;
            }
			else{
				//corr++;
				i=y-1;
				f2<<t2;
				f2<<"\n";
			}


 
            /* if(i+1<strings.size()){
				if(strings[i+1][0][0] != ';'){
					cout<<"1"<<endl;
					if(strings[i+1][0] == "POP" && strings[i][1] == strings[i+1][1]){
						cout<<"-----2--------"<<endl;
						getline(f4,temp2);
						f2<<";";
						f2<<temp2;
						f2<<"\n";

						f3<<"Line "<< i+1 <<": "<<temp2<<"\n";

						getline(f4,temp2);
						f2<<";";
						f2<<temp2;//f2 replace with f3 for garbage collect
						f2<<"\n";

						f3<<"Line "<< i+2 <<": "<<temp2<<"\n";
						i++;
						corr++;
                	}
				}
				else{
					if(i+2<strings.size()){
						if(strings[i+2][0] == "POP" && strings[i][1] == strings[i+2][1]){
							getline(f4,temp2);
							f2<<";";
							f2<<temp2;
							f2<<"\n";

							f3<<"Line "<< i+1 <<": "<<temp2<<"\n";

							getline(f4,temp2);
							f2<<temp2;
							f2<<"\n";

							//f3<<"Line "<< i+1 <<": "<<temp2<<"\n";

							getline(f4,temp2);
							f2<<";";
							f2<<temp2;//f2 replace with f3 for garbage collect
							f2<<"\n";

							f3<<"Line "<< i+2 <<": "<<temp2<<"\n";
							i++;
							i++;
							corr++;
						}
					}
					
				}
                
            }  */

        }
        if(corr == 0){
                getline(f4,temp2);
				//cout<<"****+++"<<temp2<<endl;
                f2<<temp2;
                f2<<"\n";
        }
//        for(int j = 0; j< strings[i].size(); j++){
//            cout<<strings[i][j]<<", ";
//        }
//        cout<<endl;
    }
	f2.close();
	f3.close();
	f4.close();












	cout<<"Error Count: "<<errcount<<endl;
	if(errcount>0){
		ofstream f1("1805006_code.txt");
		ofstream f2("1805006_optimizedcode.txt");
		ofstream f3("1805006_garbage.txt");
		f1<<"";
		f2<<"";
		f3<<"";
		f1.close();
		f2.close();
		f3.close();
		//cout<<"ERROR"<<endl;
	}

	/* fclose(fp2);
	fclose(fp3); */
	remove("1805006_dummy.txt");
	remove("1805006_log2.txt");
	remove("1805006_token2.txt");

	remove("1805006_code2.txt");
	remove("1805006_code3.txt");
	return 0;
}

