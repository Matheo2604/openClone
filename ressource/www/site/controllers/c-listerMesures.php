<?php
require "models/m-baseNivologie.php";
$baseNivologie = new BaseNivologie();
$listeMesures = $baseNivologie->listerMesures();

require "views/v-listerMesures.php";
?>
