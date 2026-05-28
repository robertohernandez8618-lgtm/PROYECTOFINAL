import tkinter as tk
from tkinter import filedialog, messagebox

# ── Tablas MIPS ──────────────────────────────────────────────────────────────
REG = {
    "$zero": "00000", "$at": "00001", "$v0": "00010", "$v1": "00011",
    "$a0":  "00100", "$a1": "00101", "$a2": "00110", "$a3": "00111",
    "$t0":  "01000", "$t1": "01001", "$t2": "01010", "$t3": "01011",
    "$t4":  "01100", "$t5": "01101", "$t6": "01110", "$t7": "01111",
    "$s0":  "10000", "$s1": "10001", "$s2": "10010", "$s3": "10011",
    "$s4":  "10100", "$s5": "10101", "$s6": "10110", "$s7": "10111",
    "$t8":  "11000", "$t9": "11001",
}

# Tipo R – código de función (6 bits)
FUNCT = {
    "add": "100000", "sub": "100010", "and": "100100", "or":  "100101",
    "xor": "100110", "slt": "101010", "srl": "000010", "sra": "000011",
    "tge": "110000", "teq": "110100",
}

# Tipo I – opcode (6 bits)
OPCODE_I = {
    "addi": "001000",
    "slti": "001010",
    "andi": "001100",
    "ori":  "001101",
    "lw":   "100011",
    "sw":   "101011",
    "beq":  "000100",
}

# ── Helpers ──────────────────────────────────────────────────────────────────
def to_bin(val, bits):
    """Entero (con signo) a cadena binaria de `bits` dígitos."""
    v = int(val)
    if v < 0:
        # complemento a 2
        v = v & ((1 << bits) - 1)
    return format(v, f'0{bits}b')

def parse_mem(operand):
    """
    Descompone 'offset(base)' → (offset_str, base_reg_str).
    Ejemplos: '0($zero)' → ('0', '$zero')
              '-4($sp)'  → ('-4', '$sp')
    """
    operand = operand.strip()
    if '(' in operand:
        offset_str, rest = operand.split('(', 1)
        base_reg = rest.rstrip(')')
        return offset_str.strip(), base_reg.strip()
    raise ValueError(f"Formato de memoria inválido: '{operand}'")

# ── Ensamblador de una línea ──────────────────────────────────────────────────
def ensamblar_linea(linea, num_linea=None, labels=None, linea_actual=None):
    """
    Convierte una línea de ensamblador MIPS a una cadena de 32 bits.
    Retorna None si la línea está vacía/es comentario/es etiqueta.
    Retorna una cadena 'ERROR …' en caso de problema.
    """
    # Quitar comentarios y normalizar
    linea = linea.split('#')[0].replace(',', ' ').strip().lower()
    if not linea or linea.endswith(':'):   # vacía o solo etiqueta
        return None

    # Si hay etiqueta al inicio de la instrucción, quitarla
    if ':' in linea:
        linea = linea.split(':', 1)[1].strip()
    if not linea:
        return None

    partes = linea.split()
    inst   = partes[0]

    # ── NOP ──────────────────────────────────────────────────────────────────
    if inst == "nop":
        return "0" * 32

    opcode = "000000"   # Tipo R por defecto

    try:
        # ── TIPO R: aritméticas/lógicas ──────────────────────────────────────
        if inst in ("add", "sub", "and", "or", "xor", "slt"):
            rd, rs, rt = partes[1], partes[2], partes[3]
            return opcode + REG[rs] + REG[rt] + REG[rd] + "00000" + FUNCT[inst]

        # ── TIPO R: desplazamientos ───────────────────────────────────────────
        elif inst in ("srl", "sra"):
            rd, rt, shamt = partes[1], partes[2], partes[3]
            return opcode + "00000" + REG[rt] + REG[rd] + to_bin(shamt, 5) + FUNCT[inst]

        # ── TIPO R: trampas ───────────────────────────────────────────────────
        elif inst in ("tge", "teq"):
            rs, rt = partes[1], partes[2]
            return opcode + REG[rs] + REG[rt] + "00000" + "00000" + FUNCT[inst]

        # ── TIPO I: addi / slti / andi / ori  →  rt, rs, imm ─────────────────
        #    Sintaxis ensamblador: inst $rt, $rs, inmediato
        elif inst in ("addi", "slti", "andi", "ori"):
            rt, rs, imm = partes[1], partes[2], partes[3]
            return OPCODE_I[inst] + REG[rs] + REG[rt] + to_bin(imm, 16)

        # ── TIPO I: lw  →  opcode rs rt offset(16 bits) ──────────────────────
        #    Sintaxis ensamblador: lw $rt, offset($rs)
        elif inst == "lw":
            rt = partes[1]
            offset_str, rs = parse_mem(partes[2])
            return OPCODE_I["lw"] + REG[rs] + REG[rt] + to_bin(offset_str, 16)

        # ── TIPO I: sw  →  opcode rs rt offset(16 bits) ──────────────────────
        #    Sintaxis ensamblador: sw $rt, offset($rs)
        elif inst == "sw":
            rt = partes[1]
            offset_str, rs = parse_mem(partes[2])
            return OPCODE_I["sw"] + REG[rs] + REG[rt] + to_bin(offset_str, 16)

        # ── TIPO I: beq  →  opcode rs rt offset(16 bits) ─────────────────────
        #    Sintaxis ensamblador: beq $rs, $rt, offset_numerico
        #    (p.ej. beq $zero, $zero, -1  para apuntar a la instrucción anterior)
        elif inst == "beq":
            rs, rt, offset = partes[1], partes[2], partes[3]
            return OPCODE_I["beq"] + REG[rs] + REG[rt] + to_bin(offset, 16)

    except KeyError as e:
        return f"ERROR línea {num_linea}: registro desconocido {e} → '{linea}'"
    except Exception as e:
        return f"ERROR línea {num_linea}: {e} → '{linea}'"

    return f"ERROR línea {num_linea}: instrucción no reconocida → '{inst}'"


# ── GUI ───────────────────────────────────────────────────────────────────────
def seleccionar_archivo():
    ruta = filedialog.askopenfilename(
        filetypes=[("MIPS Assembly", "*.asm"), ("Text files", "*.txt")]
    )
    if ruta:
        entrada_ruta.delete(0, tk.END)
        entrada_ruta.insert(0, ruta)

def procesar_archivo():
    ruta_origen = entrada_ruta.get()
    if not ruta_origen:
        messagebox.showwarning("Atención", "Primero carga un archivo .asm")
        return
    try:
        with open(ruta_origen, 'r') as f:
            lineas = f.readlines()

        resultado  = []
        errores    = []
        for i, l in enumerate(lineas, start=1):
            binario = ensamblar_linea(l, num_linea=i)
            if binario is None:
                continue                        # línea vacía / comentario / etiqueta
            if binario.startswith("ERROR"):
                errores.append(binario)
            else:
                resultado.append(binario)

        if errores:
            detalle = "\n".join(errores)
            if not messagebox.askyesno(
                "Advertencia",
                f"Se encontraron {len(errores)} error(es):\n\n{detalle}\n\n"
                "¿Deseas guardar de todas formas las instrucciones válidas?"
            ):
                return

        ruta_destino = filedialog.asksaveasfilename(
            defaultextension=".txt",
            filetypes=[("Text file", "*.txt"), ("Binary file", "*.bin")]
        )
        if ruta_destino:
            with open(ruta_destino, 'w') as f:
                lineas_8 = []
                for instruccion in resultado:
                    for i in range(0, 32, 8):
                        lineas_8.append(instruccion[i:i+8])
                f.write("\n".join(lineas_8))
            messagebox.showinfo(
                "Éxito",
                f"Archivo generado con {len(resultado)} instrucción(es).\n{ruta_destino}"
            )

    except Exception as e:
        messagebox.showerror("Error", f"No se pudo procesar: {e}")

# ── Ventana principal ─────────────────────────────────────────────────────────
root = tk.Tk()
root.title("MIPS Ensamblador – Tipo R + Tipo I")
root.geometry("540x260")
root.resizable(False, False)

tk.Label(root, text="Conversor ASM → Binario (R + I)",
         font=("Arial", 14, "bold")).pack(pady=12)

frame_carga = tk.Frame(root)
frame_carga.pack(pady=8)

btn_cargar = tk.Button(frame_carga, text="Cargar .asm",
                       command=seleccionar_archivo, width=12)
btn_cargar.pack(side=tk.LEFT, padx=6)

entrada_ruta = tk.Entry(frame_carga, width=42)
entrada_ruta.pack(side=tk.LEFT, padx=6)

btn_convertir = tk.Button(
    root, text="CONVERTIR A BINARIO",
    bg="#4CAF50", fg="white", font=("Arial", 10, "bold"),
    command=procesar_archivo
)
btn_convertir.pack(pady=18, ipadx=12, ipady=6)

tk.Label(root,
         text="Instrucciones soportadas – Tipo R: add sub and or xor slt srl sra teq tge nop\n"
              "Tipo I: addi slti andi ori lw sw beq",
         font=("Arial", 8), fg="gray").pack()

root.mainloop()
