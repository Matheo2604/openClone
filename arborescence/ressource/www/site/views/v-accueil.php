<?php
ob_start();
?>

<h1>Bienvenue sur le serveur de nivologie</h1>
<p>Prévision des avalanches</p>

<?php
$contenu_main = ob_get_clean();
require "v-baseLayout.php";
?>
