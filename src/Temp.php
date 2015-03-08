<?php
namespace Alberon\Awe;

use Exception;

class Temp
{
    protected $file;

    protected $instanceRegistered = false;
    protected $filesToClean = [];

    protected static $shutdownFunctionRegistered = false;
    protected static $instances = [];

    public function __construct(Filesystem $file)
    {
        $this->file = $file;
    }

    /**
     * Create a temporary directory
     *
     * Based on http://php.net/manual/en/function.tempnam.php#61436
     */
    public function dir()
    {
        $dir = rtrim(sys_get_temp_dir(), '/\\');
        $mode = 0700;

        do
        {
            $path = $dir . DIRECTORY_SEPARATOR . 'awe-' . str_pad(mt_rand(0, 9999999999), 10, 0, STR_PAD_RIGHT);
        } while (!@mkdir($path, $mode));

        $this->addToClean($path);

        return $path;
    }

    /**
     * Create a temporary file
     */
    public function file()
    {
        $path = tempnam(sys_get_temp_dir(), 'awe-');

        $this->addToClean($path);

        return $path;
    }

    public function clean($path)
    {
        if (!isset($this->filesToClean[$path]))
            throw new Exception("Not a temp path: '$path'");

        if ($this->file->isDirectory($path) && !$this->file->isLink($path))
            $this->file->deleteDirectory($path);
        else
            $this->file->delete($path);

        unset($this->filesToClean[$path]);
    }

    public function cleanAll()
    {
        foreach (array_keys($this->filesToClean) as $file) {
            $this->clean($file);
        }

        $this->unregisterInstance();
    }

    protected function addToClean($path)
    {
        $this->filesToClean[$path] = true;

        $this->registerInstance();
    }

    protected function registerInstance()
    {
        if (!$this->instanceRegistered) {
            static::registerShutdownFunction();

            static::$instances[] = $this;

            $this->instanceRegistered = true;

        }
    }

    protected function unregisterInstance()
    {
        if (!$this->instanceRegistered) {
            $key = array_search($this, static::$instances);

            unset(static::$instances[$key]);
        }
    }

    protected static function registerShutdownFunction()
    {
        // This is static because you can't unregister shutdown functions and we
        // don't want to keep registering them every time a new object is
        // created as it would create a memory leak
        if (!static::$shutdownFunctionRegistered) {
            register_shutdown_function([static::class, 'runShutdownFunction']);

            static::$shutdownFunctionRegistered = true;
        }
    }

    public static function runShutdownFunction()
    {
        foreach (static::$instances as $instance) {
            $instance->cleanAll();
        }
    }
}
