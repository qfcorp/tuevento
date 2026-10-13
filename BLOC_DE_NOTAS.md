# Bloc de notas — TuEvento (salones de eventos, quintas y haciendas · marca Tukán)

Última actualización: 13 de octubre de 2026

## Qué es
Programa para salones de eventos, quintas y haciendas de Ecuador. Nació del estudio de nichos (12 oct 2026): no había ningún programa ecuatoriano para este mercado.
Se armó juntando lo mejor de los programas existentes y lo que Tukán ya tenía:
- **Brinden** (Argentina): agenda con aviso de doble reserva, pipeline presupuestado → señado → reservado, presupuestos en PDF por WhatsApp, caja de señas, perfil público con formulario.
- **EventControl** (México): cotizaciones y contratos con paquetes, compras y gastos por evento.
- **Evento Plus**: avisos automáticos por WhatsApp en cada etapa.
- **OfiEventos** (España, en español): presupuestos, planning, salones, invitados, inventario, control de cobros, escandallo de costos.
- **Anolla / Infor / ReServe**: lista de espera, eventos que se repiten, comunicación automática, órdenes de servicio (BEO), contratos con la marca.
- **ERP QF**: propuestas en PDF, firma con QR, personal por evento y personal mínimo, cronómetro de escaleta, reportes, exportar.
- **TuSalón**: agenda, anticipos con transferencia/DeUna/Payphone, planes y prueba gratis, Telegram, app instalable.
- **TuPass**: accesos con QR y transmisión (boda en vivo).

## Decisiones tomadas
- [x] Nombre provisional: **TuEvento** (se puede cambiar)
- [x] Planes: **Salón $39/mes** (hasta 2 espacios y 3 usuarios) · **Quinta $69/mes** (todo, ilimitado). Semestral paga 5 recibe 6; anual paga 10 recibe 12 + dominio. Prueba gratis 14 días. Precios y lo que incluye cada plan se cambian después (panel Tukán → Planes).
- [x] Plan Quinta incluye: portal del cliente completo, invitados con QR, día del evento, mobiliario y boda en vivo.
- [x] **Sin facturación electrónica** por ahora (misma decisión pendiente que la veterinaria: opción B, proveedor registrado en el SRI).
- [x] Tecnología igual que TuSalón: PHP + PostgreSQL, en el servidor qfcorp, dirección **tuevento.tukanec.com**.

## Hecho (13 oct 2026) — piloto completo
- [x] Base de datos (36 tablas + 5 migraciones) con **bloqueo de doble reserva en la base** (restricción de exclusión por espacio y horario)
- [x] Ventas: calendario mensual y "próximos sábados", eventos (lista y tablero), evento con estados, seguimiento, tareas, clientes, espacios y fechas cerradas, lista de espera
- [x] Página pública del local con "¿está libre tu fecha?" y formulario de consulta (anti-robots, límite por hora)
- [x] Catálogo, paquetes (simulador por invitados), cotizaciones con versiones, IVA por línea, descuento, ganancia (solo dueño), enlace para aceptar, PDF con QR
- [x] Contratos con plantillas y variables, firma del cliente con el dedo, PDF firmado, verificación por QR y huella SHA-256
- [x] Cobros: plan de cuotas automático o a mano, pagos y recibos, comprobantes del cliente, Payphone, garantía, gastos y ganancia real, tablero de cobranza, mensajes de WhatsApp del día
- [x] Portal del cliente (básico en Salón, completo en Quinta)
- [x] Día del evento: cronograma con modo en vivo, personal con su portal, proveedores, mobiliario con disponibilidad, hoja del evento, boda en vivo con QF
- [x] Invitados: invitación digital, confirmación, mesas, pegar lista, control de ingreso con QR, portal de invitados para los novios, PDFs
- [x] Inicio del día, reportes, exportar a Excel, configuración, usuarios y roles, Telegram, calendario de Google, tareas automáticas, panel Tukán, instalador y respaldo
- [x] **Pruebas en entorno simulado: lógica 795/795 y pantallas 916/916**, sin avisos de PHP; revisado en celular y computadora (Chromium) sin errores de JavaScript; QR leídos con un lector real

## Pendiente
1. [ ] DIMI: instalar en el servidor (comando en el README) y crear la ruta del túnel `tuevento.tukanec.com`
2. [ ] DIMI: crear el super usuario del panel Tukán (`php /var/www/tuevento/bin/crear_admin.php`)
3. [ ] Probar Payphone con claves reales de un local (solo se probó con simulador)
4. [ ] Lista de 10 salones/quintas conocidos por QF Producciones → entrevistas y piloto gratis con 2-3
5. [ ] Decidir nombre definitivo (TuEvento / TuFecha / TuQuinta), precios y qué va en cada plan después del piloto
6. [ ] Facturación electrónica (opción B, proveedor registrado en el SRI) cuando se decida
7. [ ] WhatsApp automático (API oficial, pagada); hoy hay WhatsApp con un toque
8. [ ] Agregar TuEvento a tukansoftware.com
9. [ ] Manual en PDF y presentación de ventas (como TuSalón)
