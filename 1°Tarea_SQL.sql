CREATE DATABASE Sistema_bancario;
USE Sistema_bancario;

CREATE TABLE clientes (
id INT PRIMARY KEY auto_increment,
nombre VARCHAR(50),
apellido VARCHAR(50),
telefono VARCHAR(50),
direccion VARCHAR(50)
);

CREATE TABLE cuentas (
id INT PRIMARY KEY AUTO_INCREMENT,
id_cliente INT,
tipo ENUM('corriente','ahorros'),
numero BIGINT,
saldo FLOAT, -- saldo actual en soles/dólares
FOREIGN KEY (id_cliente) REFERENCES clientes(id) -- un cliente puede tener varias cuentas
);

CREATE TABLE transacciones (
id INT PRIMARY KEY AUTO_INCREMENT,
id_cuenta INT,                            
fecha_hora DATETIME,                     
tipo ENUM('deposito','retiro','transferencia'), -- tipo de movimiento
monto FLOAT,      
FOREIGN KEY (id_cuenta) REFERENCES cuentas(id) -- cada transacción pertenece a una cuenta
);

CREATE TABLE transferencias (
id INT      PRIMARY KEY AUTO_INCREMENT,
cuenta_origen INT, 
cuenta_destino INT, 
fecha_hora DATETIME,
monto FLOAT,
FOREIGN KEY (cuenta_origen)  REFERENCES cuentas(id), -- cuenta de origen de la transferencia
FOREIGN KEY (cuenta_destino) REFERENCES cuentas(id)  -- cuenta de destino de la transferencia
);

CREATE TABLE tarjetas (
id INT PRIMARY KEY AUTO_INCREMENT,
tipo ENUM('debito','credito','prepago'),    -- tipo de tarjeta
id_cliente INT,
numero BIGINT,                               -- número de tarjeta
limite FLOAT,                                -- límite de crédito
FOREIGN KEY (id_cliente) REFERENCES clientes(id) -- cada tarjeta pertenece a un cliente
);

CREATE TABLE IF NOT EXISTS prestamos (
    id          INT     PRIMARY KEY AUTO_INCREMENT,
    id_cliente  INT,
    monto       FLOAT,                                -- monto del préstamo
    tasa        FLOAT,                                
    plazo       DATETIME,                                 -- fecha de vencimiento
    estado      ENUM('activo','pagado','vencido'),     
    FOREIGN KEY (id_cliente) REFERENCES clientes(id)  -- cada préstamo pertenece a un cliente
);

CREATE TABLE IF NOT EXISTS inversiones (
    id            INT     PRIMARY KEY AUTO_INCREMENT,
    id_cliente    INT,
    tipo          ENUM('acciones','bonos','fondos'),
    monto         FLOAT,                              -- monto invertido originalmente
    fecha         DATETIME,                               -- fecha de la inversión
    valor_actual  FLOAT,                              -- valor actual de la inversión
    FOREIGN KEY (id_cliente) REFERENCES clientes(id) -- cada inversión pertenece a un cliente
);





INSERT INTO clientes (nombre, apellido, telefono, direccion) VALUES
('Juan',   'Pérez',     '999111222', 'Av. Lima 123'),
('María',  'García',    '988222333', 'Jr. Cusco 456'),
('Carlos', 'Rodríguez', '977333444', 'Av. Arequipa 789'),
('Lucía',  'Torres',    '966444555', 'Jr. Junín 321');

INSERT INTO cuentas (id_cliente, tipo, numero, saldo) VALUES
(1, 'ahorros',   10000000001, 15000.00),
(1, 'corriente', 10000000002,  3000.00),
(2, 'ahorros',   10000000003, 25000.00),
(3, 'corriente', 10000000004,  8000.00),
(3, 'ahorros',   10000000005, 12000.00);
    
INSERT INTO transacciones (id_cuenta, fecha_hora, tipo, monto) VALUES
(1, '2025-03-10 10:00:00', 'deposito',      5000.00),
(1, '2025-03-15 11:00:00', 'retiro',        1000.00),
(1, NOW(),                 'deposito',       2000.00),
(2, '2025-03-20 09:00:00', 'transferencia', 3000.00),
(3, NOW(),                 'deposito',      10000.00),
(3, NOW(),                 'retiro',          500.00),
(4, '2024-02-01 08:00:00', 'deposito',       4000.00),
(5, NOW(),                 'transferencia',  6000.00);  

INSERT INTO transferencias (cuenta_origen, cuenta_destino, fecha_hora, monto) VALUES
(1, 3, NOW(),                  2000.00),
(2, 4, '2025-03-20 09:00:00',  3000.00),
(3, 5, NOW(),                  1500.00),
(4, 1, NOW(),                   500.00),
(4, 2, NOW(),                   600.00),
(4, 3, NOW(),                   700.00),
(4, 5, NOW(),                   800.00);

INSERT INTO tarjetas (tipo, id_cliente, numero, limite) VALUES
('debito',  1, 4111111111111001, 0.00),
('credito', 2, 4111111111111002, 5000.00),
('prepago', 3, 4111111111111003, 1000.0);


INSERT INTO prestamos (id_cliente, monto, tasa, plazo, estado) VALUES
(1, 10000.00, 0.12, '2026-01-01', 'activo'),
(2,  5000.00, 0.10, '2025-06-01', 'pagado'),
(3, 20000.00, 0.15, '2024-12-01', 'vencido'),
(3,  8000.00, 0.11, '2027-01-01', 'activo');    


INSERT INTO inversiones (id_cliente, tipo, monto, fecha, valor_actual) VALUES
(1, 'acciones', 3000.00, '2024-01-15', 4500.00),
(2, 'bonos',    8000.00, '2024-03-20', 8800.00),
(3, 'fondos',   6000.00, '2024-06-01', 5500.00),
(2, 'acciones', 2000.00, '2024-09-10', 3200.00);    
 

-- PREGUNTA 1: Clientes con al menos una cuenta
SELECT id, nombre, apellido FROM clientes WHERE EXISTS (
    SELECT 1 FROM cuentas
    WHERE cuentas.id_cliente = clientes.id
);

-- PREGUNTA 2: Saldo total por cliente
SELECT nombre, apellido,
    (SELECT SUM(saldo) FROM cuentas
     WHERE cuentas.id_cliente = clientes.id) AS saldo_total
FROM clientes
WHERE id IN (SELECT id_cliente FROM cuentas);

-- PREGUNTA 3: Transacciones de un cliente específico
SELECT * FROM transacciones
WHERE id_cuenta IN (
    SELECT id FROM cuentas
    WHERE id_cliente = 1
);

-- PREGUNTA 4: Cuentas con saldo mayor a 10,000
SELECT * FROM cuentas
WHERE saldo > 10000;

-- PREGUNTA 5: Clientes que tienen tarjetas
SELECT id, nombre, apellido
FROM clientes
WHERE id IN (
    SELECT id_cliente FROM tarjetas
);

-- PREGUNTA 6: Número de cuentas por cliente
SELECT nombre, apellido,
    (SELECT COUNT(*) FROM cuentas
     WHERE cuentas.id_cliente = clientes.id) AS num_cuentas
FROM clientes
WHERE id IN (SELECT id_cliente FROM cuentas);

-- PREGUNTA 7: Préstamos activos
SELECT * FROM prestamos
WHERE estado = 'activo';

-- PREGUNTA 8: Monto total transferido desde cada cuenta
SELECT numero,
    (SELECT SUM(monto) FROM transferencias
     WHERE transferencias.cuenta_origen = cuentas.id) AS total_transferido
FROM cuentas
WHERE id IN (SELECT cuenta_origen FROM transferencias);

-- PREGUNTA 9: Transacciones del último mes
SELECT * FROM transacciones
WHERE fecha_hora >= DATE_SUB(NOW(), INTERVAL 1 MONTH);

-- PREGUNTA 10: Clientes con inversiones mayores a 5,000
SELECT id, nombre, apellido
FROM clientes
WHERE id IN (
    SELECT id_cliente FROM inversiones
    WHERE monto > 5000
);

-- PREGUNTA 11: Nombre + número de cuenta + saldo
SELECT clientes.nombre, clientes.apellido, cuentas.numero, cuentas.saldo
FROM clientes
LEFT JOIN cuentas ON clientes.id = cuentas.id_cliente
WHERE cuentas.id IS NOT NULL;

-- PREGUNTA 12: Total de transacciones por cuenta
SELECT id_cuenta,
       COUNT(id)  AS total_transacciones,
       SUM(monto) AS monto_total
FROM transacciones
GROUP BY id_cuenta;

-- PREGUNTA 13: Clientes SIN cuentas
SELECT clientes.nombre, clientes.apellido
FROM clientes
LEFT JOIN cuentas ON clientes.id = cuentas.id_cliente
WHERE cuentas.id IS NULL;

-- PREGUNTA 14: Cliente con más cuentas
SELECT nombre, apellido,
    (SELECT COUNT(*) FROM cuentas
     WHERE cuentas.id_cliente = clientes.id) AS num_cuentas
FROM clientes
ORDER BY num_cuentas DESC
LIMIT 1;

-- PREGUNTA 15: Total de préstamos por cliente
SELECT nombre, apellido,
    (SELECT SUM(monto) FROM prestamos
     WHERE prestamos.id_cliente = clientes.id) AS total_prestamos
FROM clientes
WHERE id IN (SELECT id_cliente FROM prestamos);

-- PREGUNTA 16: Total invertido por cliente
SELECT nombre, apellido,
    (SELECT SUM(monto) FROM inversiones
     WHERE inversiones.id_cliente = clientes.id) AS total_invertido
FROM clientes
WHERE id IN (SELECT id_cliente FROM inversiones);

-- PREGUNTA 17: Cuentas que nunca han tenido transacciones
SELECT numero, tipo, saldo
FROM cuentas
WHERE id NOT IN (
    SELECT DISTINCT id_cuenta FROM transacciones
);

-- PREGUNTA 18: Promedio de monto por transacción
SELECT AVG(monto) AS promedio_transaccion
FROM transacciones;

-- PREGUNTA 19: Top 5 clientes con mayor saldo total
SELECT nombre, apellido,
    (SELECT SUM(saldo) FROM cuentas
     WHERE cuentas.id_cliente = clientes.id) AS saldo_total
FROM clientes
WHERE id IN (SELECT id_cliente FROM cuentas)
ORDER BY saldo_total DESC
LIMIT 5;

-- PREGUNTA 20: Clientes con cuentas Y préstamos
SELECT nombre, apellido
FROM clientes
WHERE id IN (SELECT id_cliente FROM cuentas)
  AND id IN (SELECT id_cliente FROM prestamos);

-- PREGUNTA 21: Cliente con mayor actividad
SELECT nombre, apellido,
    (SELECT COUNT(*) FROM transacciones
     WHERE transacciones.id_cuenta IN
        (SELECT id FROM cuentas WHERE cuentas.id_cliente = clientes.id)
    ) AS total_transacciones
FROM clientes
ORDER BY total_transacciones DESC
LIMIT 1;

-- PREGUNTA 22: Cuentas sospechosas (más de 3 transferencias en un día)
SELECT cuenta_origen, DATE(fecha_hora) AS dia, COUNT(*) AS num_transferencias
FROM transferencias
GROUP BY cuenta_origen, DATE(fecha_hora)
HAVING COUNT(*) > 3;

-- PREGUNTA 23: Clientes cuyo saldo total es menor a sus préstamos
SELECT nombre, apellido,
    (SELECT SUM(saldo) FROM cuentas
     WHERE cuentas.id_cliente = clientes.id) AS saldo_total,
    (SELECT SUM(monto) FROM prestamos
     WHERE prestamos.id_cliente = clientes.id) AS total_prestamos
FROM clientes
WHERE
    (SELECT SUM(saldo) FROM cuentas
     WHERE cuentas.id_cliente = clientes.id)
    <
    (SELECT SUM(monto) FROM prestamos
     WHERE prestamos.id_cliente = clientes.id);

-- PREGUNTA 24: Ranking de clientes por inversiones
SELECT clientes.nombre, clientes.apellido,
       SUM(inversiones.monto) AS total_invertido,
       RANK() OVER (ORDER BY SUM(inversiones.monto) DESC) AS ranking
FROM clientes
LEFT JOIN inversiones ON clientes.id = inversiones.id_cliente
WHERE inversiones.id IS NOT NULL
GROUP BY clientes.id, clientes.nombre, clientes.apellido;

-- PREGUNTA 25: Crecimiento de inversiones por cliente
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

