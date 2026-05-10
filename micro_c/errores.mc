void main() {
    const int TOPE = 100;
    var int calculo;

    var int TOPE; // error semantico (re-declaración)

    calculo = 50 #@ 2; // error lexico y sintactico

    calculo= 5 @ 2; // error lexico y sintactico

    print( 5 + * 2 ); // error sintactico

    TOPE = 200; // error semantico 

    resultadoooo = 10; // error semantico 
}