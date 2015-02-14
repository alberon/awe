<?php
namespace Alberon\Awe\Stream;

class StdErr extends BaseStream
{
    protected function getStream()
    {
        return STDERR;
    }
}
