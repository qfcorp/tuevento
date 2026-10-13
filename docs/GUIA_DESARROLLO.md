# Guía para programar en TuEvento

TuEvento es el programa de la familia Tukán para **salones de eventos, quintas y haciendas** (Ecuador).
Misma forma de trabajar que TuSalón (qfcorp/tusalon): PHP 8.3+ sin framework, PostgreSQL 16, sin librerías de JavaScript.

## Estructura
| Carpeta | Qué tiene |
|---|---|
| `public/index.php` | Lista de rutas (`/?r=<ruta>`): públicas, privadas, de coordinador y del panel Tukán |
| `app/bootstrap.php` | Configuración, sesión y funciones de ayuda: `db()`, `e()`, `url()`, `url_completa()`, `redirigir()`, `dinero()`, `fecha_corta()`, `fecha_larga()`, `hora_corta()`, `aviso()`, `campo_csrf()`, `verificar_csrf()`, `es_post()`, `usuario()`, `es_dueno()`, `es_comercial()`, `puede_editar()`, `exigir()`, `es_quinta()`, `requiere_quinta()`, `vista()`, `vista_publica()`, `vista_admin()`, `numero()`, `campo()`, `registrar_cambio()`, `ip_visitante()` |
| `app/paginas/<ruta>.php` | La lógica de cada pantalla (lee el pedido, llama a `src/`, muestra una vista) |
| `app/vistas/<nombre>.php` | El HTML de cada pantalla. `_diseno.php` (sistema), `_publico.php` (páginas públicas), `_admin.php` (panel Tukán), `_evento_tabs.php` (cabecera + pestañas de un evento) |
| `app/pdf/<tipo>.php` | Cada PDF (`/?r=pdf&tipo=<tipo>&id=<id>`), con la base `src/Pdf.php` (TCPDF) |
| `src/` | La lógica del negocio (clases `TuEvento\...`) |
| `db/schema.sql` | Todas las tablas. Cambios posteriores: `db/migraciones/NNN_nombre.sql` (se pueden correr muchas veces: `IF NOT EXISTS`) |
| `public/assets/` | `app.css` y `app.js` comunes; cada módulo puede tener `mod_<modulo>.css` y `mod_<modulo>.js` (se cargan solos) |
| `tests/` | Pruebas: `logica_*.php` (lógica) y `web_*.sh` (pantallas de punta a punta) |

## Reglas
- Todo el texto en **español sencillo de Ecuador** (usuarios que saben poco de tecnología). Mensajes de error claros que dicen qué hacer.
- Cada tabla lleva `negocio_id`: **siempre** filtrar por el negocio del usuario (`$u['negocio_id']`). Un negocio nunca ve datos de otro.
- Formularios: siempre `campo_csrf()` y `verificar_csrf()`. Después de un POST correcto: `aviso('...')` + `redirigir(...)`.
- Errores de negocio: las clases lanzan `RuntimeException` con un mensaje para el usuario; la página lo atrapa y lo muestra.
- Mostrar con `e()` todo lo que venga de la base o del usuario.
- Dinero con `dinero()`, fechas con `fecha_corta()` / `fecha_larga()`.
- Permisos: `consulta` solo mira (`puede_editar`), `coordinador` solo el día del evento (lista `$deCoordinador`), ventas y cobros solo `es_comercial`, configuración y usuarios solo `es_dueno`.
- Plan Quinta: portal del cliente, invitados, día del evento, mobiliario y boda en vivo (`requiere_quinta`).
- Diseño: celular primero. Usar las clases de `app.css`: `cabecera`, `bloque`, `campo`, `fila-campos`, `rejilla-form`, `boton`, `boton-claro`, `boton-chico`, `boton-peligro`, `boton-wa`, `tabla`, `tabla-scroll`, `num`, `cifras`/`cifra-tarjeta`, `ev-estado ev-<estado>`, `pestanas`, `filas`, `aviso aviso-ok|aviso-error`, `vacio`, `barra`.
- WhatsApp con un toque: `\TuEvento\WhatsApp::enlace($telefono, $mensaje)`.

## Pruebas
```bash
# Lógica (borra y recrea la base de prueba)
TUEVENTO_DB_NAME=tuevento_prueba TUEVENTO_DB_USER=tuevento TUEVENTO_DB_PASS=prueba php tests/run_tests.php
# Pantallas (levanta un sitio de prueba solo)
bash tests/run_web.sh
```
