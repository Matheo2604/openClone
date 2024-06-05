<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Open Clone</title>
    <link rel="stylesheet" type="text/css" href="style5.css?t=<? echo time(); ?>" />
</head>
<body>
<nav>
    <h1>Open Clone</h1>
    <div class="onglets">
    <a href="creerClasse.php">Créer Postes</a>
            <a href="creerClasse1.php">Créer Classes</a>
            <a href="listerClasses.php">Afficher Postes</a>
            <a href="listerClasses1.php">Afficher Classes</a>
            <a href="demarrage.php">Démarrage</a>
            <a href="afficherPostesParClasse.php">Afficher Postes par Classe</a>
            <a href="index.php">Accueil</a>
    </div>
</nav>

<main class="main-content">
<?php
session_start();
// Inclure le fichier de connexion
require "param-baseLycee.php";

// Vérifier la connexion
if (!$conn) {
    die("Erreur de connexion : " . mysqli_connect_error());
}

// Si le formulaire est soumis, vérifier et supprimer la classe
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['id_poste'])) {
    // Récupérer l'ID de la classe à supprimer
    $id_poste = $_POST['id_poste'];

    // Préparer la requête de suppression
    $sql = "DELETE FROM donne_pc WHERE id = $id_poste";

    // Exécuter la requête de suppression
    if (mysqli_query($conn, $sql)) {
        echo "La classe avec l'ID $id_poste a été supprimée avec succès.";
    } else {
        echo "Erreur lors de la suppression de la classe : " . mysqli_error($conn);
    }
}

// Requête SQL pour récupérer les données
$reqSQL = "SELECT id, address_mac, address_ip, hostname FROM donne_pc ORDER BY id";
$resultat = mysqli_query($conn, $reqSQL);

// Vérifier si la requête a réussi
if (!$resultat) {
    die("Erreur de requête : " . mysqli_error($conn));
}
?>

    <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Adresse MAC</th>
                    <th>Adresse IP</th>
                    <th>Nom</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <?php while ($row = mysqli_fetch_assoc($resultat)): ?>
                <tr>
                    <td><?php echo $row['id']; ?></td>
                    <td><?php echo $row['address_mac']; ?></td>
                    <td><?php echo $row['address_ip']; ?></td>
                    <td><?php echo $row['hostname']; ?></td>
                    <td>
                        <!-- Formulaire pour le bouton de suppression -->
                        <form method="POST" action="">
                            <!-- Champ caché pour transmettre l'ID de la classe à supprimer -->
                            <input type="hidden" name="id_poste" value="<?php echo $row['id']; ?>">
                            <button type="submit">Supprimer</button>
                        </form>
                    </td>
                </tr>
                <?php endwhile; ?>
            </tbody>
        </table>
    </div>

<?php
// Fermer la connexion
mysqli_close($conn);
?>
</main>

<footer>
    <h5>POINT INFORMATION</h5>
    <div class="colonnes">
        <div class="colonne">
            <p>Contact</p>
            <p>E-mail</p>
            <p>Téléphone</p>
            <p>Adresse</p>
        </div>
        <div class="colonne">
            <p>Open Clone</p>
            <p>email</p>
            <p>66-60-66-60-66</p>
            <p>41 rue de chez-toi 22300 Lannion</p>
        </div>
        <div class="colonne">
            <p>Nos partenaires</p>
            <p>Lycée FLD</p>
            <p>Partenaires2</p>
            <p>Netto</p>
        </div>
    </div>
    <p>Alex</p>
</footer>
</body>
</html>
