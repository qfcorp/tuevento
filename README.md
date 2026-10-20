# TuEvento

Programa para **salones de eventos, quintas y haciendas** de Ecuador, de la marca Tukán Software.
Dirección: **tuevento.tukanec.com** (servidor qfcorp). Web de la marca: tukansoftware.com.

- Plan, avance y pendientes: [BLOC_DE_NOTAS.md](BLOC_DE_NOTAS.md)
- Cómo está hecho y reglas para programar: [docs/GUIA_DESARROLLO.md](docs/GUIA_DESARROLLO.md)
- **Manual para el cliente** (con capturas reales): [docs/Manual_TuEvento.pdf](docs/Manual_TuEvento.pdf) · versión por módulo: [docs/MANUAL.md](docs/MANUAL.md) · se regenera con `bash docs/manual/generar/generar.sh`

## Qué hace
- Calendario por espacios **sin doble reserva** (la base de datos lo impide), con horas de montaje y desmontaje, fechas cerradas y "próximos sábados".
- Embudo de ventas: consulta → cotizado → separado → confirmado → realizado, con seguimiento (llamadas, visitas, degustaciones) y tareas por evento.
- Catálogo, paquetes y **cotizaciones** con IVA por producto, descuento, versiones, ganancia, enlace para que el cliente la acepte y PDF con QR.
- **Contratos** desde plantillas con variables, **firmados por el cliente en su celular**, con verificación por QR (detecta si alguien cambió el texto).
- **Plan de cuotas** automático, pagos, recibos, comprobantes de transferencia/DeUna que sube el cliente, **Payphone**, garantía por daños, gastos y ganancia real del evento. La fecha se separa sola al pagar la reserva.
- **Portal del cliente** (sin contraseña, con enlace secreto): su evento, documentos, pagos, invitados, cronograma y transmisión.
- **Formulario del evento** por tipo (boda, quince años, corporativo…): el cliente lo llena en su portal (se guarda solo) hasta X días antes; el local ve y corrige las respuestas, que salen en la hoja del evento. Recordatorio por WhatsApp.
- **Extras en línea**: el cliente pide desde su portal hora extra, hora loca, fotocabina…; el local aprueba y se suma solo a la cotización y al plan de pagos. Si el contrato ya estaba firmado, se prepara un **anexo de contrato** que el cliente firma con el dedo (con QR de verificación y PDF).
- **Encuesta de satisfacción** después del evento (NPS y estrellas): a quien le encantó se le pide la reseña en Google; una nota baja avisa al dueño. Reporte de satisfacción.
- **Día del evento**: cronograma minuto a minuto con **modo en vivo**, personal con portal propio, proveedores, mobiliario con disponibilidad por fecha, hoja del evento (PDF).
- **Invitados con QR**: invitación digital, confirmación de asistencia, mesas, control de ingreso en la puerta escaneando el QR.
- **Proveedores y compras**: ficha de cada proveedor (RUC, cuenta del banco, días y cupo de crédito, anticipo), documentos con vencimiento (permisos, ARCSA, póliza) con aviso, órdenes de compra por evento (pedido de precio → pedida → confirmada → entregada) en PDF con QR y por WhatsApp, comparar precios y elegir, factura del proveedor a mano o **leyendo el XML del SRI**, pagos con cheques posfechados y anulación, **Por pagar** (vencido, esta semana, antigüedad de saldos, cupo, Excel), puntualidad y calificación el día del evento, **incidencias** con foto y descuento al proveedor, ranking de proveedores con **puntaje configurable por el dueño** (pesos, tolerancia, incidencias, niveles, periodo y mínimo de eventos, con vista previa), bitácora de todo y **portal del proveedor** (sus eventos, confirmar órdenes, subir facturas, sus pagos y "Ya llegué"). Las compras cuentan en la ganancia real del evento.
- **Plano visual del salón**: distribuciones de cada espacio en metros (mesas redondas, rectangulares e imperiales, pista, tarima, barra, buffet, DJ…) que se arrastran con el dedo o el mouse; el plano de cada evento está unido a las mesas de los invitados (se ve quién está sentado y qué mesa está llena), en PDF y para que los novios lo miren.
- **Metas de ventas**: meta del mes (y por vendedor), avance en el Inicio y reporte con la comparación con el mismo mes del año anterior.
- **Boda en vivo** con QF Producciones (pedido por WhatsApp y enlace en portal e invitaciones).
- Página pública del local con consulta de fechas libres y formulario que entra al sistema.
- Inicio con el día, cobranza, mensajes por WhatsApp listos para enviar, reportes (ventas, cobrado, ocupación, conversión, rentabilidad, comisiones), exportar a Excel, calendario para Google Calendar, avisos por Telegram.
- Usuarios: dueño, vendedor, coordinador (solo el día del evento) y consulta (solo mira). Panel Tukán para administrar todos los negocios y sus planes.

## Planes y módulos (Anexo B: el programa se arma por módulos)
Cada cliente tiene la **base** (siempre) y los **módulos** que paga. Se encienden y apagan por cliente desde el Panel Tukán
(ficha del negocio → **Módulos**) o desde el Panel Tukán Central. **Apagar nunca borra datos**: se esconden menús, páginas,
botones, portales públicos ("No disponible"), PDF, tareas automáticas, avisos y Mensajes de hoy; al encenderlo vuelve todo.

**Base** (todos): calendario sin doble reserva, eventos, seguimiento y tareas, clientes, espacios y catálogo, cotizaciones con PDF,
plan de pagos y recibos, Mensajes de WhatsApp del día, página pública con consulta, reportes básicos, usuarios y roles, app instalable.

| Plan | Precio base | Módulos incluidos |
|---|---|---|
| Esencial | $19/mes (1 espacio, 2 usuarios) | Solo la base |
| Salón | $39/mes (2 espacios, 3 usuarios) | Paquetes, contratos, portal del cliente, cobros en línea, formulario/extras/encuesta, proveedores y compras, incidencias, metas, Telegram, exportar |
| Quinta | $69/mes (sin límite) | Todos |

| Módulo | Qué trae | $/mes | Necesita |
|---|---|---|---|
| Paquetes y simulador | Paquetes armados que cargan la cotización en un toque; simulador por invitados | 3 | — |
| Contratos con firma | Contrato que el cliente firma con el dedo, QR de verificación, anexos por extras | 6 | — |
| Portal del cliente | Enlace del cliente sin claves: pagos, contrato, comprobantes | 6 | — |
| Cobros en línea (Payphone) | El cliente paga con tarjeta desde su portal | 4 | Portal del cliente |
| Formulario, extras y encuesta | Formulario del evento, extras pedidos en línea, encuesta NPS y reseña | 5 | Portal del cliente |
| Día del evento | Cronograma con modo en vivo, personal con su portal, hoja del evento | 8 | — |
| Invitados con QR | Invitación, confirmación, mesas, control de ingreso con QR | 8 | — |
| Plano del salón | Plano de cada espacio y de cada evento, PDF a escala | 6 | — |
| Mobiliario y menaje | Sillas, mesas, mantelería: reservas, disponibilidad y daños | 5 | — |
| Boda en vivo | Transmisión con el botón "Ver en vivo" en portal e invitación | 5 | Día del evento |
| Proveedores y compras | Ficha, documentos, órdenes de compra, facturas (XML del SRI), por pagar | 7 | — |
| Portal del proveedor | El proveedor ve sus eventos, confirma órdenes, sube facturas | 4 | Proveedores |
| Incidencias y puntaje | Problemas con foto, puntualidad y puntaje configurable | 3 | Proveedores |
| Metas y reportes avanzados | Metas de ventas, embudo, ganancia por evento, comisiones | 4 | — |
| Avisos por Telegram | Pagos, firmas, consultas, cuotas y seguimientos al celular | 3 | — |
| Exportar a Excel y Google Calendar | Descargas para Excel y calendario externo | 3 | — |

- **Precio al mes** de cada cliente = plan + módulos extra − módulos quitados (o un **precio acordado** fijo). Es el que sugiere
  "Registrar pago", el `cotizar` y el `mensual_estimado` del Panel Central. Precios, descripciones y qué trae cada plan se cambian en
  Panel Tukán → **Planes y precios → Catálogo de módulos**.
- **Mi plan** (dueño): ve sus módulos encendidos y los que puede agregar con su precio; **Pedir este módulo** crea un pedido
  (solicitud `cambio_modulos`) que Tukán aprueba o rechaza.
- **Nada se da gratis, todo se pide demo**: no hay registro con prueba gratis. `/?r=registro` es **Solicitar demo** (nombre, negocio,
  ciudad, WhatsApp, correo, qué necesita y módulos que le interesan) y llega como solicitud `demo_pedida` al Panel Central y al Resumen
  del Panel Tukán (**Crear demo**). La demo tiene todos los módulos encendidos (o los que elija Tukán) por los días que Tukán decida.

## Direcciones
| Quién | Dirección |
|---|---|
| Dueño y equipo | `/` (entrar con correo y contraseña) · **Solicitar demo**: `/?r=registro` |
| Página pública del local | `/?r=sitio&s=<nombre-del-local>` |
| Cliente (portal) | `/?r=portal&t=<enlace secreto>` · formulario `/?r=portal_cuestionario&t=…` · extras `/?r=portal_extras&t=…` · encuesta `/?r=encuesta&t=…` |
| Cotización / firma de contrato | `/?r=cot&t=…` · `/?r=firmar&t=…` · anexo `/?r=firmar_anexo&t=…` · verificación `/?r=verificar&c=<código>` |
| Invitado / puerta / en vivo / personal | `/?r=invitacion&t=…` · `/?r=puerta&t=…` · `/?r=vivo&t=…` · `/?r=staff&t=…` |
| Proveedor (portal) / verificar orden de compra | `/?r=portal_proveedor&t=<enlace secreto>` · `/?r=verificar_oc&c=<código>` |
| Tukán (super administrador) | `/?r=admin_entrar` · cuenta creada con `php bin/crear_admin.php` en el servidor · o con un clic desde el Panel Tukán Central |
| Panel Tukán Central (conector) | v1: `/tukan_central.php?accion=sso&t=…` (entrar, con enlace directo `ir`) · `/tukan_central.php?accion=estado&t=…` (cifras en JSON) · v2: `POST /tukan_central.php?accion=<capacidades, clientes, cliente, cotizar, planes, modulos, solicitudes, solicitud, finanzas, ejecutar>` (incluye pausar, borrar_cliente, restaurar_cliente, cambiar_modulos y guardar_modulos) |

## Tecnología
PHP 8.3+, PostgreSQL 16 (extensiones `btree_gist` y `pgcrypto`), TCPDF (con composer) para los PDF. Sin librerías de JavaScript.

## Instalar en el servidor (Ubuntu + PHP + PostgreSQL + nginx)
Una sola línea, como el usuario normal (no root). Se puede repetir para actualizar: si ya hay negocios, no borra la base.

```bash
curl -fsSL https://raw.githubusercontent.com/qfcorp/tuevento/main/deploy/instalar.sh -o ~/instalar_tuevento.sh && bash ~/instalar_tuevento.sh
```

Después, en Cloudflare (Zero Trust → Networks → Tunnels → tu túnel → Public Hostname) agregar `tuevento.tukanec.com` → `HTTP` → `localhost:80`, con *HTTP Host Header* = `tuevento.tukanec.com`.

Super usuario del panel Tukán: `php /var/www/tuevento/bin/crear_admin.php`

## Conectar con el Panel Tukán Central (panel.tukanec.com)
El panel central muestra las cifras de todos los programas Tukán y deja entrar a cada panel con un clic.
1. En el panel central, agrega la instalación de TuEvento: te da un **ID** (ej. `tuevento`) y un **SECRETO** (64 letras y números).
2. En el servidor, una sola línea:
   ```bash
   sudo bash /var/www/tuevento/deploy/conectar_central.sh {ID} {SECRETO} {URL}
   ```
   Ejemplo: `sudo bash /var/www/tuevento/deploy/conectar_central.sh tuevento 3f9a…c1 https://panel.tukanec.com`.
   Guarda `TUKAN_CENTRAL_ID`, `TUKAN_CENTRAL_SECRET` y `TUKAN_CENTRAL_URL` en `config/.env` (lo demás no se toca), prepara las tablas y hace una prueba: debe terminar en `OK`.
3. Listo: al entrar desde el panel central, el panel de TuEvento muestra el botón **← Panel Tukán** para volver.

- Sin `TUKAN_CENTRAL_ID` o `TUKAN_CENTRAL_SECRET`, `/tukan_central.php` responde 404 y todo sigue como antes. El instalador conserva estas líneas al actualizar.
- **Entrar solo desde el panel central:** agrega `TUKAN_SOLO_CENTRAL=1` en `config/.env`. La página `/?r=admin_entrar` dice "El ingreso del super usuario es solo desde el Panel Tukán" y no acepta contraseñas. El ingreso de los negocios no cambia.
- **Emergencia** (el panel central no responde): pon `TUKAN_SOLO_CENTRAL=0` en `config/.env` y entra con tu clave; si no la recuerdas, `php /var/www/tuevento/bin/crear_admin.php` la cambia.
- Cada entrada desde el panel central queda en "Últimos movimientos del panel" ("Entró desde el Panel Tukán Central"). La primera vez se crea el super usuario con el correo del panel central (con una contraseña al azar que nadie conoce).
- Seguridad: cada enlace dura 60 segundos y sirve una sola vez (30 s las operaciones); máximo 120 pedidos y 30 rechazados por minuto por IP; el estado no lleva datos personales (solo nombres de negocios). Detalle del protocolo: `PROTOCOLO.md` (v1) y `PROTOCOLO_V2.md` (v2) del panel central.

### Qué puede hacer el Panel Tukán Central (protocolo v2)
Con el mismo ID y el mismo secreto, el panel central ve y maneja a los clientes de TuEvento sin entrar al panel:
- **Clientes**: todos los negocios con su estado (en demo, al día, por vencer en 7 días, vencido —incluye los días de gracia— y suspendido/cancelado), plan, vencimiento, dueño, último uso, pagos, sus **módulos** (`modulos`: del plan, extra, quitados, activos y precio) y lo que paga al mes con sus módulos (`mensual_estimado`). La ficha trae los pagos (también los anulados), las últimas acciones, las notas internas y los mensajes de WhatsApp listos.
- **Solicitudes**: **pedidos de demo** (`demo_pedida`, con Crear demo prellenado), **pedidos de módulos** desde Mi plan (`cambio_modulos`, con Aprobar = `cambiar_modulos` y Rechazar), demos que terminan en 2 días / hoy / terminadas sin pagar (60 días), planes que vencen en 5 días o vencidos sin renovar (30 días) y dominios incluidos por registrar. Se marcan "en proceso", "atendida" o "descartada" (tabla `tukan_central_atenciones`).
- **Operaciones** (con las mismas funciones del panel de Tukán y una línea en "Últimos movimientos del panel" con el correo del Central): crear demo (con datos de ejemplo, plan y módulos opcionales, desde un pedido de demo; la contraseña temporal se muestra una sola vez), alargar la demo, registrar pago (con la fecha en que pagó), anular pago, suspender, reactivar, cancelar, cambiar plan, nueva clave del dueño, nota interna, atender solicitud, guardar plan/precios, **cambiar_modulos** (encender/apagar con dependencias, precio acordado; solo el rol dueño) y **guardar_modulos** (catálogo y módulos de cada plan).
- **Finanzas**: cobrado por mes (por plan, tiempo y forma de pago), nuevos pagadores, devengado, ingreso mensual recurrente (lo que pagan al mes con sus módulos) y `por_modulo` (cuántos lo tienen y cuánto suman los extras).
- Si el Central repite una operación (se cortó la red), TuEvento no la hace dos veces: devuelve el mismo resultado (`tukan_central_operaciones`, 90 días, sin contraseñas).
- **Pausar y borrar clientes** (Anexo A del protocolo):
  - `pausar` (tipo: falta de pago, pedido del cliente, revisión, uso indebido u otro + motivo): el negocio no puede trabajar y ve "Tu cuenta está pausada" con el motivo (en revisión y uso indebido, un texto genérico) y el WhatsApp de Tukán; su página pública y todos sus portales y enlaces dicen "temporalmente no disponible". `reactivar` la quita.
  - `borrar_cliente` (escribir el nombre exacto del negocio o su número + motivo; solo el rol dueño del Central): guarda una **copia completa** (todas las filas de todas las tablas del negocio, sacadas del esquema, y la lista de sus archivos subidos) en `respaldos/borrados/<id>_<fecha>.json.gz` (fuera de la web, carpeta 700 de `www-data`; otra carpeta con `TUEVENTO_BORRADOS`) y lo manda a la **papelera**: no entra, no sale en listas ni cifras (`estado`, `clientes`, `finanzas` desde ese día), sus páginas y portales dan 404 y no recibe tareas ni avisos.
  - `restaurar_cliente` dentro de 30 días lo devuelve tal cual (también desde el Panel Tukán del programa: Negocios → filtro **Papelera** → Restaurar). Pasados 30 días, la tarea de cada hora lo borra de verdad (sus archivos pasan junto a la copia); las copias se borran al año.
  - `clientes` con `filtros.estado = "papelera"` los lista (cada uno con `papelera: {desde, hasta, motivo}`); cada ficha trae los botones que corresponden (`pausar`/`reactivar`, `borrar_cliente` o `restaurar_cliente`).

## Tareas automáticas y respaldo
El instalador deja programado:
```
5 * * * * php /var/www/tuevento/bin/tareas.php          (cada hora, en el crontab de www-data)
25 3 * * * /var/www/tuevento/deploy/respaldo.sh         (cada día 3:25, guarda 14 días en /var/backups/tuevento)
```
Tareas: vencer cotizaciones, avisar fechas retenidas que se liberan, cuotas por vencer, revisar precios, evento en 7 días, pasar a realizado, devolver garantías, reporte del mes, seguimientos del día, pagos a proveedores que vencen, documentos de proveedores por vencer, proveedores sin confirmar a 3 días del evento y la **papelera** (borra de verdad los negocios con más de 30 días en ella y las copias de más de 1 año). Los negocios pausados o en la papelera no reciben tareas ni avisos, y cada tarea de un módulo (Telegram, proveedores) solo corre si el negocio lo tiene encendido.

**Al actualizar a esta versión** hay que volver a correr el instalador (la línea de arriba): aplica la migración 098 (módulos y pedidos de demo), crea `respaldos/borrados` y pasa las tareas al usuario `www-data`.

Telegram (opcional) en `config/.env`: `TELEGRAM_BOT_TOKEN`, `TELEGRAM_BOT_USERNAME` y `TELEGRAM_WEBHOOK_SECRET` (obligatorio si se usa el webhook).

## Pruebas (entorno simulado)
Solo en bases de prueba (se borran y se vuelven a crear):

```bash
# Lógica (2378 pruebas)
TUEVENTO_DB_NAME=tuevento_prueba TUEVENTO_DB_USER=tuevento TUEVENTO_DB_PASS=prueba php tests/run_tests.php
# Pantallas de punta a punta (1931 pruebas; levanta un sitio de prueba solo)
PGPASSWORD=prueba bash tests/run_web.sh
# Solo el conector con el Panel Tukán Central (v1 = logica_95/web_95, v2 = logica_96/web_96, pausar y papelera = logica_97/web_97, módulos y pedidos de demo = logica_98/web_98)
TUEVENTO_DB_NAME=tuevento_prueba TUEVENTO_DB_USER=tuevento TUEVENTO_DB_PASS=prueba php tests/run_tests.php logica_9
PGPASSWORD=prueba bash tests/run_web.sh web_9
```
