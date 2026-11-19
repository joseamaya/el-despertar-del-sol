# F5 · Encuesta de la prueba externa (tarea 4)

**Estado:** aprobada por el desarrollador el 2026-11-19 · Protocolo:
`DECISIONS/0013`

Preguntas para copiar en Google Forms. Las dos marcadas con ★ son las del criterio 8 del
GDD §14.4: su redacción y su escala no se cambian, porque son las que deciden F5.

## Cómo montar el formulario

1. **Título:** «Pachacútec: El Despertar del Sol · prueba del vertical slice».
2. **Configuración → Respuestas:**
   - **Recopilar direcciones de correo: No recopilar.**
   - **Limitar a 1 respuesta: desactivado**, porque obliga a iniciar sesión con Google.
3. **Secciones:** una por cada bloque de abajo, en el mismo orden. Los tipos de pregunta van
   entre corchetes.
4. **Obligatorias:** el consentimiento, la 1, la 7 y la 12. Las demás son opcionales, para
   que nadie abandone por una pregunta difícil.
5. **Prueba antes de enviar:** con la vista previa del formulario, y que tu amigo la responda
   en la prueba piloto (tarea 6).

---

## Descripción del formulario

> Gracias por probar *Pachacútec: El Despertar del Sol*. Es un juego de acción en tercera
> persona ambientado en el Cusco de c. 1438, todavía en desarrollo: lo que has jugado es un
> fragmento de unos 10 minutos con arte provisional.
>
> Responder te lleva unos 5 minutos. Contesta con sinceridad: una crítica concreta ayuda
> mucho más que un «está bien». No pedimos tu nombre ni tu correo.

## Consentimiento

**¿Aceptas que usemos tus respuestas, sin tu nombre, para decidir el futuro del juego, y
que podamos citarlas de forma anónima en su documentación?** [Casilla, obligatoria]
- Sí, acepto

---

## 1 · Tu partida

**1. ¿Llegaste hasta la pantalla de «Fin»?** [Opción única, obligatoria]
- Sí
- No: lo dejé en el entrenamiento con Vicaquirao
- No: lo dejé en las terrazas o la huaca
- No: lo dejé en el ayllu o las casas
- No: lo dejé en el paso (el combate final)
- No: el juego falló o no arrancó

**2. Pega aquí el resumen de partida.** [Párrafo]
*En la pantalla de «Fin», pulsa C (o Y en el mando) y pégalo aquí con Ctrl+V. Si no llegaste
al final, déjalo en blanco.*

**3. ¿En qué sistema jugaste?** [Opción única]
- Windows
- Linux
- Otro

**4. ¿Con qué jugaste?** [Opción única]
- Teclado y ratón
- Mando
- Un poco de los dos

**5. ¿El juego se movió con fluidez?** [Escala 1–5]
1 = muchos tirones · 5 = totalmente fluido

**6. ¿Algún error, cuelgue o algo que se viera raro?** [Párrafo]
*Si puedes, di en qué momento pasó.*

---

## 2 · El combate

**★ 7. ¿El combate se siente bien?** [Escala 1–5, obligatoria]
1 = nada · 5 = mucho

**8. ¿Qué te gustó más del combate y qué menos?** [Párrafo]
*Golpes, bloqueo, parry, esquiva, la resistencia, los enemigos…*

**9. ¿Cómo de difícil te pareció?** [Escala 1–5]
1 = demasiado fácil · 3 = justo · 5 = demasiado difícil

**10. ¿Hubo algún momento en que te frustraste? ¿Cuál?** [Párrafo]

**11. ¿El entrenamiento con Vicaquirao te enseñó lo que necesitabas para pelear?**
[Escala 1–5]
1 = nada · 5 = todo

---

## 3 · El escenario y la historia

**★ 12. ¿El escenario parece un juego medieval genérico?** [Escala 1–5, obligatoria]
1 = sí, podría ser cualquier juego medieval · 5 = no, se siente andino y propio

**13. ¿Qué te hizo sentir (o no) que estabas en los Andes de hace casi 600 años?** [Párrafo]

**14. ¿Entendiste lo que pasaba en la historia y por qué peleabas?** [Escala 1–5]
1 = nada · 5 = todo

**15. ¿Hubo algún texto o momento que no se entendiera?** [Párrafo]

---

## 4 · En general

**16. ¿Jugarías un capítulo completo de este juego?** [Opción única]
- Sí
- Quizás
- No

**17. ¿Qué es lo que más te gustó?** [Párrafo]

**18. Si pudieras cambiar una sola cosa, ¿cuál sería?** [Párrafo]

---

## Cómo se leen las respuestas (tarea 8)

- **Criterio 8 (`DECISIONS/0013`):** cuenta como «sí» un 4 o un 5 en la ★7 y en la ★12,
  solo entre quienes llegaron al «Fin» (pregunta 1).
- **El resumen de partida (2)** da el tiempo real y las derrotas por zona. Con ellos se ve si
  la segunda oleada del paso frustra, junto con las preguntas 9 y 10.
- **La 3, la 4 y la 6** detectan fallos por plataforma o mando. Cubren la deuda de Windows y
  del mando físico.
- **Al repo público** solo pasan los resultados anonimizados (P1, P2…), en
  `docs/fases/F5-resultados.md`. La hoja de Google se queda en tu cuenta.
