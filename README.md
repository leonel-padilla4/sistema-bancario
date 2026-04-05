# sistema-bancario

```
Sistema Bancario — Base de Datos SQL
```

# Descripción
```
Este sistema modela las entidades y relaciones fundamentales de un banco:
clientes, cuentas, movimientos, transferencias, tarjetas, préstamos e inversiones.
```

# Tablas del sistema
```
Clientes: almacena el nombre, apellido, teléfono y
dirección de cada cliente del banco.
```
```
Cuentas: representa las cuentas bancarias de cada cliente.
Puede ser de tipo corriente o ahorros, y guarda el número de cuenta y el saldo actual.
```
```
Transacciones: registra cada movimiento realizado sobre una cuenta:
depósito, retiro o transferencia, con su fecha, hora y monto.
```
```
Transferencias: guarda los envíos de dinero entre cuentas,
indicando la cuenta de origen, la cuenta destino, el monto y la fecha.
```
```
Tarjetas: asocia tarjetas bancarias a los clientes.
Pueden ser de débito, crédito o prepago, e incluyen el número y el límite de crédito.
```
```
Prestamos: registra los préstamos solicitados por los clientes, con el monto,
la tasa de interés, la fecha de vencimiento y el estado actual (activo, pagado o vencido).
```
```
Inversiones: guarda los productos de inversión de cada cliente (acciones, bonos o fondos),
el monto invertido originalmente y su valor actual de mercado.
```

# Relaciones
```
Un cliente puede tener muchas cuentas, tarjetas, préstamos e inversiones.
Cada cuenta puede tener muchas transacciones.
Una transferencia siempre involucra dos cuentas: la de origen y la de destino.
```

# Consulta 1 — Clientes con al menos una cuenta
```
En esta consulta utilicé EXISTS para verificar si cada cliente tiene al menos una cuenta registrada.
Lo que hace es revisar por cada cliente si existe alguna fila en la tabla cuentas que coincida con su id.
Si existe, el cliente aparece en el resultado.

SELECT id, nombre, apellido FROM clientes WHERE EXISTS (
    SELECT 1 FROM cuentas
    WHERE cuentas.id_cliente = clientes.id
);
```

# Consulta 2 — Saldo total por cliente
```
Aquí usé una subconsulta escalar dentro del SELECT para calcular la suma de todos los saldos de cada cliente.
Solo muestro los clientes que tienen al menos una cuenta usando IN con otra subconsulta.

SELECT nombre, apellido,
    (SELECT SUM(saldo) FROM cuentas
     WHERE cuentas.id_cliente = clientes.id) AS saldo_total
FROM clientes
WHERE id IN (SELECT id_cliente FROM cuentas);
```

# Consulta 3 — Transacciones de un cliente específico
```
Para esta consulta primero obtuve todas las cuentas que pertenecen al cliente con id 1, y
luego filtré las transacciones que corresponden a esas cuentas.
Usé una subconsulta dentro del WHERE con IN para lograrlo.

SELECT * FROM transacciones
WHERE id_cuenta IN (
    SELECT id FROM cuentas
    WHERE id_cliente = 1
);
```

# Consulta 4 — Cuentas con saldo mayor a 10,000
```
Apliqué un filtro directo con WHERE sobre el campo saldo para obtener las cuentas que superan los 10,000.

SELECT * FROM cuentas
WHERE saldo > 10000;
```

# Consulta 5 — Clientes que tienen tarjetas
```
Usé IN con una subconsulta sobre la tabla tarjetas para obtener los id de los
clientes que tienen al menos una tarjeta registrada, y luego los busqué en la tabla clientes.

SELECT id, nombre, apellido
FROM clientes
WHERE id IN (
    SELECT id_cliente FROM tarjetas
);
```

# Consulta 6 — Número de cuentas por cliente
```
Aquí utilicé COUNT dentro de una subconsulta escalar para contar cuántas cuentas tiene cada cliente.
Solo aparecen los clientes que tienen al menos una cuenta registrada.

SELECT nombre, apellido,
    (SELECT COUNT(*) FROM cuentas
     WHERE cuentas.id_cliente = clientes.id) AS num_cuentas
FROM clientes
WHERE id IN (SELECT id_cliente FROM cuentas);
```

# Consulta 7 — Préstamos activos
```
En esta consulta simplemente filtré los préstamos cuyo campo estado tiene el valor activo.
Como ese campo es de tipo ENUM, solo puede tener los valores activo, pagado o vencido.

SELECT * FROM prestamos
WHERE estado = 'activo';
```

# Consulta 8 — Monto total transferido desde cada cuenta
```
Aquí calculé cuánto dinero ha salido de cada cuenta como origen de una transferencia.
Usé SUM en una subconsulta y filtré solo las cuentas que aparecen al menos una vez como cuenta de origen.

SELECT numero,
    (SELECT SUM(monto) FROM transferencias
     WHERE transferencias.cuenta_origen = cuentas.id) AS total_transferido
FROM cuentas
WHERE id IN (SELECT cuenta_origen FROM transferencias);
```

# Consulta 9 — Transacciones del último mes
```
Para obtener las transacciones recientes usé DATE_SUB junto con NOW(),
lo que me permite restar un mes a la fecha actual de forma dinámica.
Así no necesito escribir una fecha fija.

SELECT * FROM transacciones
WHERE fecha_hora >= DATE_SUB(NOW(), INTERVAL 1 MONTH);
```

# Consulta 10 — Clientes con inversiones mayores a 5,000
```
Filtré dentro de la subconsulta los registros de inversiones cuyo monto supera los 5,000,y
con esos id busqué a los clientes correspondientes en la tabla clientes usando IN.

SELECT id, nombre, apellido
FROM clientes
WHERE id IN (
    SELECT id_cliente FROM inversiones
    WHERE monto > 5000
);
```

# Consulta 11 — Nombre, número de cuenta y saldo
```
Aquí usé LEFT JOIN para combinar la información de clientes con sus cuentas.
El filtro WHERE cuentas.id IS NOT NULL me permite excluir a los clientes que no tienen ninguna cuenta.

SELECT clientes.nombre, clientes.apellido, cuentas.numero, cuentas.saldo
FROM clientes
LEFT JOIN cuentas ON clientes.id = cuentas.id_cliente
WHERE cuentas.id IS NOT NULL;
```

# Consulta 12 — Total de transacciones por cuenta
```
Usé GROUP BY para agrupar todas las transacciones por cuenta, y
luego apliqué COUNT para contar cuántas operaciones tuvo cada una y SUM para sumar el monto total movido.

SELECT id_cuenta,
       COUNT(id)  AS total_transacciones,
       SUM(monto) AS monto_total
FROM transacciones
GROUP BY id_cuenta;
```

# Consulta 13 — Clientes SIN cuentas
```
Con LEFT JOIN puedo traer todos los clientes aunque no tengan cuentas.
Luego filtré con IS NULL para quedarme solo con los que no tienen ninguna cuenta asociada,
como es el caso de Lucía Torres.

SELECT clientes.nombre, clientes.apellido
FROM clientes
LEFT JOIN cuentas ON clientes.id = cuentas.id_cliente
WHERE cuentas.id IS NULL;
```

# Consulta 14 — Cliente con más cuentas
```
Conté las cuentas de cada cliente con una subconsulta y luego ordené el resultado de mayor a menor.
Usé LIMIT 1 para mostrar solo los dos clientes con más cuentas abiertas.

SELECT nombre, apellido,
    (SELECT COUNT(*) FROM cuentas
     WHERE cuentas.id_cliente = clientes.id) AS num_cuentas
FROM clientes
ORDER BY num_cuentas DESC
LIMIT 1;
```

# Consulta 15 — Total de préstamos por cliente
```
Sumé todos los montos de préstamos por cliente usando SUM en una subconsulta escalar.
Solo aparecen los clientes que tienen al menos un préstamo registrado.

SELECT nombre, apellido,
    (SELECT SUM(monto) FROM prestamos
     WHERE prestamos.id_cliente = clientes.id) AS total_prestamos
FROM clientes
WHERE id IN (SELECT id_cliente FROM prestamos);
```

# Consulta 16 — Total invertido por cliente
```
Similar a la anterior pero aplicada a inversiones. Sume el monto original de cada inversión
por cliente para saber cuánto ha invertido en total cada uno.

SELECT nombre, apellido,
    (SELECT SUM(monto) FROM inversiones
     WHERE inversiones.id_cliente = clientes.id) AS total_invertido
FROM clientes
WHERE id IN (SELECT id_cliente FROM inversiones);
```

# Consulta 17 — Cuentas sin transacciones
```
Usé NOT IN para excluir todas las cuentas que aparecen en la tabla transacciones.
Las que quedan son cuentas que nunca han tenido ningún movimiento registrado.

SELECT numero, tipo, saldo
FROM cuentas
WHERE id NOT IN (
    SELECT DISTINCT id_cuenta FROM transacciones
);
```

# Consulta 18 — Promedio de monto por transacción
```
Aquí simplemente apliqué la función AVG sobre el campo monto de la tabla transacciones
para obtener el promedio general de todas las operaciones registradas.

SELECT AVG(monto) AS promedio_transaccion
FROM transacciones;
```

# Consulta 19 — Top 5 clientes con mayor saldo total
```
Calculé el saldo total de cada cliente sumando todas sus cuentas, luego ordené de mayor a menor y
usé LIMIT 5 para obtener solo los cinco clientes con más dinero acumulado.

SELECT nombre, apellido,
    (SELECT SUM(saldo) FROM cuentas
     WHERE cuentas.id_cliente = clientes.id) AS saldo_total
FROM clientes
WHERE id IN (SELECT id_cliente FROM cuentas)
ORDER BY saldo_total DESC
LIMIT 5;
```

# Consulta 20 — Clientes con cuentas Y préstamos
```
Combiné dos condiciones con AND, cada una verificando con IN si el cliente aparece en cuentas y
también en préstamos. Solo aparecen los clientes que cumplen ambas condiciones al mismo tiempo.

SELECT nombre, apellido
FROM clientes
WHERE id IN (SELECT id_cliente FROM cuentas)
  AND id IN (SELECT id_cliente FROM prestamos);
```

# Consulta 21 — Cliente con mayor actividad
```
Esta fue una de las más complejas. Usé una subconsulta anidada que primero obtiene todas las cuentas del cliente y
luego cuenta todas las transacciones de esas cuentas. Ordené de mayor a menor y con LIMIT 1 obtuve solo el cliente más activo.

SELECT nombre, apellido,
    (SELECT COUNT(*) FROM transacciones
     WHERE transacciones.id_cuenta IN
        (SELECT id FROM cuentas WHERE cuentas.id_cliente = clientes.id)
    ) AS total_transacciones
FROM clientes
ORDER BY total_transacciones DESC
LIMIT 1;
```

# Consulta 22 — Cuentas sospechosas
```
Agrupé las transferencias por cuenta y por día usando GROUP BY. Luego apliqué HAVING para filtrar solo los grupos
donde se realizaron más de 3 transferencias en el mismo día, lo que podría indicar actividad inusual o sospechosa.

SELECT cuenta_origen, DATE(fecha_hora) AS dia, COUNT(*) AS num_transferencias
FROM transferencias
GROUP BY cuenta_origen, DATE(fecha_hora)
HAVING COUNT(*) > 3;
```

# Consulta 23 — Clientes con saldo menor a sus préstamos
```
Aquí comparé directamente dos subconsultas en el WHERE: el saldo total de las cuentas contra la suma de los préstamos.
Si el saldo es menor, ese cliente representa un riesgo financiero y aparece en el resultado.

SELECT nombre, apellido,
    (SELECT SUM(saldo) FROM cuentas
     WHERE cuentas.id_cliente = clientes.id) AS saldo_total,
    (SELECT SUM(monto) FROM prestamos
     WHERE prestamos.id_cliente = clientes.id) AS total_prestamos
FROM clientes
WHERE
    (SELECT SUM(saldo) FROM cuentas
     WHERE cuentas.id_cliente = clientes.id)
    
    (SELECT SUM(monto) FROM prestamos
     WHERE prestamos.id_cliente = clientes.id);
```

# Consulta 24 — Ranking de clientes por inversiones
```
Usé la función de ventana RANK() OVER para asignarle un número de posición a
cada cliente según cuánto ha invertido en total. A diferencia de un ORDER BY normal,
esta función permite ver el ranking sin perder los demás datos del resultado.

SELECT clientes.nombre, clientes.apellido,
       SUM(inversiones.monto) AS total_invertido,
       RANK() OVER (ORDER BY SUM(inversiones.monto) DESC) AS ranking
FROM clientes
LEFT JOIN inversiones ON clientes.id = inversiones.id_cliente
WHERE inversiones.id IS NOT NULL
GROUP BY clientes.id, clientes.nombre, clientes.apellido;
```

# Consulta 25 — Crecimiento de inversiones por cliente
```
Calculé el monto original invertido, el valor actual, la ganancia absoluta restando ambos valores,
y el porcentaje de crecimiento dividiendo la ganancia entre el monto original y multiplicando por 100.
Usé ROUND para redondear el porcentaje a 2 decimales y que el resultado se vea más limpio.

SELECT nombre, apellido,
    (SELECT SUM(monto) FROM inversiones
     WHERE inversiones.id_cliente = clientes.id) AS monto_original,
    (SELECT SUM(valor_actual) FROM inversiones
     WHERE inversiones.id_cliente = clientes.id) AS valor_actual,
    (SELECT SUM(valor_actual) - SUM(monto) FROM inversiones
     WHERE inversiones.id_cliente = clientes.id) AS ganancia,
    ROUND((SELECT (SUM(valor_actual) - SUM(monto)) / SUM(monto) * 100
         FROM inversiones
         WHERE inversiones.id_cliente = clientes.id)
    , 2) AS porcentaje_crecimiento
FROM clientes WHERE id IN (SELECT id_cliente FROM inversiones);
```
