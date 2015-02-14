<?php
namespace Alberon\Awe\Stream;

class StdOut extends BaseStream
{
    protected function getStream()
    {
        return STDOUT;
    }
}
