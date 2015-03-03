<?php
use Mockery as m;

class ConfigTest extends TestCase
{
    protected function setUp()
    {
        parent::setUp();

        $this->configNormaliser = m::mock('Alberon\Awe\ConfigNormaliser');
        $this->config           = $this->app->make('Alberon\Awe\Config', ['normaliser' => $this->configNormaliser]);
    }

    public function testLoadMethodReadsYamlFileAndCallsNormalise()
    {
        $data = [
            'ASSETS' => [
                'test' => [
                    'src' =>  'assets/src/',
                    'dest' => 'assets/build/',
                ],
            ],
        ];

        $this->configNormaliser->shouldReceive('normalise')->with($data)->once()->andReturn('normalised');

        $config = $this->config->load($this->fixtures . '/' . __CLASS__ . '/' . __FUNCTION__);

        $this->assertSame('normalised', $config);
    }
}
