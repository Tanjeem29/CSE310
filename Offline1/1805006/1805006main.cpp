#include<iostream>
#include<fstream>
#include<string>
#include<sstream>
#include "1805006SymbolInfo.h"
#include "1805006Hash.h"
#include "1805006ScopeTable.h"
#include "1805006SymbolTable.h"
using namespace std;


int main(){
    int i;
    int tb;
    ifstream in ("1805006input.txt");
    //cin>>tb;
    in>>tb;

    SymbolTable* ST = new SymbolTable(tb);
    SymbolInfo* SI;
    while(!in.eof()){
        cout<<endl;
        i=0;
        string str, tokens[10], temp;

        //ws(cin);
        ws(in);

        //getline(cin, str);
        getline(in, str);
        stringstream ss(str);
        while(getline(ss, temp, ' ')){
            tokens[i++] = temp;
        }

        cout<<endl;
        if(tokens[0] == "I"){
            if(i!=3){
                cout<<"invalid command"<<endl;
                continue;
            }
            SI = new SymbolInfo(tokens[1],tokens[2]);
            ST->Insert(SI);

        }
        else if(tokens[0] == "L"){
            if(i!=2){
                cout<<"invalid command"<<endl;
                continue;
            }
            ST->LookUpBig(tokens[1]);
        }
        else if(tokens[0] == "D"){
            if(i!=2){
                cout<<"invalid command"<<endl;
                continue;
            }
            ST->RemoveVal(tokens[1]);
        }
        else if(tokens[0] == "P"){
            if(i!=2){
                cout<<"invalid command"<<endl;
                continue;
            }
            if(tokens[1] == "C"){
                ST->printCurr();
            }
            else if(tokens[1] == "A"){
                ST->printAll();
            }
            else{
                cout<<"invalid command"<<endl;
            }

        }
        else if(tokens[0] == "S"){
            if(i!=1){
                cout<<"invalid command"<<endl;
                continue;
            }
            ST->enterScope();
        }
        else if(tokens[0] == "E"){
            if(i!=1){
                cout<<"invalid command"<<endl;
                continue;
            }
            ST->deleteScope();
        }
        else{
            cout<<"invalid command"<<endl;
        }
        cout<<endl;

    }



}

