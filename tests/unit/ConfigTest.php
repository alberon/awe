<?php
use Mockery as m;

class ConfigTest extends TestCase
{
    protected function setUp()
    {
        parent::setUp();

        $this->app              = new Alberon\Awe\App;
        $this->configNormaliser = m::mock('Alberon\Awe\ConfigNormaliser');
        $this->config           = $this->app->make('Alberon\Awe\Config', ['normaliser' => $this->configNormaliser]);
    }

    public function testLoadConfig()
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

        $config = $this->config->load(dirname(dirname(__DIR__)) . '/fixtures/config-test');

        $this->assertSame('normalised', $config);
    }
}
