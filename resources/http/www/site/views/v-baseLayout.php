<!DOCTYPE html>
<html lang="fr">

<head>
    <meta charset="utf-8">
    <title>Nivologie</title>
    <link href="/css/nivologie.css" type="text/css" rel="stylesheet">
    <!--link href="/css/formulaire.css" type="text/css" rel="stylesheet"-->
</head>

<body>
    <div id="conteneur">
        <header>
            Stations de Ski des Alpes
        </header>

        <nav>
            <a href="/index.php/accueil"><button>Accueil</button></a>
            <a href="/index.php/listerMesures"><button>Lister les mesures</button></a>
            <a href="/index.php/listerStations"><button>Lister les stations</button></a><br>
        </nav>

        <aside>
            <img src="/medias/capteursStation.jpg" alt="capteurs">
        </aside>

        <main>
            <?php
            echo $contenu_main;
            ?>
        </main>

        <footer>
            Version 2023
        </footer>
    </div>
</body>

</html>