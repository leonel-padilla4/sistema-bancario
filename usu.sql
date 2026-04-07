CREATE DATABASE sistema_usuarios;
USE sistema_usuarios;

CREATE TABLE roles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_rol VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE usuarios  (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario VARCHAR(50) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL,
    rol_id INT NOT NULL,
    FOREIGN KEY (rol_id) REFERENCES roles(id)
);

INSERT INTO roles (nombre_rol) VALUES 
('Administrador'),
('Usuario'),
('Moderador');

INSERT INTO usuarios (usuario, nombre, apellidos, password, rol_id) VALUES
('admin', 'Juan', 'Pérez García', '1234', 1);