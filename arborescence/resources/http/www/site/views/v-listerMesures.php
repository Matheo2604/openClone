<?php
ob_start();
?>

<h1>Enneigement - Bulletin neige</h1>


<table>
    <thead>
        <tr>
            <th> Référence
            <th> Type
            <th> Valeur
            <th> Unité
            <th>Date-time
    </thead>

    <?php
    foreach ($listeMesures as $mesure) {
        echo "<tr><td>" . $mesure['reference'] . "<td>" . $mesure['type'] . "<td>" . $mesure['valeur'] . "<td>" . $mesure['unite'] . "<td>" . $mesure['datetime'];
    }
    ?>

</table>

<?php
$contenu_main = ob_get_clean();
require "v-baseLayout.php";
?>
