<?php
use TuEvento\DiaEvento;

/** Proveedores: DJ, fotógrafos, floristas, catering... ?id=<proveedor> para editar. */
$nid = (int) $u['negocio_id'];
$dia = new DiaEvento(db());
$verId = (int) ($_GET['id'] ?? 0);

if (es_post()) {
    verificar_csrf();
    exigir(puede_editar($u), 'Tu usuario solo puede mirar.');
    $accion = (string) ($_POST['accion'] ?? '');
    $pid = (int) ($_POST['proveedor_id'] ?? 0);
    try {
        $datos = ['nombre' => campo('nombre'), 'servicio' => campo('servicio', 'otros'), 'contacto' => campo('contacto'),
                  'telefono' => campo('telefono'), 'email' => campo('email'), 'notas' => campo('notas')];
        if ($accion === 'crear') {
            $pid = $dia->guardarProveedor($nid, null, $datos);
            aviso("Listo, {$datos['nombre']} está en tus proveedores.");
            redirigir('proveedores');
        } elseif ($accion === 'editar') {
            $dia->guardarProveedor($nid, $pid, $datos + ['activo' => !empty($_POST['activo'])]);
            aviso('Cambios guardados.');
            redirigir('proveedores');
        }
        throw new RuntimeException('Acción no válida.');
    } catch (RuntimeException $e) {
        aviso($e->getMessage(), 'error');
        $_SESSION['form_proveedor'] = $_POST;
        redirigir('proveedores', $pid ? ['id' => $pid] : []);
    }
}

$previo = $_SESSION['form_proveedor'] ?? null;
unset($_SESSION['form_proveedor']);
$proveedor = $verId ? $dia->proveedor($nid, $verId) : null;
if ($verId && !$proveedor) {
    http_response_code(404);
    vista('error', ['mensaje' => 'No se encontró ese proveedor.'], 'Proveedores · TuEvento');
    return;
}
$lista = $dia->proveedores($nid);
vista('proveedores', compact('lista', 'proveedor', 'previo'), 'Proveedores · TuEvento');
