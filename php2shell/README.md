# Lab · PHP2Shell (CVE-2026-109618 / CVE-2026-109619 / CVE-2026-115560)

**Nivel: detección y parcheo.** Este laboratorio te deja comprobar, en tu máquina y en aislado,
si una versión de PHP está expuesta a PHP2Shell y confirmar que tras actualizar deja de estarlo.
Acompaña al artículo: https://aldama.net/articulos/php2shell/

## Qué necesitas
Docker con Compose. Nada más.

## Cómo se usa

```sh
docker compose up
```

Levanta dos contenedores que solo ejecutan el comprobador y terminan:

- **vulnerable** → PHP 8.4.16 (anterior al parche) con `session.upload_progress` activo → sale **expuesto**.
- **parcheado** → PHP 8.4.27 (primera versión segura de la rama 8.4) con el vector desactivado → sale **a salvo**.

Ese es el contraste: la misma comprobación da resultados opuestos según la versión. Al acabar:

```sh
docker compose down
```

### Comprobar tu propio servidor
`comprobar.sh` no depende del lab. Cópialo a cualquier servidor y ejecútalo donde corre tu PHP:

```sh
sh comprobar.sh
```

Mira la versión en ejecución contra la tabla de versiones parcheadas y si `session.upload_progress`
está activo. Devuelve 0 si estás a salvo, 1 si estás expuesto (útil en un cron o en CI).

### Revisar logs
Amazon vio intentos de explotación desde el 17-oct-2026, cuatro días antes del aviso. Para mirar
tus accesos:

```sh
sh revisar-logs.sh /ruta/a/access.log
```

Marca peticiones con señales **compatibles** con el vector (menciones a `PHP_SESSION_UPLOAD_PROGRESS`,
ráfagas de POST desde una IP). No es un veredicto: es dónde mirar.

## Hasta aquí llega el lab, y por qué

Este laboratorio **detecta y verifica el parcheo. No reproduce el ataque.**

PHP2Shell es un fallo de corrupción de memoria (use-after-free del heap) que se estaba explotando
de forma activa cuando salió. Un lab que «demostrara el efecto» tendría que incluir la petición que
dispara el fallo, y escribir eso es escribir la primera mitad de un exploit funcional de un RCE sin
autenticación. No lo hacemos: no por que sea difícil (hay pruebas de concepto públicas de terceros),
sino porque publicar un arma reutilizable de un fallo activo no ayuda a nadie a defenderse y sí a
atacar. Lo que un administrador necesita es saber si está expuesto y confirmar que el parche cierra
el agujero. Eso es exactamente lo que hace este lab.

Quien quiera estudiar la mecánica interna encontrará el análisis técnico en las fuentes del artículo.

## Fuentes
Versiones parcheadas y vectores: [php.net](https://www.php.net/) · [CISA](https://www.cisa.gov/news-events/alerts/2026/10/21/critical-vulnerabilities-php-require-immediate-patching) · [Datadog Security Labs](https://securitylabs.datadoghq.com/articles/php2shell-critical-vulnerabilities-in-php/).
