# F5 · Difusión de la prueba externa

**Estado:** aprobado por el desarrollador el 2026-11-19 · Protocolo: `DECISIONS/0013` (enmienda del 2026-11-19)

Material para conseguir de 5 a 7 personas que prueben la build `0.1-slice`: un tráiler
corto, un flyer vertical y un mensaje para grupos y redes. **Todo usa imágenes reales de la
build**, nada de lo que el juego no tiene todavía. Así, quien llega por el tráiler encuentra
lo mismo al jugar y la pregunta ★12 de la encuesta no se contamina.

Los archivos (`.mp4` y `.png`) no van al repositorio porque pesan. Se generan en
`build/trailer/` y los publica el desarrollador.

## 1. Mensaje para grupos y redes (acompaña al vídeo o al flyer)

> 🎮 **¿Me ayudas a probar un juego?**
>
> Estoy haciendo **«Pachacútec: El Despertar del Sol»**, un juego de acción sobre el Cusco
> de 1438, cuando los chancas llegaron a sus puertas y el inca Viracocha lo dio por perdido.
>
> Ya hay una **demo de unos 10 minutos** y busco gente que la juegue y me diga con
> sinceridad qué tal está: tu opinión decide cómo sigue el juego.
>
> - Gratis, sin registrarte.
> - Windows o Linux, con teclado o mando.
> - Unos 20 minutos en total: jugar y responder una encuesta corta y anónima.
>
> Si te animas, escríbeme y te paso el enlace con las instrucciones. 🙌

Quien responde recibe, de forma individual, el mensaje de la sección 2 de
`F5-guia-prueba.md`. Así todos juegan con las mismas instrucciones.

## 2. Guion del tráiler (65 s, 1080p)

Imágenes de una partida completa grabada con el piloto automático
(`tools/scene_benchmark.gd --playthrough` con `--write-movie`). Formato panorámico con
bandas negras, que ocultan el HUD y los cuadros de diálogo. Música: *Peru Style 3*
(Tozan, CC0) sobre el sonido del juego. Rótulos sobre negro.

| # | Imagen | Rótulo |
| --- | --- | --- |
| 1 | El valle al amanecer | «Cusco, 1438» |
| 2 | Negro | «El inca ha abandonado la ciudad.» / «Dicen que el Cusco ya está perdido.» |
| 3 | Terrazas, primera pelea y la huaca | — |
| 4 | Negro | «Los chancas avanzan sobre el Cusco.» |
| 5 | Las casas del ayllu y pelea entre ellas | — |
| 6 | Negro | «Cusi Yupanqui no huye.» |
| 7 | El paso: «¡Los hombres del ayllu llegan!», «¡Llegan más chancas desde lo alto!» y peleas | — |
| 8 | Cusi mira el valle al amanecer | «PACHACÚTEC» / «El Despertar del Sol» |
| 9 | Cierre | «Demo gratuita · 10 minutos · Windows y Linux» / «Pruébala y ayúdanos a construirlo» |
| 10 | Créditos al pie | «Música: Tozan (CC0) · Pututu: David Bolton (CC BY 2.5) · Juego en desarrollo» |

El pututu suena en el sonido del juego del plano 7 y es CC BY: el crédito del rótulo 10 es
obligatorio.

**Cómo regenerarlo:** los dos pasos de la cabecera de `tools/trailer/make_trailer.sh`. La
grabación tarda unos 5 minutos y abre una ventana; el montaje, menos de un minuto. Se
obtienen `build/trailer/trailer.mp4` (65 s, 1080p, unos 47 MB) y `build/trailer/flyer.png`.
Si el slice cambia, hay que revisar los tiempos de los planos.

## 3. Flyer (1080 × 1350, para WhatsApp e Instagram)

Una captura real de una pelea en el paso (sin HUD), el título, «Buscamos probadores» y las
tres condiciones del mensaje (gratis, 20 minutos, Windows o Linux), con «escríbeme» como
llamada a la acción. Plantilla: `tools/trailer/flyer.html`.
