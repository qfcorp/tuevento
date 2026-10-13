<?php
use TuEvento\{Cotizaciones, WhatsApp};

/** @var array $lista @var ?array $proveedor @var ?array $previo */
$editable = puede_editar($u);
$p = $proveedor;
$v = fn(string $k, $def = '') => e($previo[$k] ?? $p[$k] ?? $def);
$porServicio = [];
foreach ($lista as $x) $porServicio[$x['servicio']][] = $x;
?>
<div class="cabecera">
    <div>
        <h1>Proveedores</h1>
        <p>Tu agenda de DJ, fotógrafos, florerías, pastelerías y más. Los agregas a cada evento con su hora de llegada.</p>
    </div>
    <?php if ($p): ?><a class="boton boton-claro" href="<?= e(url('proveedores')) ?>">Ver todos</a><?php endif; ?>
</div>
<div class="rejilla rejilla-2">
    <section class="bloque">
        <h2>Tus proveedores <small class="suave">(<?= count(array_filter($lista, fn($x) => $x['activo'])) ?> activos)</small></h2>
        <?php if (!$lista): ?>
            <div class="vacio">
                <p><strong>Todavía no tienes proveedores.</strong></p>
                <p>Agrega a los que trabajan contigo seguido (DJ, fotógrafo, florería). Los que trae el cliente se anotan directo en cada evento.</p>
            </div>
        <?php else: ?>
            <?php foreach (Cotizaciones::CATEGORIAS as $cat => $nombreCat): if (empty($porServicio[$cat])) continue; ?>
            <h3 class="dia-subtitulo"><?= e($nombreCat) ?></h3>
            <ul class="filas">
                <?php foreach ($porServicio[$cat] as $x):
                    $wa = WhatsApp::enlace($x['telefono'], 'Hola ' . trim(explode(' ', (string) ($x['contacto'] ?: $x['nombre']))[0]) . ', te escribe ' . $u['negocio'] . '.'); ?>
                <li class="<?= $x['activo'] ? '' : 'dia-inactivo' ?>">
                    <div>
                        <strong><?= e($x['nombre']) ?></strong> <?php if (!$x['activo']): ?><span class="etq etq-cancelada">Inactivo</span><?php endif; ?>
                        <br><small><?= e(implode(' · ', array_filter([$x['contacto'], $x['telefono'], $x['email']]))) ?: 'Sin datos de contacto' ?></small>
                        <?php if ((int) $x['proximos']): ?><br><small><?= (int) $x['proximos'] ?> <?= (int) $x['proximos'] === 1 ? 'evento próximo' : 'eventos próximos' ?></small><?php endif; ?>
                        <?php if ($x['notas']): ?><br><small class="suave"><?= e($x['notas']) ?></small><?php endif; ?>
                    </div>
                    <div class="derecha acciones">
                        <?php if ($wa): ?><a class="boton boton-wa boton-chico" href="<?= e($wa) ?>" target="_blank" rel="noopener" aria-label="WhatsApp a <?= e($x['nombre']) ?>">WhatsApp</a><?php endif; ?>
                        <?php if ($editable): ?><a class="boton boton-claro boton-chico" href="<?= e(url('proveedores', ['id' => $x['id']])) ?>">Editar</a><?php endif; ?>
                    </div>
                </li>
                <?php endforeach; ?>
            </ul>
            <?php endforeach; ?>
        <?php endif; ?>
    </section>
    <?php if ($editable): ?>
    <form method="post" class="bloque" id="form-proveedor">
        <h2><?= $p ? 'Editar ' . e($p['nombre']) : 'Agregar proveedor' ?></h2>
        <?= campo_csrf() ?>
        <input type="hidden" name="accion" value="<?= $p ? 'editar' : 'crear' ?>">
        <?php if ($p): ?><input type="hidden" name="proveedor_id" value="<?= (int) $p['id'] ?>"><?php endif; ?>
        <div class="campo"><label for="pnom">Nombre o empresa</label>
            <input type="text" id="pnom" name="nombre" value="<?= $v('nombre') ?>" required maxlength="150" placeholder="DJ Fiesta Total"></div>
        <div class="fila-campos">
            <div class="campo"><label for="pser">Servicio</label>
                <select id="pser" name="servicio">
                    <?php foreach (Cotizaciones::CATEGORIAS as $k => $t): ?><option value="<?= e($k) ?>" <?= ($previo['servicio'] ?? $p['servicio'] ?? 'musica') === $k ? 'selected' : '' ?>><?= e($t) ?></option><?php endforeach; ?>
                </select></div>
            <div class="campo"><label for="pcon">Persona de contacto</label>
                <input type="text" id="pcon" name="contacto" value="<?= $v('contacto') ?>" maxlength="100"></div>
        </div>
        <div class="fila-campos">
            <div class="campo"><label for="ptel">Celular</label>
                <input type="tel" id="ptel" name="telefono" value="<?= $v('telefono') ?>" placeholder="0991234567"></div>
            <div class="campo"><label for="pmail">Correo <small>(opcional)</small></label>
                <input type="email" id="pmail" name="email" value="<?= $v('email') ?>"></div>
        </div>
        <div class="campo"><label for="pnot">Notas <small>(precios, qué incluye, cuenta bancaria…)</small></label>
            <textarea id="pnot" name="notas" rows="3" maxlength="500"><?= $v('notas') ?></textarea></div>
        <?php if ($p): ?>
            <label class="opcion" style="margin-bottom:14px"><input type="checkbox" name="activo" value="1" <?= $p['activo'] ? 'checked' : '' ?>>
                <span><strong>Activo</strong><small>Desmárcalo si ya no trabajas con este proveedor.</small></span></label>
        <?php endif; ?>
        <button class="boton boton-ancho" type="submit"><?= $p ? 'Guardar cambios' : 'Agregar proveedor' ?></button>
    </form>
    <?php endif; ?>
</div>
