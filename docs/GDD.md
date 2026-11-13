# GDD 1.2 — Pachacútec: El Despertar del Sol

13 de noviembre de 2026 · Miguel Amaya

## 0. Ficha del proyecto

El GDD 1.1 ajusta el proyecto a un desarrollador solo con agentes de IA y fija un canon histórico propio, elegido por su valor dramático.

| Campo | Descripción |
| --- | --- |
| Título de trabajo | Pachacútec: El Despertar del Sol |
| Título alternativo | Pachacútec: El Nacimiento de un Imperio |
| Género | Action-RPG / aventura histórica |
| Perspectiva | Tercera persona |
| Ambientación | Cusco y alrededores, c. 1438 (cronología tradicional) |
| Motor | Godot 4.7.2 estable, renderer Mobile (`docs/DECISIONS/0001`, `0004`) |
| Lenguaje | GDScript tipado |
| Herramientas 3D | Blender |
| Estilo visual | Low poly detallado con iluminación cinematográfica |
| Plataformas | PC (Windows y Linux), teclado/ratón y mando |
| Modo | Un jugador |
| Equipo | 1 desarrollador + agentes de IA |
| Estado | Preproducción |

### Historial de versiones

| Versión | Cambios principales |
| --- | --- |
| 1.2 | Decisiones de Fase 0: Godot 4.7.2, gdUnit4, renderer Mobile, equipo de referencia con GPU integrada, 20 h/semana, carpeta raíz `el-despertar-del-sol/`. |
| 1.1 | Canon histórico fijado (sección 3). Core loop. Sistema de Apoyo para la progresión política. Lock-on, mando y tabla de tuning. Guardado, accesibilidad y localización. Vertical slice con gancho cultural. Plan y alcance para desarrollador solo. Riesgos ampliados. Glosario. |
| 1.0 | Propuesta inicial de preproducción. |

**Sobre el título:** «El Despertar del Sol» encaja mejor con el arco del juego, que termina con la coronación y no con la expansión. «El Nacimiento de un Imperio» queda como alternativa comercial.

## 1. Visión del proyecto

### 1.1. High concept

Un Action-RPG histórico en tercera persona: el jugador es Cusi Yupanqui, el príncipe que se queda a defender el Cusco cuando su padre, el Inca Viracocha, y su heredero Urco lo abandonan ante el avance chanca.

Lo que empieza como una defensa desesperada se convierte en el ascenso de un líder. El juego termina cuando Cusi Yupanqui toma el nombre de Pachacútec, «el que transforma el mundo».

La experiencia combina:

- Combate cuerpo a cuerpo táctico y contundente.
- Escenarios semiabiertos.
- Ganarse el apoyo de ayllus y curacas, que decide cuántos combaten a tu lado.
- Misticismo andino ambiguo: visiones, huacas y los Pururaucas.

### 1.2. Visión creativa

Una aventura histórica con licencias asumidas: el juego toma la versión de cada episodio que mejor funciona como drama y la declara como su canon (sección 3).

No es fantasía genérica ni un superhéroe con poderes. Lo sobrenatural vive en lo que creen y ven los personajes, y el juego nunca lo confirma del todo.

### 1.3. Propuesta de valor

1. Un escenario casi inédito en los videojuegos: los Andes antes del imperio.
2. Un protagonista que crece en fuerza y en legitimidad, y las dos importan en la batalla.
3. Arquitectura, paisaje y cultura material andinos como identidad visual.
4. Un códice en el juego que separa lo documentado, lo narrado por los cronistas y lo inventado, y convierte el rigor en contenido.

**Público objetivo:** jugadores de action-RPG de escala media (tipo Ashen, Hellblade) y público latinoamericano interesado en su historia.

## 2. Referencias de diseño

Sirven para estudiar sistemas concretos, no para copiarlos. La identidad visual y cultural debe ser original.

| Juego | Qué estudiar |
| --- | --- |
| Sekiro | Postura enemiga, parry y ruptura de guardia. |
| Ashen | Escala de un equipo pequeño, atmósfera, estilización. |
| God of War (2018) | Cámara cercana, peso de los golpes. |
| Ghost of Tsushima | Cultura e historia en un juego de acción; modo de presentación cinematográfica. |
| Hellblade: Senua's Sacrifice | Ambigüedad entre visión y realidad; producción acotada. |
| Sable / The Pathless | Paisaje y dirección artística estilizada. |
| Never Alone | Cocreación con una comunidad indígena; contenido documental desbloqueable. |
| Assassin's Creed (Discovery Tour) | Capa educativa separada del juego. |
| Kingdom Come: Deliverance | Contexto histórico integrado en la experiencia. |

## 3. Canon histórico del juego

El juego sigue como columna vertebral el relato de Juan de Betanzos (*Suma y narración de los incas*, 1551), el más heroico para Cusi Yupanqui. Donde otra versión funciona mejor, se toma y se declara como licencia.

### 3.1. Filosofía

La jugabilidad y el drama mandan. Las licencias están permitidas sin límite, con una sola condición: quedan registradas aquí y en el códice del juego.

Cada entrada del códice lleva una de tres etiquetas:

- **Documentado:** arqueología, geografía, cultura material.
- **Según los cronistas:** relatos coloniales, con su autor.
- **Licencia del juego:** inventado o reordenado para la historia.

### 3.2. Versión elegida de cada episodio

| Episodio | Versión del juego | Fuente o licencia |
| --- | --- | --- |
| Fecha | c. 1438 | Cronología tradicional (Cabello Valboa); discutida por historiadores |
| Amenaza chanca | Los chancas, dirigidos por Uscovilca, Astoyhuaraca y Tomayhuaraca, avanzan desde Andahuaylas | Betanzos |
| Huida | Viracocha y Urco se retiran a Caquia Xaquixaguana; Cusi Yupanqui se queda con pocos leales | Betanzos |
| Aliados | Vicaquirao y Apo Mayta lo acompañan desde el principio | Betanzos / Sarmiento; personalidades inventadas |
| Visión de Susurpuquio | Ocurre la noche antes de la batalla, no después: es la llamada del héroe | Molina sitúa la visión antes de la guerra; el momento exacto es licencia |
| Curacas vecinos | Esperan a ver quién gana antes de unirse | Betanzos; base del sistema de Apoyo |
| Defensa del Cusco | Asalto chanca por Carmenca; combate en las calles y laderas | Betanzos |
| Chañan Cori Coca | Mujer que dirige la defensa del barrio de Choco-Cachona | Santa Cruz Pachacuti; papel ampliado como licencia |
| Pururaucas | Las piedras se alzan como guerreros en el momento crítico | Varios cronistas; presentación ambigua |
| Muerte de Uscovilca | Cae en la defensa del Cusco; su imagen sagrada es capturada | Betanzos; duelo final como licencia |
| Segunda batalla | Persecución y batalla final contra Astoyhuaraca y Tomayhuaraca, llamada Yahuarpampa («campo de sangre») | Betanzos la sitúa cerca de Xaquixaguana; el nombre viene de Garcilaso, que atribuye la victoria a Viracocha: licencia |
| Pururaucas como huacas | Tras la guerra, las piedras se guardan y veneran en el Cusco | Tradición cronística |
| Viracocha rechaza el botín | Cusi Yupanqui ofrece los despojos a su padre, que pide que sea Urco quien los pise; Cusi Yupanqui se niega | Betanzos |
| Urco | Muere en un enfrentamiento con su hermano | Varias versiones; la forma exacta es licencia |
| Coronación | Toma el nombre de Pachacútec e inicia la reconstrucción del Cusco | Betanzos; condensado en el tiempo |

### 3.3. Los Pururaucas

Es el momento más importante del juego y no tiene una explicación definitiva.

- Niebla, siluetas de guerreros, sonidos de combate sin fuente.
- El jugador los ve; algunos personajes no.
- Después, unos dicen que fueron dioses y otros que fueron los curacas que llegaron a tiempo. El juego no lo resuelve.
- No son una invocación repetible. Aparecen una vez, en la batalla del Cusco.
- Conexión con el sistema de Apoyo: cuántas figuras aparecen depende del apoyo conseguido (sección 8).

### 3.4. Cosmovisión andina

Se usan con contexto: Inti, Viracocha (el dios), huacas, ancestros (mallquis), apus y espacios ceremoniales. No se mezclan culturas ni períodos sin declararlo.

### 3.5. Lo que no se cambia

Aunque haya licencias, estas cosas se mantienen para no romper la identidad andina:

1. Cultura material: ropa, armas, herramientas y cerámica plausibles para la época.
2. Paisaje y geografía del Cusco.
3. Los chancas son un pueblo con identidad propia, no monstruos.
4. Nada de elementos de otras culturas (aztecas, mayas) ni de la conquista española.

### 3.6. Investigación mínima

Como desarrollador solo, la investigación se limita a lo que el juego necesita: una carpeta de referencias visuales por recurso y el archivo `HISTORICAL_REFERENCES.md` con las licencias. Antes de publicar, conviene una revisión de un historiador o arqueólogo peruano y de un quechuahablante.

## 4. Pilares y core loop

### 4.1. Pilares

1. **Combate táctico y contundente.** Físico, deliberado, sin spam de ataques.
2. **Exploración andina.** El paisaje es protagonista; explorar da información y Apoyo, no coleccionables vacíos.
3. **Legitimidad.** Cusi Yupanqui gana batallas con aliados, no solo con su maza.
4. **Identidad cultural.** Nada debe parecer un RPG medieval con otra piel.

### 4.2. Core loop

- **Minuto a minuto:** leer al enemigo, gestionar la resistencia, golpear en la ventana correcta.
- **Por misión (10–20 min):** llegar a una zona, resolver un problema de una comunidad, combatir, ganar Apoyo.
- **Por capítulo (1–2 h):** acumular Apoyo y mejoras para la batalla clave.

**Core loop por capítulo:**

1. Explorar el escenario (caminos, huacas, personajes).
2. Combatir encuentros (leer patrones, mejorar técnica).
3. Ayudar a ayllus y curacas (misiones que suman Apoyo).
4. Batalla clave del capítulo (aliados según el Apoyo ganado) → nuevo capítulo.

El Apoyo ganado en las misiones decide cuántos aliados combaten en la batalla clave, y en la batalla del Cusco, cuántos Pururaucas aparecen.

## 5. Personajes

Un reparto pequeño y fuerte: seis personajes con nombre bastan para los cuatro capítulos y caben en el presupuesto de un desarrollador solo.

### 5.1. Cusi Yupanqui (protagonista)

Joven príncipe, hijo menor de Viracocha, sin derecho a la sucesión. Empieza dudando de sí mismo y termina asumiendo el costo del poder, incluida la ruptura con su padre y la muerte de su hermano.

| Dimensión | De | A |
| --- | --- | --- |
| Física | Combatiente sin experiencia | Guerrero curtido |
| Política | Príncipe ignorado | Líder con legitimidad propia |
| Personal | Hijo que busca la aprobación del padre | Gobernante que rompe con el viejo orden |

**Diseño visual:** unku (túnica) de élite, llauto en la cabeza, orejeras de noble, champi al cinto. Silueta reconocible. El atuendo cambia por capítulo para marcar su ascenso.

### 5.2. Aliados

| Personaje | Rol en el juego | Base |
| --- | --- | --- |
| Vicaquirao | Capitán veterano y mentor de combate; enseña el tutorial | Cronistas; personalidad inventada |
| Apo Mayta | Estratega leal; conecta con los curacas | Cronistas; personalidad inventada |
| Chañan Cori Coca | Defensora de Choco-Cachona; aliada clave de la batalla del Cusco | Santa Cruz Pachacuti; papel ampliado |
| Quipucamayoc (nombre por definir) | Guardián de los quipus; da información y registra la historia (narrador del códice) | Inventado |

### 5.3. Antagonistas y familia

| Personaje | Rol en el juego |
| --- | --- |
| Uscovilca | Líder chanca; jefe final del Capítulo II |
| Astoyhuaraca y Tomayhuaraca | Capitanes chancas; jefes del Capítulo III |
| Viracocha Inca | El padre que huye; conflicto emocional, no enemigo |
| Urco | Heredero oficial; rival político del Capítulo IV |

**Los chancas:** pueblo orgulloso de la zona de Andahuaylas, que lleva a sus ancestros y la imagen de Uscovilca a la guerra. Visualmente distintos de los incas (tocados, colores, pintura facial inventada pero coherente). Deben tener al menos una escena que los humanice.

### 5.4. Animaciones del protagonista (mínimo)

Idle, caminar, correr, sprint, frenar, girar, esquivar, bloquear, parry, ataque ligero (cadena de 3), ataque pesado, recibir impacto, aturdimiento, ejecución, morir, interactuar.

Para el prototipo se usan animaciones de stock (p. ej. Mixamo) redirigidas al esqueleto propio con el BoneMap de Godot. Se reemplazan por animaciones propias solo cuando el combate esté validado.

## 6. Sistema de combate

El jugador gestiona salud y resistencia; los enemigos tienen además una barra de postura que, al romperse, abre una ejecución. Tres recursos para el jugador serían redundantes en el slice.

### 6.1. Filosofía

- Leer al enemigo antes de atacar.
- Cada acción cuesta resistencia; sin resistencia no hay esquiva ni bloqueo.
- El parry recompensa la precisión con mucho daño de postura.
- Pocos movimientos, bien sentidos, en vez de muchos combos.

### 6.2. Controles

| Acción | Teclado y ratón | Mando |
| --- | --- | --- |
| Movimiento | WASD | Stick izquierdo |
| Cámara | Ratón | Stick derecho |
| Fijar objetivo (lock-on) | Clic central / Q | R3 |
| Cambiar objetivo | Rueda / mover ratón con lock-on | Stick derecho con lock-on |
| Ataque ligero | Clic izquierdo | RB / R1 |
| Ataque pesado | Clic derecho | RT / R2 |
| Bloquear (parry al pulsar a tiempo) | F | LB / L1 |
| Esquivar | Espacio | B / Círculo |
| Sprint | Shift (mantener) | L3 / mantener esquiva |
| Interactuar | E | A / X |
| Apuntar con huaraca (posterior) | Mantener C | LT / L2 |

Todos los controles son reasignables. El mando se soporta desde el vertical slice.

### 6.3. Armas

**Champi (maza de cabeza estrellada).** Arma principal. Golpes contundentes, buen daño de postura, interrumpe ataques ligeros enemigos. En el juego puede llamarse «macana» en diálogos para el público general, pero el nombre del objeto es *champi*.

**Huaraca (honda).** Posterior al slice. Ataque a distancia que aturde a honderos y rompe escudos ligeros; precisión dependiente de la carga; piedras recogidas del suelo.

### 6.4. Atributos

| Atributo | Jugador | Enemigo |
| --- | --- | --- |
| Salud | Sí | Sí |
| Resistencia | Sí | No (se simula con pausas de IA) |
| Postura | No en el slice | Sí; al llenarse, aturdimiento y ejecución |

Daño y defensa son valores de cada arma y armadura, no atributos que el jugador reparte.

### 6.5. Tabla de tuning inicial

Valores de partida para el prototipo a 60 FPS; se ajustan con pruebas.

| Parámetro | Valor inicial |
| --- | --- |
| Salud del jugador | 100 |
| Resistencia del jugador | 100; recupera 30/s tras 0,6 s sin gastar |
| Coste ataque ligero / pesado | 12 / 25 |
| Coste esquiva / bloqueo por golpe | 20 / 15 |
| Invulnerabilidad de la esquiva | 0,25 s (15 frames) |
| Ventana de parry | 0,15 s (9 frames) |
| Anticipación ataque enemigo básico | 0,6–0,8 s |
| Golpes ligeros para matar guerrero básico | 5–6 |
| Golpes enemigos para matar al jugador | 6–8 |
| Parries para romper postura de guerrero básico | 2–3 |
| Hitstop al impactar | 0,05–0,08 s |

Los valores viven en Resources (`.tres`) para ajustarlos sin tocar código.

### 6.6. Diseño de encuentros

Un encuentro típico mezcla roles: uno presiona de frente, otro intenta flanquear y otro espera o ataca a distancia. Solo dos enemigos atacan a la vez (sistema de turnos de ataque), el resto amaga y rodea.

## 7. IA de enemigos

Máquina de estados por nodos (un nodo por estado) más un coordinador de encuentro que reparte los turnos de ataque. Es simple de depurar y suficiente para el juego completo.

### 7.1. Arquitectura

- **Estados:** Idle, Patrol, Alert, Chase, Strafe (rodear), Attack, Block, Stagger, Retreat, Dead.
- **Percepción:** cono de visión con raycast + radio de oído.
- **EncounterDirector:** concede como máximo 2 «fichas de ataque» a la vez; los demás rodean.
- **Datos:** cada tipo de enemigo es un Resource (salud, postura, ataques, tiempos). Nuevo enemigo = nuevo Resource + animaciones, no nuevo código.

### 7.2. Tipos de enemigo

| Enemigo | Rol | Rasgos | Cuándo |
| --- | --- | --- | --- |
| Guerrero chanca | Cuerpo a cuerpo básico | Ataques telegrafiados, bloqueo ocasional, retrocede al recibir golpes pesados | Vertical slice |
| Hondero chanca | Distancia | Busca altura, mantiene distancia, recarga visible, huye si te acercas | Capítulo II |
| Escudero chanca | Defensivo | Escudo frontal; obliga a flanquear o usar pesado | Capítulo II |
| Capitán chanca | Mini-jefe | Escudo, ataques pesados, dos fases | Tras validar el combate |
| Uscovilca / Astoyhuaraca / Tomayhuaraca | Jefes | Patrones únicos y escenario propio | Capítulos II y III |

## 8. Progresión y sistema de Apoyo

La progresión política se concreta en un solo número visible, el **Apoyo**, que se gana ayudando a ayllus y curacas y que cambia la batalla clave de cada capítulo.

### 8.1. Progresión física

Cusi Yupanqui mejora con entrenamientos de Vicaquirao y con ofrendas en huacas, no con puntos de experiencia por matar.

- Más resistencia y recuperación.
- Nuevas técnicas: contraataque tras parry, golpe pesado cargado, empuje.
- Mejor equipo: champi de bronce, escudo, armadura acolchada.

Unas 8–10 mejoras en todo el juego. Sin árbol de habilidades.

### 8.2. Apoyo (progresión política)

Cada curaca o ayllu tiene un estado: **Neutral → Simpatizante → Aliado**. Se avanza con misiones concretas:

- Rescatar a personas atrapadas o prisioneras.
- Recuperar provisiones o llamas robadas.
- Resolver una disputa (decisión con consecuencias).
- Demostrar valor en un combate visible.

**Efectos del Apoyo:**

| Apoyo | Efecto en la batalla clave |
| --- | --- |
| Bajo | Pocos aliados; la batalla es muy difícil pero posible |
| Medio | Escuadras aliadas defienden flancos |
| Alto | Refuerzos llegan en el momento crítico; más Pururaucas en la batalla del Cusco |

La historia principal no se bloquea nunca por falta de Apoyo; cambia la dificultad y algunas escenas.

### 8.3. Quipus

Cusi Yupanqui no lee quipus: los lleva al quipucamayoc, que los interpreta. Esto desbloquea información (rutas, posiciones chancas, qué curaca duda) y entradas del códice.

### 8.4. Huacas

Puntos de interés espiritual. Al hacer una ofrenda: una visión breve (recuerdo, presagio), una mejora física pequeña y una entrada del códice. Tras la guerra, las piedras de los Pururaucas se convierten en huacas que se pueden visitar en el Capítulo IV.

No hay teletransporte ni invocaciones.

## 9. Estructura narrativa

Cuatro capítulos de 1–2 horas cada uno (5–8 horas en total). La visión de Susurpuquio pasa al final del Capítulo I como llamada del héroe, y Yahuarpampa ocupa el Capítulo III.

### Capítulo I — El Cusco abandonado

**Lugar:** Cusco y laderas de Carmenca.

- Llegan noticias del avance chanca. Viracocha y Urco se retiran a Caquia Xaquixaguana.
- Cusi Yupanqui decide quedarse con Vicaquirao y Apo Mayta.
- Tutorial de movimiento y combate; primeras escaramuzas con exploradores chancas.
- Primeras misiones de Apoyo: convencer a ayllus del Cusco de quedarse.
- **Cierre:** la noche antes del asalto, en la fuente de Susurpuquio, Cusi Yupanqui tiene la visión: una figura solar le anuncia la victoria. Escena contemplativa y jugable.

### Capítulo II — La defensa del Cusco

**Lugar:** Carmenca, calles del Cusco, Choco-Cachona.

- Preparar defensas, reunir aliados, conocer a Chañan Cori Coca.
- Nuevos enemigos: honderos y escuderos.
- **Batalla del Cusco:** asalto chanca por varios frentes. En el peor momento, los Pururaucas: niebla, figuras de piedra, gritos.
- **Jefe:** Uscovilca. Su muerte y la captura de su imagen rompen al ejército chanca.

### Capítulo III — Yahuarpampa

**Lugar:** camino a Xaquixaguana y la llanura de la batalla.

- Los curacas que esperaban ahora quieren unirse. Decisiones: a quién aceptar y en qué condiciones.
- Persecución de los restos chancas; Cusi Yupanqui pasa por el refugio de su padre.
- **Batalla de Yahuarpampa:** la gran batalla abierta. Jefes: Astoyhuaraca y Tomayhuaraca.
- Escena humanizadora del lado chanca tras la victoria.

### Capítulo IV — El despertar del Sol

**Lugar:** Cusco, Caquia Xaquixaguana.

- Cusi Yupanqui lleva los despojos a Viracocha, que pide que Urco los pise. Cusi Yupanqui se niega.
- Conflicto con Urco y con las panacas que lo apoyan; misiones políticas y de investigación con el quipucamayoc.
- **Enfrentamiento final:** Urco.
- **Cierre:** coronación, el nombre Pachacútec, y los primeros trazos del nuevo Cusco. El epílogo insinúa la expansión, sin mostrarla como inmediata.

### Presentación narrativa (escala de un desarrollador solo)

- Diálogos en texto, sin voces completas en la primera versión.
- Escenas en el motor con cámara guiada, sin cinemáticas prerrenderizadas.
- Momentos clave con ilustraciones fijas y narración (el quipucamayoc), como alternativa barata a la cinemática.
- Voces solo para gritos de combate y frases cortas, en quechua.

## 10. Dirección artística

Low poly detallado con iluminación cinematográfica: es el estilo que un desarrollador solo puede producir con calidad y coherencia, y envejece bien.

### 10.1. Principios

- Geometría estilizada, siluetas claras, pocas texturas (colores planos + detalles pintados).
- La luz hace el trabajo: niebla, luz rasante de altura, cielos dramáticos.
- Un kit modular de arquitectura reutilizado en todo el juego.

### 10.2. Arquitectura: el Cusco antes del imperio

La cantería fina y los grandes muros (Coricancha, Sacsayhuamán) se asocian a la reconstrucción posterior de Pachacútec. El Cusco de 1438 se muestra más modesto: muros de piedra irregular (pirca), adobe, techos de ichu.

Esto da un arco visual: en el Capítulo IV aparecen los primeros trazos y obras del nuevo Cusco. El jugador ve nacer la ciudad imperial.

### 10.3. Paisaje

Cada escenario tiene una identidad geográfica: laderas de Carmenca, valle del Cusco, pampa de Xaquixaguana, fuente de Susurpuquio. Elementos: montañas (apus), terrazas, caminos, ichu, quebradas, niebla.

### 10.4. Paleta

Ocres, marrones, grises de piedra, verdes secos, azules atmosféricos. Los textiles aportan los acentos: rojo y amarillo para los incas, otra gama para los chancas, para que se distingan en combate de un vistazo.

### 10.5. Producción de arte como desarrollador solo

1. Prototipo con assets CC0 (Kenney, Quaternius) y cápsulas.
2. Kit modular propio en Blender: 20–30 piezas de arquitectura.
3. Un modelo base humano con variaciones de ropa, tocado y accesorios por facción (no solo cambios de color).
4. Arte generado por IA solo como concepto o referencia, nunca como recurso final sin revisar licencia y coherencia.

## 11. Sonido y música

### 11.1. Música

Banda sonora original con quenas, antaras (zampoñas de cerámica), pututus (trompetas de caracola), tambores (wancar) y voces. No se asume que la música andina actual representa la del siglo XV. Opción realista: encargar música a un músico peruano o licenciar grabaciones de instrumentos y componer con ellas.

### 11.2. Efectos

Impactos de maza sobre escudo, cuerpo y piedra; pasos sobre piedra, tierra e ichu; viento de altura; pututus como señal de ataque chanca; multitudes. Bibliotecas CC0 o de pago para el prototipo.

### 11.3. Lo espiritual

Las visiones y los Pururaucas tienen una firma sonora propia: sonido amortiguado, ecos, voces sin fuente. Nunca suenan como el combate normal.

## 12. Interfaz y experiencia de usuario

Interfaz mínima con motivos textiles (tocapus) en vez de marcos de fantasía medieval.

### 12.1. HUD

Salud, resistencia, postura del enemigo fijado, indicador de interacción, objetivo actual. El HUD se oculta fuera de combate.

### 12.2. Guardado y muerte

- Guardado automático en puntos de control (huacas y campamentos aliados) y al terminar cada misión.
- Al morir: reaparición en el último punto de control, enemigos restablecidos, sin pérdida de progreso.
- Un archivo de guardado por perfil en JSON versionado (para migrar entre versiones del juego).

### 12.3. Dificultad

Tres niveles: Relato (ventanas amplias, menos daño), Guerrero (el diseño base), Sinchi (enemigos más agresivos). Ajustan valores de la tabla de tuning, no el comportamiento.

### 12.4. Accesibilidad

- Controles reasignables y opción de mantener o alternar (bloqueo, sprint, apuntar).
- Subtítulos con tamaño y fondo ajustables.
- Sensibilidad de cámara, invertir ejes, reducir sacudidas de cámara.
- Indicadores de ataque visibles y audibles.

### 12.5. Localización

Español (original) e inglés desde el lanzamiento. Quechua para gritos, nombres, frases rituales y canciones; subtítulos en quechua como objetivo a largo plazo con colaboración de hablantes. Todo texto pasa por el sistema de traducción de Godot (CSV/PO) desde el primer día.

### 12.6. Códice

Menú de entradas desbloqueables (personajes, lugares, objetos, creencias). Cada entrada lleva su etiqueta: Documentado, Según los cronistas o Licencia del juego.

## 13. Arquitectura técnica

Godot 4 con composición por nodos-componente, comunicación por señales y datos en Resources. Es lo que permite que los agentes de IA trabajen en un sistema sin romper otro.

### 13.1. Tecnología

| Componente | Decisión |
| --- | --- |
| Motor | Godot 4.7.2.stable (fijado en Fase 0); no se actualiza de versión menor a mitad de una fase |
| Renderer | Mobile, por el equipo de referencia con GPU integrada (`docs/DECISIONS/0004`) |
| Lenguaje | GDScript con tipado estático; advertencias de tipado como errores |
| Física | GodotPhysics3D, evaluado frente a Jolt en Fase 1 (`docs/DECISIONS/0006`) |
| Navegación | NavigationServer3D + NavigationRegion3D |
| Animación | AnimationTree con máquina de estados; animación en el sitio (sin root motion) en el prototipo |
| Hitboxes | Area3D en el arma, activadas por pistas de método en la animación; hurtboxes en el cuerpo |
| Pruebas | gdUnit4 (`docs/DECISIONS/0002`) + escenas de prueba manuales |
| Integración continua | GitHub Actions: pruebas + exportación Windows/Linux en cada push a main |
| Versionado | Git + Git LFS para .blend, texturas y audio |
| Documentación | Markdown en `docs/` |

### 13.2. Principios

1. Un componente, una responsabilidad.
2. Comunicación por señales; los componentes no buscan a otros por ruta.
3. Datos de juego en Resources (`.tres`), no en código.
4. Autoloads solo para servicios globales: guardado, eventos, ajustes.
5. Sin dependencias circulares; sin controladores monolíticos.
6. El proyecto se ejecuta después de cada commit en main.

### 13.3. Sistemas

| Sistema | Responsabilidad |
| --- | --- |
| PlayerController | Movimiento, orientación, locomoción |
| CameraController | Seguimiento, colisión, lock-on |
| HealthComponent | Salud y daño |
| StaminaComponent | Resistencia y recuperación |
| PostureComponent | Postura enemiga y ruptura |
| Hitbox / Hurtbox | Detección de impactos |
| CombatComponent | Ataques, bloqueo, parry, esquiva |
| EnemyAI + EncounterDirector | Estados, percepción, turnos de ataque |
| InteractionSystem | Personas, objetos, huacas |
| SupportSystem | Apoyo por curaca y ayllu |
| NarrativeSystem | Diálogos, eventos, escenas |
| SaveSystem | Guardado y carga versionados |
| Codex | Entradas desbloqueables |

### 13.4. Estructura del repositorio

```text
el-despertar-del-sol/
├── project.godot
├── AGENTS.md
├── docs/          (GDD, referencias históricas, decisiones)
├── assets/        (modelos, animaciones, audio, texturas, ui)
├── scenes/        (main, player, enemies, levels, ui)
├── scripts/       (core, player, combat, enemies, systems)
├── resources/     (weapons, enemies, tuning)
└── tests/
```

Se crean carpetas solo cuando hacen falta.

## 14. Vertical slice 0.1

Una experiencia de 8–12 minutos en las laderas de Carmenca que prueba dos cosas: que el combate es satisfactorio y que la identidad andina se siente desde el primer minuto.

### 14.1. Secuencia

1. **Apertura (1 min):** amanecer en Carmenca, el Cusco abajo, columnas de humo en el horizonte. Vicaquirao explica que el Inca se ha ido.
2. **Exploración (2–3 min):** caminar por terrazas hasta una huaca. Ofrenda y visión breve: siluetas de piedra en la niebla (anticipo de los Pururaucas).
3. **Decisión de Apoyo (1 min):** una familia de un ayllu pide ayuda para recuperar sus llamas; aceptar o seguir adelante. Cambia quién te acompaña en el combate final.
4. **Combate (3–5 min):** dos escaramuzas con guerreros chancas; luego defender un paso contra tres.
5. **Cierre (1 min):** pututus chancas en el valle; Cusi Yupanqui mira al Cusco. Fin.

### 14.2. Incluido

| Elemento | Alcance |
| --- | --- |
| Escenario | Un sector de Carmenca con terrazas, camino y huaca |
| Personajes | Cusi Yupanqui, Vicaquirao, un comunero |
| Arma | Champi |
| Enemigos | Guerrero chanca (hasta 3 a la vez) |
| Mecánicas | Movimiento, cámara, lock-on, ataque ligero y pesado, bloqueo, parry, esquiva, resistencia, postura enemiga |
| Sistemas | Una huaca, una decisión de Apoyo, una entrada del códice |
| Interfaz | Salud, resistencia, postura enemiga, menú de pausa, ajustes básicos |
| Controles | Teclado/ratón y mando |
| Audio | Ambiente, pasos, combate, una pieza musical |
| Guardado | Checkpoints dentro del slice |

### 14.3. Excluido

Mundo abierto, inventario, árbol de habilidades, honderos, jefes, Pururaucas completos, sistema de Apoyo completo, voces, cinemáticas, huaraca, dificultad seleccionable.

### 14.4. Criterios de aceptación

1. Se recorre de principio a fin sin errores críticos en una compilación exportada (Windows y Linux).
2. 60 FPS estables a 1080p en el equipo de referencia.
3. Los golpes están sincronizados con la animación y los impactos se detectan siempre.
4. Bloqueo, parry, esquiva y resistencia funcionan según la tabla de tuning.
5. Los enemigos detectan, rodean, atacan por turnos y reaccionan al daño.
6. Hay condición clara de victoria y derrota, con reaparición en checkpoint.
7. La decisión de Apoyo produce una diferencia visible.
8. **Prueba con jugadores (5–10 personas):** al menos 7 de cada 10 dicen que el combate se siente bien y que el escenario no parece un juego medieval genérico.

## 15. Plan de desarrollo

Con unas 20 horas por semana, el vertical slice está listo en unas 23 semanas (5–6 meses). Es una estimación de partida: se recalcula al cerrar la Fase 2.

| Fase | Duración | Criterio de salida |
| --- | --- | --- |
| F0 · Preproducción | 2 sem | GDD, AGENTS.md, repo, CI y Godot fijados |
| F1 · Movimiento y cámara | 3 sem | Moverse y fijar objetivo se siente bien |
| F2 · Combate | 6 sem | Pelear contra 3 guerreros es divertido |
| F3 · Escenario de Carmenca | 5 sem | Recorrible a 60 FPS y reconocible andino |
| F4 · Integración del slice | 5 sem | 8–12 min completos en build exportada |
| F5 · Prueba externa | 2 sem | Decidir: continuar, ajustar o recortar |

Si el combate no convence al cerrar la Fase 2, se itera ahí antes de producir escenario; nunca se avanza a la Fase 3 con un combate dudoso.

**Reglas para un desarrollador solo:**

- Una fase activa a la vez; nada de la fase siguiente se adelanta.
- Cada fase cierra con un build exportado y una nota de lo aprendido.
- Si una fase se pasa un 50 % de su estimación, se recorta alcance, no se añade tiempo.
- Publicar avances (vídeos cortos, devlog) desde la Fase 2 para medir interés y mantener la motivación.

**Dedicación fijada en Fase 0:** unas 20 horas por semana; las estimaciones de la tabla se mantienen.

## 16. Producción con agentes de IA

Tú diriges y pruebas; los agentes escriben código, pruebas, herramientas y documentación. Un agente no puede juzgar si un golpe se siente bien: eso lo decides tú con el mando en la mano.

### 16.1. En qué rinden los agentes

| Rinden bien | Rinden poco | No delegar |
| --- | --- | --- |
| Sistemas en GDScript (componentes, IA, guardado) | Escenas .tscn complejas editadas a mano | Sensación del combate (game feel) |
| Pruebas unitarias y escenas de prueba | Ajuste fino de animaciones | Dirección artística |
| Herramientas de editor y scripts de importación | Modelado y rigging 3D | Decisiones de canon histórico |
| Refactorización y revisión de código | Shaders visuales sin verlos | Alcance y prioridades |
| Documentación y resumen de decisiones |  |  |

### 16.2. Flujo de trabajo por tarea

1. Escribes una tarea pequeña con criterio de aceptación (una tarde de trabajo como máximo).
2. El agente lee `AGENTS.md`, el GDD y el código afectado.
3. Propone un plan; tú lo apruebas.
4. Implementa en una rama, con pruebas.
5. CI pasa; tú pruebas en el juego y haces merge.
6. Si cambia una decisión, se registra en `docs/DECISIONS/`.

### 16.3. Roles por sesión

Un solo agente cambia de rol por sesión: arquitectura, gameplay, IA enemiga, herramientas de arte, QA. No hace falta un sistema multiagente. Una sesión de QA con un agente distinto (o un modelo distinto) para revisar el código del otro reduce errores.

### 16.4. Reglas de AGENTS.md

1. Leer el GDD y `AGENTS.md` antes de trabajar.
2. Revisar el código existente antes de proponer cambios.
3. Solo el alcance de la fase actual.
4. No inventar datos históricos; consultar `HISTORICAL_REFERENCES.md`.
5. No reescribir sistemas que funcionan sin justificarlo.
6. GDScript tipado; sin controladores monolíticos; sin dependencias nuevas sin aprobación.
7. Valores de juego en Resources, no en código.
8. Entregar pruebas y decir explícitamente qué no se pudo verificar.
9. Mantener el proyecto ejecutable después de cada cambio.

### 16.5. Herramientas para los agentes: MCPs y skills

Pocas herramientas, bien elegidas: cada MCP activo consume contexto del agente, así que se mantienen 3–4 activos y el resto se activa solo en la fase que lo necesita.

**MCPs recomendados**

| MCP | Para qué | Fase | Prioridad |
| --- | --- | --- | --- |
| Godot MCP (p. ej. Coding-Solo/godot-mcp) | Que el agente lance el editor, ejecute el proyecto y lea errores y salida de depuración | Desde F1 | Alta |
| GitHub MCP (oficial) o la CLI `gh` | Issues como tareas, ramas, pull requests, estado de CI | Desde F0 | Alta |
| Context7 | Documentación actualizada de Godot 4 para evitar API obsoleta de Godot 3 | Desde F0 | Alta |
| Blender MCP (ahujasid/blender-mcp) | Automatizar tareas repetitivas en Blender: kit modular, nombrado, exportación a glTF | F3–F4 | Media |
| ElevenLabs MCP (u otro de audio) | Placeholders de efectos y voces para el prototipo | F4, opcional | Baja |

**Herramientas de línea de comandos (sin MCP)**

| Herramienta | Para qué |
| --- | --- |
| Godot en modo headless (`--headless`) | Correr pruebas y exportar desde el agente y desde CI |
| GUT o gdUnit4 | Pruebas unitarias ejecutables por el agente |
| gdtoolkit (`gdlint`, `gdformat`) | Estilo y formato uniforme del GDScript generado |
| Servidor de lenguaje de GDScript (editor de Godot) | Errores de tipado en tiempo real si el entorno del agente lo soporta |
| Git LFS | Archivos .blend, texturas y audio |

**Skills propios a crear** (con `skill-creator`, guardados en el repositorio)

| Skill | Qué hace |
| --- | --- |
| `godot-component` | Crea un componente con GDScript tipado, señales, Resource de configuración y prueba, siguiendo AGENTS.md |
| `godot-scene-audit` | Revisa una escena: dependencias, rutas frágiles, nodos sin uso, scripts monolíticos |
| `combat-tuning` | Lee y ajusta los Resources de tuning y registra cada cambio con su motivo |
| `enemy-from-resource` | Crea un enemigo nuevo a partir de un Resource y un juego de animaciones |
| `canon-check` | Revisa textos, diálogos y entradas del códice contra `HISTORICAL_REFERENCES.md` y marca la etiqueta correcta |
| `phase-gate` | Al cerrar una fase: corre pruebas, exporta, compara con el criterio de salida y redacta el informe |
| `devlog` | Convierte los commits y notas de la semana en una entrada de devlog |

**Precauciones**

- Los MCPs de Godot y Blender son proyectos de la comunidad: revisar el código y el estado del repositorio antes de instalar, y fijar la versión.
- Blender MCP puede conectarse a servicios de modelos generados por IA: no usar esos modelos como recurso final sin verificar licencia.
- Ningún MCP recibe credenciales con más permisos de los necesarios (token de GitHub limitado al repositorio).

## 17. Rendimiento

60 FPS con salida a 1080p en el equipo de referencia (3D renderizado al 75–83 %, `docs/DECISIONS/0005`), medido en hardware real desde la Fase 1.

- Equipo de referencia (Fase 0): Intel Core i7-13700, gráfica integrada Intel UHD 770, 32 GB de RAM, Linux. Renderer Mobile y sin efectos exclusivos de Forward+ (`docs/DECISIONS/0004`).
- Geometría optimizada, sombras dinámicas solo del sol y de unos pocos focos, colisiones simplificadas.
- LOD y oclusión solo cuando una escena representativa lo justifique.
- Perfilado con el Profiler de Godot al cerrar cada fase.

## 18. Riesgos

| Riesgo | Impacto | Mitigación |
| --- | --- | --- |
| Alcance excesivo para una persona | Alto | Vertical slice primero; cada fase con criterio de salida; recortar antes que alargar |
| Agotamiento del desarrollador | Alto | Horario sostenible; hitos pequeños y visibles; descansos tras cada fase |
| Combate poco satisfactorio | Alto | Prototipo con cápsulas antes de producir arte; pruebas con jugadores |
| Animación como cuello de botella | Alto | Stock + retargeting en prototipo; menos animaciones, mejor ejecutadas |
| Código de agentes difícil de mantener | Medio | AGENTS.md, tareas pequeñas, revisión, CI con pruebas |
| Representación cultural errónea | Medio | Revisión de historiador y quechuahablante antes de publicar; códice que declara las licencias |
| Recursos inconsistentes | Medio | Kit modular y guía visual de una página |
| Límites de Godot en 3D | Medio | Probar Jolt, AnimationTree y navegación en Fase 1; escenas acotadas |
| Licencias de recursos de terceros o de IA | Medio | Solo CC0 o licencias claras; registro de origen de cada recurso |
| Permisos para usar sitios arqueológicos | Bajo | Consultar al Ministerio de Cultura antes de fotogrametría o uso comercial de imágenes |

## 19. Principios no negociables

1. La jugabilidad manda sobre la cantidad de contenido.
2. Las licencias históricas están permitidas, siempre declaradas.
3. Cultura material, paisaje e identidad andina se respetan aunque la historia se adapte.
4. Nada de mundo abierto en el MVP.
5. Lo sobrenatural es ambiguo y escaso.
6. Cada fase termina con una versión ejecutable.
7. No se amplía el alcance sin quitar otra cosa.
8. No se acepta código monolítico, venga de quien venga.

## 20. Visión a largo plazo y éxito

Si el slice se valida, el siguiente paso no es el juego completo sino el Capítulo I completo (1–2 horas), publicable como demo en Steam o itch.io para medir interés.

Ampliaciones posteriores, en este orden: Capítulo II con los Pururaucas, honderos y jefes, sistema de Apoyo completo, Capítulos III y IV, voces en quechua.

**La primera etapa es un éxito si:**

- El slice es estable y el combate convence a quienes lo prueban.
- La identidad andina se reconoce sin explicaciones.
- La arquitectura permite añadir enemigos y misiones sin reescribir sistemas.
- La gente quiere saber qué pasa después.

## 21. Glosario y norma ortográfica

Se usa la grafía hispanizada tradicional, que es la más reconocible para el público (decisión revisable).

| Término | Significado |
| --- | --- |
| Ayllu | Comunidad de parentesco, base de la sociedad andina |
| Apu | Montaña sagrada y espíritu protector |
| Champi | Maza de cabeza de bronce o piedra, a menudo estrellada |
| Curaca | Jefe local de un ayllu o grupo de ayllus |
| Huaca | Lugar u objeto sagrado |
| Huaraca | Honda |
| Ichu | Paja de altura usada en techos |
| Llauto | Cinta trenzada en la cabeza, distintivo inca |
| Mallqui | Cuerpo momificado de un ancestro |
| Panaca | Linaje de un Inca fallecido |
| Pirca | Muro de piedra sin labrar |
| Pururauca | Piedra que se convierte en guerrero |
| Pututu | Trompeta de caracola |
| Quipu / quipucamayoc | Registro de cuerdas anudadas / su especialista |
| Tahuantinsuyo | El estado inca, «las cuatro regiones unidas» |
| Unku | Túnica andina |
