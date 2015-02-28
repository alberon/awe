<?php
namespace Alberon\Awe;

class BuildOutput
{
    protected $stdout;
    protected $stderr;

    public function __construct(StdOut $stdout, StdErr $stderr)
    {
        $this->stdout = $stdout;
        $this->stderr = $stderr;
    }

    protected function output($action, $filename = '', $notes = '', $message = '')
    {
        // // Action
        // text = actions[action]

        // // Spaces
        // if filename || notes
        //   text += S(' ').repeat(maxLength - chalk.stripColor(text).length + 2).s

        // // Filename
        // if filename
        //   if action == 'error'
        //     text += chalk.bold.red(filename)
        //   else if action == 'warning'
        //     text += chalk.yellow(filename)
        //   else
        //     text += chalk.bold(filename)

        // // Notes
        // if notes
        //   text += ' ' if filename
        //   text += chalk.gray(notes)

        // // Display error/warning count when finished building
        // if action == 'finished'
        //   if output.counters.error
        //     s = if output.counters.error == 1 then '' else 'S'
        //     text += '\n' + chalk.bold.white.bgRed(" ** #{output.counters.error} ERROR#{s}  ** ")
        //   if output.counters.warning
        //     s = if output.counters.warning == 1 then '' else 'S'
        //     text += '\n' + chalk.yellow.inverse(" ** #{output.counters.warning} WARNING#{s} ** ")

        // // Detailed message
        // message = S(message).trim().s
        // if message
        //   text += "\n\n#{message}\n"

        // // Output
        // if action in ['error', 'warning']
        //   console.error(text)
        // else
        //   console.log(text)

    }

    public function error($filename, $notes = '', $message = '')
    {
        echo "error - $filename - $notes - $message\n";
    }

    public function compiled($filename, $notes = '', $message = '')
    {
        echo "compiled - $filename - $notes - $message\n";
    }
}
