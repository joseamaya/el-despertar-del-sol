# 0015 · Escudo de Cusi: la huallcanca (F6)

**Fecha:** 2026-11-23 · **Estado:** aceptada (decidida por el desarrollador)

## Contexto
En F6 (tarea 4) el bloqueo se hizo visible con una pose de brazos cruzados y un destello en
la maza. Al revisarlo, el desarrollador señaló que bloquear con la mano no es creíble:
quien lo hiciera de verdad quedaría muy herido. Propuso añadir un escudo inca de la época.
El GDD solo daba a Cusi el champi (§6.3, §14.2).

**Qué dicen las fuentes:**
- **El Inca Garcilaso** (*Comentarios Reales*): la única arma defensiva de los incas era el
  escudo, «rodelas o paveses», que llamaban *huallcanca*. Cada región hacía unas armas
  distintas, y los escudos se fabricaban con los materiales que hubiera a mano.
- **Guamán Poma** dibuja escudos en las láminas de los capitanes incas (ff. 145–183 del
  manuscrito de Copenhague). No se pudieron consultar para confirmar la forma.
- **Una fuente secundaria, sin verificar,** que cita a Bernabé Cobo describe un escudo
  pequeño y redondo de tiras de palma tejidas con algodón.

## Decisión
1. **Cusi lleva una huallcanca** sujeta al antebrazo izquierdo. Al bloquear, la alza delante
   de la cabeza, a la izquierda de su silueta, para que se vea desde la cámara.
2. **Forma: rodela** redonda de unos 50 cm, elegida entre las dos que nombra Garcilaso tras
   ver capturas de las dos.
3. **Hecha con formas simples por código** (`Shield` y `ShieldLook`), como el champi: no
   hay recursos de terceros. Su aspecto y su sujeción viven en
   `resources/equipment/huallcanca_rodela.tres`.
4. **Los golpes bloqueados destellan en el escudo**, y no en la maza.
5. **Canon:** `HISTORICAL_REFERENCES.md` registra la huallcanca «según los cronistas»
   (Garcilaso). La forma redonda, el tamaño, los colores y la banda de cuadros son
   licencia del juego.

## Consecuencias
- **GDD §6.3 y §14.2** añaden la huallcanca.
- **Los guerreros chancas siguen sin escudo.** Dárselo es otra tarea y otra decisión; para
  los chancas no se encontró ninguna fuente específica.
- **El faldón de tela colgando** está preparado en `ShieldLook.fringe_length`, pero sigue
  desactivado hasta confirmarlo.

## Cuándo revisarla
- Al consultar las láminas de Guamán Poma, o al hablar con un especialista: si la forma o
  la decoración no encajan, se cambian en el `.tres`.
- Si la próxima prueba con jugadores dice que el escudo estorba la vista o no se lee.
