<?php
namespace Alberon\Awe;

class StdErr extends BaseStream
{
    protected function getStream()
    {
        return STDERR;
    }
}
