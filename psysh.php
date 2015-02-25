#!/usr/bin/env php
<?php
// This script is just to make it easier to experiment with the code

$autoloader = require_once __DIR__ . '/bootstrap/autoload.php';

$awe = new Alberon\Awe\App;

Psy\Shell::debug(compact('autoloader', 'awe'), $awe);
