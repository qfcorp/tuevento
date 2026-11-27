-- 119 · País y ciudad del cliente (27 nov 2026, pedido de Dimitry). Se puede correr muchas veces.
--   Regla «exterior = sin IVA» de TuFactura: con cédula o RUC ecuatoriano válido siempre hay IVA; con otro país y sin cédula/RUC válido,
--   la factura y el cobro Plux salen sin IVA. El país viene en «Ecuador» por defecto y la ciudad es opcional.
--   No toca las filas que ya existen (solo agrega las columnas).
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS pais   VARCHAR(60) NOT NULL DEFAULT 'Ecuador';
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS ciudad VARCHAR(80);
