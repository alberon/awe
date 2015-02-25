<?php
namespace Alberon\Awe;

use Symfony\Component\Console\Formatter\OutputFormatter;

abstract class BaseStream
{
    protected $formatter;

    public function __construct(OutputFormatter $formatter)
    {
        $this->formatter = $formatter;
    }

    abstract protected function getStream();

    public function raw($data)
    {
        fwrite($this->getStream(), $data);
    }

    public function rawln($data = '')
    {
        $this->raw("$data\n");
    }

    public function write($data)
    {
        $this->raw($this->formatter->format($data));
    }

    public function writeln($data = '')
    {
        $this->write("$data\n");
    }

    public function escape($data)
    {
        return $this->formatter->escape($data);
    }
}
