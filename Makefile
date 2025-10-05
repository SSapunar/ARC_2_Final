# ===== Config =====
VERILOG_FILES = \
  computer.v \
  alu.v \
  pc.v \
  mux2.v \
  instruction_memory.v \
  register.v
# (si luego agregas data_memory.v o control_unit.v, súmalos aquí)

TESTBENCH_FILE = testbench.v
YOSYS_SCRIPT   = yosys.tcl
IVERILOG_FLAGS = -g2012

# Rutas de salida
OUT_DIR        = out
OUT_FILE       = $(OUT_DIR)/tb.vvp
WAVEFORM_FILE  = $(OUT_DIR)/dump.vcd

# ---------- GTKWave (forzar Flatpak para evitar conflictos con snap/core20) ----------
# Guarda una vista en File → Write Save File… como out/wave.gtkw para que se cargue sola.
WAVE_SAVE ?= $(OUT_DIR)/wave.gtkw
GTKWAVE_BIN := flatpak run io.github.gtkwave.GTKWave

# Targets
.PHONY: all build run wave synth clean

# Target por defecto
all: run

# Crear carpeta de salida
$(OUT_DIR):
	@mkdir -p $(OUT_DIR)

# Construir ejecutable de simulación
build: $(OUT_DIR) $(VERILOG_FILES) $(TESTBENCH_FILE)
	@echo "Construyendo ejecutable de simulación..."
	iverilog $(IVERILOG_FLAGS) -o $(OUT_FILE) $(TESTBENCH_FILE) $(VERILOG_FILES)
	@echo "Construcción OK → $(OUT_FILE)"

# Ejecutar simulación
run: build
	@echo "Ejecutando simulación..."
	vvp $(OUT_FILE)

# Ver formas de onda (Flatpak siempre)
wave: run
	@echo "Abriendo GTKWave (Flatpak)..."
	@if [ ! -f "$(WAVEFORM_FILE)" ]; then \
	  echo "No existe $(WAVEFORM_FILE). Corre 'make run' primero."; exit 1; \
	fi
	@if [ -f "$(WAVE_SAVE)" ]; then \
	  $(GTKWAVE_BIN) "$(WAVEFORM_FILE)" "$(WAVE_SAVE)" & \
	else \
	  $(GTKWAVE_BIN) "$(WAVEFORM_FILE)" & \
	fi

# Síntesis (opcional)
synth: $(OUT_DIR)
	@echo "Iniciando síntesis lógica con Yosys..."
	yosys -c $(YOSYS_SCRIPT)
	@echo "Síntesis completa."

stats:
	yosys -p 'read_verilog -sv computer.v alu.v pc.v mux2.v instruction_memory.v register.v; hierarchy -check -top computer; stat'


# Limpiar
clean:
	@echo "Limpiando archivos generados..."
	@rm -rf $(OUT_DIR)
	@rm -f yosys.log
	@echo "Limpieza completa."
