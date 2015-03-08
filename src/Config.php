<?php
namespace Alberon\Awe;

use Symfony\Component\Yaml\Parser as Yaml;

class Config
{
    protected $filesystem;
    protected $normaliser;

    protected $data;
    protected $rootPath;

    public function __construct(Filesystem $filesystem, ConfigNormaliser $normaliser, Yaml $yaml)
    {
        $this->filesystem = $filesystem;
        $this->normaliser = $normaliser;
        $this->yaml       = $yaml;
    }

    public function load($path)
    {
        $file = $this->findConfigFile($path);

        if (!$file)
            return false;

        $yaml = $this->filesystem->get($file);

        $data = $this->yaml->parse($yaml);

        return $this->data = $this->normaliser->normalise($data);
    }

    public function get($key = null, $default = null)
    {
        return data_get($this->data, $key, $default);
    }

    public function rootPath()
    {
        return $this->rootPath;
    }

    protected function findConfigFile($path)
    {
        while ($path !== '/') {
            $file = "$path/awe.yaml";

            if ($this->filesystem->isFile($file)) {
                $this->rootPath = $path;
                return $file;
            }

            $path = dirname($path);
        }
    }
}
