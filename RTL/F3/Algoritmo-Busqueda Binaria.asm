# CONFIGURACION

addi $s0, $zero, 0       # base arreglo
addi $s1, $zero, 10      # n = 10
addi $s2, $zero, 45      # valor a buscar

# BUBBLE SORT

addi $t0, $zero, 0       # i = 0

CICLO_EXTERNO:

    addi $t8, $s1, -1
    slt  $t9, $t0, $t8
    nop
    nop
    beq  $t9, $zero, INICIO_BUSQUEDA
    nop
    nop

    addi $t1, $zero, 0   # j = 0

CICLO_INTERNO:

    sub  $t7, $t8, $t0   # limite = n-1-i

    slt  $t9, $t1, $t7
    nop
    nop
    beq  $t9, $zero, FIN_INTERNO
    nop
    nop

    # offset = j * 4

    add  $t4, $t1, $t1
    nop
    nop

    add  $t4, $t4, $t4
    nop
    nop

    add  $t5, $s0, $t4
    nop
    nop

    # A[j]

    lw   $s3, 0($t5)
    nop
    nop
    nop
    nop

    # A[j+1]

    lw   $s4, 4($t5)
    nop
    nop
    nop
    nop

    # if A[j+1] < A[j]

    slt  $t6, $s4, $s3
    nop
    nop

    beq  $t6, $zero, NO_SWAP
    nop
    nop

    # swap

    sw   $s4, 0($t5)
    nop
    nop

    sw   $s3, 4($t5)
    nop
    nop

NO_SWAP:

    addi $t1, $t1, 1
    nop
    nop

    j CICLO_INTERNO
    nop
    nop

FIN_INTERNO:

    addi $t0, $t0, 1
    nop
    nop

    j CICLO_EXTERNO
    nop
    nop

# BUSQUEDA BINARIA

INICIO_BUSQUEDA:

    addi $v0, $zero, -1

    addi $t0, $zero, 0       # izq
    addi $t1, $s1, -1        # der

BUSQUEDA:

    slt  $t2, $t1, $t0
    nop
    nop

    bne  $t2, $zero, FIN
    nop
    nop

    # medio = (izq + der)/2

    add  $t3, $t0, $t1
    nop
    nop

    srl  $t4, $t3, 1
    nop
    nop

    # direccion = medio * 4

    add  $t5, $t4, $t4
    nop
    nop

    add  $t5, $t5, $t5
    nop
    nop

    add  $t6, $s0, $t5
    nop
    nop

    # leer A[medio]

    lw   $s3, 0($t6)
    nop
    nop
    nop
    nop

    # encontrado

    beq  $s3, $s2, EXITO
    nop
    nop

    # A[medio] < X ?

    slt  $t7, $s3, $s2
    nop
    nop

    beq  $t7, $zero, IZQUIERDA
    nop
    nop

    # derecha

    addi $t0, $t4, 1
    nop
    nop

    j BUSQUEDA
    nop
    nop

IZQUIERDA:

    addi $t1, $t4, -1
    nop
    nop

    j BUSQUEDA
    nop
    nop

EXITO:

    add  $v0, $zero, $t4
    nop
    nop

FIN:

    j FIN
    nop
    nop