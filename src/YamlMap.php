<?php
namespace Alberon\Awe;

use Exception;
use Symfony\Component\Yaml\Exception\ParseException;
use Symfony\Component\Yaml\Yaml as Yaml;

class YamlMap
{
    protected $file;
    protected $yaml;

    public function __construct(Filesystem $file, Yaml $yaml)
    {
        $this->file = $file;
        $this->yaml = $yaml;
    }

    public function load($filename, $bowerPath = null)
    {
        // Read YAML file
        $content = $this->file->get($filename);

        // Parse YAML
        try {
            $files = $this->yaml->parse($content, true);
        } catch (ParseException $e) {
            throw new YamlMapException("Error parsing YAML: " . $e->getMessage());
        }

        if (!is_array($files))
            throw new YamlMapException("Does not contain an array of files");

        // Convert each of the entries into a filename
        $filePath = dirname($filename);

        foreach ($files as &$file) {
            if (is_string($file)) {

                // String value is simply a relative path to a file
                $file = $filePath . DIRECTORY_SEPARATOR . $file;

            } elseif (!is_array($file) || count($file) !== 1 || empty($file['bower'])) {

                // The only other type allowed is a map (bower: file.js)
                $file = trim($this->yaml->dump($file));
                throw new YamlMapException("Invalid import path '$file' - should match '<filename>' or 'bower: <filename>'");

            } elseif (!$bowerPath) {

                throw new YamlMapException("Bower is disabled");

            } else {

                $file = $bowerPath . DIRECTORY_SEPARATOR . $file['bower'];

            }
        }

        // return normalisedFiles
        return $files;
    }
}

class YamlMapException extends Exception {}
