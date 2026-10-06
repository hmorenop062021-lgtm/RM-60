import json
import os
import sys
import threading
import time
import datetime
import re
import keyboard

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
CONFIG_PATH = os.path.join(BASE_DIR, "config.json")
LOG_PATH = os.path.join(BASE_DIR, "proxy.log")

def log(msg):
    now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S.%f")[:-3]
    line = f"[{now}] {msg}"
    print(line, flush=True)
    try:
        with open(LOG_PATH, "a", encoding="utf-8") as f:
            f.write(line + "\n")
            f.flush()
    except Exception:
        pass

def load_config():
    default_config = {
        "bandera": "5000",
        "tiempo_limite_lector_ms": 150,
        "productos_unidad": {
            "103": "Pan Amasado",
            "104": "Empanada de Pino",
            "105": "Torta Selva Negra",
            "106": "Pastel Milhojas",
            "108": "Dobladita",
            "109": "Pan de Molde",
            "110": "Brazo de Reina"
        }
    }
    if os.path.exists(CONFIG_PATH):
        try:
            with open(CONFIG_PATH, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            log(f"Error cargando config.json: {e}")
    return default_config

config = load_config()
BANDERA = str(config.get("bandera", "5000"))
TIMEOUT = float(config.get("tiempo_limite_lector_ms", 150)) / 1000.0
PRODUCTOS_UNIDAD = config.get("productos_unidad", {})

log("=" * 65)
log("       DEMONIO PROXY BALANZA DIGI RM-60 -> ELEVENTA")
log("=" * 65)
log(f"Bandera configurada       : {BANDERA}")
log(f"Timeout ráfaga lector     : {TIMEOUT*1000:.0f} ms")
log(f"Productos por unidad      : {len(PRODUCTOS_UNIDAD)} registrados:")
for k, v in PRODUCTOS_UNIDAD.items():
    log(f"   * PLU {k:>3} -> {v}")
log("=" * 65)
log("Estado: ACTIVO Y ESCUCHANDO LECTOR...")

buffer = []
timer = None
lock = threading.Lock()

def flush_buffer():
    global buffer, timer
    with lock:
        if buffer:
            chars = "".join(buffer)
            buffer = []
            log(f"[FLUSH] Escritura manual o no-balanza detectada. Liberando: {chars}")
            keyboard.write(chars)
        timer = None

def process_barcode(raw_barcode):
    log(f"[SCAN DETECTADO] Trama cruda: '{raw_barcode}'")
    
    # Limpiar caracteres no numéricos iniciales o finales (como STX, symbology identifiers)
    m = re.search(r"(" + re.escape(BANDERA) + r"\d{8,9})", raw_barcode)
    if m:
        barcode = m.group(1)
        log(f"  -> Código balanza extraído: {barcode}")
        codigo_plu = barcode[len(BANDERA):len(BANDERA)+3]
        valor_raw = barcode[len(BANDERA)+3:len(BANDERA)+8]
        
        if codigo_plu in PRODUCTOS_UNIDAD:
            nombre = PRODUCTOS_UNIDAD[codigo_plu]
            try:
                cantidad = int(valor_raw)
            except ValueError:
                cantidad = 1
            if cantidad <= 0:
                cantidad = 1
                
            log(f"  -> Tipo: PRODUCTO POR UNIDAD -> PLU {codigo_plu} ({nombre})")
            log(f"  -> Cantidad detectada: {cantidad} pieza(s)")
            
            if cantidad == 1:
                cmd = f"{codigo_plu}"
            else:
                cmd = f"{cantidad}*{codigo_plu}"
                
            log(f"  -> ENVIANDO A ELEVENTA: [{cmd}] + [ENTER]")
            time.sleep(0.05)
            keyboard.write(cmd)
            time.sleep(0.03)
            keyboard.send("enter")
            log(f"  -> Envío completado con éxito.")
            return
            
        else:
            log(f"  -> Tipo: PRODUCTO PESABLE / TOTAL (PLU {codigo_plu})")
            log(f"  -> ENVIANDO CÓDIGO ORIGINAL A ELEVENTA: [{barcode}] + [ENTER]")
            time.sleep(0.05)
            keyboard.write(barcode)
            time.sleep(0.03)
            keyboard.send("enter")
            log(f"  -> Envío completado con éxito.")
            return

    log(f"  -> No coincide con bandera balanza '{BANDERA}'. Enviando original: [{raw_barcode}] + [ENTER]")
    time.sleep(0.05)
    keyboard.write(raw_barcode)
    time.sleep(0.03)
    keyboard.send("enter")

def on_key(e):
    global buffer, timer
    
    name = e.name
    if not name:
        return True
        
    c = name.replace("num ", "")
    
    # Suprimir key up de teclas en buffer
    if e.event_type != "down":
        with lock:
            return False if buffer else True

    with lock:
        # Buffer vacío
        if not buffer:
            # Si la tecla puede ser inicio de bandera ('5') o inicio de scan
            if c == BANDERA[0]:
                buffer.append(c)
                timer = threading.Timer(TIMEOUT, flush_buffer)
                timer.start()
                return False
            else:
                return True
                
        else:
            # Buffer ya tiene caracteres
            if timer:
                timer.cancel()
                
            if c in ("enter", "return"):
                barcode = "".join(buffer)
                buffer = []
                timer = None
                threading.Thread(target=process_barcode, args=(barcode,)).start()
                return False
                
            elif len(c) == 1:
                buffer.append(c)
                # Si en los primeros caracteres ya no coincide con la bandera, soltar inmediatamente
                if len(buffer) <= len(BANDERA):
                    if not BANDERA.startswith("".join(buffer)):
                        chars = "".join(buffer)
                        buffer = []
                        timer = None
                        keyboard.write(chars)
                        return False
                        
                timer = threading.Timer(TIMEOUT, flush_buffer)
                timer.start()
                return False
                
            else:
                chars = "".join(buffer)
                buffer = []
                timer = None
                keyboard.write(chars)
                return True

def start_proxy():
    hook_ref = keyboard.hook(on_key, suppress=True)
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        log("Deteniendo proxy...")
    finally:
        keyboard.unhook(hook_ref)
        log("Proxy detenido.")

if __name__ == "__main__":
    start_proxy()
