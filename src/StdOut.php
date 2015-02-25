<?php
namespace Alberon\Awe;

class StdOut extends BaseStream
{
    protected function getStream()
    {
        return STDOUT;
    }
}
