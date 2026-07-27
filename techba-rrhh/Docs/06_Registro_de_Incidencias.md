# Registro de Incidencias

## Objetivo

Durante el desarrollo del proyecto se registraron todas las incidencias detectadas, junto con su análisis, resolución y estado final.

Este documento forma parte de la documentación técnica del proyecto y tiene como objetivo evidenciar el proceso de validación, depuración y mejora continua aplicado durante la construcción del pipeline de datos y del modelo analítico.

Las incidencias documentadas incluyen problemas relacionados con:

- Calidad de datos.
- Modelado relacional.
- PostgreSQL.
- Power BI.
- Integridad de la información.
- Diseño de visualizaciones.

# TechBA — Registro de Incidencias Detectadas y Corregidas

Este documento consolida todos los problemas identificados durante el desarrollo del proyecto TechBA (dataset ficticio de HR Analytics), junto con su diagnóstico, solución aplicada y estado actual. Sirve como evidencia de proceso técnico para el portfolio.

---

## 1. Conexión y modelado de datos

### 1.1 Columna geométrica rompía la carga en Power BI
- **Problema:** la columna `punto_geometrico` (tipo PostGIS) en la tabla `departamentos` provocaba error al importar datos desde Neon.
- **Causa:** Power BI (modo Import) no soporta de forma nativa tipos de datos geométricos de PostGIS.
- **Solución:** se excluyó `punto_geometrico` del modelo de Power BI. Se utilizan en su lugar las columnas `latitud` y `longitud` para cualquier necesidad de mapeo.
- **Estado:** ✅ Resuelto.

### 1.2 Relación bidireccional generaba cross-filtering incorrecto
- **Problema:** la relación entre `core vw_ausentismo_resumen` y `core vw_empleados_completo` estaba configurada como bidireccional, generando filtrados cruzados no deseados entre visuales.
- **Causa:** direccionalidad de filtro mal configurada en el modelo relacional.
- **Solución:** se corrigió la relación a dirección única (Empleados → Ausentismo).
- **Estado:** ✅ Resuelto.

### 1.3 Relación entre `core vw_empleados_completo` y `vw_valuaciones_x_empleado` no propaga filtro correctamente
- **Problema:** al usar la columna `Nombre Completo` (definida en `core vw_empleados_completo`) como eje de un gráfico de ranking, todos los empleados mostraban el mismo valor de `Puntaje Promedio General` (5,51), en vez de sus promedios individuales.
- **Causa:** la relación entre ambas tablas no está filtrando correctamente el contexto de fila hacia la tabla de evaluaciones (posible relación inactiva, dirección incorrecta, o cardinalidad mal definida).
- **Solución aplicada (paliativa):** se reemplazó `Nombre Completo` por el campo `empleado` (nombre simple), tomado directamente desde `vw_valuaciones_x_empleado`, evitando así depender de la relación entre tablas.
- **Estado:** ⚠️ Resuelto de forma alternativa — **pendiente revisar la causa raíz de la relación**, ya que podría estar afectando otros visuales que sí dependen de ella (ej. tarjetas de "última evaluación", que solo se actualizan correctamente si la selección se hace desde la tabla Empleados y no desde la tabla Evaluaciones).

---

## 2. Calidad de datos

### 2.1 Empleados sin registro de sueldo
- **Problema:** 8 empleados presentaban valores `NULL` en moneda, sueldo y período.
- **Decisión:** se aceptó como caso realista de calidad de datos, sin corregir ni completar artificialmente.
- **Solución:** se crearon columnas calculadas DAX (`Moneda Display`, `Sueldo Display`, `Periodo Display`) con fallback de texto "Sin dato" para visualización, preservando las columnas numéricas/fecha originales para KPIs y agregaciones.
- **Transparencia:** se agregó una tarjeta en el dashboard ("Empleados sin sueldo cargado: 8") documentando el hallazgo como parte del análisis, no como defecto oculto.
- **Estado:** ✅ Resuelto (documentado como hallazgo, no como error a ocultar).

### 2.2 Cardinalidad poco realista en `evaluador_id`
- **Problema:** el campo `evaluador_id` tenía 199 evaluadores distintos, un valor poco creíble para una estructura organizacional de este tamaño.
- **Intento de corrección:** se probó reasignar los evaluadores a un pool reducido de 27 (roles tipo Gerente RRHH / Product Manager).
- **Decisión final:** se revirtió el cambio por decisión del usuario — se determinó que fabricar correlaciones realistas en un dataset ficticio es costoso e imperfecto.
- **Estado:** ⚠️ No corregido — aceptado como limitación del dataset ficticio. Próximos proyectos usarán datos reales para evitar este tipo de problema.

### 2.3 Inconsistencia entre `categoria` y `puntaje` en evaluaciones
- **Problema:** la columna `categoria` no correlacionaba con el `puntaje` numérico (ej. registros con categoría "Excepcional" pero puntaje de 1,70).
- **Causa:** los datos ficticios fueron generados sin una regla de negocio consistente entre puntaje y categoría.
- **Solución:** se ejecutó un `UPDATE` en PostgreSQL aplicando los siguientes cortes:
  - `puntaje` ≥ 8.5 → Excepcional
  - `puntaje` ≥ 6.5 → Bueno
  - `puntaje` ≥ 4.5 → Regular
  - `puntaje` < 4.5 → Bajo
- **Control de seguridad:** se creó una columna de respaldo antes del `UPDATE`, verificada, y eliminada una vez confirmado el resultado.
- **Estado:** ✅ Resuelto. Confirmado visualmente en la tabla de detalle de evaluaciones (categorías coherentes con puntajes tras el refresh).

### 2.4 Tratamiento de datos faltantes

Durante el proceso de validación se detectaron registros con información incompleta, como empleados sin salario asignado o evaluaciones de desempeño sin puntaje.

Se decidió no completar ni modificar estos valores de manera arbitraria.

En su lugar, los registros fueron conservados y documentados como incidencias de calidad de datos.

Esta decisión permite:

- Mantener la integridad de la información original.
- Evitar introducir supuestos sin respaldo funcional.
- Reflejar un escenario realista de calidad de datos.
- Evidenciar la importancia de definir reglas de negocio antes de transformar información.

---

## 3. Comportamiento de visuales en Power BI

### 3.1 Gráfico de evolución vacío sin selección de empleado
- **Problema:** al no haber ningún empleado seleccionado en la tabla maestro, los visuales de detalle (tabla/gráfico de evaluaciones) quedaban vacíos o poco legibles.
- **Solución:** se reemplazó el enfoque de tabla/gráfico de línea por un set de **tarjetas de "última evaluación"** (Puntaje, Categoría, Período), que se activan y muestran datos claros únicamente cuando hay una selección activa.
- **Estado:** ✅ Resuelto.

### 3.2 Gráfico de línea poco adecuado para pocos registros por empleado
- **Problema:** al tener solo 3-5 evaluaciones por empleado, el gráfico de línea se veía "flojo" visualmente.
- **Solución:** se reemplazó por gráfico de columnas con leyenda por categoría y eje Y secundario, sin etiquetas de valores.
- **Estado:** ✅ Resuelto.

### 3.3 Tarjetas de última evaluación no respondían a selección desde la tabla de detalle
- **Problema:** al seleccionar una fila en la tabla "Evaluaciones por empleado" (detalle), las tarjetas de última evaluación no se actualizaban — solo funcionaban al seleccionar desde la tabla "Empleados" (maestro).
- **Causa:** las medidas DAX usaban `SELECTEDVALUE` únicamente sobre `core vw_empleados_completo[empleado_id]`, sin considerar selección desde la tabla de evaluaciones.
- **Solución propuesta:** uso de `COALESCE` entre ambos posibles orígenes de selección (`core vw_empleados_completo` y `vw_valuaciones_x_empleado`) más `ALL()` para evitar que el filtro de fila limite el cálculo del "último" período.
- **Decisión del usuario:** se revirtió el cambio, manteniendo el comportamiento original (las tarjetas responden solo a selección desde la tabla Empleados).
- **Estado:** ⚠️ No aplicado — quedó documentada la solución técnica por si se retoma en el futuro.

### 3.4 Donut de distribución por categoría se filtraba al seleccionar un empleado
- **Problema:** el gráfico de distribución de evaluaciones por categoría (donut) cambiaba sus valores al seleccionar un empleado en la tabla maestro, cuando el objetivo era que mostrara siempre el panorama general.
- **Solución:** se utilizó la función **Editar interacciones** de Power BI, configurando la interacción de la tabla Empleados sobre el donut como "Ninguno", evitando así que el filtro de selección lo afecte.
- **Estado:** ✅ Resuelto.

---
# 5. Decisiones de Ingeniería

## Datos faltantes

Los valores nulos no fueron reemplazados automáticamente.

La imputación de información requiere reglas de negocio definidas por el cliente.

En ausencia de dichas reglas, los registros fueron conservados y documentados como incidencias.

---

## Lógica de negocio

Toda la lógica fue implementada en PostgreSQL.

Power BI consume únicamente vistas analíticas.

---

## Calidad de datos

Las inconsistencias detectadas fueron registradas y clasificadas antes de construir el modelo relacional.

---

## Reproducibilidad

El proceso completo puede repetirse siguiendo las mismas etapas de carga, validación y transformación.

---
## 5. Resumen de estado general

| Incidencia | Estado |
|---|---|
| Columna PostGIS rompía carga | ✅ Resuelto |
| Relación bidireccional (Ausentismo) | ✅ Resuelto |
| Relación Empleados ↔ Evaluaciones no filtra bien | ⚠️ Resuelto alternativamente / causa raíz pendiente |
| 8 empleados sin sueldo | ✅ Resuelto (documentado como hallazgo) |
| Cardinalidad `evaluador_id` poco realista | ⚠️ No corregido (limitación aceptada del dataset ficticio) |
| Inconsistencia `categoria` vs `puntaje` | ✅ Resuelto |
| Visual vacío sin selección | ✅ Resuelto |
| Línea poco adecuada para pocos registros | ✅ Resuelto |
| Tarjetas no responden a selección desde detalle | ⚠️ No aplicado (decisión del usuario) |
| Donut se filtraba por selección de empleado | ✅ Resuelto |

---

*Documento generado como parte de la documentación técnica del proyecto TechBA — portfolio de Julián Olaviaga.*
