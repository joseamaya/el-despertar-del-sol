# F6 · Guía de la nueva prueba con jugadores (tarea 11)

Cómo repartir la build `0.2-slice` y qué decir a quien la prueba. Protocolo: el de
`DECISIONS/0013`, con sus enmiendas. Esta guía cambia solo lo necesario para esta prueba.

- **Descarga:** <https://github.com/joseamaya/el-despertar-del-sol/releases/tag/v0.2-slice>
  (pre-release pública; no hace falta cuenta de GitHub). **Todavía no está publicada:** se
  publica tras la medición de rendimiento (tarea 1); la prueba del desarrollador
  (tarea 10) ya está hecha.
- **Encuesta:** `<ENLACE DE LA ENCUESTA 0.2>`, pendiente; ver la sección 1.

## 1. Lo que hace el desarrollador

1. **Encuesta: duplica el formulario de F5** («Pachacútec · prueba del vertical slice»)
   y llama a la copia «prueba 0.2».
   - Así las respuestas de la 0.2 no se mezclan con las de la 0.1.
   - Las preguntas siguen iguales, para poder comparar las dos pruebas. Sobre todo las dos
     del criterio 8, que no se tocan.
   - Pega aquí el enlace nuevo y en el mensaje de la sección 2.
2. **Probadores (tarea 9):** envía el mensaje de forma individual a las personas
   apalabradas, para que nadie lea las opiniones de los demás antes de jugar.
3. **Quien ya jugó la 0.1 puede repetir.** Sus respuestas se marcan aparte en los
   resultados: ya conocía el juego.
4. **No les expliques el juego.** Lo que no entiendan sin ayuda es justo lo que queremos
   saber.
5. **Pásame las respuestas** cuando tengas varias; las leo en tu Chrome si me lo pides. Los
   comentarios que lleguen fuera del formulario (mensajes, notas de voz) también sirven:
   pásamelos.

## 2. Mensaje para quien prueba (copiar y enviar)

> **¡Hola! Gracias por probar «Pachacútec: El Despertar del Sol».** Es un juego de acción en
> el Cusco de hacia 1438, todavía en desarrollo. Lo que vas a jugar es un fragmento de unos
> 10 minutos. Te pido unos 20 minutos en total: jugar y responder una encuesta corta.
>
> **Descargar**
> 1. Entra en <https://github.com/joseamaya/el-despertar-del-sol/releases/tag/v0.2-slice>.
> 2. En «Assets», descarga el `.zip` de tu sistema:
>    - Windows: `el-despertar-del-sol-0.2-slice-windows.zip`.
>    - Linux: `el-despertar-del-sol-0.2-slice-linux.zip`.
> 3. Descomprímelo. Si tenías una versión anterior, bórrala para no confundirlas.
>
> **Arrancar**
> - **Windows:** abre `el-despertar-del-sol.exe`. Puede salir «Windows protegió su PC»
>   porque el juego no está firmado: pulsa **Más información** y luego **Ejecutar de todas
>   formas**.
> - **Linux:** abre una terminal en esa carpeta y ejecuta
>   `chmod +x el-despertar-del-sol.x86_64`; después, `./el-despertar-del-sol.x86_64`.
>
> **Controles con teclado y ratón**
> - Moverse: **W A S D** · Cámara: **ratón** · Correr: **Mayús**.
> - Ataque ligero: **clic izquierdo** · Ataque pesado: **clic derecho**.
> - Fijar objetivo: **Q** o **clic de la rueda**. Te recomiendo usarlo en las peleas.
> - Bloquear con el escudo: **mantén F**. Para hacer un parry, suelta F y vuelve a
>   pulsarla justo antes de que llegue el golpe.
> - Esquivar: **Espacio** (necesita resistencia: la barra amarilla).
> - Interactuar, pasar diálogos y saltar la presentación: **E** · Códice: **Tab** ·
>   Pausa: **Esc**.
>
> **Controles con mando** (tipo Xbox)
> - Moverse: **stick izquierdo** · Cámara: **stick derecho** · Correr: **pulsar el stick
>   izquierdo**.
> - Ataque ligero: **RB** · Ataque pesado: **RT** · Bloquear: **LB** · Esquivar: **B**.
> - Fijar objetivo: **pulsar el stick derecho** · Interactuar: **A** · Códice: **Back** ·
>   Pausa: **Start**.
>
> **Qué hacer**
> 1. Juega desde el principio hasta que salga **«Fin»**, como lo harías normalmente.
>    Arriba a la izquierda verás qué tienes que hacer, y un rombo dorado te indica adónde
>    ir.
> 2. Al empezar, Vicaquirao te ofrece un **entrenamiento**. No es una pelea de verdad: él
>    no puede caer. Puedes hacerlo o saltarlo.
> 3. Si caes en combate, pulsa **R** (o **Start**) para reintentar.
> 4. En la pantalla de «Fin» pulsa **C** (o **Y** en el mando): se copia un resumen de tu
>    partida.
> 5. Abre la encuesta y pega ese resumen donde lo pide (Ctrl+V): `<ENLACE DE LA ENCUESTA 0.2>`.
>    Son unos 5 minutos y no pide tu nombre ni tu correo.
>
> **Aunque no llegues al final o el juego falle, rellena igualmente la encuesta** y
> cuéntame hasta dónde llegaste: también me sirve mucho.

## 3. Qué cambió desde la 0.1 (para el desarrollador, no para enviar)

- **Apertura** de tres planos que muestra el momento, a los chancas y a Cusi (0.1.1).
- **Entrenamiento** opcional, que ahora enseña a fijar objetivo (F6, tarea 3).
- **Bloqueo:** la guardia encara al golpe, y Cusi bloquea con la huallcanca, con un destello
  al parar (F6, tareas 3 y 4).
- **Controles:** las pulsaciones a destiempo se guardan, la esquiva corta la anticipación,
  la barra avisa cuando falta resistencia y la resistencia se recupera antes (F6, tarea 7).
- **Orientación:** el rombo dorado hacia el objetivo (F6, tarea 8).

Lo que se quiere ver en esta prueba es si estos cambios llevan el combate y el escenario
al 4–5 del criterio 8 (GDD §14.4).
