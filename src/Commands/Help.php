<?php
namespace Alberon\Awe\Commands;

use Alberon\Awe\InvalidParameterException;

class Help extends BaseCommand
{
    public function run()
    {
        $out = $this->stdout;

        // No parameters - show global help
        if (empty($this->params[0])) {
            $out->writeln("<b>SYNOPSIS</b>");
            $out->writeln();
            $out->writeln("   awe [<b>-h</b>|<b>--help</b>] <u>command</u> [<u>args</u>]");
            $out->writeln();
            $out->writeln("<b>GLOBAL COMMANDS</b>");
            $out->writeln();
            $out->writeln("   <u>help</u>        Display help");
            $out->writeln("   <u>init</u>        Create awe.yaml in the current directory");
            $out->writeln("   <u>version</u>     Display Awe version");
            $out->writeln();
            $out->writeln("<b>PROJECT COMMANDS</b>");
            $out->writeln();
            $out->writeln("   <u>build</u> (<u>b</u>)   Compile assets");
            $out->writeln("   <u>watch</u> (<u>w</u>)   Watch for changes and automatically recompile assets");
            $out->writeln();
            $out->writeln("<b>SEE ALSO</b>");
            $out->writeln();
            $out->writeln("   Documentation: <u>http://awe.alberon.co.uk/</u>");
            return;
        }

        // Parameter - should be the name of a command or synonym
        $cmd = $this->params[0];

        $argsParser = $this->app->make('Alberon\Awe\ArgsParser');
        $synonyms = $argsParser->synonyms();

        if (isset($synonyms[$cmd])) {
            // Synonym - display a message then the help for that command
            $real = $synonyms[$cmd];
            $out->writeln("'awe <u>$cmd</u>' is shorthand for 'awe <u>$real</u>'\n");
            $cmd = $real;
        }

        $commands = $argsParser->commands();
        if (isset($commands[$cmd])) {
            // TODO: Separate help pages for each with more detail about what they do...
            $out->writeln("<b>SYNOPSIS</b>");
            $out->writeln();
            $out->writeln("   awe <u>$cmd</u>");
            $out->writeln();
            $out->writeln("<b>SEE ALSO</b>");
            $out->writeln();
            $out->writeln("   Documentation: <u>http://awe.alberon.co.uk/</u>");
            return;
        }

        throw new InvalidParameterException("Unknown command '$cmd'");
    }
}
