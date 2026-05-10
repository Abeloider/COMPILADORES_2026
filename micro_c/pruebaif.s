##################
# Seccion de datos
.data
$str1:
    .asciiz "Inicio de la prueba IF\n"
$str2:
    .asciiz "Exito: Entro al primer IF porque 'a' es 1\n"
$str3:
    .asciiz "Error: No deberia imprimir esto porque 'a' es 0\n"
$str4:
    .asciiz "Fin de la prueba\n"
_a:
    .word 0
##################
# Seccion de codigo
        .text
        .globl main
main:
    li $v0 4
    la $a0 $str1
    syscall
    li $t0 1
    sw $t0 _a
    lw $t0 _a
    beqz $t0 $l0
    li $v0 4
    la $a0 $str2
    syscall
$l0: 
    li $t0 0
    sw $t0 _a
    lw $t0 _a
    beqz $t0 $l1
    li $v0 4
    la $a0 $str3
    syscall
$l1: 
    li $v0 4
    la $a0 $str4
    syscall
##################
# Fin
        li $v0, 10
        syscall
