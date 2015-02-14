<?php
namespace Alberon\Awe;

use Alberon\Awe\Stream\StdErr;

class CLI
{
    protected $argsParser;

    public function __construct(ArgsParser $argsParser, StdErr $stderr)
    {
        $this->argsParser = $argsParser;
        $this->stderr     = $stderr;
    }

    public function run(array $args)
    {
        try {
            $return = $this->argsParser->parse($args)->run();
        } catch (InvalidParameterException $e) {
            $this->stderr->writeln('<error>' . $this->stderr->escape($e->getMessage()) . '</error>');
            return 1;
        }

        if (is_int($return) || ctype_digit($return))
            return (int) $return;
        elseif (is_bool($return))
            return $return ? 0 : 1;
        else
            return 1;
    }
}
