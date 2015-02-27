<?php
namespace Alberon\Awe;

use fool\executor\ProcOpen;

class ProcOpen3 extends ProcOpen
{
    const FD3 = 3;

    protected function getDescriptorSpec()
    {
        $spec = parent::getDescriptorSpec();

        $spec[self::FD3] = ['pipe', 'w'];

        return $spec;
    }

    public function getFD3()
    {
        return $this->pipes[self::FD3];
    }
}
