<?php
$im = new Imagick('./15.jpg');
$im->scaleImage(300, 300);
$im->writeImage('./dogstar_test1.jpg');
