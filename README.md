# RM-60 - Configuración y daemon para eleventa

Este repositorio contiene todos los archivos necesarios para cargar el catálogo actualizado de la panadería tanto en la balanza **DIGI RM-60** como en el sistema de punto de venta **eleventa**, junto con el demonio proxy para la pistola de código de barras.

## Archivos del Catálogo (95 productos, códigos 200 a 422)

* **`PLU00000.CSV` / `PLU_from_excel.csv`**: Archivo de **51 columnas** con formato nativo DIGI RM-60 para importar directamente mediante pendrive USB (`Modo S ➜ FIX ➜ USB TO SCALE`). Los productos pesables están en modo `PR-KG` (`0`) y los unitarios en `PR-PCS` (`1`). Precios sin tarifa asignada han sido fijados en `$1`.
* **`productos_rm60.csv`**: Archivo simplificado de 5 columnas (`PLU,Nombre,Precio,Unidad,ItemCode`) para control o carga por red con LabelNet.
* **`productos_panaderia_eleventa.csv`**: Formato estándar de importación para eleventa (`CÓDIGO, DESCRIPCIÓN, PRECIO DE COSTO, PRECIO DE VENTA, PRECIO DE MAYOREO, DEPARTAMENTO, CANTIDAD INVENTARIO, MÍNIMO, TIPO DE VENTA`).
* **`config.json`**: Configuración para el demonio proxy con la bandera `5000` y el mapeo de los **85 productos por unidad** que deben ser transformados a piezas al escanear.
* **`balanza_proxy.py`**: Demonio Python que intercepta el lector de barras (Keyboard Wedge).

---

## Procedimiento de Carga

### 1. Carga en la Balanza DIGI RM-60 (vía Pendrive USB)
1. Copia el archivo `PLU00000.CSV` en la raíz de un pendrive USB (formato FAT32).
2. Conecta el pendrive al puerto USB de la RM-60.
3. Presiona `[MODE]` hasta la pantalla `S1 PLU`.
4. Presiona la tecla `[FIX]` (mostrará `USB READ FILE`).
5. Presiona `[*]` para confirmar `USB NAME`.
6. Con la tecla `[X]` o flechas cambia para que diga claramente: **`USB TO SCALE`** *(¡No confirmar en SCALE TO USB!)*.
7. Presiona `[*]` y ante las preguntas `USB INSERT Y-C` y `USB EXIST Y-C` presiona `[C]` (Sí).
8. Espera el mensaje `USB FINISH` y presiona `[T]` para volver.

### 2. Importación en eleventa
1. Abre eleventa y dirígete a: **Configuración ➜ Importar productos** (o desde **F3 Productos ➜ Importar**).
2. Selecciona el archivo `productos_eleventa.xlsx` o `productos_panaderia_eleventa.csv`.
3. Confirma el mapeo de columnas (Código, Descripción, Precio Venta, Departamento, Tipo de Venta).
4. Ejecuta la importación; se registrarán los 95 productos clasificados automáticamente en Granel (panes/galletas) y Unidad (pastelería/bollería).

### 3. Poner en marcha el Proxy Demonio
* Haz doble clic en el acceso directo del Escritorio: **`INICIAR_PROXY_BALANZA`** (ejecutar como Administrador).
* Al escanear tickets en eleventa, los productos por unidad registrarán sus piezas directamente y los pesables liquidarán sus kilos sin errores.

---

## Licencia
MIT - Libre para uso y distribución interna.
