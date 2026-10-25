# Lab · GitLab regex (CVE-2026-110264 y CVE-2026-97229)

**Nivel: detección.** Comprueba si una versión de GitLab está parcheada contra los dos fallos de
10 sobre 10 de octubre de 2026, y recuerda el detalle que pilló a mucha gente: quien actualizó el
12-oct quedó expuesto al fallo del 21. Acompaña al artículo: https://aldama.net/articulos/gitlab-regex/

## Qué necesitas
Docker con Compose. O solo `sh`, si usas el script a mano.

## Cómo se usa

```sh
docker compose up     # comprueba una lista de versiones de ejemplo
docker compose down
```

Verás el contraste: 19.4.2 y 19.3.4 salen **expuestas**, 18.11.13 y 19.5.1 **a salvo**, y una rama
vieja (17.9) sin parche propio.

### Comprobar tu propia instancia

`comprobar.sh` no necesita Docker. Pásale tu versión:

```sh
sh comprobar.sh 19.3.4
```

Para sacar la versión de tu servidor:

```sh
gitlab-rake gitlab:env:info | grep -m1 Version
```

Devuelve 0 si estás parcheado, 1 si estás expuesto (útil en un cron de inventario).

## Hasta aquí llega el lab, y por qué

Este laboratorio **solo detecta**. No reproduce el ataque, por dos razones que se suman:

- **No hay prueba de concepto pública** y GitLab ha retenido a propósito la ruta de explotación
  («under certain conditions», sin más detalle).
- Aunque la hubiera, es un desbordamiento de enteros que lleva a ejecución remota sin autenticar:
  montar el efecto sería escribir un arma para un fallo de severidad máxima en software que mucha
  gente expone a Internet. No vamos a ser los primeros en publicarla.

Lo útil y responsable aquí es saber si tu versión está al día y actualizar. Eso es lo que hace.

## Fuentes
[GitLab · parche 19.5.1 (21-oct)](https://docs.gitlab.com/releases/patches/patch-release-gitlab-19-5-1-released/) · [GitLab · parche 19.4.2 (12-oct)](https://docs.gitlab.com/releases/patches/patch-release-gitlab-19-4-2-released/) · [CERT-EU 2026-016](https://cert.europa.eu/publications/security-advisories/2026-016/).
