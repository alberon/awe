<?php
namespace Alberon\Awe;

abstract class BaseCommand
{
    protected $app;
    protected $params;

    public function __construct(array $params, App $app, StdOut $stdout, StdErr $stderr)
    {
        $this->app    = $app;
        $this->stdout = $stdout;
        $this->stderr = $stderr;
        $this->params = $params;
    }

    abstract public function run();
}
