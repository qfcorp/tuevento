<?php
declare(strict_types=1);

require dirname(__DIR__) . '/app/bootstrap.php';

/*
 * Rutas de TuEvento: /?r=<ruta>. Cada ruta es un archivo app/paginas/<ruta>.php
 */

// Páginas públicas (sin iniciar sesión): acceso, página del negocio, enlaces secretos del cliente, invitados y personal
$publicas = [
    'login', 'registro', 'privacidad', 'admin_entrar', 'telegram',
    'sitio', 'consulta', 'disponible', 'imagen_publica',      // página pública del negocio
    'cot', 'firmar', 'verificar',                              // cotización, firma y verificación del contrato
    'portal', 'portal_pagar', 'payphone',                      // portal del cliente y pagos
    'invitacion', 'puerta', 'ingreso',                         // invitados: confirmación, control de ingreso con QR
    'vivo', 'staff', 'ical',                                   // cronograma en vivo, portal del personal, calendario externo
];
// Páginas del sistema (con sesión)
$privadas = [
    'inicio', 'calendario', 'eventos', 'evento', 'evento_nuevo', 'evento_editar',
    'cotizacion', 'contrato', 'evento_pagos', 'evento_dia', 'invitados',
    'clientes', 'cliente', 'seguimiento', 'cobros', 'mensajes',
    'catalogo', 'paquetes', 'espacios', 'personal', 'proveedores', 'mobiliario',
    'reportes', 'exportar', 'configuracion', 'usuarios', 'mi_cuenta', 'planes', 'prueba_terminada',
    'notificaciones', 'archivo', 'pdf', 'buscar', 'mas', 'salir',
];
// Lo que puede abrir un coordinador (el día del evento); lo demás lo hace el dueño o el vendedor
$deCoordinador = ['inicio', 'calendario', 'eventos', 'evento', 'evento_dia', 'invitados', 'personal', 'proveedores', 'mobiliario', 'espacios',
                  'mi_cuenta', 'notificaciones', 'archivo', 'pdf', 'buscar', 'mas', 'salir', 'prueba_terminada'];
// Panel del super administrador (Tukán): sesión aparte
$deAdmin = ['admin', 'admin_negocios', 'admin_negocio', 'admin_nuevo', 'admin_planes', 'admin_ver', 'admin_volver', 'admin_salir'];

$ruta = (string) ($_GET['r'] ?? 'inicio');
if (in_array($ruta, $deAdmin, true) && !superadmin()) {
    redirigir('admin_entrar');
}
if (!in_array($ruta, array_merge($publicas, $privadas, $deAdmin), true) || !is_file(RAIZ . "/app/paginas/$ruta.php")) {
    http_response_code(404);
    $ruta = usuario() ? 'inicio' : 'login';
}

if (in_array($ruta, $privadas, true)) {
    $u = requiere_sesion();
    if ($u['rol'] === 'coordinador' && !in_array($ruta, $deCoordinador, true)) {
        redirigir('inicio');
    }
    // Prueba vencida, plan vencido o cuenta suspendida: solo puede ver cómo pagar
    if (!in_array($ruta, ['prueba_terminada', 'salir', 'planes'], true)
        && !planes()->alDia($u) && !(!empty($_SESSION['admin_viendo']) && superadmin())) {
        redirigir('prueba_terminada');
    }
}

try {
    require RAIZ . "/app/paginas/$ruta.php";
} catch (Throwable $e) {
    error_log('TuEvento: ' . $e->getMessage() . ' en ' . $e->getFile() . ':' . $e->getLine());
    if (!headers_sent()) http_response_code(500);
    if (in_array($ruta, ['disponible', 'buscar'], true)) {
        header('Content-Type: application/json');
        echo json_encode(['error' => true]);
    } elseif (in_array($ruta, $publicas, true)) {
        vista_publica('error_publico', ['mensaje' => 'Algo falló al abrir esta página. Intenta de nuevo en un momento.'], 'TuEvento');
    } else {
        vista('error', ['mensaje' => 'Algo falló al procesar esta página. Intenta de nuevo; si sigue pasando, escríbenos por WhatsApp.']);
    }
}
