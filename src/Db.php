<?php
declare(strict_types=1);

namespace TuEvento;

use PDO;

/**
 * Conexión a PostgreSQL. Los datos de acceso vienen de variables de entorno
 * (nunca escritos en el código):
 *   TUEVENTO_DB_HOST, TUEVENTO_DB_PORT, TUEVENTO_DB_NAME, TUEVENTO_DB_USER, TUEVENTO_DB_PASS
 */
final class Db
{
    public static function conectar(): PDO
    {
        $host = getenv('TUEVENTO_DB_HOST') ?: '127.0.0.1';
        $port = getenv('TUEVENTO_DB_PORT') ?: '5432';
        $name = getenv('TUEVENTO_DB_NAME') ?: 'tuevento';
        $user = getenv('TUEVENTO_DB_USER') ?: 'tuevento';
        $pass = getenv('TUEVENTO_DB_PASS') ?: '';

        $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$name", $user, $pass, [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]);
        $pdo->exec("SET TIME ZONE 'America/Guayaquil'");
        return $pdo;
    }
}
