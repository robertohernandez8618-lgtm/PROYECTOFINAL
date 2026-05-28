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
    "bne":  "000101",  # MODIFICACIÓN: Agregado bne
}

# Tipo J - opcode (6 bits)
OPCODE_J = {
    "j": "000010",     # MODIFICACIÓN: Agregado opcode de saltos incondicionales
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
    """Descompone 'offset(base)' → (offset_str, base_reg_str)."""
    operand = operand.strip()
    if '(' in operand:
        offset_str, rest = operand.split('(', 1)
        base_reg = rest.rstrip(')')
        return offset_str.strip(), base_reg.strip()
    raise ValueError(f"Formato de memoria inválido: '{operand}'")

# ── Ensamblador de una línea ──────────────────────────────────────────────────
def ensamblar_linea(linea, num_linea=None, labels=None, pc_actual=None):
    """
    Convierte una línea de ensamblador MIPS a una cadena de 32 bits.
    Soporta resolución de etiquetas dinámicas en saltos de Tipo I y J.
    """
    # Limpieza básica
    linea = linea.split('#')[0].replace(',', ' ').strip().lower()
    if not linea:
        return None

    partes = linea.split()
    inst = partes[0]

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

        # ── TIPO I: aritméticas inmediatas ───────────────────────────────────
        elif inst in ("addi", "slti", "andi", "ori"):
            rt, rs, imm = partes[1], partes[2], partes[3]
            return OPCODE_I[inst] + REG[rs] + REG[rt] + to_bin(imm, 16)

        # ── TIPO I: lw ───────────────────────────────────────────────────────
        elif inst == "lw":
            rt = partes[1]
            offset_str, rs = parse_mem(partes[2])
            return OPCODE_I["lw"] + REG[rs] + REG[rt] + to_bin(offset_str, 16)

        # ── TIPO I: sw ───────────────────────────────────────────────────────
        elif inst == "sw":
            rt = partes[1]
            offset_str, rs = parse_mem(partes[2])
            return OPCODE_I["sw"] + REG[rs] + REG[rt] + to_bin(offset_str, 16)

        # ── TIPO I: beq / bne (Saltos Condicionales) ─────────────────────────
        # MODIFICACIÓN: Cálculo de offset automático basado en etiquetas o números
        elif inst in ("beq", "bne"):
            rs, rt, destino = partes[1], partes[2], partes[3]
            
            if labels and destino in labels:
                # El offset relativo en MIPS es: (PC_destino - (PC_actual + 1))
                offset_num = labels[destino] - (pc_actual + 1)
            else:
                offset_num = int(destino)
                
            return OPCODE_I[inst] + REG[rs] + REG[rt] + to_bin(offset_num, 16)

        # ── TIPO J: j (Salto Incondicional) ──────────────────────────────────
        # MODIFICACIÓN: Agregado soporte completo para instrucciones Tipo J
        elif inst == "j":
            destino = partes[1]
            if labels and destino in labels:
                target_address = labels[destino]
            else:
                target_address = int(destino)
                
            return OPCODE_J["j"] + to_bin(target_address, 26)

    except KeyError as e:
        return f"ERROR línea {num_linea}: registro o campo desconocido {e} → '{linea}'"
    except Exception as e:
        return f"ERROR línea {num_linea}: {e} → '{linea}'"

    return f"ERROR línea {num_linea}: instrucción no reconocida → '{inst}'"


# ── GUI & PROCESAMIENTO ───────────────────────────────────────────────────────
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
            lineas_crudas = f.readlines()

        labels = {}
        lineas_instrucciones = []
        
        # ── PRIMERA PASADA: Identificar y registrar posiciones de etiquetas ──
        pc_temp = 0
        for idx, l in enumerate(lineas_crudas, start=1):
            linea_limpia = l.split('#')[0].replace(',', ' ').strip().lower()
            if not linea_limpia:
                continue
                
            # Procesar si la línea contiene una etiqueta (ej. "EXITO:")
            if ':' in linea_limpia:
                partes_etiqueta = linea_limpia.split(':', 1)
                nombre_label = partes_etiqueta[0].strip()
                labels[nombre_label] = pc_temp  # Guarda la posición actual de memoria
                linea_restante = partes_etiqueta[1].strip()
                if not linea_restante:
                    continue  # La línea solo tenía la etiqueta, pasamos a la siguiente
                linea_limpia = linea_restante

            lineas_instrucciones.append((idx, linea_limpia, pc_temp))
            pc_temp += 1

        # ── SEGUNDA PASADA: Traducción real a binario de 32 bits ──────────────
        resultado = []
        errores = []
        
        for num_linea, contenido, pc_actual in lineas_instrucciones:
            binario = ensamblar_linea(contenido, num_linea=num_linea, labels=labels, pc_actual=pc_actual)
            if binario is None:
                continue
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
                # Tu código original separa la instrucción de 32 bits en 4 bloques de 8 bits
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
root.title("Conversor – Algoritmos R + I + J")
root.geometry("540x270")
root.resizable(False, False)

tk.Label(root, text="Conversor ASM → Binario (R + I + J)",
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
         text="Soporta etiquetas de texto dinámicas (ej: CICLO_EXTERNO:, EXITO:)\n"
              "Tipo R: add sub and or xor slt srl sra teq tge nop | Tipo I: addi slti andi ori lw sw beq bne | Tipo J: j",
         font=("Arial", 8), fg="gray").pack()

root.mainloop()