<?php
namespace Alberon\Awe;

class BuildOutput
{
    protected $stdout;
    protected $stderr;

    protected $errorCount = 0;
    protected $warningCount = 0;

    public function __construct(StdOut $stdout, StdErr $stderr)
    {
        $this->stdout = $stdout;
        $this->stderr = $stderr;
    }

    protected function output(BaseStream $stream, $action, $filename = '', $notes = '', $message = '')
    {
        // Action - required
        $text = $action;

        if ($filename || $notes)
            $text .= str_repeat(' ', 9 - strlen(strip_tags($action)) + 2);

        // Filename
        if ($filename)
            $text .= $filename;

        if ($notes && $filename)
            $text .= ' ';

        // Notes
        if ($notes)
            $text .= "<grey>$notes</grey>";

        // Detailed message
        if ($message = trim($message))
            $text .= "\n\n{$message}\n";

        // Output
        $stream->writeln($text);
    }

    public function watching()
    {
        $this->stdout->write('<fg=cyan;options=bold>WATCHING...</fg=cyan;options=bold> ');
        $this->stdout->write('<grey>Press</grey> ');
        $this->stdout->write('<fg=white>b</fg=white> ');
        $this->stdout->write('<grey>to build,</grey> ');
        $this->stdout->write('<fg=white>q</fg=white> ');
        $this->stdout->writeln('<grey>to quit</grey> ');
    }

    public function building()
    {
        $this->stdout->writeln('<fg=cyan;options=bold>BUILDING...</fg=cyan;options=bold>');

        $this->errorCount   = 0;
        $this->warningCount = 0;
    }

    public function finished()
    {
        $this->stdout->writeln('<fg=cyan;options=bold>FINISHED.</fg=cyan;options=bold>');

        if ($this->errorCount) {
            $S = $this->errorCount == 1 ? '' : 'S';
            $this->stderr->writeln("<fg=white;bg=red;options=bold> ** {$this->errorCount} ERROR$S  ** </fg=white;bg=red;options=bold>");
        }

        if ($this->warningCount) {
            $S = $this->warningCount == 1 ? '' : 'S';
            $this->stderr->writeln("<fg=yellow;options=reverse> ** {$this->warningCount} WARNING$S ** </fg=yellow;options=reverse>");
        }
    }

    public function modified($filename, $notes = '', $message = '')
    {
        $this->output(
            $this->stdout,
            '<fg=green;options=bold,reverse>Modified</fg=green;options=bold,reverse>',
            $filename ? "<options=bold>$filename</options=bold>" : '',
            $notes,
            $message
        );
    }

    public function error($filename, $notes = '', $message = '')
    {
        $this->errorCount++;

        $this->output(
            $this->stderr,
            '<fg=white;bg=red;options=bold>Error</fg=white;bg=red;options=bold>',
            $filename ? "<fg=red;options=bold>$filename</fg=red;options=bold>" : '',
            $notes,
            $message
        );
    }

    public function warning($filename, $notes = '', $message = '')
    {
        $this->warningCount++;

        $this->output(
            $this->stderr,
            '<fg=yellow;options=reverse>Warning</fg=yellow;options=reverse>',
            $filename ? "<fg=yellow>$filename</fg=yellow>" : '',
            $notes,
            $message
        );
    }

    public function created($filename, $notes = '', $message = '')
    {
        $this->output(
            $this->stdout,
            '<fg=red;options=bold>Created</fg=red;options=bold>',
            $filename ? "<options=bold>$filename</options=bold>" : '',
            $notes,
            $message
        );
    }

    public function emptied($filename, $notes = '', $message = '')
    {
        $this->output(
            $this->stdout,
            '<fg=red;options=bold>Emptied</fg=red;options=bold>',
            $filename ? "<options=bold>$filename</options=bold>" : '',
            $notes,
            $message
        );
    }

    public function symlink($filename, $target = '')
    {
        $this->output(
            $this->stdout,
            '<fg=magenta;options=bold>Symlink</fg=magenta;options=bold>',
            $filename ? "<options=bold>$filename</options=bold>" : '',
            $target ? " -> $target" : ''
        );
    }

    public function copied($filename, $notes = '', $message = '')
    {
        $this->output(
            $this->stdout,
            '<fg=green;options=bold>Copied</fg=green;options=bold>',
            $filename ? "<options=bold>$filename</options=bold>" : '',
            $notes,
            $message
        );
    }

    public function compiled($filename, $notes = '', $message = '')
    {
        $this->output(
            $this->stdout,
            '<fg=green;options=bold>Compiled</fg=green;options=bold>',
            $filename ? "<options=bold>$filename</options=bold>" : '',
            $notes,
            $message
        );
    }

    public function generated($filename, $notes = '', $message = '')
    {
        $this->output(
            $this->stdout,
            '<fg=yellow;options=bold>Generated</fg=yellow;options=bold>',
            $filename ? "<options=bold>$filename</options=bold>" : '',
            $notes,
            $message
        );
    }
}
