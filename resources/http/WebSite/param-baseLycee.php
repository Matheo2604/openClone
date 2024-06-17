<?php
// Définition des informations de connexion à la base de données
$servername = "localhost";   // Nom du serveur MySQL
$username = "alex";        // Nom d'utilisateur MySQL
$password = "felix22";      // Mot de passe MySQL
$dbname = "openclone"; // Nom de la base de données

// Création de la connexion à la base de données
$conn = mysqli_connect($servername, $username, $password, $dbname);

// Vérification de la connexion
if (!$conn) {
 // Si la connexion a échoué, afficher un message d'erreur et arrêter
    die("Connection failed: " . mysqli_connect_error());
}
?>