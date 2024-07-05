#pragma once
#include<iostream>
#include<string>
#include<fstream>
#include "1805006SymbolInfo.h"
#include "1805006Hash.h"
using namespace std;

class ScopeTable{
private:
    int TotalBuckets;
    ScopeTable * parent;
    ScopeTable * child;
    int childNum;
    int myNum;
    string ID;
    SymbolInfo ** Hashtable;

public:

    ScopeTable(int tb, ScopeTable *p){
        Hashtable = new SymbolInfo*[tb];
        for(int i=0;i<tb;i++){
            Hashtable[i] = nullptr;
        }
        TotalBuckets = tb;
        this->parent = p;
        this->childNum = 0;
        if(p!=nullptr){
            p->setChild(this);
        }


        if(p != nullptr){
            myNum = ++(p->childNum);
            ID = (p->ID) + "." + to_string(myNum);

        }
        else{
            myNum = 1;
            ID = to_string(myNum);
        }


    }

    ~ScopeTable(){
        SymbolInfo* prev;
        SymbolInfo* curr;
        for(int i=0;i<getTotalBuckets();i++){
            curr = Hashtable[i];
            while(curr!=nullptr){
                prev = curr;
                curr = curr->getNext();
                delete prev;
            }
        }
    }

    void printTable(){
        //cout<<"ScopeTable# "<<ID<<endl;
        for(int i = 0; i<getTotalBuckets(); i++){
            //cout<<i<<" --> ";
            SymbolInfo* curr = Hashtable[i];
            while(curr!=nullptr){
                //cout<<"< "<<curr->getName()<<" : "<<curr->getType()<<" > ";
                curr = curr->getNext();
            }
            //cout<<endl;
        }
    }

    void printTable2(ofstream& coutf){
        coutf<<"ScopeTable # "<<ID<<endl;
        for(int i = 0; i<getTotalBuckets(); i++){
            SymbolInfo* curr = Hashtable[i];
            if(curr == nullptr) continue;
            coutf<<" "<<i<<" --> ";
            while(curr!=nullptr){
                coutf<<"< "<<curr->getName()<<" : "<<curr->getType()<<"> ";
                curr = curr->getNext();
            }
            coutf<<endl;
        }
    }



    bool Insert(SymbolInfo *s){
        //s->print();
        ////cout<<"ScopeTInsert"<<endl;
        unsigned long h = Hash(s, TotalBuckets);
        ////cout<<"ScopeTInsert2"<<endl;
        SymbolInfo* curr = Hashtable[h];
        ////cout<<"ScopeTInsert3"<<endl;
        SymbolInfo temp;
        
        if(curr == nullptr){
            Hashtable[h] =  (new SymbolInfo(*s));
            //cout<<"Inserted into ScopeTable# "<<ID<< " at position "<<h<<", "<<0<<endl;
            return true;
        }
        else{
                SymbolInfo* prev;
                int cnt = 0;
                while(curr!=nullptr){
                if(curr->getName()==s->getName()){
                        //cout<<"This name already exists"<<endl;
                        //s->print();
                        //cout<<"already exists in current Scope"<<endl;
                        delete s;
                        return false;
                    }

                    prev = curr;
                    curr = curr->getNext();
                    cnt++;
                }
                curr = (new SymbolInfo(*s));
                prev ->setNext(curr);
                //cout<<"Inserted into ScopeTable# "<<ID<< " at position "<<h<<", "<<cnt<<endl;
                return true;
        }
    }

    SymbolInfo* LookUp(string s){
        string x = "...";
        SymbolInfo temp(s,x);
        int h = Hash(&temp, getTotalBuckets());
        SymbolInfo* curr = Hashtable[h];

        int cnt = 0;
        while(curr!=nullptr){
            if(curr->getName() == s){
                //cout<<"Found in ScopeTable# "<<getID()<< " at position "<<h<<", "<<cnt<<endl;
                return curr;
            }
            curr = curr ->getNext();
            cnt++;
        }

        return curr;

    }
    bool deleteSymbolInfo(SymbolInfo *s){
        return deleteVal(s->getName());
    }

    bool deleteVal(string s){
        string x = "...";
        SymbolInfo temp(s,x);
        int h = Hash(&temp, getTotalBuckets());
        ////cout<<h<<endl;
        SymbolInfo* curr = Hashtable[h];
        SymbolInfo* prev = nullptr;
        int cnt = 0;
        while(curr!=nullptr){
            if(curr->getName() == s){
                //cout<<"Found in ScopeTable# "<<getID()<< " at "<<h<<", "<<cnt<<endl;
                deleteUtil(curr, prev, h);
                //cout<<"Deleted Entry "<<h<<", "<<cnt<<" from Current Scope Table"<<endl;
                return true;
            }
            cnt++;
            prev = curr;
            curr = curr ->getNext();
        }
        //cout<<"Not found"<<endl;
        return false;

    }
    void deleteUtil(SymbolInfo* curr, SymbolInfo* prev, int h){
        if(prev == nullptr){
            Hashtable[h] = curr->getNext();
            delete curr;
            return;
        }
        else{
            prev->setNext(curr->getNext());
            delete curr;
            return;
        }
    }



    int getTotalBuckets(){
        return TotalBuckets;
    }
    void setTotalBuckets( int tb){
        TotalBuckets = tb;
    }

    ScopeTable * getParent(){
        return parent;
    }
    void setParent(ScopeTable *p){
        parent = p;
    }

    ScopeTable * getChild(){
        return child;
    }
    void setChild(ScopeTable *c){
        child = c;
    }


    string getID(){
        return ID;
    }



};

