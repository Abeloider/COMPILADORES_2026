##################
# Seccion de datos
.data
$str1:
    .asciiz "Error: a es 0\n"
$str2:
    .asciiz "Exito: entramos en ELSE\n"
$str3:
    .asciiz "Exito: entramos en IF\n"
$str4:
    .asciiz "Error: a no es 0\n"
$str5:
    .asciiz "Valor final (debe ser 3): "
_a:
    .word 0
_b:
    .word 0
##################
# Seccion de codigo
	.text
	.globl main
main:
    li $t0 3
    neg $t1 $t0
    sw $t1 _b
    li $t0 0
    sw $t0 _a
    lw $t0 _a
    beqz $t0 $l0
    li $v0 4
    la $a0 $str1
    syscall
    b $l1
$l0: 
    li $v0 4
    la $a0 $str2
    syscall
    lw $t1 _b
    sw $t1 _a
$l1: 
    lw $t0 _a
    beqz $t0 $l2
    li $v0 4
    la $a0 $str3
    syscall
    lw $t1 _a
    li $t2 8
    add $t1 $t1 $t2
    sw $t1 _a
    b $l3
$l2: 
    li $v0 4
    la $a0 $str4
    syscall
$l3: 
    li $v0 4
    la $a0 $str5
    syscall
    lw $t0 _a
    li $v0 1
    move $a0 $t0
    syscall
##################
# Fin
	li $v0, 10
	syscall
