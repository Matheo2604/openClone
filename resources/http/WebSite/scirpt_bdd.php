<?php
// Connexion à la base de données
$serveur = "localhost"; // Adresse du serveur MySQL
$utilisateur = "alex"; // Nom d'utilisateur MySQL
$motDePasse = "felix22"; // Mot de passe MySQL
$baseDeDonnees = "openclone"; // Nom de la base de données
$connexion = new mysqli($serveur, $utilisateur, $motDePasse, $baseDeDonnees);

// Vérification de la connexion
if ($connexion->connect_error) {
    die("La connexion a échoué : " . $connexion->connect_error);
}

// Variables contenant les données à ajouter
$addressmac = "00:0a:cd:21:e3:d5"; // Remplacez ceci par votre adresse MAC
$addressip = "192.168.150.153"; // Remplacez ceci par votre adresse IP
$hostname = "host"; // Remplacez ceci par le nom d'hôte que vous souhaitez ajouter

// Requête SQL pour insérer les données
$sql = "INSERT INTO donne_pc (address_mac, address_ip, hostname) VALUES ('$addressmac', '$addressip', '$hostname')";

// Exécution de la requête
if ($connexion->query($sql) === TRUE) {
    echo "Nouvel enregistrement ajouté avec succès.";
} else {
    echo "Erreur lors de l'ajout de l'enregistrement : " . $connexion->error;
}

// Fermeture de la connexion
$connexion->close();
?>
