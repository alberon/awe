<?php
namespace Alberon\Awe;

use Illuminate\Filesystem\Filesystem;
use Symfony\Component\Yaml\Parser as Yaml;

class Config
{
    protected $filesystem;
    protected $normaliser;

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

        return $this->normaliser->normalise($data);
    }

    protected function findConfigFile($path)
    {
        while ($path !== '/') {
            $file = "$path/awe.yaml";

            if ($this->filesystem->isFile($file))
                return $file;

            $path = dirname($path);
        }
    }
}
