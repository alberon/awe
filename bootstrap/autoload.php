<?php

// Autoload source code and dependencies from Composer, or give a helpful error
// message if they're not installed

$dir = dirname(__DIR__);
$file = $dir . '/vendor/autoload.php';

if (!file_exists($file)) {
    fwrite(STDERR, "awe: Could not load $file - maybe you need to run $dir/install-dependencies.sh?\n");
    exit(1);
}

return require $file;
