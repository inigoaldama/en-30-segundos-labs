-- Base de datos de juguete del lab. Tres usuarios con tokens de texto normales.
-- Ninguno vale "0": el atacante entra sin conocer ningún token, solo por el truco de tipos.
CREATE TABLE usuarios (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(50) NOT NULL,
  api_token VARCHAR(64) NOT NULL
);
INSERT INTO usuarios (nombre, api_token) VALUES
  ('Ana',   'a8f3c1d4e5f6a7b8c9d0e1f2a3b4c5d6'),
  ('Luis',  '7c21e9f0a1b2c3d4e5f6a7b8c9d0e1f2'),
  ('Marta', 'f09e44a1b2c3d4e5f6a7b8c9d0e1f2a3');
