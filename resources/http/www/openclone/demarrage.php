<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Open Clone</title>
    <link rel="stylesheet" href="style6.css">
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

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Démarrage à distance</title>
</head>
<body>
    <h1>Démarrage à distance d'un ordinateur :</h1>
    <form method="post" action="<?php echo $_SERVER['PHP_SELF']; ?>">
        <label for="adresseMAC">Adresse MAC de l'ordinateur :</label>
        <input type="text" id="adresseMAC" name="adresseMAC">
        <button type="submit" name="submit">Démarrer</button>
    </form>

    <?php
if (isset($_POST['submit'])) {
    // Récupérez les paramètres du formulaire et échappez correctement pour éviter l'injection de commandes
    $adresseMAC = escapeshellarg($_POST['adresseMAC']);

    // Chemin vers le script local que vous souhaitez exécuter
    $scriptPath = '/srv/www/site/test.sh';

    // Vérifiez si le script existe et est exécutable
    if (file_exists($scriptPath) && is_executable($scriptPath)) {
        // Construisez la commande avec les paramètres
        $command = escapeshellcmd("$scriptPath $adresseMAC");

        // Exécutez le script en utilisant la fonction shell_exec() pour capturer la sortie
        $result = shell_exec($command);

        // Affichez le résultat ou faites d'autres traitements selon vos besoins
        echo "Résultat de l'exécution du script : " . htmlspecialchars($result);
    } else {
        echo "Le script n'existe pas ou n'est pas exécutable.";
    }
} else {
    echo "Formulaire non soumis.";
}
?>

</body>
</html>



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
