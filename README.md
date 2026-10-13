# TuEvento

Programa para **salones de eventos, quintas y haciendas** de Ecuador, de la marca Tukán Software.
Dirección: **tuevento.tukanec.com** (servidor qfcorp). Web de la marca: tukansoftware.com.

- Plan, avance y pendientes: [BLOC_DE_NOTAS.md](BLOC_DE_NOTAS.md)
- Cómo está hecho y reglas para programar: [docs/GUIA_DESARROLLO.md](docs/GUIA_DESARROLLO.md)

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

## Direcciones
| Quién | Dirección |
|---|---|
| Dueño y equipo | `/` (entrar con correo y contraseña) |
| Página pública del local | `/?r=sitio&s=<nombre-del-local>` |
| Cliente (portal) | `/?r=portal&t=<enlace secreto>` · formulario `/?r=portal_cuestionario&t=…` · extras `/?r=portal_extras&t=…` · encuesta `/?r=encuesta&t=…` |
| Cotización / firma de contrato | `/?r=cot&t=…` · `/?r=firmar&t=…` · anexo `/?r=firmar_anexo&t=…` · verificación `/?r=verificar&c=<código>` |
| Invitado / puerta / en vivo / personal | `/?r=invitacion&t=…` · `/?r=puerta&t=…` · `/?r=vivo&t=…` · `/?r=staff&t=…` |
| Proveedor (portal) / verificar orden de compra | `/?r=portal_proveedor&t=<enlace secreto>` · `/?r=verificar_oc&c=<código>` |
| Tukán (super administrador) | `/?r=admin_entrar` · cuenta creada con `php bin/crear_admin.php` en el servidor |

## Tecnología
PHP 8.3+, PostgreSQL 16 (extensiones `btree_gist` y `pgcrypto`), TCPDF (con composer) para los PDF. Sin librerías de JavaScript.

## Instalar en el servidor (Ubuntu + PHP + PostgreSQL + nginx)
Una sola línea, como el usuario normal (no root). Se puede repetir para actualizar: si ya hay negocios, no borra la base.

```bash
curl -fsSL https://raw.githubusercontent.com/qfcorp/tuevento/main/deploy/instalar.sh -o ~/instalar_tuevento.sh && bash ~/instalar_tuevento.sh
```

Después, en Cloudflare (Zero Trust → Networks → Tunnels → tu túnel → Public Hostname) agregar `tuevento.tukanec.com` → `HTTP` → `localhost:80`, con *HTTP Host Header* = `tuevento.tukanec.com`.

Super usuario del panel Tukán: `php /var/www/tuevento/bin/crear_admin.php`

## Tareas automáticas y respaldo
El instalador deja programado:
```
5 * * * * php /var/www/tuevento/bin/tareas.php          (cada hora)
25 3 * * * /var/www/tuevento/deploy/respaldo.sh         (cada día 3:25, guarda 14 días en /var/backups/tuevento)
```
Tareas: vencer cotizaciones, avisar fechas retenidas que se liberan, cuotas por vencer, revisar precios, evento en 7 días, pasar a realizado, devolver garantías, reporte del mes, seguimientos del día, pagos a proveedores que vencen, documentos de proveedores por vencer y proveedores sin confirmar a 3 días del evento.

Telegram (opcional) en `config/.env`: `TELEGRAM_BOT_TOKEN`, `TELEGRAM_BOT_USERNAME` y `TELEGRAM_WEBHOOK_SECRET` (obligatorio si se usa el webhook).

## Pruebas (entorno simulado)
Solo en bases de prueba (se borran y se vuelven a crear):

```bash
# Lógica (795 pruebas)
TUEVENTO_DB_NAME=tuevento_prueba TUEVENTO_DB_USER=tuevento TUEVENTO_DB_PASS=prueba php tests/run_tests.php
# Pantallas de punta a punta (916 pruebas; levanta un sitio de prueba solo)
PGPASSWORD=prueba bash tests/run_web.sh
```
