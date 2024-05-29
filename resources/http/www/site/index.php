<?php

// Tableau associatif qui associe des URL à des fichiers PHP correspondants
$routes = [
    '/'                         => 'c-accueil.php',
    '/index.php'                => 'c-accueil.php',
    '/index.php/accueil'        => 'c-accueil.php',
];

// aaaaaRécupération de l'URL demandée
$request_uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// Vérification si l'URL demandée correspond à une page connue
if (array_key_exists($request_uri, $routes)) {
    // Inclusion de la page PHP correspondante
    require("controllers/".$routes[$request_uri]);
} else {
    // Page non trouvée
    header("HTTP/1.1 404 Not Found");
    echo "ERREUR 404 : Page non trouvée";
}
?>

