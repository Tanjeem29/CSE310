#pragma once
#include<iostream>
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
        cout<<"New ScopeTable with id "<< curr->getID() <<" created"<< endl;
    }

    void deleteScope(){
        ScopeTable* prev = curr->getParent();
        cout<<"ScopeTable with id "<<curr->getID()<<" removed"<<endl;
        delete curr;
        curr = prev;
    }

    bool Insert(SymbolInfo *s){
        return curr->Insert(s);
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
                cout<<"Not Found in SymbolTable"<<endl;
                return nullptr;
            }
            ret = temp->LookUp(s);
        }
        if(curr == temp){
            cout<<"(Current)";
        }
        cout<<endl;
        return ret;
    }

    void printCurr(){
        curr->printTable();
        cout<<endl;
    }
    void printAll(){
        ScopeTable* temp;
        temp = curr;
        while(temp!=nullptr){
            temp->printTable();
            temp = temp->getParent();
            cout<<endl;
        }
    }

};
