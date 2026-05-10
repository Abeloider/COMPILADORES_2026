void main() {
    var int a;
    print("Inicio de la prueba IF\n");
    a = 1;
    if (a) {
        print("Exito: Entro al primer IF porque 'a' es 1\n");
    }
    a = 0;
    if (a) {
        print("Error: No deberia imprimir esto porque 'a' es 0\n");
    }
    print("Fin de la prueba\n");
}