<?php
header('Content-Type: application/json');

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

// Bump score
$pdo->exec("UPDATE score SET count = count + 1 WHERE id = 1");

// Get new score
$stmt = $pdo->query("SELECT count FROM score WHERE id = 1");
$newScore = (int)$stmt->fetchColumn();

// Return JSON
echo json_encode(['score' => $newScore]);
