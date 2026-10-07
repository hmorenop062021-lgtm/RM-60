# RM-60 - Configuración y daemon para Eleventa

Este repositorio contiene:

* productos_rm60.csv - Lista de productos (PLU, nombre, precio, unidad) lista para importar a la balanza DIGI RM-60 mediante LabelNet o carga manual. PLU empieza en **110** y aumenta de **10 en 10**. Se han excluido filas con precio 0 y títulos de familia (ej. "FAMILIA PAN", "PASTELERÍA").
* productos_panaderia_eleventa.csv - CSV original de precios de panadería (empanadas, marraquetas, etc.) con columnas CODIGO, NOMBRE, PRECIO_COSTO, PRECIO_VENTA, DEPARTAMENTO, TIPO_VENTA, UNIDAD. Puede usarse como referencia o para generar otros formatos.
* PLU_from_excel.csv - CSV listo para importar a la balanza DIGI RM-60, generado a partir de productos_panaderia_eleventa.csv siguiendo la plantilla de PLU00000.CSV (51 columnas). PLU asignado desde 110 en incrementos de 10.
* balanza_proxy.py - Daemon Python que intercepta el lector de barras y envía teclas simuladas a Eleventa. Transforma los tickets de la balanza:
  * Productos unitarios → CODIGO{ENTER} (o CANTIDAD*CODIGO{ENTER})
  * Productos pesables → deja el código tal cual para que Eleventa lo interprete como peso.
* config.json - Parámetros del daemon (bandera, timeout y lista de productos que se venden por pieza).
* Instrucciones rápidas de uso están en este mismo archivo.

## Cómo usar

1. Importa productos_rm60.csv a la RM-60 (LabelNet → PLU → Send) o carga los PLUs manualmente desde el teclado de la balanza.  
   Alternativamente, puedes usar PLU_from_excel.csv si deseas importar directamente los productos del Excel de precios.
2. Asegúrate de que la balanza tenga:
   * SPEC 048 = 0 (Allow barcode)
   * SPEC 072 = 1 (F1F2 CCCCC XXXXX CD)
   * SPEC 075 = 1 (peso) **o** 2 (precio) según tu flujo de negocio.
   * Bandera (S16) = 05 (de modo que el ticket empiece con 5000).
3. Ejecuta el daemon con privilegios de Administrador:
   `
   INICIAR_PROXY_BALANZA.bat   # o ejecuta directamente: python balanza_proxy.py
   `
4. En Eleventa, configura los productos que aparecen en unit_products como “Por unidad / Pza” y los demás como “A granel (usa báscula)”.
5. Al escanear el ticket de la balanza, el daemon transformará:
   * 5000104000017 → 104{ENTER} (1 empanada)
   * 5000104000024 → 2*104{ENTER} (2 empanadas)
   * Los códigos de productos pesables se dejan tal cual para que Eleventa los interprete como peso.

## Licencia

MIT – siéntete libre de usar, modificar y distribuir.
