##################
# Seccion de datos
.data
$str1:
    .asciiz "Inicio del bucle while\n"
$str2:
    .asciiz "El contador vale: "
$str3:
    .asciiz "\n"
$str4:
    .asciiz "Fin del bucle\n"
_contador:
    .word 0
##################
# Seccion de codigo
	.text
	.globl main
main:
    li $t0 3
    sw $t0 _contador
    li $v0 4
    la $a0 $str1
    syscall
$l0: 
    lw $t0 _contador
    beqz $t0 $l1
    li $v0 4
    la $a0 $str2
    syscall
    lw $t1 _contador
    li $v0 1
    move $a0 $t1
    syscall
    li $v0 4
    la $a0 $str3
    syscall
    lw $t1 _contador
    li $t2 1
    sub $t1 $t1 $t2
    sw $t1 _contador
    b $l0
$l1: 
    li $v0 4
    la $a0 $str4
    syscall
##################
# Fin
	li $v0, 10
	syscall
