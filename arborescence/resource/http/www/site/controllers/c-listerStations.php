<?php
require "models/m-baseNivologie.php";
$baseNivologie = new BaseNivologie();
$listerStations = $baseNivologie->listerStations();

require "views/v-listerStations.php";
?>