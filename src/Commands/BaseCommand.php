<?php
namespace Alberon\Awe\Commands;

use Alberon\Awe\App;
use Alberon\Awe\StdOut;
use Alberon\Awe\StdErr;

abstract class BaseCommand
{
    protected $app;
    protected $stdout;
    protected $stderr;

    protected $params;

    public function __construct(array $params, App $app, StdOut $stdout, StdErr $stderr)
    {
        $this->params = $params;
        $this->app    = $app;
        $this->stdout = $stdout;
        $this->stderr = $stderr;
    }

    abstract public function run();
}
