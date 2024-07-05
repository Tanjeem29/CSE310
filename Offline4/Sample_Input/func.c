int f(int a){
    return 2*a; //gives error in my code
    a=9;
}

int g(int a, int b){
    int x;
    x=f(a)+a+b;
    return x;
}

int main(){
    int a,b;
    a=1;
    b=2;
    a=g(a,b);
    println(a);
    return 0;
}
