# Registro de Incidencias

## Objetivo

Durante el desarrollo del proyecto se registraron todas las incidencias detectadas, junto con su análisis, resolución y resultado.

Este documento forma parte de la documentación técnica del proyecto y evidencia el proceso de validación, depuración y mejora continua aplicado durante la construcción del pipeline de datos y del modelo analítico.

Las incidencias documentadas abarcan aspectos relacionados con:

- Calidad de datos.
- Modelado relacional.
- PostgreSQL.
- Power BI.
- Integridad de la información.
- Diseño de visualizaciones.

---

# 1. Conexión y Modelado de Datos

## 1.1 Columna geométrica impedía la carga en Power BI

**Problema**

La columna `punto_geometrico` (tipo PostGIS) de la tabla `departamentos` provocaba errores durante la importación desde Neon.

**Análisis**

Power BI (modo Import) no soporta de forma nativa tipos geométricos de PostGIS.

**Resolución**

Se excluyó la columna `punto_geometrico` del modelo y se utilizaron las columnas `latitud` y `longitud` para cualquier necesidad de representación geográfica.

**Resultado**

✅ Resuelto.

---

## 1.2 Relación bidireccional generaba filtrado cruzado incorrecto

**Problema**

La relación entre `core vw_ausentismo_resumen` y `core vw_empleados_completo` estaba configurada como bidireccional.

**Análisis**

La dirección del filtro provocaba propagación incorrecta entre los distintos visuales del informe.

**Resolución**

Se modificó la relación a dirección única (Empleados → Ausentismo).

**Resultado**

✅ Resuelto.

---

## 1.3 Relación entre Empleados y Evaluaciones no propagaba correctamente el contexto de filtro

**Problema**

Al utilizar `Nombre Completo` como eje del gráfico de ranking, todos los empleados mostraban el mismo valor de puntaje promedio.

**Análisis**

La relación entre ambas vistas no propagaba correctamente el contexto de filtro. La causa raíz permanece pendiente de análisis.

**Resolución**

Como solución alternativa se utilizó el campo `empleado` proveniente directamente de `core vw_valuaciones_x_empleado`, evitando depender de dicha relación.

**Resultado**

⚠️ Resuelto parcialmente. La solución implementada resuelve el comportamiento del visual, aunque la causa raíz continúa pendiente de revisión.

---

# 2. Calidad de Datos

## 2.1 Empleados sin registro de sueldo

**Problema**

Ocho empleados no tenían información de moneda, sueldo ni período.

**Análisis**

No existían reglas de negocio que permitieran completar la información faltante sin introducir supuestos.

**Resolución**

Se preservaron los valores originales y se crearon columnas DAX (`Moneda Display`, `Sueldo Display` y `Periodo Display`) para mostrar el texto **"Sin dato"** únicamente en la visualización.

Además, se incorporó un indicador en el dashboard informando la cantidad de empleados sin sueldo registrado.

**Resultado**

ℹ️ Documentado como hallazgo de calidad de datos.

---

## 2.2 Cardinalidad poco realista en `evaluador_id`

**Problema**

El campo `evaluador_id` contenía una cantidad de evaluadores poco representativa para una organización de este tamaño.

**Análisis**

Se evaluó reducir la cardinalidad simulando una estructura organizacional más realista.

Sin embargo, dicha modificación implicaba inventar reglas de negocio inexistentes.

**Resolución**

Se decidió conservar los datos originales y aceptar esta limitación del conjunto de datos.

**Resultado**

⚠️ Limitación aceptada.

---

## 2.3 Inconsistencia entre categoría y puntaje

**Problema**

La categoría asignada no guardaba relación con el puntaje obtenido.

**Análisis**

Los datos originales no respetaban una regla consistente entre ambas variables.

**Resolución**

Se implementó una regla de negocio en PostgreSQL para recalcular la categoría en función del puntaje.

Antes de ejecutar el proceso se creó una columna de respaldo para verificar el resultado y garantizar la recuperación de la información en caso necesario.

**Resultado**

✅ Resuelto.

---

# 3. Comportamiento de Visuales

## 3.1 Visuales de detalle sin selección de empleado

**Problema**

Los visuales de detalle quedaban vacíos cuando no existía un empleado seleccionado.

**Análisis**

La experiencia de usuario resultaba poco clara y dificultaba la interpretación del dashboard.

**Resolución**

Se reemplazó el enfoque inicial por un conjunto de tarjetas que muestran la última evaluación únicamente cuando existe una selección válida.

**Resultado**

✅ Resuelto.

---

## 3.2 Gráfico de línea poco representativo

**Problema**

Cada empleado disponía únicamente de tres a cinco evaluaciones, por lo que el gráfico de líneas no representaba adecuadamente la información.

**Análisis**

El volumen de datos hacía más apropiada otra visualización.

**Resolución**

Se descartó el gráfico de línea y se optó por mostrar el historial completo de evaluaciones (período, puntaje y categoría) en la tabla de detalle "Evaluaciones por empleado", que resulta más legible con este volumen de datos por empleado.

**Resultado**

✅ Resuelto.

---

## 3.3 Tarjetas de última evaluación no respondían a la selección desde la tabla de detalle

**Problema**

Las tarjetas únicamente respondían a la selección realizada desde la tabla de empleados.

**Análisis**

Se desarrolló una solución utilizando `COALESCE()` y `ALL()` para soportar ambos orígenes de selección.

**Resolución**

Se decidió mantener el comportamiento original por considerarlo más claro para el usuario final.

La solución alternativa quedó documentada para futuras mejoras.

**Resultado**

⚠️ No implementado por decisión de diseño.

---

## 3.4 Donut filtrado por selección de empleado

**Problema**

El gráfico de distribución por categoría cambiaba al seleccionar un empleado.

**Análisis**

El comportamiento no representaba el objetivo del visual, que debía mostrar siempre la distribución general.

**Resolución**

Se configuró **Editar interacciones** en Power BI, deshabilitando el filtrado desde la tabla de empleados.

**Resultado**

✅ Resuelto.

---

# 4. Resumen Ejecutivo de Incidencias

| Incidencia | Resultado |
|------------|-----------|
| Columna PostGIS impedía la carga | ✅ Resuelto |
| Relación bidireccional en Ausentismo | ✅ Resuelto |
| Relación Empleados ↔ Evaluaciones | ⚠️ Resuelto parcialmente |
| Empleados sin sueldo registrado | ℹ️ Documentado |
| Cardinalidad de `evaluador_id` | ⚠️ Limitación aceptada |
| Inconsistencia categoría vs. puntaje | ✅ Resuelto |
| Visuales vacíos sin selección | ✅ Resuelto |
| Gráfico de línea poco representativo | ✅ Resuelto |
| Tarjetas desde tabla de detalle | ⚠️ No implementado |
| Donut filtrado por selección | ✅ Resuelto |

---

*Documento integrante de la documentación técnica del proyecto TechBA.*