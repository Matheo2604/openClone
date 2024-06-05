<?php
// Afficher toutes les erreurs PHP (à désactiver en production)
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Vérifier si le formulaire a été soumis
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Vérifier si les champs requis sont vides
    if (empty($_POST['address_mac']) || empty($_POST['Host']) || empty($_POST['Ip']) || empty($_POST['classe'])) {
        $message = "Au moins un des champs est vide.";
    } else {
        require "param-baseLycee.php"; // Inclusion du fichier une seule fois
        
        // Connexion à la base de données
        $conn = mysqli_connect($servername, $username, $password, $dbname);

        // Vérifier la connexion
        if (!$conn) {
            die("Erreur de connexion : " . mysqli_connect_error());
        }

        // Préparer la requête d'insertion pour la table `donne_pc`
        $reqSQL = "INSERT INTO donne_pc (address_mac, address_ip, hostname, classe) VALUES (?, ?, ?, ?)";
        $stmt = mysqli_prepare($conn, $reqSQL);

        // Vérifier si la préparation a réussi
        if (!$stmt) {
            die("Erreur de préparation de la requête : " . mysqli_error($conn));
        }

        // Liaison des paramètres et exécution de la requête
        mysqli_stmt_bind_param($stmt, "ssss", $_POST['address_mac'], $_POST['Ip'], $_POST['Host'], $_POST['classe']);
        if (mysqli_stmt_execute($stmt)) {
            $message = "Poste créé avec succès.";

            // Mettre à jour la table classes avec les informations du poste
            $reqSQL_update = "UPDATE classes SET last_host=?, last_ip=? WHERE nom_de_classe=?";
            $stmt_update = mysqli_prepare($conn, $reqSQL_update);
            mysqli_stmt_bind_param($stmt_update, "sss", $_POST['Host'], $_POST['Ip'], $_POST['classe']);
            if (!mysqli_stmt_execute($stmt_update)) {
                $message = "Erreur lors de la mise à jour de la classe : " . mysqli_error($conn);
            }
            mysqli_stmt_close($stmt_update);

        } else {
            $message = "Erreur lors de la création du poste : " . mysqli_error($conn);
        }

        // Fermer la connexion
        mysqli_stmt_close($stmt);
        mysqli_close($conn);
    }
}

// Connexion à la base de données pour récupérer les classes
require "param-baseLycee.php";
$conn = mysqli_connect($servername, $username, $password, $dbname);

if (!$conn) {
    die("Erreur de connexion : " . mysqli_connect_error());
}

$reqSQL = "SELECT id, nom_de_classe FROM classes ORDER BY nom_de_classe";
$resultat = mysqli_query($conn, $reqSQL);

if (!$resultat) {
    die("Erreur de requête : " . mysqli_error($conn));
}
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Open Clone</title>
    <link rel="stylesheet" type="text/css" href="style6.css?t=<?php echo time(); ?>" />
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
    <div class="container">
        <h1>Créer un nouveau poste</h1>
        <h2>Nouveau poste</h2>
        <form method="POST" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>">
            <label for="address_mac">Mac :</label>
            <input type="text" id="address_mac" name="address_mac"><br>
            <label for="Host">Host :</label>
            <input type="text" id="Host" name="Host"><br>
            <label for="Ip">Ip :</label>
            <input type="text" id="Ip" name="Ip"><br>
            <label for="classe">Classe :</label>
            <select id="classe" name="classe">
                <?php while ($row = mysqli_fetch_assoc($resultat)): ?>
                    <option value="<?php echo $row['nom_de_classe']; ?>"><?php echo $row['nom_de_classe']; ?></option>
                <?php endwhile; ?>
            </select><br>
            <button type="submit" class="btn-green">Valider</button>
            <button type="reset" class="btn-red">Reset</button>
            <?php if (isset($message)) echo "<p>$message</p>"; ?>
        </form>
    </div>
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
            <p>mail</p>
            <p>0101010101</p>
        </div>
        <div class="colonne">
            <p>Nos partenaires</p>
            <p>Lycée FLD</p>
            <p>Partenaires 2</p>
            <p>Netto</p>
        </div>
    </div>
    <p>Alex Favrel</p>
</footer>
</body>
</html>
<?php
mysqli_close($conn);
?>

