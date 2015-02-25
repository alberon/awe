<?php
namespace Alberon\Awe;

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
            $return = false;
        }

        return $this->normaliseReturnValue($return);
    }

    // Public to allow for unit testing
    // TODO: Find a better way...
    public function normaliseReturnValue($value)
    {
        if (is_int($value) || ctype_digit($value))
            return (int) $value;
        elseif (is_bool($value))
            return $value ? 0 : 1;
        else
            return 1;
    }
}
