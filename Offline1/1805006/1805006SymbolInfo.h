#pragma once
#include<iostream>
#include<string>

using namespace std;


class SymbolInfo {
  private:
    string *name;
    string *type;
    SymbolInfo *next;
  public:

    ///constructors
    SymbolInfo(){
        next = nullptr;
        name = new string("");
        type = new string("");
    }
    SymbolInfo(string n, string t){
        name = new string(n);
        type = new string(t);
        next = nullptr;
    }
    SymbolInfo(const SymbolInfo &x){
        name = new string(*(x.name));
        type = new string(*(x.type));
        next = x.next;
    }
    ///Destructor
    ~SymbolInfo(){
        delete name;
        delete type;
    }



    ///Name
    string getName(){
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


    ///next
    SymbolInfo* getNext(){
        return next;
    }

    void setNext(SymbolInfo* s){
        next = s;
    }

    void print(){
        cout<<"< "<<getName()<< ", "<< getType()<<" >";
    }


};


