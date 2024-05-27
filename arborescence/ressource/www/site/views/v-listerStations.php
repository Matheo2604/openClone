<?php
ob_start();
?>

<h1>Liste des Nivomètres</h1>


<table>
    <thead>
        <tr>
            <th> Référence
            <th> Localisation
            <th> Description
    </thead>

    <?php
    foreach ($listerStations as $station) {
        echo "<tr><td>" . $station['reference'] . "<td>" . $station['localisation'] . "<td>" . $station['description'];
    }
    ?>

</table>

<?php
$contenu_main = ob_get_clean();
require "v-baseLayout.php";
?>
