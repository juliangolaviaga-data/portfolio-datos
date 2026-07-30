# Modelo de Datos

## Tabla de hechos

### ventas_brutas

- order_id
- fecha
- cliente_id
- producto_id
- cantidad
- precio_unitario
- descuento
- metodo_pago
- estado
- ingreso_neto

## Dimensiones

### productos

- producto_id
- nombre
- categoria
- precio
- stock
- proveedor
- activo

### clientes

- cliente_id
- nombre
- email
- telefono
- ciudad
- fecha_registro
- segmento

## Relaciones

ventas_brutas.producto_id → productos.producto_id

ventas_brutas.cliente_id → clientes.cliente_id

## Modelo analítico

El modelo permite analizar:

- Ventas por producto
- Ventas por categoría
- Clientes por ciudad
- Clientes por segmento
- Métodos de pago
- Estados de órdenes
- Evolución temporal
- Ticket promedio