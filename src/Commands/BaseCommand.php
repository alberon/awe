<?php
namespace Alberon\Awe\Commands;

use Alberon\Awe\App;
use Alberon\Awe\Stream\StdOut;
use Alberon\Awe\Stream\StdErr;

abstract class BaseCommand
{
    protected $app;
    protected $params;

    public function __construct(App $app, StdOut $stdout, StdErr $stderr, array $params)
    {
        $this->app    = $app;
        $this->stdout = $stdout;
        $this->stderr = $stderr;
        $this->params = $params;
    }

    abstract public function run();
}
