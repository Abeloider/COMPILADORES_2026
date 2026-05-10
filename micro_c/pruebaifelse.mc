void main() {
    var int a;
    const int b = -3;

    a = 0;
    if (a) {
        print("Error: a es 0\n");
    } else {
        print("Exito: entramos en ELSE\n");
        a = b; // a ahora vale 5
    }

    if (a) {
        print("Exito: entramos en IF\n");
        a = a + 8; // a ahora vale 3
    } else {
        print("Error: a no es 0\n");
    }

    print("Valor final (debe ser 3): ");
    print(a);
}