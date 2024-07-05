#pragma once
#include<iostream>
#include<fstream>
#include<string>
#include "1805006SymbolInfo.h"
#include "1805006Hash.h"
#include "1805006ScopeTable.h"

using namespace std;

class SymbolTable{
private:
    int TotalBuckets;
    ScopeTable* root;
    ScopeTable* curr;
public:
    SymbolTable(int tb){
        root = new ScopeTable(tb, nullptr);
        curr = root;
        TotalBuckets = tb;
    }
    ~SymbolTable(){
        ScopeTable *temp;
        while(root!=curr){
            temp = curr;
            curr = curr->getChild();
            delete temp;
        }
        delete root;
    }
    int getTotalBuckets(){
        return TotalBuckets;
    }

    void enterScope(){
        ScopeTable *temp = new ScopeTable(getTotalBuckets(), curr);
        curr = temp;
        //cout<<"New ScopeTable with id "<< curr->getID() <<" created"<< endl;
    }

    void deleteScope( ofstream& coutf){
        ScopeTable* prev = curr->getParent();
        if(curr->getID() == "1"){
            //cout<<"Final Scope. Delete unsuccessful"<<endl;
            //delete curr;
            return;
        }
        if(prev->getID() == "1"){
            delete curr;
            curr = prev;
            //printAll2(coutf);
            return;
        }
        //printAll2(coutf);
        //cout<<"ScopeTable with id "<<curr->getID()<<" removed"<<endl;
        delete curr;
        curr = prev;
    }

    bool Insert(SymbolInfo *s, ofstream& coutf){
        //return curr->Insert(s);
        //cout<<"SymTInsert"<<endl;
        bool ans = curr->Insert(s);
        if(ans)
            printAll2(coutf);
        return ans;
    }
    bool RemoveSymbolInfo(SymbolInfo *s){
        return RemoveVal(s->getName());
    }

    bool RemoveVal(string s){
        return curr->deleteVal(s);
    }
    SymbolInfo * LookUpBig(string s){
        ScopeTable * temp = curr;
        SymbolInfo * ret = curr->LookUp(s);
        while(ret==nullptr){
            temp = temp->getParent();
            if(temp == nullptr){
                //cout<<"Not Found in SymbolTable"<<endl;
                return nullptr;
            }
            ret = temp->LookUp(s);
        }
        if(curr == temp){
            //cout<<"(Current)";
        }
        //cout<<endl;
        return ret;
    }
    SymbolInfo * LookUpCurr(string s){
        
        return curr->LookUp(s);
    }

    void printCurr(){
        curr->printTable();
        //cout<<endl;
    }
    void printAll(){
        ScopeTable* temp;
        temp = curr;
        while(temp!=nullptr){
            temp->printTable();
            temp = temp->getParent();
            //cout<<endl;
        }
    }
    void printAll2(ofstream& coutf){
        ScopeTable* temp;
        temp = curr;
        while(temp!=nullptr){
            temp->printTable2(coutf);
            temp = temp->getParent();
            coutf<<endl;
        }
    }
    string getCurrID(){
        return curr->getID();
    }
    

};
