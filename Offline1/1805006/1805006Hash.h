#pragma once
#include<string>
#include<iostream>
#include "1805006SymbolInfo.h"
using namespace std;


    static unsigned long
    sdbmHash(unsigned char *str)
    {
        unsigned long h = 0;
        int c;
        while (c = *str++){
            h = c + (h << 6) + (h << 16) - h;
            cout<<"1"<<endl;
        }
        return h;
    }

    static unsigned long
    sdbmHash(string s)
    {
        char * t = new char[s.size() + 1];
        copy(s.begin(), s.end(), t);
        t[s.size()] = '\0';
        unsigned long h = 0;
        int c;
        while (c = *t++){
            h = c + (h << 6) + (h << 16) - h;
        }
        delete[] t;
        return h;

    }

    static unsigned long Hash(SymbolInfo *s, int tb){
        unsigned long h = sdbmHash(s->getName()) % tb;
        return h;
    }
