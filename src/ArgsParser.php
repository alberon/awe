<?php
namespace Alberon\Awe;

/**
 * Command-line arguments parser.
 *
 * This is a simple parser that only parses global parameters and finds the
 * command to run. All remaining arguments are passed to that command to be
 * handled however it sees fit. Sometimes they will be parsed by us, sometimes
 * passed unmodified to an external program (e.g. MySQL) - so this class mustn't
 * change them in any way.
 */
class ArgsParser
{
    protected $commands = [
        'build'   => 'Alberon\Awe\BuildCommand',
        'help'    => 'Alberon\Awe\HelpCommand',
        'init'    => 'Alberon\Awe\InitCommand',
        'watch'   => 'Alberon\Awe\WatchCommand',
        'version' => 'Alberon\Awe\VersionCommand',
    ];

    protected $synonyms = [
        'b' => 'build',
        'w' => 'watch',
    ];

    protected $app;

    public function __construct(App $app)
    {
        $this->app = $app;
    }

    public function commands()
    {
        return $this->commands;
    }

    public function synonyms()
    {
        return $this->synonyms;
    }

    public function parse(array $params)
    {
        # This while loop will currently only ever run once, but it's here for
        # future use when we add global parameters
        while ($params) {
            $param = array_shift($params);

            // Convert synonym to the equivalent full command
            if (isset($this->synonyms[$param]))
                $param = $this->synonyms[$param];

            if (isset($this->commands[$param])) {

                // Special case for -h and --help command parameters (with no
                // other parameters), for consistency and to save each command
                // implementing this flag separately
                if ($params === ['-h'] || $params === ['--help'])
                    return $this->make('help', [$param]);

                // Regular command
                return $this->make($param, $params);

            } elseif ($param === '-h' || $param === '--help') {

                // Global help flag
                return $this->make('help', $params);

            } elseif ($param === '-v' || $param === '--version') {

                // Global version flag
                return $this->make('version', $params);

            } elseif ($param[0] === '-') {

                // Unknown global parameter
                throw new InvalidParameterException("Unknown global parameter '$param'");

            } else {

                // Unknown command
                throw new InvalidParameterException("Unknown command '$param'");

            }
        }

        // No command given
        return $this->make('help', $params);
    }

    protected function make($command, $params)
    {
        return $this->app->make($this->commands[$command], [$params]);
    }
}
