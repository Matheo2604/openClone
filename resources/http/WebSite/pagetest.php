<?php
// Inclure le fichier de connexion
require "param-baseLycee.php";

// Vérifier la connexion
if (!$conn) {
    die("Erreur de connexion : " . mysqli_connect_error());
}

// Requête SQL pour récupérer les données
$reqSQL = "SELECT id, address_mac, address_ip, hostname FROM donne_pc ORDER BY id";
$resultat = mysqli_query($conn, $reqSQL);

// Vérifier si la requête a réussi
if (!$resultat) {
    die("Erreur de requête : " . mysqli_error($conn));
}
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Liste des classes</title>
</head>
<body>
    <h1>Liste des classes</h1>
    <table border="1">
        <tr>
            <th>ID</th>
            <th>Adresse MAC</th>
            <th>Adresse IP</th>
            <th>Nom</th>
        </tr>
        <?php while ($row = mysqli_fetch_assoc($resultat)): ?>
        <tr>
            <td><?php echo $row['id']; ?></td>
            <td><?php echo $row['address_mac']; ?></td>
            <td><?php echo $row['address_ip']; ?></td>
            <td><?php echo $row['hostname']; ?></td>
        </tr>
        <?php endwhile; ?>
    </table>
</body>
</html>

<?php
// Fermer la connexion
mysqli_close($conn);
?>
