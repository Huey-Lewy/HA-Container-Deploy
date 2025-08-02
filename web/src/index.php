<?php
// Load settings
$host = getenv('DB_HOST');
$db   = getenv('DB_NAME');
$user = getenv('DB_USER');
$pw   = trim(file_get_contents(getenv('DB_PASSWORD_FILE')));

// Connect
$dsn = "mysql:host=$host;dbname=$db;charset=utf8mb4";
$opts = [
  PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
  PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
];
$pdo = new PDO($dsn, $user, $pw, $opts);

// Fetch page template
$stmt = $pdo->prepare("SELECT content FROM pages WHERE name = 'index'");
$stmt->execute();
$page = $stmt->fetchColumn();

// Fetch current score
$stmt2 = $pdo->query("SELECT count FROM score WHERE id = 1");
$score = $stmt2->fetchColumn();

// Render HTML
echo str_replace('{{score}}', $score, $page);
