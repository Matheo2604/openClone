<?php
// Inclure le fichier de connexion à la base de données
require "param-baseLycee.php";

// Vérifier si le formulaire a été soumis
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Vérifier si l'ID de la classe à supprimer est défini
    if (isset($_POST['id_classe'])) {
        // Connexion à la base de données
        $conn = mysqli_connect($servername, $username, $password, $dbname);

        // Vérification de la connexion
        if (!$conn) {
            die("Connection failed: " . mysqli_connect_error());
        }

        // Préparer la requête de suppression
        $id_classe = $_POST['id_classe'];
        $sql = "DELETE FROM donne_pc WHERE id = $id_classe";

        // Exécuter la requête de suppression
        if (mysqli_query($conn, $sql)) {
            echo "La classe avec l'ID $id_classe a été supprimée avec succès.";
        } else {
            echo "Erreur lors de la suppression de la classe : " . mysqli_error($conn);
        }

        // Fermer la connexion à la base de données
        mysqli_close($conn);
    } else {
        echo "Veuillez fournir l'ID de la classe à supprimer.";
    }
} else {
    // Rediriger vers la page d'accueil si le formulaire n'a pas été soumis
    header("Location: index.php");
    exit();
}
?>
