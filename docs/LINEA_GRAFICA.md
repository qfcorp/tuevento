# Identidad gráfica de TuEvento (kit común Tukán, modelo ERP) — 10 nov 2026

Todos los programas Tukán se ven y se usan igual: barra de arriba del color del programa, menú izquierdo azul noche con
todas las opciones (emoji + nombre) en grupos, dashboard con primeros pasos y cifras, tarjetas de sección, tablas con
cabecera azul noche. **Cada programa solo cambia su color.**

## El kit (no se edita aquí)
- `public/assets/tukan-ui.css` y `public/assets/tukan-ui.js`: **idénticos byte a byte en todos los programas**
  (`md5sum` debe dar lo mismo que en los demás). Si falta algo, va en el CSS propio del programa, nunca en el kit.
- Se cargan en `app/vistas/_diseno.php`, **después** de `app.css` y los `mod_*.css`, y solo actúan con `<body class="tk">`.
  El portal público del cliente (`_publico.php`), los PDF y los correos no llevan el kit: no cambian.

## Color de TuEvento (la única línea propia, en `app/vistas/_diseno.php`)
```html
<style>:root{ --tk-color:#D9822B; --tk-color-claro:#EBA35C; --tk-color-texto:#14213D; }</style>
```
**Decisión de Dimitry, 10 nov 2026: el color de la web.** Cada programa usa por dentro el mismo color que tiene en
tukansoftware.com (y en el Panel). TuEvento es **naranja `#D9822B`** (antes vino `#6B2D3C`). También `<meta name="theme-color">`
y `theme_color` de `public/manifest.json` (los íconos y la app de Google Play no cambian).
- El naranja es claro: el **texto sobre la barra, el botón principal y la opción activa del menú es azul noche `#14213D`**
  (5,5:1; blanco daba 2,9:1). `#EBA35C` (cifras y títulos del menú) sobre azul noche: 8,4:1.
- **Como letra sobre blanco el naranja no se lee** (2,9:1). En el puente (`app.css`): `--te-color-letra` = el mismo naranja
  más oscuro (`color-mix(… 65%, #000)` ≈ `#8D541C`, 6,1:1). Lo usan los enlaces sueltos, el foco del teclado en el contenido,
  las iniciales «Te» del círculo de la barra y **`--verde`** (las piezas de antes que lo usaban como letra: pestañas, «Ver…»,
  montos, días del fin de semana del calendario). `--verde-claro` y `--verde-oscuro` también son tonos del naranja.
- Las piezas de antes que usaban `--verde` de **fondo con letra blanca** (botón `.boton` suelto, chips activos, contadores,
  pestañas del día del evento, embudo de reportes, paso actual, sello de entrar…) están listadas una a una al final del puente
  («Piezas de antes con fondo del color del programa»): fondo naranja y texto `var(--tk-color-texto)`. **Si aparece una pieza
  nueva con fondo del color, agrégala ahí** (blanco sobre naranja no se lee).
- El portal público del cliente, los PDF, los correos y los colores que elige cada negocio (vino por defecto) no cambian.

## Menú (`app/menu.php`, función `tk_menu()`): una sola definición para el menú y la pantalla «Más»
| Grupo | Opciones (las de módulos apagados o sin permiso no salen) |
|---|---|
| Principal | 📊 Inicio · 📅 Calendario · 🎉 Eventos · 🔔 Avisos (con globito de sin leer) |
| Ventas | 👥 Clientes · 📞 Seguimiento · 💬 Mensajes por WhatsApp · 🏷️ Catálogo y precios · 📦 Paquetes · 🎁 Extras del portal · 🎯 Metas de ventas |
| Dinero | 💳 Cobros · 🧾 Por pagar · 📈 Reportes |
| Operación | 🏛️ Espacios · 🗺️ Planos del salón · 🧑‍🍳 Personal · 🚚 Proveedores · ⚠️ Incidencias · 🪑 Mobiliario |
| Configuración | ⚙️ Configuración · ✍️ Plantillas de contrato · 📋 Formularios del evento · 🧑‍💼 Usuarios · 🧾 Factura electrónica · ⭐ Mi plan · 👤 Mi cuenta · ❓ Ayuda |

- El coordinador no ve Ventas ni Dinero; solo el dueño y los administradores ven Configuración, usuarios, factura y Mi plan.
- Arriba del menú queda «Buscar evento o cliente…». En la barra de arriba: logo del negocio (o «Te»), nombre del negocio,
  «TuEvento · Plan …», nombre del usuario (lleva a Mi cuenta), su cargo y «Salir».
- En el celular el menú se abre con ☰ (lo hace `tukan-ui.js`). Ya no hay barra de botones abajo.

## Inicio (dashboard), en este orden (`app/vistas/inicio.php`)
1. **Saludo** según la hora de Ecuador.
2. **Avisos importantes** (`.tk-tira`): demo con los días que quedan y «Ver Mi plan», plan por vencer, términos por aceptar,
   contraseña temporal, comprobantes por revisar, y la tarjeta de la demo con el manual y los primeros pasos.
3. **Primeros pasos** (`.tk-pasos`), los que ya calculaba `Configuracion::primerosPasos()`: completar los datos del negocio ·
   subir el logo · revisar espacios y precios · crear el primer evento · conectar Telegram. Con barra de avance, «Hacerlo» y
   «Ya sé usarlo, ocultar» (se guarda por negocio). Desaparece al completarlos.
4. **Cifras** (`.tk-cifras`, las que el Inicio ya calculaba): eventos este mes · eventos en los próximos 30 días ·
   vencido por cobrar · consultas nuevas sin atender · pagos a proveedores (si hay y el módulo está encendido).
5. **Tarjetas del día** (`.tk-columnas`): próximos 7 días · cuotas vencidas o por vencer · seguimientos de hoy ·
   tareas por vencer · para atender · avisos sin leer. Cada una con título, descripción, botón «Ver…» y tabla o vacío que guía.
6. **Accesos rápidos**: Nuevo evento · Calendario · Cobros · Eventos · Clientes.

## Las demás pantallas
- Sus piezas llevan las clases del kit junto a las de antes: `boton tk-boton` (`boton-claro` → `secundario`, `boton-chico` →
  `chico`, `boton-peligro` → `peligro`, `boton-wa` → `ok`), `bloque tk-tarjeta`, `cabecera tk-titulo-pagina`, `campo tk-campo`,
  `tabla tk-tabla`, `vacio tk-vacio`, `acciones tk-acciones`. En una pantalla nueva usa directamente las clases `tk-…`.
- **Puente** (al final de `public/assets/app.css`, todo con `body.tk`): lo propio de TuEvento que el kit no trae —campos
  sueltos, avisos (`aviso aviso-ok|error|alerta`), estados del evento como chips, buscador del menú, pantalla «Más»— y los
  **emojis de los botones**: el botón lleva `data-ico="guardar|mas|editar|basura|descargar|ojo|tarjeta|check|flecha…"` y el
  puente le pone el emoji delante, sin cambiar el texto del botón.
- **Tablas en el celular**: `app.js` les pone a las tablas `tk-tabla` el título de cada columna (`data-titulo`) y la clase
  `tarjetas`; así se ven como tarjetas. No toca las que tienen campos para escribir ni las marcadas `data-tabla-fija`.
- **Tres nombres del kit que ya existían en TuEvento** (ojo al copiar esto a otro programa de la misma familia):
  `aviso` (aquí es la clase de los mensajes: para cifras y tarjetas ámbar se usa `te-ambar`), `tarjetas` (era una rejilla: el
  puente la anula en las tablas) y el botón «ocupado» de `tukan-ui.js` (los formularios que abren otra pestaña o que piden
  confirmación llevan `data-sin-ocupado`).
- **Contraste AA**: el puente oscurece dos colores del kit que no llegaban a 4,5:1 (texto gris sobre el fondo gris y blanco
  sobre el botón verde de WhatsApp). Cuando el kit lo corrija para todos, esas dos líneas del puente se quitan.
