<?php
/**
 * País (Ecuador por defecto) y ciudad del cliente, para la factura con TuFactura (módulo «facturacion»; si está apagado no se muestra).
 * Con cédula o RUC ecuatoriano válido siempre se factura con IVA; con otro país y sin cédula/RUC válido, la factura y el cobro Plux salen sin IVA.
 * Variables: $pcPais, $pcCiudad (valores), $pcPrefijo ('' o 'cliente_': nombres de los campos).
 */
$pcPrefijo ??= '';
$pcSel = (string) ($pcPais ?? '') ?: TuEvento\FacturaTukan::PAIS_DEFECTO;
$pcLista = TuEvento\FacturaTukan::paises();
if (!in_array($pcSel, $pcLista, true)) $pcLista[] = $pcSel;
?>
<div class="campo tk-campo">
    <label for="<?= e($pcPrefijo) ?>pais"><strong>País</strong> <small>(para la factura)</small></label>
    <select id="<?= e($pcPrefijo) ?>pais" name="<?= e($pcPrefijo) ?>pais"><?php foreach ($pcLista as $p): ?><option value="<?= e($p) ?>" <?= $p === $pcSel ? 'selected' : '' ?>><?= e($p) ?></option><?php endforeach; ?></select>
</div>
<div class="campo tk-campo">
    <label for="<?= e($pcPrefijo) ?>ciudad">Ciudad <small>(opcional)</small></label>
    <input type="text" id="<?= e($pcPrefijo) ?>ciudad" name="<?= e($pcPrefijo) ?>ciudad" maxlength="80" value="<?= e((string) ($pcCiudad ?? '')) ?>">
</div>
<p class="suave ayuda-chica"><small>Con cédula o RUC ecuatoriano válido siempre se factura con IVA; con otro país y sin cédula/RUC válido, la factura y el cobro Plux salen sin IVA.</small></p>
