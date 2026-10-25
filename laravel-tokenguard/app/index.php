<?php
/*
 * Lab Laravel TokenGuard (CVE-2026-114509) — demostración didáctica del fallo y del arreglo.
 *
 * Esto NO es Laravel ni su código. Es una maqueta mínima de UNA sola línea de TokenGuard: cómo
 * buscaba el usuario por su token de API. Reproduce el fallo en aislado, contra una base de datos
 * de juguete, para que se vea POR QUÉ un número entra como otro usuario. No sirve contra ningún
 * sistema real: es una app de laboratorio que se habla a sí misma.
 *
 * Endpoints (GET para que se pruebe desde el navegador o con curl):
 *   /?modo=vulnerable&token=<valor>   → comprobación laxa (como TokenGuard < 12.68.0)
 *   /?modo=parcheado&token=<valor>    → comprobación correcta (token debe ser texto)
 */
declare(strict_types=1);
header('Content-Type: text/plain; charset=utf-8');

// EMULATE_PREPARES => true: el tipo del parámetro (int vs texto) se refleja en el SQL que llega a
// MySQL, igual que en el escenario del fallo. Con ello, un int dispara la comparación numérica.
$pdo = new PDO('mysql:host=db;dbname=lab;charset=utf8mb4', 'lab', 'lab',
    [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_EMULATE_PREPARES => true]);

$modo  = $_GET['modo']  ?? 'vulnerable';
$token = $_GET['token'] ?? '';

/*
 * El corazón del fallo. TokenGuard sacaba el token de la petición y solo comprobaba que no
 * estuviera vacío. Si el cliente mandaba un número (dentro de un JSON), ese número llegaba aquí
 * como int, y la comparación en SQL pasaba a ser numérica: MySQL convierte cada token de texto a
 * número (y 'a8f3c1…' vale 0), con lo que token = 0 casa con el primer usuario.
 */
function buscaUsuario(PDO $pdo, $token, string $modo): ?array {
    if ($modo === 'parcheado') {
        // El arreglo (12.68.0 / 13.29.0): si el token no es una cadena, no es válido. Fin.
        if (!is_string($token)) return null;
    }
    // En 'vulnerable' aceptamos el valor tal cual, como hacía TokenGuard: solo "no vacío".
    if ($token === '' || $token === null) return null;

    $sql = 'SELECT id, nombre FROM usuarios WHERE api_token = ? LIMIT 1';
    $st = $pdo->prepare($sql);
    // Como el código vulnerable: el valor viaja con su tipo PHP. Si es int, MySQL compara
    // numéricamente y convierte cada token de texto a número (0), de ahí el fallo.
    $st->bindValue(1, $token, is_int($token) ? PDO::PARAM_INT : PDO::PARAM_STR);
    $st->execute();
    $u = $st->fetch(PDO::FETCH_ASSOC);
    return $u ?: null;
}

/*
 * Un atacante no manda texto, manda un número dentro de un JSON: {"api_token": 0}. En PHP/Laravel
 * eso llega como int. Lo simulamos: si el token es "0" lo tratamos como el número 0 que llegaría
 * por JSON. (En el modo parcheado, is_string() lo rechaza antes de tocar la base de datos.)
 */
if ($token === '0') { $token = 0; }

$u = buscaUsuario($pdo, $token, $modo);

echo "Modo: $modo\n";
echo 'Token recibido: ' . var_export($token, true) . "\n";
echo str_repeat('-', 42) . "\n";
if ($u) {
    echo "ACCESO CONCEDIDO como: {$u['nombre']} (id {$u['id']})\n";
    if ($modo === 'vulnerable' && $token === 0) {
        echo "\n>> Y ahí está el fallo: sin conocer ningún token, un simple 0 te mete\n";
        echo ">> como el primer usuario de la tabla. Sin contraseña.\n";
    }
} else {
    echo "ACCESO DENEGADO\n";
    if ($modo === 'parcheado' && $token === 0) {
        echo "\n>> El arreglo rechaza el 0 porque no es texto, antes de preguntar a la base de datos.\n";
    }
}
