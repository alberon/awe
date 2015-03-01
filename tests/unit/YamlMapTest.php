<?php

use Mockery as m;

class YamlMapTest extends TestCase
{
    protected function setUp()
    {
        parent::setUp();

        $this->file    = m::mock('Alberon\Awe\Filesystem');
        $this->yamlMap = $this->app->make('Alberon\Awe\YamlMap', ['file' => $this->file]);
    }

    public function testSupportsRelativePaths()
    {
        $yaml = "- sample.css\n";
        $this->file->shouldReceive('get')->with('/path/to/import.yaml')->andReturn($yaml);

        $files = $this->yamlMap->load('/path/to/import.yaml');

        $this->assertSame(['/path/to/sample.css'], $files);
    }

    public function testSupportsBowerPaths()
    {
        $yaml = "- bower: sample.css\n";
        $this->file->shouldReceive('get')->with('/path/to/import.yaml')->andReturn($yaml);

        $files = $this->yamlMap->load('/path/to/import.yaml', '/bower/path');

        $this->assertSame(['/bower/path/sample.css'], $files);
    }

    public function testSupportsMultipleFiles()
    {
        $yaml = "- sample.css\n- bower: sample.css\n";
        $this->file->shouldReceive('get')->with('/path/to/import.yaml')->andReturn($yaml);

        $files = $this->yamlMap->load('/path/to/import.yaml', '/bower/path');

        $this->assertSame(['/path/to/sample.css', '/bower/path/sample.css'], $files);
    }

    /**
     * @expectedException Alberon\Awe\YamlMapException
     * @expectedExceptionMessage Error parsing YAML: Malformed inline YAML string
     */
    public function testThrowsAnExceptionWhenYamlIsInvalid()
    {
        $yaml = "not: [valid\n";
        $this->file->shouldReceive('get')->with('/path/to/import.yaml')->andReturn($yaml);

        $this->yamlMap->load('/path/to/import.yaml', '/bower/path');
    }

    /**
     * @expectedException Alberon\Awe\YamlMapException
     * @expectedExceptionMessage Does not contain an array of files
     */
    public function testThrowsAnExceptionWhenRootIsNull()
    {
        $yaml = "";
        $this->file->shouldReceive('get')->with('/path/to/import.yaml')->andReturn($yaml);

        $this->yamlMap->load('/path/to/import.yaml', '/bower/path');
    }

    /**
     * @expectedException Alberon\Awe\YamlMapException
     * @expectedExceptionMessage Invalid import path 'null'
     */
    public function testThrowsAnExceptionWhenEntryIsNull()
    {
        $yaml = "- null";
        $this->file->shouldReceive('get')->with('/path/to/import.yaml')->andReturn($yaml);

        $this->yamlMap->load('/path/to/import.yaml', '/bower/path');
    }

    /**
     * @expectedException Alberon\Awe\YamlMapException
     * @expectedExceptionMessage Invalid import path 'notbower: true'
     */
    public function testThrowsAnExceptionWhenEntryIsInvalidMap()
    {
        $yaml = "- notbower: true";
        $this->file->shouldReceive('get')->with('/path/to/import.yaml')->andReturn($yaml);

        $this->yamlMap->load('/path/to/import.yaml', '/bower/path');
    }
}
