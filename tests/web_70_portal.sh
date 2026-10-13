# Portal del cliente, segunda parte (migración 070): formulario del evento (plantillas, portal con guardado automático,
# cierre, "listo"), extras pedidos desde el portal (configurar, pedir, aprobar, rechazar, cancelar), encuesta de satisfacción
# (enlace secreto, reseña en Google, aviso por nota baja), reporte de satisfacción, PDF y permisos por rol y por negocio.
FOTO70="$TMP/extra_70.jpg"
php -r '$i=imagecreatetruecolor(480,270);imagefill($i,0,0,imagecolorallocate($i,230,200,120));imagestring($i,5,150,120,"Hora loca",0);imagejpeg($i,$argv[1]);' "$FOTO70"
cat > "$TMP/aceptar_70.php" <<'PHP'
<?php
// Arma y acepta la cotización de un evento con un paquete (para las pruebas): php aceptar_70.php <evento_id> [paquete]
require getcwd() . '/app/bootstrap.php';
$e = (int) $argv[1];
$n = (int) db()->query("SELECT negocio_id FROM eventos WHERE id = $e")->fetchColumn();
$st = db()->prepare('SELECT id FROM paquetes WHERE negocio_id = ? AND nombre = ?');
$st->execute([$n, $argv[2] ?? 'Paquete Boda Oro']);
$cot = new TuEvento\Cotizaciones(db());
$c = $cot->crear($n, $e, (int) $st->fetchColumn() ?: null);
$cot->aceptar($n, $c, 'Cliente Web');
echo $c;
PHP
aceptar_cot() { TUEVENTO_DB_NAME=$DB TUEVENTO_DB_USER=tuevento TUEVENTO_DB_PASS=$PGPASSWORD TUEVENTO_URL=$BASE php "$TMP/aceptar_70.php" "$@"; }
pdf_get70() { curl -s -b "$JAR" -c "$JAR" -o "$TMP/doc70.pdf" -w "%{http_code} %{content_type}" "$BASE/?$1"; }
# POST desde el portal (sin sesión del sistema): post_portal "r=portal_cuestionario&t=X" datos...
post_portal() { local ruta=$1; shift; post_desde "$ruta" "$ruta" "$@"; }

echo "1. Formularios del evento (plantillas del dueño)"
registrar quinta "Quinta Portal $RANDOM"
NID1=$NID; EMAIL1=$EMAIL
check "Plantillas de formularios" "200" "$(get "r=cuestionarios")"
contiene "Título" "$TMP/pag.html" "Formularios del evento"
contiene "Formulario de boda con sus preguntas" "$TMP/pag.html" "Canción de entrada de la novia"
contiene "Chips por tipo de evento" "$TMP/pag.html" "Quince años"
check "Se crearon las 9 plantillas" "9" "$(sql "SELECT count(*) FROM cuestionario_plantillas WHERE negocio_id = $NID1")"
r=$(post_desde "r=cuestionarios&tipo=boda" "r=cuestionarios&tipo=boda" --data-urlencode "accion=pregunta" --data-urlencode "texto=¿Quieren lluvia de pétalos?" \
     --data-urlencode "tipo=sino" --data-urlencode "seccion=Ceremonia" --data-urlencode "obligatoria=")
check "Agregar pregunta a la plantilla" "1" "$(sql "SELECT count(*) FROM cuestionario_preguntas q JOIN cuestionario_plantillas p ON p.id = q.plantilla_id WHERE p.negocio_id = $NID1 AND q.texto = '¿Quieren lluvia de pétalos?'")"
r=$(post_desde "r=cuestionarios&tipo=boda" "r=cuestionarios&tipo=boda" --data-urlencode "accion=pregunta" --data-urlencode "texto=Color" --data-urlencode "tipo=opcion" --data-urlencode "opciones=Rojo")
get "r=cuestionarios&tipo=boda" > /dev/null
contiene "Opción con una sola opción: error claro" "$TMP/pag.html" "al menos 2 opciones"
contiene "No pierde lo escrito" "$TMP/pag.html" 'value="Color"'
r=$(post_desde "r=cuestionarios" "r=cuestionarios" --data-urlencode "accion=ajustes" --data-urlencode "dias_cierre=5" --data-urlencode "dias_aviso=25")
check "Ajustes guardados" "5|25" "$(sql "SELECT cuestionario_dias_cierre || '|' || cuestionario_dias_aviso FROM negocios WHERE id = $NID1")"
r=$(post_desde "r=cuestionarios" "r=cuestionarios" --data-urlencode "accion=ajustes" --data-urlencode "dias_cierre=7" --data-urlencode "dias_aviso=30")
get "r=mas" > /dev/null
contiene "Más: Formularios del evento" "$TMP/pag.html" "r=cuestionarios"
contiene "Más: Extras del portal" "$TMP/pag.html" "r=extras"

echo "2. Formulario en el evento (pestaña) y en el portal del cliente"
FECHA=$(date -d "+40 days" +%F)
EV=$(crear_evento_sql "$FECHA" separado)
COT=$(aceptar_cot "$EV")
TOKEN=$(sql "SELECT token_cliente FROM eventos WHERE id = $EV")
check "Pestaña Formulario y extras" "200" "$(get "r=evento_formulario&id=$EV")"
contiene "Pestaña en el evento" "$TMP/pag.html" "Formulario y extras"
contiene "Copió el formulario de boda" "$TMP/pag.html" "Formulario de boda"
contiene "Trae la pregunta nueva de la plantilla" "$TMP/pag.html" "¿Quieren lluvia de pétalos?"
contiene "Avance 0 de N" "$TMP/pag.html" "0 de "
contiene "WhatsApp con el enlace del formulario" "$TMP/pag.html" "r%3Dportal_cuestionario%26t%3D$TOKEN"
NPREG=$(sql "SELECT count(*) FROM evento_preguntas WHERE evento_id = $EV")
check "Portal del cliente" "200" "$(get "r=portal&t=$TOKEN")"
contiene "Tarjeta del formulario" "$TMP/pag.html" "Formulario de tu evento"
contiene "Botón para llenarlo" "$TMP/pag.html" "Llenar el formulario"
check "Formulario en el portal" "200" "$(get "r=portal_cuestionario&t=$TOKEN")"
contiene "Guardado automático" "$TMP/pag.html" "data-pt-autoguardar"
contiene "Pregunta de la boda" "$TMP/pag.html" "Canción del primer baile"
contiene "Fecha de cierre" "$TMP/pag.html" "Puedes llenarlo y cambiarlo hasta el"
contiene "Botón Listo" "$TMP/pag.html" "Listo, enviar al local"
P_BAILE=$(sql "SELECT id FROM evento_preguntas WHERE evento_id = $EV AND texto = 'Canción del primer baile'")
P_MUSICA=$(sql "SELECT id FROM evento_preguntas WHERE evento_id = $EV AND texto = 'Estilos de música para la fiesta'")
P_VALS=$(sql "SELECT id FROM evento_preguntas WHERE evento_id = $EV AND texto = 'Hora del vals'")
P_CONTACTO=$(sql "SELECT id FROM evento_preguntas WHERE evento_id = $EV AND obligatoria LIMIT 1")
r=$(post_portal "r=portal_cuestionario&t=$TOKEN" --data-urlencode "ajax=1" --data-urlencode "accion=guardar" --data-urlencode "en[]=$P_BAILE" \
     --data-urlencode "r[$P_BAILE]=Perfect - Ed Sheeran")
check "Guardado automático responde 200" "200 " "$r"
contiene "Responde JSON con el avance" "$TMP/post.html" '"respondidas":1'
check "La respuesta quedó guardada" "Perfect - Ed Sheeran" "$(sql "SELECT respuesta FROM evento_preguntas WHERE id = $P_BAILE")"
r=$(post_portal "r=portal_cuestionario&t=$TOKEN" --data-urlencode "ajax=1" --data-urlencode "en[]=$P_VALS" --data-urlencode "r[$P_VALS]=25:99")
check "Error de validación: 422" "422 " "$r"
contiene "Mensaje claro en el JSON" "$TMP/post.html" "Revisa la hora"
r=$(post_portal "r=portal_cuestionario&t=$TOKEN" --data-urlencode "accion=guardar" --data-urlencode "en[]=$P_MUSICA" --data-urlencode "r[$P_MUSICA][]=Salsa" \
     --data-urlencode "r[$P_MUSICA][]=Merengue" --data-urlencode "en[]=$P_VALS" --data-urlencode "r[$P_VALS]=22:30")
check "Guardar con el botón vuelve al formulario" "302 $BASE/?r=portal_cuestionario&t=$TOKEN" "$r"
check "Varias opciones guardadas" "Salsa
Merengue" "$(sql "SELECT respuesta FROM evento_preguntas WHERE id = $P_MUSICA")"
get "r=portal_cuestionario&t=$TOKEN" > /dev/null
contiene "Aviso de guardado con el avance" "$TMP/pag.html" "Tus respuestas quedaron guardadas (3 de $NPREG)"
contiene "Marca la opción elegida" "$TMP/pag.html" 'value="Salsa" checked'
r=$(post_portal "r=portal_cuestionario&t=$TOKEN" --data-urlencode "accion=terminar" --data-urlencode "en[]=$P_BAILE" --data-urlencode "r[$P_BAILE]=Perfect - Ed Sheeran")
get "r=portal_cuestionario&t=$TOKEN" > /dev/null
contiene "Listo sin la obligatoria: pide responderla" "$TMP/pag.html" "Te falta responder"
r=$(post_portal "r=portal_cuestionario&t=$TOKEN" --data-urlencode "accion=terminar" --data-urlencode "en[]=$P_CONTACTO" --data-urlencode "r[$P_CONTACTO]=Pedro 0991234567")
check "Listo: vuelve al portal" "302 $BASE/?r=portal&t=$TOKEN" "$r"
check "Queda enviado" "1" "$(sql "SELECT count(*) FROM evento_cuestionarios WHERE evento_id = $EV AND enviado_en IS NOT NULL")"
check "Aviso al local" "1" "$(sql "SELECT count(DISTINCT texto) FROM notificaciones WHERE negocio_id = $NID1 AND texto LIKE '📝 %terminó el formulario%'")"
get "r=portal&t=$TOKEN" > /dev/null
contiene "Gracias al enviar" "$TMP/pag.html" "Enviamos tus respuestas"
contiene "La tarjeta muestra el avance" "$TMP/pag.html" "4 de $NPREG"
check "Token falso: 404" "404" "$(get "r=portal_cuestionario&t=$(printf 'ab%.0s' {1..24})")"
r=$(curl -s -o "$TMP/post.html" -w "%{http_code}" --data-urlencode "ajax=1" --data-urlencode "csrf=malo" "$BASE/?r=portal_cuestionario&t=$TOKEN")
check "Guardado sin token de la página: 400" "400" "$r"

echo "3. El local ve y corrige las respuestas; PDF y hoja del evento"
get "r=evento_formulario&id=$EV" > /dev/null
contiene "El local ve la respuesta" "$TMP/pag.html" "Perfect - Ed Sheeran"
contiene "Dice que el cliente lo envió" "$TMP/pag.html" "El cliente lo envió el"
r=$(post_desde "r=evento_formulario&id=$EV" "r=evento_formulario&id=$EV" --data-urlencode "accion=respuestas" --data-urlencode "en[]=$P_BAILE" --data-urlencode "r[$P_BAILE]=Thinking out loud")
check "El local corrige una respuesta" "Thinking out loud" "$(sql "SELECT respuesta FROM evento_preguntas WHERE id = $P_BAILE")"
check "Queda quién la cambió" "Dimitry Prueba" "$(sql "SELECT respondido_por FROM evento_preguntas WHERE id = $P_BAILE")"
r=$(post_desde "r=evento_formulario&id=$EV" "r=evento_formulario&id=$EV" --data-urlencode "accion=pregunta_agregar" --data-urlencode "texto=¿Traen su propio licor?" --data-urlencode "tipo=sino")
check "Pregunta solo para este evento" "$((NPREG+1))" "$(sql "SELECT count(*) FROM evento_preguntas WHERE evento_id = $EV")"
PQ=$(sql "SELECT id FROM evento_preguntas WHERE evento_id = $EV AND texto = '¿Traen su propio licor?'")
r=$(post_desde "r=evento_formulario&id=$EV" "r=evento_formulario&id=$EV" --data-urlencode "accion=pregunta_borrar" --data-urlencode "pregunta_id=$PQ")
check "Quitar la pregunta" "$NPREG" "$(sql "SELECT count(*) FROM evento_preguntas WHERE evento_id = $EV")"
check "PDF del formulario" "200 application/pdf" "$(pdf_get70 "r=pdf&tipo=formulario&id=$EV")"
pdftotext "$TMP/doc70.pdf" "$TMP/doc70.txt" 2>/dev/null
contiene "El PDF trae la respuesta" "$TMP/doc70.txt" "Thinking out loud"
check "Hoja del evento" "200 application/pdf" "$(pdf_get70 "r=pdf&tipo=hoja&id=$EV")"
pdftotext "$TMP/doc70.pdf" "$TMP/doc70.txt" 2>/dev/null
contiene "La hoja trae el formulario del cliente" "$TMP/doc70.txt" "Formulario del cliente"
contiene "La hoja trae la hora del vals" "$TMP/doc70.txt" "22:30"
# Cierre: después de la fecha límite el cliente solo ve sus respuestas
sql "UPDATE negocios SET cuestionario_dias_cierre = 45 WHERE id = $NID1" > /dev/null
get "r=portal_cuestionario&t=$TOKEN" > /dev/null
contiene "Cerrado: lo dice" "$TMP/pag.html" "El formulario se cerró el"
no_contiene "Cerrado: sin campos para escribir" "$TMP/pag.html" "data-pt-autoguardar"
contiene "Cerrado: muestra sus respuestas" "$TMP/pag.html" "Thinking out loud"
r=$(post_portal "r=portal_cuestionario&t=$TOKEN" --data-urlencode "en[]=$P_BAILE" --data-urlencode "r[$P_BAILE]=Cambio tarde")
check "Cerrado: no guarda" "Thinking out loud" "$(sql "SELECT respuesta FROM evento_preguntas WHERE id = $P_BAILE")"
sql "UPDATE negocios SET cuestionario_dias_cierre = 7 WHERE id = $NID1" > /dev/null
EVC=$(crear_evento_sql "$(date -d "+80 days" +%F)" consulta)
TOKC=$(sql "SELECT token_cliente FROM eventos WHERE id = $EVC")
get "r=portal_cuestionario&t=$TOKC" > /dev/null
contiene "Evento en consulta: se abre al separar la fecha" "$TMP/pag.html" "se abre cuando tu fecha queda separada"
get "r=portal&t=$TOKC" > /dev/null
no_contiene "Evento en consulta: sin tarjeta del formulario" "$TMP/pag.html" "Llenar el formulario"

echo "4. Recordatorio del formulario en Mensajes de hoy"
EVR=$(crear_evento_sql "$(date -d "+20 days" +%F)" confirmado)
check "Mensajes de hoy" "200" "$(get "r=mensajes")"
contiene "Sección de formularios" "$TMP/pag.html" "Formularios del evento sin llenar"
contiene "Mensaje con el enlace del formulario" "$TMP/pag.html" "r%3Dportal_cuestionario%26t%3D$(sql "SELECT token_cliente FROM eventos WHERE id = $EVR")"
r=$(post_desde "r=mensajes" "r=mensajes&accion=enviado" --data-urlencode "tipo=cuestionario" --data-urlencode "ref_id=$EVR")
check "Marcar el recordatorio como enviado" "1" "$(sql "SELECT count(*) FROM mensajes_enviados WHERE negocio_id = $NID1 AND tipo = 'cuestionario' AND ref_id = $EVR")"
get "r=mensajes" > /dev/null
no_contiene "Ya no sale" "$TMP/pag.html" "Formularios del evento sin llenar"
contiene "Sale en enviados hoy" "$TMP/pag.html" "Formulario</span>"

echo "5. Extras: el local elige qué se pide en el portal"
P_HORA=$(sql "SELECT id FROM productos WHERE negocio_id = $NID1 AND nombre = 'Hora adicional'")
P_LOCA=$(sql "SELECT id FROM productos WHERE negocio_id = $NID1 AND nombre = 'Hora loca'")
check "Extras del portal" "200" "$(get "r=extras")"
contiene "Lista del catálogo" "$TMP/pag.html" "Hora adicional"
get "r=extras" > /dev/null; T=$(csrf)
r=$(curl -s -b "$JAR" -c "$JAR" -o /dev/null -w "%{http_code}" -F "csrf=$T" -F "accion=producto" -F "producto_id=$P_LOCA" -F "en_portal=1" \
     -F "portal_texto=Zanqueros, máscaras y luces para la pista" -F "portal_foto=@$FOTO70;type=image/jpeg" "$BASE/?r=extras")
check "Marcar con foto" "302" "$r"
r=$(post_desde "r=extras" "r=extras" --data-urlencode "accion=producto" --data-urlencode "producto_id=$P_HORA" --data-urlencode "en_portal=1")
check "Dos extras en el portal" "2" "$(sql "SELECT count(*) FROM productos WHERE negocio_id = $NID1 AND en_portal")"
check "Foto guardada" "1" "$(sql "SELECT count(*) FROM productos WHERE id = $P_LOCA AND portal_foto IS NOT NULL")"
get "r=catalogo" > /dev/null
contiene "El catálogo dice qué se pide en el portal" "$TMP/pag.html" "se pide en el portal"
check "Foto con sesión" "200" "$(curl -s -b "$JAR" -o /dev/null -w '%{http_code}' "$BASE/?r=extras&foto=$P_LOCA")"

echo "6. El cliente pide extras desde su portal"
get "r=portal&t=$TOKEN" > /dev/null
contiene "Tarjeta de extras en el portal" "$TMP/pag.html" "Extras para tu evento"
check "Página de extras" "200" "$(get "r=portal_extras&t=$TOKEN")"
contiene "Precio con IVA (150 + 15 %)" "$TMP/pag.html" "\$172,50"
contiene "Texto para el cliente" "$TMP/pag.html" "Zanqueros, máscaras y luces para la pista"
contiene "Foto pública del extra" "$TMP/pag.html" "r=portal_extras&amp;t=$TOKEN&amp;foto=$P_LOCA"
contiene "Botones de cantidad" "$TMP/pag.html" "data-pt-paso"
check "La foto se ve desde el portal" "200 image/jpeg" "$(curl -s -o /dev/null -w '%{http_code} %{content_type}' "$BASE/?r=portal_extras&t=$TOKEN&foto=$P_LOCA")"
check "Foto de un producto que no se ofrece: 404" "404" "$(curl -s -o /dev/null -w '%{http_code}' "$BASE/?r=portal_extras&t=$TOKEN&foto=$(sql "SELECT id FROM productos WHERE negocio_id = $NID1 AND nombre = 'Torta de bodas'")")"
r=$(post_portal "r=portal_extras&t=$TOKEN" --data-urlencode "accion=pedir" --data-urlencode "cant[$P_HORA]=0")
get "r=portal_extras&t=$TOKEN" > /dev/null
contiene "Pedido vacío: error claro" "$TMP/pag.html" "Elige al menos un extra"
r=$(post_portal "r=portal_extras&t=$TOKEN" --data-urlencode "accion=pedir" --data-urlencode "cant[$P_HORA]=2" --data-urlencode "cant[$P_LOCA]=1" --data-urlencode "nota=Para bailar hasta tarde")
check "Pedido enviado" "302 $BASE/?r=portal_extras&t=$TOKEN#mis-pedidos" "$r"
PED=$(sql "SELECT id FROM extras_pedidos WHERE evento_id = $EV ORDER BY id DESC LIMIT 1")
check "Pedido pendiente por 667" "pendiente|667.00" "$(sql "SELECT estado || '|' || total FROM extras_pedidos WHERE id = $PED")"
get "r=portal_extras&t=$TOKEN" > /dev/null
contiene "El cliente ve que espera respuesta" "$TMP/pag.html" "Esperando respuesta"
contiene "Aviso de enviado" "$TMP/pag.html" "Enviamos tu pedido"
check "Aviso al local del pedido" "1" "$(sql "SELECT count(DISTINCT texto) FROM notificaciones WHERE negocio_id = $NID1 AND texto LIKE '🛍️ %Hora adicional ×2%'")"
get "r=portal&t=$TOKEN" > /dev/null
contiene "El portal muestra el pedido esperando" "$TMP/pag.html" "1 pedido esperando respuesta"

echo "7. El local aprueba: se suma a la cotización y al plan de pagos"
TOTAL0=$(sql "SELECT total FROM eventos WHERE id = $EV")
NCUOTAS0=$(sql "SELECT count(*) FROM cuotas WHERE evento_id = $EV")
get "r=extras" > /dev/null
contiene "Pendiente en la lista del negocio" "$TMP/pag.html" "Pedidos por responder"
get "r=evento_formulario&id=$EV" > /dev/null
contiene "El evento muestra el pedido" "$TMP/pag.html" "Extras que pidió el cliente"
contiene "Nota del cliente" "$TMP/pag.html" "Para bailar hasta tarde"
contiene "Botón aprobar" "$TMP/pag.html" "Aprobar y sumar al evento"
r=$(post_desde "r=evento_formulario&id=$EV" "r=evento_formulario&id=$EV" --data-urlencode "accion=aprobar" --data-urlencode "pedido_id=$PED" --data-urlencode "nota=¡Listo! Los zanqueros llegan 23:00")
check "Aprobar vuelve a los extras" "302 $BASE/?r=evento_formulario&id=$EV#extras" "$r"
check "Pedido aprobado" "aprobado" "$(sql "SELECT estado FROM extras_pedidos WHERE id = $PED")"
check "El total del evento sube 667" "$(sql "SELECT $TOTAL0 + 667")" "$(sql "SELECT total FROM eventos WHERE id = $EV")"
check "Una cuota más" "$((NCUOTAS0+1))" "$(sql "SELECT count(*) FROM cuotas WHERE evento_id = $EV")"
check "Cuota de extras por 667" "Extras: Hora adicional, Hora loca|667.00" "$(sql "SELECT concepto || '|' || monto FROM cuotas WHERE evento_id = $EV ORDER BY numero DESC LIMIT 1")"
check "Las cuotas suman el total" "$(sql "SELECT total FROM eventos WHERE id = $EV")" "$(sql "SELECT sum(monto) FROM cuotas WHERE evento_id = $EV")"
check "Versión nueva aceptada" "1|2" "$(sql "SELECT count(*) FILTER (WHERE estado = 'aceptada') || '|' || max(version) FROM cotizaciones WHERE evento_id = $EV")"
check "La anterior queda reemplazada" "reemplazada" "$(sql "SELECT estado FROM cotizaciones WHERE id = $COT")"
get "r=evento_formulario&id=$EV" > /dev/null
contiene "Aviso del aprobado" "$TMP/pag.html" "Extras aprobados: el evento sube \$667,00"
contiene "Botón para avisar al cliente" "$TMP/pag.html" "Avisar al cliente por WhatsApp"
get "r=evento_pagos&id=$EV" > /dev/null
contiene "Pagos: la cuota de extras" "$TMP/pag.html" "Extras: Hora adicional, Hora loca"
get "r=evento&id=$EV" > /dev/null
contiene "Resumen: cotización en versión 2" "$TMP/pag.html" "versión 2"
r=$(post_desde "r=evento_formulario&id=$EV" "r=evento_formulario&id=$EV" --data-urlencode "accion=aprobar" --data-urlencode "pedido_id=$PED")
get "r=evento_formulario&id=$EV" > /dev/null
contiene "Aprobar dos veces: bloqueado" "$TMP/pag.html" "Este pedido ya fue aprobado."
check "No suma dos veces" "$(sql "SELECT $TOTAL0 + 667")" "$(sql "SELECT total FROM eventos WHERE id = $EV")"
get "r=portal&t=$TOKEN" > /dev/null
contiene "Portal: el plan de pagos con los extras" "$TMP/pag.html" "Extras: Hora adicional, Hora loca"
get "r=portal_extras&t=$TOKEN" > /dev/null
contiene "Portal: aprobado" "$TMP/pag.html" "Aprobado"
contiene "Portal: lo que se sumó" "$TMP/pag.html" "Se sumaron <strong>\$667,00</strong>"
contiene "Portal: nota del local" "$TMP/pag.html" "Los zanqueros llegan 23:00"

echo "8. Rechazar y cancelar"
r=$(post_portal "r=portal_extras&t=$TOKEN" --data-urlencode "accion=pedir" --data-urlencode "cant[$P_HORA]=3")
PED2=$(sql "SELECT id FROM extras_pedidos WHERE evento_id = $EV ORDER BY id DESC LIMIT 1")
r=$(post_desde "r=evento_formulario&id=$EV" "r=evento_formulario&id=$EV" --data-urlencode "accion=rechazar" --data-urlencode "pedido_id=$PED2" --data-urlencode "nota=")
get "r=evento_formulario&id=$EV" > /dev/null
contiene "Rechazar sin nota: error" "$TMP/pag.html" "Escribe una nota para el cliente"
r=$(post_desde "r=evento_formulario&id=$EV" "r=evento_formulario&id=$EV" --data-urlencode "accion=rechazar" --data-urlencode "pedido_id=$PED2" --data-urlencode "nota=La ordenanza no permite pasar de las 02:00")
check "Pedido rechazado" "rechazado" "$(sql "SELECT estado FROM extras_pedidos WHERE id = $PED2")"
get "r=portal_extras&t=$TOKEN" > /dev/null
contiene "Portal: no aprobado con la nota" "$TMP/pag.html" "La ordenanza no permite"
r=$(post_portal "r=portal_extras&t=$TOKEN" --data-urlencode "accion=pedir" --data-urlencode "cant[$P_LOCA]=1")
PED3=$(sql "SELECT id FROM extras_pedidos WHERE evento_id = $EV ORDER BY id DESC LIMIT 1")
r=$(post_portal "r=portal_extras&t=$TOKEN" --data-urlencode "accion=cancelar" --data-urlencode "pedido_id=$PED3")
check "El cliente cancela" "cancelado" "$(sql "SELECT estado FROM extras_pedidos WHERE id = $PED3")"
EVS=$(crear_evento_sql "$(date -d "+60 days" +%F)" separado)
TOKS=$(sql "SELECT token_cliente FROM eventos WHERE id = $EVS")
get "r=portal_extras&t=$TOKS" > /dev/null
contiene "Sin cotización aceptada: lo explica" "$TMP/pag.html" "cuando aceptes tu cotización"
r=$(post_portal "r=portal_extras&t=$TOKS" --data-urlencode "accion=cancelar" --data-urlencode "pedido_id=$PED")
check "Un evento no cancela pedidos de otro" "aprobado" "$(sql "SELECT estado FROM extras_pedidos WHERE id = $PED")"

echo "9. Encuesta de satisfacción"
sql "UPDATE eventos SET fecha = CURRENT_DATE - 1, estado = 'realizado' WHERE id = $EV" > /dev/null
sql "UPDATE evento_espacios SET periodo = tsrange((CURRENT_DATE - 1) + time '15:00', (CURRENT_DATE - 1) + time '23:59') WHERE evento_id = $EV" > /dev/null
TOKE=$(sql "SELECT token_encuesta FROM eventos WHERE id = $EV")
get "r=mensajes" > /dev/null
contiene "La reseña lleva el enlace de la encuesta" "$TMP/pag.html" "r%3Dencuesta%26t%3D$TOKE"
get "r=portal&t=$TOKEN" > /dev/null
contiene "Portal después del evento: pide la opinión" "$TMP/pag.html" "Dar mi opinión"
check "Encuesta" "200" "$(get "r=encuesta&t=$TOKE")"
contiene "Pregunta del NPS" "$TMP/pag.html" "qué tanto nos recomendarías"
contiene "Estrellas de la comida" "$TMP/pag.html" "La comida"
contiene "Campo trampa" "$TMP/pag.html" 'name="sitio_web"'
check "Encuesta con enlace falso: 404" "404" "$(get "r=encuesta&t=$(printf 'cd%.0s' {1..24})")"
check "El enlace del portal no abre la encuesta" "404" "$(get "r=encuesta&t=$TOKEN")"
r=$(post_desde "r=encuesta&t=$TOKE" "r=encuesta&t=$TOKE" --data-urlencode "comida=5")
get "r=encuesta&t=$TOKE" > /dev/null
contiene "Sin NPS: error" "$TMP/pag.html" "Elige del 0 al 10"
contiene "No pierde las estrellas" "$TMP/pag.html" 'value="5" checked'
sql "UPDATE negocios SET resenas_url = 'https://g.page/r/quinta-portal/review' WHERE id = $NID1" > /dev/null
r=$(post_desde "r=encuesta&t=$TOKE" "r=encuesta&t=$TOKE" --data-urlencode "nps=10" --data-urlencode "comida=5" --data-urlencode "atencion=5" \
     --data-urlencode "instalaciones=4" --data-urlencode "organizacion=5" --data-urlencode "comentario=¡La mejor noche de nuestras vidas!")
check "Enviar la encuesta" "302 $BASE/?r=encuesta&t=$TOKE" "$r"
check "Respuesta guardada" "10|5" "$(sql "SELECT nps || '|' || comida FROM encuestas WHERE evento_id = $EV")"
get "r=encuesta&t=$TOKE" > /dev/null
contiene "Gracias" "$TMP/pag.html" "¡Gracias,"
contiene "NPS 10 + enlace: botón de Google" "$TMP/pag.html" "Dejar mi reseña en Google"
contiene "Lleva al enlace de reseñas" "$TMP/pag.html" "g.page/r/quinta-portal/review"
r=$(post_desde "r=encuesta&t=$TOKE" "r=encuesta&t=$TOKE" --data-urlencode "nps=0")
check "Una sola respuesta" "10" "$(sql "SELECT nps FROM encuestas WHERE evento_id = $EV")"
get "r=portal&t=$TOKEN" > /dev/null
contiene "Portal: gracias por tu opinión" "$TMP/pag.html" "¡Gracias por tu opinión!"
get "r=evento_formulario&id=$EV" > /dev/null
contiene "El evento muestra la opinión" "$TMP/pag.html" "Nos recomendaría"
contiene "Con el comentario" "$TMP/pag.html" "La mejor noche de nuestras vidas"
# Nota baja: aviso al dueño
EV2=$(crear_evento_sql "$(date -d "-3 days" +%F)" realizado)
TOKE2=$(sql "SELECT token_encuesta FROM eventos WHERE id = $EV2")
r=$(post_desde "r=encuesta&t=$TOKE2" "r=encuesta&t=$TOKE2" --data-urlencode "nps=3" --data-urlencode "comida=2" --data-urlencode "comentario=El DJ llegó tarde")
check "Nota baja: aviso al dueño" "1" "$(sql "SELECT count(*) FROM notificaciones WHERE negocio_id = $NID1 AND texto LIKE '⚠️ Opinión baja%El DJ llegó tarde%'")"
get "r=encuesta&t=$TOKE2" > /dev/null
no_contiene "Nota baja: sin botón de Google" "$TMP/pag.html" "Dejar mi reseña en Google"
contiene "Nota baja: mensaje de disculpa" "$TMP/pag.html" "se comunicará contigo"
EVF=$(crear_evento_sql "$(date -d "+30 days" +%F)" confirmado)
get "r=encuesta&t=$(sql "SELECT token_encuesta FROM eventos WHERE id = $EVF")" > /dev/null
contiene "Evento futuro: todavía no abre" "$TMP/pag.html" "se abre el día de tu evento"

echo "10. Reporte de satisfacción"
check "Reportes" "200" "$(get "r=reportes&p=rango&desde=$(date -d '-10 days' +%F)&hasta=$(date +%F)")"
contiene "Sección de satisfacción" "$TMP/pag.html" "Satisfacción de los clientes"
contiene "NPS 0 (1 promotor y 1 detractor)" "$TMP/pag.html" "<strong>0</strong><span>NPS · 2 encuestas"
contiene "Comentarios en el reporte" "$TMP/pag.html" "El DJ llegó tarde"
contiene "Índice con satisfacción" "$TMP/pag.html" 'href="#satisfaccion"'
check "Reporte del año" "200" "$(get "r=reportes&p=anio")"

echo "11. Permisos por rol"
HASH=$(php -r 'echo password_hash("claveSegura1", PASSWORD_DEFAULT);')
sql "INSERT INTO usuarios (negocio_id, nombre, email, password_hash, rol) VALUES ($NID1, 'Coord Portal', 'coord70$NID1@prueba.ec', '$HASH', 'coordinador'),
     ($NID1, 'Vende Portal', 'vend70$NID1@prueba.ec', '$HASH', 'vendedor'), ($NID1, 'Mira Portal', 'cons70$NID1@prueba.ec', '$HASH', 'consulta')" > /dev/null
r=$(post_portal "r=portal_extras&t=$TOKS" --data-urlencode "accion=pedir" --data-urlencode "cant[$P_HORA]=1")
EVA=$(crear_evento_sql "$(date -d "+50 days" +%F)" separado)
aceptar_cot "$EVA" > /dev/null
TOKA=$(sql "SELECT token_cliente FROM eventos WHERE id = $EVA")
r=$(post_portal "r=portal_extras&t=$TOKA" --data-urlencode "accion=pedir" --data-urlencode "cant[$P_HORA]=1")
PEDA=$(sql "SELECT id FROM extras_pedidos WHERE evento_id = $EVA")
entrar "coord70$NID1@prueba.ec" "claveSegura1"
check "Coordinador ve el formulario" "200" "$(get "r=evento_formulario&id=$EV")"
no_contiene "Coordinador: la pestaña se llama solo Formulario" "$TMP/pag.html" "Formulario y extras"
contiene "Coordinador: ve las respuestas" "$TMP/pag.html" "Thinking out loud"
no_contiene "Coordinador: no ve los extras (dinero)" "$TMP/pag.html" "Extras que pidió el cliente"
no_contiene "Coordinador: sin campos para cambiar" "$TMP/pag.html" "Guardar respuestas"
r=$(post_desde "r=mi_cuenta" "r=evento_formulario&id=$EV" --data-urlencode "accion=respuestas" --data-urlencode "en[]=$P_BAILE" --data-urlencode "r[$P_BAILE]=Hack")
check "Coordinador no cambia respuestas (403)" "403" "${r%% *}"
check "Coordinador no entra a extras" "302" "$(get "r=extras")"
check "Coordinador no entra a plantillas" "302" "$(get "r=cuestionarios")"
check "Coordinador: PDF del formulario" "200 application/pdf" "$(pdf_get70 "r=pdf&tipo=formulario&id=$EV")"
entrar "vend70$NID1@prueba.ec" "claveSegura1"
check "Vendedor no cambia plantillas (403)" "403" "$(get "r=cuestionarios")"
check "Vendedor ve extras" "200" "$(get "r=extras")"
r=$(post_desde "r=evento_formulario&id=$EVA" "r=evento_formulario&id=$EVA" --data-urlencode "accion=aprobar" --data-urlencode "pedido_id=$PEDA")
check "Vendedor aprueba extras" "aprobado" "$(sql "SELECT estado FROM extras_pedidos WHERE id = $PEDA")"
check "Queda quién aprobó" "Vende Portal" "$(sql "SELECT u.nombre FROM extras_pedidos x JOIN usuarios u ON u.id = x.respondido_por WHERE x.id = $PEDA")"
entrar "cons70$NID1@prueba.ec" "claveSegura1"
check "Consulta mira las plantillas" "200" "$(get "r=cuestionarios")"
no_contiene "Consulta: sin agregar preguntas" "$TMP/pag.html" "Agregar una pregunta"
r=$(post_desde "r=mi_cuenta" "r=cuestionarios" --data-urlencode "accion=ajustes" --data-urlencode "dias_cierre=1" --data-urlencode "dias_aviso=2")
check "Consulta no cambia plantillas (403)" "403" "${r%% *}"
check "Consulta mira el formulario del evento" "200" "$(get "r=evento_formulario&id=$EV")"
no_contiene "Consulta: sin botón aprobar" "$TMP/pag.html" "Aprobar y sumar al evento"
r=$(post_desde "r=mi_cuenta" "r=evento_formulario&id=$EV" --data-urlencode "accion=respuestas" --data-urlencode "en[]=$P_BAILE" --data-urlencode "r[$P_BAILE]=Hack")
check "Consulta no cambia respuestas (403)" "403" "${r%% *}"
check "Respuesta intacta" "Thinking out loud" "$(sql "SELECT respuesta FROM evento_preguntas WHERE id = $P_BAILE")"

echo "12. Un negocio nunca ve lo de otro; plan Salón"
registrar salon "Salón Ajeno $RANDOM"
NID2=$NID
check "Otro negocio: el formulario de mi evento no existe (404)" "404" "$(get "r=evento_formulario&id=$EV")"
no_contiene "Otro negocio: no ve las respuestas" "$TMP/pag.html" "Thinking out loud"
EVB=$(crear_evento_sql "$(date -d "+45 days" +%F)" separado)
r=$(post_desde "r=evento_formulario&id=$EVB" "r=evento_formulario&id=$EVB" --data-urlencode "accion=aprobar" --data-urlencode "pedido_id=$PED2")
get "r=evento_formulario&id=$EVB" > /dev/null
contiene "Otro negocio no responde mis pedidos" "$TMP/pag.html" "No se encontró ese pedido"
check "Mi pedido sigue igual" "rechazado" "$(sql "SELECT estado FROM extras_pedidos WHERE id = $PED2")"
check "Otro negocio no ve mis fotos" "404" "$(curl -s -b "$JAR" -o /dev/null -w '%{http_code}' "$BASE/?r=extras&foto=$P_LOCA")"
get "r=extras" > /dev/null
no_contiene "Otro negocio no ve mis pedidos" "$TMP/pag.html" "Para bailar hasta tarde"
get "r=reportes" > /dev/null
no_contiene "Otro negocio no ve mis comentarios" "$TMP/pag.html" "El DJ llegó tarde"
TOKB=$(sql "SELECT token_cliente FROM eventos WHERE id = $EVB")
get "r=portal&t=$TOKB" > /dev/null
contiene "Plan Salón: también tiene el formulario" "$TMP/pag.html" "Formulario de tu evento"
check "Plan Salón: formulario en el portal" "200" "$(get "r=portal_cuestionario&t=$TOKB")"
contiene "Plan Salón: con preguntas" "$TMP/pag.html" "data-pt-autoguardar"
check "Plan Salón: plantillas propias" "9" "$(sql "SELECT count(*) FROM cuestionario_plantillas WHERE negocio_id = $NID2")"
