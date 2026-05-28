# ============================================================
# PRUEBA DE INSTRUCCIONES TIPO R
# ============================================================

# Aritméticas y Lógicas (rd, rs, rt)
add $t0, $s1, $s2
sub $t1, $t0, $s3
and $t2, $s4, $s5
or  $t3, $t1, $t2
xor $t4, $t2, $t3
slt $t5, $s1, $s2

# Desplazamientos (rd, rt, shamt)  —  rs queda en 00000
srl $s6, $t4, 2
sra $s7, $t5, 4

# Trampas (rs, rt)  —  rd y shamt quedan en 00000
teq $s1, $s2
tge $t0, $t1

# Operación Nula
nop

# ============================================================
# PRUEBA DE INSTRUCCIONES TIPO I
# ============================================================

# Aritméticas / lógicas con inmediato  (rt, rs, imm)
addi $t0, $zero, 10     # reg 8  -> decimal debe ser 10
slti $t1, $zero, 10     # reg 9  -> decimal debe ser 1
andi $t2, $zero, 10     # reg 10 -> decimal debe ser 0
ori  $t3, $zero, 10     # reg 11 -> decimal debe ser 1

# Memoria  —  sw/lw usan formato: reg_dato, offset(reg_base)
sw $t0, 0($zero)        # guardar reg 8 (10) en mem[0]
lw $t4, 0($zero)        # cargar  mem[0] (10) en reg 12

# Salto condicional  (rs, rt, etiqueta o offset)
beq $zero, $zero, -1    # salta al inicio  (offset -1 => 0xFFFF)
