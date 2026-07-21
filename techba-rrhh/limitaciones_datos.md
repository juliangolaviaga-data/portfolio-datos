# Limitaciones conocidas de los datos — TechBA-RRHH

Este documento registra particularidades y limitaciones reales detectadas en el dataset durante la migración de `staging` a `core`. El objetivo es que cualquier persona que use estas tablas (o el propio equipo en el futuro) entienda por qué ciertas columnas no tienen constraints "ideales" (NOT NULL, UNIQUE, etc.) y qué significa cada excepción.

---

## core.empleados

### `email` no garantiza unicidad por persona

En 9 casos (18 de 200 empleados), dos empleados con nombre y apellido idénticos comparten el mismo email, generado a partir del patrón `nombre.apellido@techba.com`. Se confirmó que corresponden a personas distintas: en cada par, el teléfono, la fecha de nacimiento, la fecha de ingreso y el departamento son todos diferentes.

**Pares afectados:**
- aldana.rojas@techba.com
- camila.molina@techba.com
- cecilia.cabrera@techba.com
- cecilia.medina@techba.com
- cecilia.nunez@techba.com
- ezequiel.gomez@techba.com
- micaela.herrera@techba.com
- natalia.molina@techba.com
- ramiro.vera@techba.com

**Implicancia:** `email` **no** debe usarse como clave de búsqueda o relación. La clave de identidad única es `empleado_id`.

**Decisión de diseño:** no se agregó constraint `UNIQUE` sobre `email`, ya que reflejaría una regla de negocio inexistente en los datos reales y rompería la carga.

### Duplicados exactos en staging (resuelto)

6 `empleado_id` tenían filas duplicadas exactas en `staging` (206 filas → 200 únicas). Se resolvió con `SELECT DISTINCT` al migrar a `core`. Verificado con `utils.control_duplicados_exactos`: 0 duplicados restantes en `core`.

---

## core.sueldos

### `monto` permite valores no numéricos ("A confirmar")

138 de 5649 filas (~2.4%) tienen `monto = 'A confirmar'`, un valor de negocio real (sueldo aún no definido), no un error de carga.

**Decisión de diseño:** se removió el `NOT NULL` sobre `monto` y se agregó el cast `::numeric` solo donde corresponde, permitiendo que estas filas convivan con el resto sin forzar un valor inventado.

**Implicancia:** cualquier cálculo agregado sobre `monto` (promedios, sumas) debe filtrar o tratar explícitamente estos 138 casos, ya que no son numéricos.

---

## core.evaluaciones

### `puntaje` permite valores pendientes

29 de 835 filas (~3.5%) tienen puntaje pendiente de asignar (evaluación aún no completada), mismo criterio que en `sueldos`: se removió el `NOT NULL`.

**Implicancia:** igual que con `monto`, cualquier promedio o análisis de `puntaje` debe excluir o tratar explícitamente estos casos.

### Constraint `chk_eval_id_formato` corregido

El constraint original esperaba un formato de 1 letra + dígitos; el formato real de los IDs es `EV` + dígitos. Corregido para reflejar el formato real de los datos.

---

## core.ausentismo

### Normalización de `justificado`

El constraint `chk_justificado_valores` no toleraba variantes de escritura (`S`, `SI`, `si`, `N`, `NO`, `no`). Se resolvió usando la función `utils.normalizar_booleano` ya existente en la librería.

**Diseño de columnas:** se mantienen dos columnas con roles distintos:
- `justificado` (VARCHAR): conserva el valor original tal como vino en staging.
- `justificado_bool` (BOOLEAN): valor normalizado, pensado para filtrado rápido y agregaciones.

### Fechas incompletas completadas por convención

Una parte de las fechas en `staging` venían incompletas (sin día). Se completan por convención: día 1 del mes para `fecha_inicio`, último día del mes para `fecha_fin`. Esto significa que una porción de las fechas en `core.ausentismo` no son el dato exacto original, sino una fecha inferida según esta regla.

**Implicancia:** el constraint `chk_orden_fechas` (`fecha_fin >= fecha_inicio`) valida que la convención se haya aplicado correctamente; cualquier análisis que dependa de precisión exacta a nivel día debe considerar que estas fechas son aproximadas.

> El detalle de desarrollo de esta corrección (bug en `utils.limpiar_fecha_generica`, parámetro `completar_como`, manejo de sobrecarga de función) queda documentado en el CHANGELOG de la librería `utils`, no acá — este archivo describe el dato resultante, no el proceso de la librería.

---

## core.puesto

Sin incidentes. Revisada sin duplicados (20/20), constraints coherentes (`chk_puesto_id_formato`, `chk_bandas_salariales`), sin diferencias entre `staging` y `core`.

---

## core.departamentos

Sin incidentes. Sin duplicados (0/0 vía `utils.control_duplicados_exactos`).

---

## Resumen de control de calidad — Nivel 5 (staging vs core)

Las 6 tablas cuadran sin pérdida de filas:

| Tabla | Staging | Core |
|---|---|---|
| empleados | 200 | 200 |
| sueldos | 5649 | 5649 |
| evaluaciones | 835 | 835 |
| departamentos | 12 | 12 |
| puesto | 20 | 20 |
| ausentismo | 628 | 628 |

## Duplicados exactos (Nivel 1) — `utils.control_duplicados_exactos`

| Tabla | Duplicados encontrados |
|---|---|
| empleados | 6 (resueltos) |
| departamentos | 0 |
| puesto | 0 |
| sueldos | revisado, sin problemas |
| evaluaciones | revisado, sin problemas |

---

*Última actualización: sesión de migración a `core`, julio 2026.*
