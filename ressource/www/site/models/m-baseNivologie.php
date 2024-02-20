<?php

class BaseNivologie
{
    private $base;

    public function __construct()
    {
        require "m-param-baseNivologie.php";
        // Connexion à la base de données
        try {
            $this->base = new PDO("sqlite:".$fichierBdd);
        } catch (PDOException $e) {
            echo "Erreur : " . $e->getMessage() . "<br>";
            die();
        }
    }

    public function __destruct()
    {
        // Fermeture de la base de données
        $this->base = null;
    }

    public function listerMesures()
    {
        try {
            $reqSQL = "SELECT reference, nom as type,valeur,unite,datetime FROM Mesure, Station JOIN Type ON Mesure.idType=Type.idType ORDER BY datetime(datetime) DESC";
            $stmt = $this->base->prepare($reqSQL);
            $stmt->execute();
            return ($stmt->fetchAll());
        } catch (PDOException $e) {
            echo "Erreur : " . $e->getMessage() . "<br>";
            die();
        }
    }

    public function listerStations(){
        try {
            $reqSQL = "SELECT reference, localisation, description FROM Station";
            $stmt = $this->base->prepare($reqSQL);
            $stmt->execute();
            return ($stmt->fetchAll());
        } catch (PDOException $e) {
            echo "Erreur : " . $e->getMessage() . "<br>";
            die();
        }
    }

    public function aseptiser($string)
    {
        $string = trim($string);
        $string = htmlspecialchars($string);
        return $string;
    }
}

?>
