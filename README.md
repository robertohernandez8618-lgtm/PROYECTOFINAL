# Arquitectura de Computadoras

| | |
|---|---|
| **Estudiante** | Roberto |
| **Código** | 224786188 |
| **Sección** | D03 |
| **Profesor** | Jorge Ernesto Lopez Arce Delgado |

## Descripción
Repositorio del proyecto final sobre el diseño e implementación de un procesador MIPS con soporte para instrucciones tipo R, I y J, incluyendo un ensamblador en Python para convertir código ASM a binario.

---

## Temas trabajados

### 🔧 Hardware / Diseño Digital
- Compuertas lógicas y álgebra booleana
- Flip-flops y registros
- Multiplexores y ALU

### ⚙️ Arquitectura MIPS
- Formato de instrucciones Tipo R, I y J
- Banco de registros (`$0 - $31`)
- Conjunto de instrucciones (`add`, `sub`, `lw`, `sw`, `beq`, `j`, etc.)

### 🧩 Componentes del Procesador
- PC (Program Counter)
- Memoria de instrucciones y datos
- Unidad de control
- Extensor de signo

### 💻 Verilog
- Módulos y puertos
- Lógica combinacional y secuencial
- Testbenches

### 🔄 Datapath
- Ciclo de instrucción (Fetch → Decode → Execute → Memory → Writeback)
- Conexión de componentes
- Señales de control por tipo de instrucción

### 🐍 Ensamblador (ASM → Binario)
- Estructura de un archivo ensamblador MIPS
- Parsing de instrucciones en Python
- Tablas de codificación (opcodes, funct, registros)
- Lectura y limpieza de archivos `.asm`
- Diccionarios para mapeo de instrucciones
- Conversión a binario/hexadecimal
- Escritura del archivo de salida `.bin` o `.hex`
