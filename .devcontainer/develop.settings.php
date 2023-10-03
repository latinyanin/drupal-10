<?php

/**
 * @file
 * Drupal site-specific configuration file.
 */

use Drupal\Core\Installer\InstallerKernel;

/*
 * MySQL now supports a new collation, utf8mb4_0900_as_ci,
 * for the utf8mb4 Unicode character set. This collation is accent
 * sensitive and case insensitive. It is similar to the default
 * utf8mb4 collation (utf8mb4_0900_ai_ci) except that the
 * default collation is accent insensitive.
 *
 * See Character Set Support
 * https://dev.mysql.com/doc/relnotes/mysql/8.0/en/news-8-0-2.html
 */
$databases = [
  "default" => [
    "default" => [
      "database" => $_ENV['MYSQL_DATABASE'],
      "username" => $_ENV['MYSQL_USER'],
      "password" => $_ENV['MYSQL_PASSWORD'],
      "host" => "db",
      "port" => "3306",
      "driver" => "mysql",
      "prefix" => "",
      'charset' => 'utf8mb4',
      'collation' => 'utf8mb4_0900_as_ci',
    ],
  ],
];
$settings["file_temp_path"] = '/tmp';
$settings['config_sync_directory'] = '../config';
$settings['file_public_path'] = 'sites/default/files';
$settings['file_private_path'] = __DIR__ . '/files/private';
$settings['trusted_host_patterns'] = [];
$settings["hash_salt"] = '6b753fa4518648ca489b4e463af1a445';
$settings['container_yamls'][] = $app_root . '/' . $site_path . '/services.yml';
$config['smtp.settings']['smtp_on'] = TRUE;
$config['smtp.settings']['smtp_host'] = 'mailhog';
$config['smtp.settings']['smtp_port'] = '1025';
$config['smtp.settings']['smtp_username'] = '';
$config['smtp.settings']['smtp_password'] = '';
$config['smtp.settings']['smtp_protocol'] = 'standard';
$config['smtp.settings']['smtp_autotls'] = FALSE;
$config['smtp.settings']['smtp_timeout'] = 30;
$config['smtp.settings']['smtp_allowhtml'] = 1;

if (extension_loaded('redis') && !InstallerKernel::installationAttempted()) {
  $settings['redis.connection']['interface'] = 'PhpRedis';
  $settings['redis.connection']['host'] = 'redis';
  $settings['cache']['default'] = 'cache.backend.redis';
  $settings['redis.connection']['port'] = '6379';
  $settings['container_yamls'][] = 'modules/contrib/redis/example.services.yml';
}
if (file_exists(__DIR__ . '/settings.local.php')) {
  include __DIR__ . '/settings.local.php';
}
