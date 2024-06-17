<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Afficher les Postes par Classe</title>
    <link rel="stylesheet" type="text/css" href="style8.css">
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
        <h1>Afficher les Postes par Classe</h1>
        
        <form method="POST">
            <label for="classe">Sélectionnez une classe :</label>
            <select id="classe" name="classe">
                <?php
                require "param-baseLycee.php"; 

                $conn = mysqli_connect($servername, $username, $password, $dbname);
                if (!$conn) {
                    die("Erreur de connexion : " . mysqli_connect_error());
                }

                $sql = "SELECT nom_de_classe FROM classes";
                $result = mysqli_query($conn, $sql);
                if (mysqli_num_rows($result) > 0) {
                    while ($row = mysqli_fetch_assoc($result)) {
                        echo "<option value='" . $row['nom_de_classe'] . "'>" . $row['nom_de_classe'] . "</option>";
                    }
                } else {
                    echo "<option disabled>Aucune classe disponible</option>";
                }

                mysqli_close($conn);
                ?>
            </select>
            <button type="submit">Afficher les Postes</button>
        </form>

        <?php
        if ($_SERVER["REQUEST_METHOD"] == "POST") {
            $selectedClass = $_POST['classe'];

            require "param-baseLycee.php"; 
            $conn = mysqli_connect($servername, $username, $password, $dbname);

            if (!$conn) {
                die("Erreur de connexion : " . mysqli_connect_error());
            }

            $reqSQL = "SELECT * FROM donne_pc WHERE classe = ?";

            $stmt = mysqli_prepare($conn, $reqSQL);

            mysqli_stmt_bind_param($stmt, "s", $selectedClass);
            mysqli_stmt_execute($stmt);

            $result = mysqli_stmt_get_result($stmt);

            echo "<h2>Postes pour la classe $selectedClass :</h2>";
            echo "<table>
                    <tr>
                        <th>Adresse MAC</th>
                        <th>Adresse IP</th>
                        <th>Host</th>
                    </tr>";

            while ($row = mysqli_fetch_assoc($result)) {
                echo "<tr>";
                echo "<td>" . $row['address_mac'] . "</td>";
                echo "<td>" . $row['address_ip'] . "</td>";
                echo "<td>" . $row['hostname'] . "</td>";
                echo "</tr>";
            }
            echo "</table>";

            mysqli_stmt_close($stmt);
            mysqli_close($conn);
        }
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
