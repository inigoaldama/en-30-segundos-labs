# Lab · Laravel TokenGuard (CVE-2026-114509)

**Nivel: efecto completo.** Aquí se ve el fallo entrar y el parche cerrarlo, en tu máquina y en
aislado. Se puede mostrar el efecto completo sin riesgo porque el «exploit» es mandar un número:
no hay cadena de memoria ni herramienta reutilizable contra sistemas reales. Es una maqueta de
juguete que se habla a sí misma. Acompaña al artículo: https://aldama.net/articulos/laravel-tokenguard/

> Esto **no es Laravel**. Es una reproducción mínima de la única línea que fallaba (cómo TokenGuard
> buscaba al usuario por su token), para enseñar el mecanismo. No sirve contra ninguna aplicación real.

## Qué necesitas
Docker con Compose.

## Cómo se usa

```sh
docker compose up -d      # levanta web (PHP+Apache) y db (MySQL) en aislado
sh demo.sh                # lanza los cuatro casos de un tirón
docker compose down -v    # al terminar
```

`demo.sh` muestra el contraste:

| Caso | Modo | Token | Resultado |
|---|---|---|---|
| El ataque | vulnerable | `0` (un número) | **entra** como el primer usuario, sin conocer su token |
| Uso legítimo | vulnerable | token real | entra como ese usuario |
| Ataque, ya tapado | parcheado | `0` | **rechazado** antes de tocar la base de datos |
| Legítimo, intacto | parcheado | token real | sigue funcionando |

También puedes probar a mano en el navegador: `http://localhost:8080/?modo=vulnerable&token=0`.

## Por qué funciona el truco

TokenGuard solo comprobaba que el token **no estuviera vacío**, no que fuera texto. El atacante manda
un número dentro de un JSON (`{"api_token": 0}`), que llega a PHP como entero. Al comparar en SQL un
número con una columna de texto, MySQL convierte cada token de texto a número: `a8f3c1…` pasa a valer
`0`, y `token = 0` casa con el primer usuario. El arreglo (Laravel 12.68.0 / 13.29.0) rechaza el token
si no es una cadena, antes de preguntar a la base de datos. Lo ves en [app/index.php](app/index.php),
comentado línea a línea.

## Hasta aquí llega el lab

Muestra el efecto porque aquí hacerlo no entrega nada peligroso: reproducir «mandar un 0» no es un
arma, es una lección de tipos. Aun así, el lab se habla a sí mismo y no toca nada de fuera. Para
comprobar si **tu** proyecto está afectado, mira el artículo: resumen, si usas el driver `token`,
y la versión a la que actualizar.

## Fuentes
[GitLab Advisory Database](https://advisories.gitlab.com/composer/laravel/framework/CVE-2026-114509/) · [Laravel 12.68.0](https://github.com/laravel/framework/releases/tag/v12.68.0) · [Laravel 13.29.0](https://github.com/laravel/framework/releases/tag/v13.29.0).
