# En 30 segundos · Laboratorios

Laboratorios para probar por ti mismo, en aislado y en tu máquina, los fallos que cuento en la serie
**«En 30 segundos»** (https://aldama.net/articulos/). Cada carpeta acompaña a un artículo.

Todos siguen la misma regla: **te ayudan a comprobar si estás expuesto y a verificar el parcheo.**
Reproducen el *efecto* de un fallo solo cuando hacerlo no entrega un arma reutilizable; cuando sí lo
haría, el lab se queda en detección y lo explica. El «hasta aquí llega y por qué» está en el README de
cada uno.

| Lab | Fallo | Nivel |
|---|---|---|
| [php2shell](php2shell/) | CVE-2026-109618 / 109619 / 115560 | Detección y parcheo |

Requisito común: Docker con Compose.

— Iñigo Aldama · [aldama.net](https://aldama.net)
