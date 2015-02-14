<?php

$autoloader = require_once __DIR__ . '/autoload.php';

// Autoload additional test classes (e.g. TestCase)
$autoloader->add('', __DIR__ . '/../tests');
