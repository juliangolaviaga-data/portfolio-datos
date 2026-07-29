# Conexión a Neon PostgreSQL desde DBeaver

Guía de referencia para crear una conexión a una base de datos Neon (PostgreSQL serverless) desde DBeaver, usando el connection string **directo** (sin pooling).

---

## 1. Obtener el connection string en Neon

1. Entrar al dashboard de Neon → seleccionar el proyecto.
2. Ir a **Connection Details** (o "Connection String").
3. Elegir la variante **directa** (host SIN `-pooler`). Ejemplo de formato:

```
postgresql://usuario:password@ep-xxxx-xxxx.region.aws.neon.tech/basededatos?sslmode=require&channel_binding=require
```

> Nota: Neon también ofrece una variante con `-pooler` en el host, pensada para muchas conexiones concurrentes y cortas (apps serverless, cron jobs). Para trabajo interactivo en DBeaver conviene la directa, porque el modo *transaction* del pooler no soporta bien sesiones largas ni algunas funciones (prepared statements con nombre, cursors, etc.).

---

## 2. Crear la conexión en DBeaver

**Atajo:** `Ctrl + Shift + N`
(o desde el ícono de "nueva conexión" en la barra superior del panel de Conexiones — el que tiene forma de enchufe)

Elegir **PostgreSQL** como tipo de driver → Siguiente.

---

## 3. Pestaña "General"

Completar los campos separando manualmente las partes del connection string:

| Campo DBeaver | De dónde sale | Ejemplo |
|---|---|---|
| **Host** | Entre `@` y la siguiente `/` | `ep-crimson-butterfly-acycsvor.sa-east-1.aws.neon.tech` |
| **Port** | Después de los `:` en el host (Neon siempre usa 5432) | `5432` |
| **Database** | Después de la última `/`, **solo el nombre**, sin `?sslmode=...` ni nada después del `?` | `neondb` |
| **Nombre de usuario** | Entre `//` y `:` | `neondb_owner` |
| **Contraseña** | Entre `:` y `@` | (la contraseña de Neon) |

⚠️ **Error común**: copiar y pegar todo lo que viene después de la última `/` directo en el campo Database, incluyendo `?sslmode=require&channel_binding=require`. Ese fragmento **no va ahí** — la parte de SSL se configura aparte (paso 4), y `channel_binding` es opcional.

Tildar **"Save password"** si no querés que la pida cada vez.

---

## 4. Pestaña "SSL"

Neon exige SSL siempre. En la pestaña **SSL**:

- Activar **"Use SSL"**
- **SSL mode**: `require`
- No hace falta certificado cliente (Neon maneja el SSL del lado del servidor).

---

## 5. (Opcional) channel_binding

Si Neon lo exige y la conexión falla sin él, se puede agregar en la pestaña **"Driver properties"** como propiedad extra:

- Nombre: `channel_binding`
- Valor: `require`

En la mayoría de los casos alcanza con SSL mode `require` y no hace falta tocar esto.

---

## 6. Probar y guardar

1. Click en **"Probar conexión..."** (abajo a la izquierda).
2. Si pide descargar el driver de PostgreSQL, aceptar.
3. Si da OK → **Finalizar**.

---

## Resumen visual del mapeo

```
postgresql://neondb_owner:PASSWORD@ep-crimson-butterfly-acycsvor.sa-east-1.aws.neon.tech:5432/neondb?sslmode=require&channel_binding=require
             └────┬────┘ └───┬──┘ └──────────────────────┬────────────────────────────┘      └─┬──┘  └──────────┬─────────────────────┘
              Username   Password                     Host                                  Database    Query params → van en pestaña SSL
                                                                                                            (no en el campo Database)
```

---

## Notas para el proyecto TechBA-RRHH

- Esta conexión usa credenciales reales de Neon → **no debe versionarse** en el repo público `portfolio-datos`.
- DBeaver guarda las conexiones localmente (no quedan en el repo), pero cualquier archivo `.env`, script de conexión o `.pbix` con esta conexión embebida debe ir a `.gitignore` o compartirse por Drive de forma privada, siguiendo el mismo criterio ya definido para este proyecto.
