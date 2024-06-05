<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Exécuter le Script</title>
    <link rel="stylesheet" type="text/css" href="style5.css">
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
            <h1>Exécuter le Script Shell</h1>
            <form action="executerScript.php" method="POST">
                <button type="submit" name="executer">Exécuter le Script</button>
            </form>
            <?php
                if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['executer'])) {
                    $output = shell_exec('/path/to/your/script.sh');
                    echo "<h2>Résultat du script :</h2>";
                    echo "<pre>$output</pre>";
                }
            ?>
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
