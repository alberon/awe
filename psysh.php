#!/usr/bin/env php
<?php
// This script is just to make it easier to experiment with the code

$autoloader = require_once __DIR__ . '/bootstrap/autoload.php';

$app = new Alberon\Awe\App;

Psy\Shell::debug(compact('autoloader', 'app'), $app);
