#!/usr/bin/php -q
<?php
$installationVersion = '3.3';
$p = getenv('PROTOCOL');
$d = getenv('DOMAIN');
$dbh = getenv('DB_HOST');
$dbu = getenv('DB_USER');
$dbp = getenv('DB_PASSWORD');
$ap = getenv('ADMIN_PASSWORD');
$t = getenv('SITE_TITLE');
$l = getenv('LANG');
$en = getenv('ENCODER');

$conn = new mysqli($dbh, $dbu, $dbp, 'youPHPTubeEncoder');
if ($conn->connect_error) {
    $conn = new mysqli($dbh, $dbu, $dbp);
    $sql = 'CREATE DATABASE IF NOT EXISTS youPHPTubeEncoder CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;';
    $conn->query($sql);
    $conn->select_db('youPHPTubeEncoder');
    $conn->query(file_get_contents('/var/www/html/install/database.sql'));
    $sql = "INSERT INTO streamers (siteURL, user, pass, priority, created, modified, isAdmin) VALUES ('$p://$d/', 'admin', '$ap', 1, now(), now(), 1)";
    $conn->query($sql);
    $sql = "INSERT INTO configurations (id, allowedStreamersURL, defaultPriority, version, created, modified) VALUES (1, '$p://$d/', '1', '$installationVersion', now(), now())";
    $conn->query($sql);
}
$conn->close();

$file = '/var/www/html/videos/configuration.php';
if (!file_exists($file)) {
    $content = "<?php
\$global['configurationVersion'] = 2;
\$global['webSiteRootURL'] = '$p://$d/';
\$global['systemRootPath'] = '/var/www/html';
\$global['webSiteRootPath'] = '$d';
\$global['disableConfigurations'] = false;
\$global['disableBulkEncode'] = false;
\$global['disableImportVideo'] = false;
\$global['disableWebM'] = false;

\$mysqlHost = '$dbh';
\$mysqlPort = '3306';
\$mysqlUser = '$dbu';
\$mysqlPass = '$dbp';
\$mysqlDatabase = 'youPHPTubeEncoder';
\$global['allowed'] = array('mp4', 'avi', 'mov', 'flv', 'mp3', 'wav', 'm4v', 'webm', 'wmv', 'mpg', 'mpeg', 'f4v', 'm4v', 'm4a', 'm2p', 'rm', 'vob', 'mkv', '3gp');
/**
 * Do NOT change from here
 */
require_once \$global['systemRootPath'].'objects/include_config.php';
";
    $fp = fopen($file, 'wb');
    fwrite($fp, $content);
    fclose($fp);
}
