<?php
namespace Alberon\Awe;

use fool\executor\ProcOpen as ProcOpenBase;
use fool\executor\InvalidFileModeException;

class ProcOpen extends ProcOpenBase
{
    protected $descriptorSpecExtras = [];

    protected function getDescriptorSpec()
    {
        return parent::getDescriptorSpec() + $this->descriptorSpecExtras;
    }

    /**
     * @param integer $id
     * @param  string $mode
     * @throws InvalidFileModeException
     */
    public function addPipe($id, $mode)
    {
        $this->disableAfterExecution("Unable to modify pipes after process has begun execution");
        $this->descriptorSpecExtras[$id] = array('pipe', $mode);
    }

    /**
     * @param integer $id
     * @param  string $file
     * @param  string $mode
     * @throws InvalidFileModeException
     */
    public function addPipeFromFile($id, $file, $mode)
    {
        $this->disableAfterExecution("Unable to modify pipes after process has begun execution");
        if (!in_array($mode, array('r', 'r+') /*self::$readModes*/)) {
            throw new InvalidFileModeException($mode, self::$readModes);
        }
        $this->descriptorSpecExtras[$id] = array('file', $file, $mode);
    }

    /**
     * @param integer $id
     * @param resource $resource
     */
    public function addPipeFromStream($id, $resource)
    {
        $this->disableAfterExecution("Unable to modify pipes after process has begun execution");
        if (is_resource($resource)) {
            $this->descriptorSpecExtras[$id] = $resource;
        }
    }

    /**
     * @param  integer $id
     * @return resource
     */
    public function getPipe($id)
    {
        if (isset($this->pipes[$id]))
            return $this->pipes[$id];
        else
            return null;
    }

    /**
     * @param  string $message
     * @throws InvalidProcOpenStateException
     */
    private function disableAfterExecution($message)
    {
        if ($this->executed) {
            throw new InvalidProcOpenStateException($message);
        }
    }
}
