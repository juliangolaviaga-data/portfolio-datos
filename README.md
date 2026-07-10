# Portfolio de Datos — Julián G. Golaviaga

Portfolio de proyectos de análisis de datos: pipelines SQL, limpieza y modelado en PostgreSQL, dashboards en Power BI.

## Stack

PostgreSQL · Power BI (DirectQuery) · Python · Git/GitHub · DBeaver

## Proyectos

### 🛍️ [FashionStore](./fashionstore/) — Completo
Pipeline de ventas de e-commerce: staging, limpieza de datos, modelo relacional y dashboard interactivo.
- [`limpieza_datos_fashionstore.sql`](./fashionstore/limpieza_datos_fashionstore.sql) — script de staging y limpieza
- [`FashionStore - Portfolio de Datos.html`](./fashionstore/FashionStore%20-%20Portfolio%20de%20Datos.html) — resumen del proyecto
- `FashionStore_arg.pbix` — dashboard Power BI

### 👥 TechBA RRHH — En progreso
Análisis de RRHH: empleados, sueldos, evaluaciones, ausentismo, departamentos y puestos. Fuente: [Neon](https://neon.tech).

## Setup local

```bash
pip install -r requirements.txt
# crear .env con DATABASE_URL
python test_conexion.py
```