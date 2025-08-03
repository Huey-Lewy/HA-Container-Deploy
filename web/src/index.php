<?php
// Load settings
$host = getenv('DB_HOST') ?: 'db';
$db   = getenv('DB_NAME') ?: 'ha_app';
$user = getenv('DB_USER') ?: 'ha_user';
$pw   = getenv('DB_USER_PASSWORD');

// Connect
$dsn  = "mysql:host=$host;dbname=$db;charset=utf8mb4";
$pdo  = new PDO($dsn, $user, $pw, [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
]);

// Fetch page template
$stmt = $pdo->prepare("SELECT content FROM pages WHERE name = 'index'");
$stmt->execute();
$page = $stmt->fetchColumn();

// Fetch current score and render HTML
$score = $pdo->query("SELECT count FROM score WHERE id = 1")->fetchColumn();
echo str_replace('{{score}}', $score, $page);
