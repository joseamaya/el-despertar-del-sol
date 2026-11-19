# F4 · Prueba en Windows (y con mando, en F5)

> **F5:** esta guía queda sustituida por `F5-guia-prueba.md`. La build se descarga de la
> release `v0.1-slice`, y la prueba de Windows es la prueba piloto (tarea 6 de F5). Los
> resultados se apuntan abajo.

Tarea 11 del backlog de F4. La build de Windows se exporta en la CI desde F1, pero nunca se ha
ejecutado en Windows. El desarrollador no tiene Windows ni mando: un amigo prueba la build
de Windows siguiendo esta guía, y la prueba con mando físico pasa a F5.

## 1. Lo que hace el desarrollador

1. Después de hacer merge en `main`, abre la pestaña **Actions** del repositorio en GitHub.
2. Entra en la última ejecución de **CI** de `main` que esté en verde.
3. Abajo, en **Artifacts**, descarga `el-despertar-del-sol-Windows-<commit>`. Es un `.zip`
   de unos 110 MB.
4. Pásale el `.zip` a tu amigo (por enlace de Drive, WeTransfer o similar). El repositorio es
   privado: él no puede descargarlo de GitHub.
5. Pásale también la sección 2 de este archivo.

## 2. Guía para quien prueba (copiar y enviar)

> **Gracias por probar «Pachacútec: El Despertar del Sol».** Es un prototipo de unos 10
> minutos. Te pido unos 20 minutos en total.
>
> **Arrancar**
> 1. Descomprime el `.zip` y abre `el-despertar-del-sol.exe`.
> 2. Windows puede mostrar «Windows protegió su PC», porque el ejecutable no está firmado.
>    Pulsa **Más información** y luego **Ejecutar de todas formas**.
>
> **Controles (teclado y ratón)**
> - Moverse: **W A S D**. Cámara: **ratón**. Correr: **Mayús**.
> - Ataque ligero: **clic izquierdo**. Ataque pesado: **clic derecho**.
> - Bloquear: **F**; si lo pulsas justo antes del golpe, haces un parry. Esquivar: **Espacio**.
> - Fijar objetivo: **Q** o **clic de la rueda**.
> - Interactuar y pasar diálogos: **E**. Códice: **Tab**. Pausa y ajustes: **Esc**.
> - **F3** muestra los FPS abajo a la derecha.
>
> **Qué hacer**
> 1. Juega la partida entera hasta que salga «Fin». Sigue el camino cuesta arriba: arriba a la
>    izquierda verás siempre el objetivo.
> 2. Pulsa **F3** al empezar y fíjate en los FPS en tres momentos:
>    - mirando el valle al inicio;
>    - en la pelea de las casas;
>    - en la pelea del paso, la última.
> 3. En **Esc → Ajustes**, mueve el volumen y la calidad gráfica. Cierra el juego, vuelve a
>    abrirlo y comprueba que los ajustes se mantienen.
>
> **Qué contarme** (basta con responder a esta lista)
> 1. Windows (10 u 11), procesador, tarjeta gráfica y memoria. Lo ves en *Configuración →
>    Sistema → Información*.
> 2. ¿Arrancó a la primera? ¿Hubo algún mensaje de error?
> 3. FPS aproximados en los tres momentos.
> 4. ¿Se oye todo: viento, pasos, música al inicio y al final, golpes?
> 5. ¿Los textos con tildes y eñes se ven bien («Códice», «Pachacútec», «Señor»)?
> 6. ¿Se guardaron los ajustes al volver a abrir?
> 7. ¿Hubo algo raro: congelones, caídas a través del suelo, sitios donde te quedaste
>    atascado, sonidos que faltan?
> 8. Opcional: ¿qué te pareció?

## 3. Prueba con mando (pasa a F5)

El mapa de mando de la tabla del GDD §6.2 está cubierto por
`tests/player/test_input_map.gd`. Esa prueba encontró y corrigió que A y B no servían en los
menús. Lo que no puede comprobar una prueba automática y debe mirarse en F5 con un mando
físico:

- **Sticks:** que la zona muerta no deje a Cusi caminando solo y que la cámara no se sienta
  lenta ni demasiado rápida (sensibilidad del stick en `camera_tuning.tres` y en Ajustes).
- **Combate:**
  - bloqueo mantenido con LB y parry a tiempo;
  - ataque pesado con RT, como gatillo analógico;
  - esquiva con B.
- **Lock-on:** fijar con R3 y cambiar de objetivo con un golpe de stick derecho.
- **Slice:**
  - la ofrenda y los diálogos con A;
  - la elección de la familia con la cruceta o el stick;
  - el códice con Back.
- **Menús:**
  - pausa con Start;
  - recorrer el menú con la cruceta, confirmar con A y volver con B;
  - mover los deslizadores de Ajustes con izquierda y derecha.
- **Reintentar** con Start tras una derrota y en el «Fin».

## Resultados

_Pendiente: se rellena con la respuesta de quien pruebe la build de Windows._
