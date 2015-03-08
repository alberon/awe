<?php
namespace Alberon\Awe;

use Illuminate\Container\Container;
use Symfony\Component\Console\Formatter\OutputFormatter;
use Symfony\Component\Console\Formatter\OutputFormatterStyle;

class App extends Container
{
    public function __construct()
    {
        $this->registerInstance();
        $this->registerBindings();
        $this->registerSingletons();
    }

    protected function registerInstance()
    {
        static::setInstance($this);

        $this->instance(App::class, $this);
    }

    protected function registerSingletons()
    {
        $this->singleton('Alberon\Awe\BuildOutput');
        $this->singleton('Alberon\Awe\Config');
    }

    protected function registerBindings()
    {
        $this->bind(OutputFormatter::class, function()
        {
            // TODO: Detect if the output supports formatting?
            // Maybe there's a Symfony method to do that already?
            $formatter = new OutputFormatter(true);

            // Register custom styles
            $formatter->setStyle('b', new OutputFormatterStyle(null, null, ['bold']));
            $formatter->setStyle('u', new OutputFormatterStyle(null, null, ['underscore']));
            $formatter->setStyle('grey', new OutputFormatterStyle('black', null, ['bold']));

            return $formatter;
        });
    }
}
