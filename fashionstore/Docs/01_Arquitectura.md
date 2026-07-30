# Arquitectura

## Objetivo

Preparar datos de ventas para análisis comercial en Power BI.

## Flujo del proceso

CSV / Excel
    ↓
PostgreSQL (staging)
    ↓
Limpieza y validación SQL
    ↓
PostgreSQL (core)
    ↓
Power Query
    ↓
Modelo de datos en Power BI
    ↓
Medidas DAX
    ↓
Dashboards

## Esquemas

### staging
- Importación de archivos originales
- Conservación del dato sin modificar
- Diagnóstico de calidad

### core
- Tablas normalizadas
- Integridad referencial
- Base utilizada por Power BI

## Herramientas

- PostgreSQL
- SQL
- Power Query
- Power BI
- DAX