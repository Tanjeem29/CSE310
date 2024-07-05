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
SymbolInfo* tempSI2;
int begfuncline;
int endfuncline;



ofstream coutf2("1805006_log.txt");
//ofstream couterr("1805006_error.txt");
ofstream coutdummy("1805006_dummy.txt");
extern ofstream couterr;
void yyerror(char *s)
{
	//write your code
}


%}
%union{
	SymbolInfo *SI;
} 

%token <SI> IF ELSE FOR WHILE ID LPAREN RPAREN SEMICOLON COMMA LCURL RCURL DOUBLE CHAR MAIN INT FLOAT VOID LTHIRD CONST_INT CONST_CHAR RTHIRD PRINTLN RETURN ASSIGNOP LOGICOP RELOP ADDOP MULOP CONST_FLOAT NOT INCOP DECOP 
%token <SI> SWITCH CASE DEFAULT DO BREAK CONTINUE


%type <SI> start program unit var_declaration func_declaration func_definition type_specifier parameter_list compound_statement statements declaration_list statement expression_statement expression variable logic_expression rel_expression simple_expression term unary_expression factor argument_list arguments

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : program
	{
		//write your code in this block in all the similar blocks below
		$$ = new SymbolInfo($1->getName() + " ", non_token);
		
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

func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement {
		//coutf2<<"GENJAAAAAM3"<<endl<<endl;

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
			if(returnType->getDataType() == tempSI2->getDataType() || (tempSI2->getDataType() == "float" && returnType->getDataType() == "int") ){
				ST->Insert(tempSI2, coutdummy);
				returnType ->setDataType("void");
			}
			else{
				couterr<<"Error at line "<<yylineno - (endfuncline - begfuncline + 1)<<": Return type mismatch of "<< tempSI2->getName() <<endl<<endl;
				 coutf2<<"Error at line "<<yylineno - (endfuncline - begfuncline + 1)<<": Return type mismatch of "<< tempSI2->getName() <<endl<<endl;
				errcount++;
				ST->Insert(tempSI2, coutdummy);
				returnType ->setDataType("void");
			}
			//ST->printAll2(coutf2);
			//tempSI2->print();
		}
		paramstore.clear();
		paramstoretemp.clear();



		$$ = new SymbolInfo($1->getName() + " " + $2->getName() + "(" + $4->getName() + ")" + $6->getName() , non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
		//ST->printAll2(coutf2);
	}
		| type_specifier ID LPAREN RPAREN compound_statement						{
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
			if(returnType->getDataType() == tempSI2->getDataType() || (tempSI2->getDataType() == "float") && (returnType->getDataType() == "int") ){
				ST->Insert(tempSI2, coutdummy);
				returnType ->setDataType("void");
			}
			else{
				couterr<<"Error at line "<<yylineno - (endfuncline - begfuncline + 1)<<": Return type mismatch of "<< tempSI2->getName() <<endl<<endl;
				 coutf2<<"Error at line "<<yylineno - (endfuncline - begfuncline + 1)<<": Return type mismatch of "<< tempSI2->getName() <<endl<<endl;
				errcount++;
				ST->Insert(tempSI2, coutdummy);
				returnType ->setDataType("void");
			}
			//ST->Insert(tempSI2, coutdummy);
			//tempSI2->print();
			
		}
		paramstore.clear();
		paramstoretemp.clear();


		$$ = new SymbolInfo($1->getName() + " " + $2->getName() + "()" + $5->getName(), non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"func_definition : type_specifier ID LPAREN RPAREN compound_statement"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
		ST->printAll2(coutf2);
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
							for(auto a : paramstoretemp){
								ST->Insert(a, coutdummy);
							}
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
		for(int i=0;i<varstore.size();i++){
			 
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
				ST->Insert(tempSI2, coutdummy);
			}
			
		}
		// for(auto a: varstore){
		// 	(ST->LookUpCurr(a->getName()))->print();
		// }
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
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement	{
		$$ = new SymbolInfo("for(" + $3->getName() + $4->getName() + $5->getName() + ")\n" + $7->getName()  , non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
	}
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE												{
		$$ = new SymbolInfo("if(" + $3->getName() + ")\n" + $5->getName()  , non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"statement : IF LPAREN expression RPAREN statement"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
	}
	  | IF LPAREN expression RPAREN statement ELSE statement								{
		$$ = new SymbolInfo("if(" + $3->getName() + ")\n" + $5->getName() + "\nelse\n" + $7->getName() , non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"statement : IF LPAREN expression RPAREN statement ELSE statement"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
	}
	  | WHILE LPAREN expression RPAREN statement											{
		$$ = new SymbolInfo("while(" + $3->getName() + ")\n" + $5->getName(), non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"statement : WHILE LPAREN expression RPAREN statement"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
	}
	  | PRINTLN LPAREN ID RPAREN SEMICOLON													{

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
	}
	  | RETURN expression SEMICOLON															{
		$$ = new SymbolInfo("return " + $2->getName() + ";", non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"statement : RETURN expression SEMICOLON"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;

		returnType ->setDataType($2->getDataType());
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
		
		if(tempSI2 == nullptr){
			if(tempSI3 != nullptr){
				if(tempSI3->getVarType() == 0){
					$$->setDataType(tempSI3->getDataType()); //parent scope variable
					$$->setVarType(tempSI3->getVarType());
					$$->setSize(tempSI3->getSize());
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
			$$->setDataType(tempSI2->getDataType());
			$$->setVarType(tempSI2->getVarType());
			$$->setSize(tempSI2->getSize());
			 couterr<<"Error at line "<<yylineno<<": Type Mismatch, "<< $1->getName()<<" is not a Single Variable" <<endl<<endl;
			 coutf2<<"Error at line "<<yylineno<<": Type Mismatch, "<< $1->getName()<<" is not a Single Variable" <<endl<<endl;
			errcount++;
		}
		else{
			//tempSI2->print();
			//cout<<tempSI2->getDataType()<<endl;
			$$->setDataType(tempSI2->getDataType());
			$$->setVarType(tempSI2->getVarType());
			$$->setSize(tempSI2->getSize());
		}
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"variable : ID"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
		//$$->print();
		//if(tempSI2!=nullptr)tempSI2->print();
		//if(tempSI3!=nullptr)tempSI3->print();
	}
	 | ID LTHIRD expression RTHIRD 		{
		//coutf2<<"---------GENJAM17"<<endl<<endl;
		$$ = new SymbolInfo($1->getName() + "[" + $3->getName() + "]", non_token);
		SymbolInfo* tempSI3 = ST->LookUpBig($1->getName());
		tempSI2 = ST->LookUpCurr($1->getName());
		if(tempSI2 == nullptr){
			//  
			//  couterr<<"Error at line "<<yylineno<<"  Undeclared Variable "<< $1->getName() <<endl<<endl;
			if(tempSI3 != nullptr){
				if(tempSI3->getVarType() == 1){
					$$->setDataType(tempSI3->getDataType()); //a global variable
					$$->setVarType(tempSI3->getVarType());
					$$->setSize(tempSI3->getSize());
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
			$$->setDataType(tempSI2->getDataType());
			$$->setVarType(tempSI2->getVarType());
			$$->setSize(tempSI2->getSize());
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
		couterr<<"Syntax Error at line no "<<yylineno<<": in argument list of function call" <<endl<<endl;
		coutf2<<"Syntax Error at line no "<<yylineno<<": in argument list of function call" <<endl<<endl;
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
		//$$->print();
	}
	   | variable ASSIGNOP logic_expression 	{
		$$ = new SymbolInfo($1->getName() +  " = " + $3->getName(), non_token);
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
		if($2->getName()=="%"){
			if(stoi($3->getName())==0){
				 
				 couterr<<"Error at line "<<yylineno<<": Modulus by 0 "<<endl<<endl;
				 coutf2<<"Error at line "<<yylineno<<": Modulus by 0 "<<endl<<endl;
				errcount++;
				$$->setDataType(" ");
			}
		}
		if($2->getName()=="/"){
			if(stoi($3->getName())==0){
				 
				 couterr<<"Error at line "<<yylineno<<": Divide by 0 "<<endl<<endl;
				 coutf2<<"Error at line "<<yylineno<<": Divide by 0 "<<endl<<endl;
				errcount++;
				$$->setDataType(" ");
			}
		}
		
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
		//$$->print();
	}
		 | NOT unary_expression 			{
		$$ = new SymbolInfo("!" + $2->getName(), non_token);
		$$->setDataType($2->getDataType());
		$$->setVarType(0);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"unary_expression : NOT unary_expression"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
		//$$->print();
	}
		 | factor 							{
		$$ = new SymbolInfo($1->getName(), non_token);
		$$->setDataType($1->getDataType());
		$$->setVarType($1->getVarType());
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"unary_expression : factor"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
		//$$->print();
	}
		 ;
	
factor	: variable 						{
		$$ = new SymbolInfo($1->getName(), non_token);
		$$->setDataType($1->getDataType());
		$$->setVarType($1->getVarType());
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"factor : variable"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
	}
	| ID LPAREN argument_list RPAREN	{
		//coutf2<<"Genjam??"<<endl<<endl;
		$$ = new SymbolInfo($1->getName() + "(" + $3->getName() + ")", non_token);

		int fl = 0;
		tempSI2 = ST->LookUpBig($1->getName());
		if(tempSI2 == nullptr){
			 
			 couterr<<"Error at line "<<yylineno<<": Undeclared function "<< $1->getName() <<endl<<endl;
			 coutf2<<"Error at line "<<yylineno<<": Undeclared function "<< $1->getName() <<endl<<endl;
			errcount++;
			fl++;
			$$->setDataType(" ");
		}
		else if(tempSI2->getVarType() == 3){
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
		argstore.clear();
		//$$->print();
	}
	| LPAREN expression RPAREN			{
		$$ = new SymbolInfo("(" + $2->getName() + ")", non_token);
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"factor : LPAREN expression RPAREN"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
		$$->setDataType($2->getDataType());
		$$->setVarType($2->getVarType());
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
	}
	| variable INCOP 					{
		$$ = new SymbolInfo($1->getName() + "++", non_token);
		$$->setDataType($1->getDataType());
		$$->setVarType($1->getVarType());
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"factor : variable INCOP"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
	}
	| variable DECOP					{
		$$ = new SymbolInfo($1->getName() + "--", non_token);
		$$->setDataType($1->getDataType());
		$$->setVarType($1->getVarType());
		coutf2<<"Line "<<yylineno<<": ";
		coutf2<<"factor : variable DECOP"<<endl<<endl;
		coutf2<<$$->getName()<<endl<<endl;
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
	

	/* fclose(fp2);
	fclose(fp3); */
	remove("1805006_dummy.txt");
	remove("1805006_log2.txt");
	remove("1805006_token2.txt");
	return 0;
}

