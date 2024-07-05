#pragma once
#include<iostream>
#include<string>
#include<bits/stdc++.h>


using namespace std;

class SymbolInfo {
  private:
    string *name;
    string *type; //tokenType;
    SymbolInfo *next;
    //only for token type ID
    int varType=0; // 0 == variable, 1 == array, 2 == funcDeclaration, 3 == funcDefinition
    int size=0; // for array type, else don't use.
    string *dataType; //int or  float or void(func only)
    int global=0;//for global variables and arrays;

    //for ICG
    int dataSize = 2; //2 bytes == 16 bits for integers (only int in Offline 4)
    int stackPos = 0; //position relative to Base pointer for variables, Base pointer for Function;
    int retPos; //restore old stackpointer for after function ends
    string *value; //for storing int type values;
    string *cd;

  public:
    vector<SymbolInfo*> funcparams;
    ///constructors
    SymbolInfo(){
        next = nullptr;
        name = new string("");
        type = new string("");
        dataType = new string("");
        value = new string("");
        cd = new string("");
         
    }
    SymbolInfo(string n, string t){
        name = new string(n);
        type = new string(t);
        next = nullptr;
        dataType = new string("");
        value = new string("");
        cd = new string(""); 
    }
    SymbolInfo(const SymbolInfo &x){
        name = new string(*(x.name));
        type = new string(*(x.type));
        next = x.next;
        dataType = new string(*(x.dataType));
        varType = x.varType;
        funcparams = x.funcparams;
        size = x.size;
        global = x.global;
        value = new string(*(x.value));
        dataSize = x.dataSize;
        retPos = x.retPos;
        stackPos = x.stackPos;
        cd = new string(*(x.cd)); 
    }
    ///Destructor
    ~SymbolInfo(){
        delete name;
        delete type;
        delete dataType;
        delete value;
    }
    //VariableType
    int getVarType(){
        return varType;
    }
    void setVarType(int x){
        varType = x;
    }

    ///DataType
    string getDataType(){
        return *dataType;
    }
    void setDataType(string t){
        *dataType = t;
    }

    ///Name
    string getName(){
        //cout<<"name"<<endl;
        return *name;
    }
    void setName(string n){
        *name = n;
    }


    ///Type
    string getType(){
        return *type;
    }
    void setType(string t){
        *type = t;
    }

    //Size
    int getSize(){
        return size;
    }
    void setSize(int x){
        size = x;
    }
    //global
    void setGlobal(){
        global = 1;
    }
    void resetGlobal(){
        global = 0;
    }
    int getGlobal(){
        return global;
    }

    ///next
    SymbolInfo* getNext(){
        return next;
    }

    void setNext(SymbolInfo* s){
        next = s;
    }

    void print(){
        cout<<getName()<<" "<<getType()<<" "<<getDataType()<<" "<<getSize()<<" "<<getVarType()<<" "<<getGlobal()<<" "<<getStackPos() <<" "<<getVal() <<endl;
        for(auto p : funcparams){
            cout<<" -- ";
            p->print();
            cout<<endl;
        }
    }
    //funcparamschecks
    int isUnequalFunc(SymbolInfo* SI){
        if(SI ->funcparams.size() == 0 && funcparams.size() == 1 && (funcparams[0]->getDataType() == "void" || funcparams[0]->getDataType() == "VOID")){
            return 0;
        }
        if(funcparams.size() == 0 && SI->funcparams.size() == 1 && (SI ->funcparams[0]->getDataType() == "void" || SI ->funcparams[0]->getDataType() == "VOID")){
            return 0;
        }
        if(SI ->funcparams.size() != funcparams.size()){
            //cout<<"Param Number Mismatch"<<endl;
            return 1;
        }
        if(SI->getDataType()!= getDataType()){
            //cout<<"Return Type mismatch"<<endl;
            return 3;
        }
        for(int i=0;i<funcparams.size();i++){
            if(SI ->funcparams[i]->getDataType()!=funcparams[i]->getDataType()){
                //cout<<"Param DataType Mismatch"<<endl;
                return 2;
            }
        }

        return 0;
    }
    void addParam(SymbolInfo* SI){
        funcparams.push_back(SI);
    }


    //For ICG

    int getDataSize(){
        return dataSize;
    }

    void setStackPos(int sp){   //
        stackPos = sp;
    }
    int getStackPos(){
        return stackPos;
    }

    void setVal(string x){
        value = new string(x);
    }

    string getVal(){
        return *value;
    }
    int getValInt(){
        return stoi(*value);
    }



};



