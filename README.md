# Portfolio de Datos — Julián

**Data Analyst / Analytics Engineer** · Córdoba, Argentina

SQL-first. PostgreSQL como motor de modelado y transformación, Power BI como capa de visualización sobre datos ya preparados.

[LinkedIn](https://www.linkedin.com/in/julian-olaviaga-0b9329385) · [Workana](https://www.workana.com/freelancer/ec9769ac6e5b2321c25e71f03e372a13) · [juliangolaviaga@gmail.com](mailto:juliangolaviaga@gmail.com)

---

## Sobre este portfolio

Cada proyecto acá adentro sigue el mismo pipeline end-to-end: **datos crudos → staging → diagnóstico → limpieza SQL → modelado relacional → capa de exposición → dashboard en Power BI**. No son ejercicios de "conectar un CSV a un gráfico": el trabajo pesado —limpieza, reglas de negocio, integridad de datos, arquitectura del modelo— pasa en SQL, y Power BI entra recién al final, sobre datos que ya están confiables.

Esto refleja cómo trabajo en la práctica: como analista con background en desarrollo de software, priorizo que la lógica viva en un lugar versionable, testeable y reutilizable (la base de datos) antes que en fórmulas de Power Query o medidas DAX dispersas por el modelo.

---

## Proyectos

| # | Proyecto | Dataset | Foco técnico | Estado |
|---|---|---|---|---|
| 1 | [**FashionStore**](./FashionStore) | E-commerce de moda (ficticio) | Diagnóstico y limpieza de datos crudos reales: fechas en 7 formatos distintos, categorías inconsistentes, duplicados, valores inválidos. SQL avanzado (CTEs, window functions, columnas generadas) | ✅ Completo |
| 2 | [**TechBA**](./TechBA) | HR Analytics (ficticio) | Arquitectura de datos gobernada: capa de exposición exclusiva vía vistas (`core` schema), PostgreSQL en Neon, manejo de datos faltantes con transparencia, modelo relacional más complejo | ✅ Completo |
| 3 | *Próximo proyecto* | Dataset real (Kaggle u otra fuente pública) | — | 🔜 Planeado |

Los proyectos están ordenados cronológicamente a propósito: **FashionStore es el punto de partida** (demuestra que puedo llevar un dataset sucio del mundo real hasta un dashboard confiable) y **TechBA ya incorpora más gobernanza y disciplina arquitectónica** (reglas explícitas sobre cómo se expone el dato, documentación de gaps de calidad como activo, no como falla). La idea es que este portfolio siga creciendo con esa misma progresión: cada proyecto nuevo debería sumar una capa de complejidad o una herramienta que el anterior no tenía — no repetir el mismo ejercicio con otro dataset.

El próximo proyecto va a usar **datos reales** (no ficticios) para mostrar manejo de problemas de calidad que no se pueden diseñar a mano.

---

## Stack tecnológico

- **PostgreSQL** — modelado, limpieza, transformación, vistas
- **DBeaver** — cliente SQL para diagnóstico y desarrollo
- **Power BI Desktop** — modelado semántico y visualización (Import mode)
- **Power Query (M)** — transformaciones complementarias sobre datos ya limpios en SQL
- **DAX** — medidas de negocio sobre el modelo ya preparado

---

## Principios de trabajo

Estas son las reglas que sigo en todos los proyectos de este repo, no solo en uno:

- **La lógica de negocio vive en SQL, no en DAX ni en Power Query.** Power BI consume datos ya modelados y limpios; su trabajo es visualizar, no transformar.
- **Transparencia de calidad de datos.** Los gaps, nulos o inconsistencias que aparecen en un dataset real se documentan y se muestran — no se esconden ni se rellenan con valores inventados. Un `NULL` explícito es más honesto que un promedio disfrazado de dato.
- **Cada decisión de limpieza tiene una justificación de negocio explícita**, documentada junto al código SQL que la implementa.
- **La capa de exposición hacia BI está controlada.** A medida que los proyectos maduran, la tendencia es exponer datos vía vistas (nunca tablas base) para centralizar la lógica y controlar qué ve cada herramienta consumidora.
- **Todo es reproducible.** Cada proyecto documenta su pipeline completo (scripts SQL, decisiones, datasets crudos) para que el proceso se pueda auditar o repetir, no solo el resultado final.

---

## Estructura del repo

```
/
├── README.md                    ← estás acá
├── FashionStore/
│   ├── README.md                 ← documentación del proyecto
│   ├── datos_crudos/
│   ├── sql/
│   └── dashboard/
├── TechBA/
│   ├── README.md
│   ├── datos_crudos/
│   ├── sql/
│   └── dashboard/
└── (próximos proyectos)/
```

Cada carpeta de proyecto tiene su propio `README.md` con el detalle técnico completo: origen de datos, problemas encontrados, decisiones de limpieza, modelo relacional, vistas, medidas DAX y resultados. Este README raíz es solo la puerta de entrada.
