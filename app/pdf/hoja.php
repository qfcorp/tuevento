<?php
/** Hoja del evento (orden de servicio para el equipo): /?r=pdf&tipo=hoja&id=<evento>. Recibe $u, $negocio, $id. */
use TuEvento\{DiaEvento, Pdf, PdfDia};

if (!requiere_quinta($u, 'Hoja del evento', 'La hoja del evento junta en un PDF los horarios, el cronograma, el personal, los proveedores, el mobiliario y el menú para todo el equipo.')) return;
$dia = new DiaEvento(db());
$h = $dia->hoja((int) $u['negocio_id'], $id);
$h['enlace_vivo'] = url_completa('vivo', ['t' => $h['evento']['token_vivo']]);
Pdf::enviar(PdfDia::hoja($h), 'hoja-' . $h['evento']['codigo'] . '.pdf');
