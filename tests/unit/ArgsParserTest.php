<?php
use Mockery as m;

class ArgsParserTest extends TestCase
{
    protected function setUp()
    {
        parent::setUp();

        $this->app = m::mock('Alberon\Awe\App');
        $this->argsParser = new Alberon\Awe\ArgsParser($this->app);
    }

    protected function expectMake($class, $args)
    {
        $this->app->shouldReceive('make')->with($class, [$args])->once();
    }

    public function testCommands()
    {
        $commands = $this->argsParser->commands();

        $this->assertSame($commands['build'], 'Alberon\Awe\Commands\Build');
        $this->assertSame($commands['watch'], 'Alberon\Awe\Commands\Watch');
    }

    public function testSynonyms()
    {
        $synonyms = $this->argsParser->synonyms();

        $this->assertSame($synonyms['b'], 'build');
        $this->assertSame($synonyms['w'], 'watch');
    }

    public function testParse()
    {
        $this->expectMake('Alberon\Awe\Commands\Build', []);

        $this->argsParser->parse(['build']);
    }

    public function testParseWithParameters()
    {
        $this->expectMake('Alberon\Awe\Commands\Build', ['-h', 'a', 'b', '--', 'c']);

        $this->argsParser->parse(['build', '-h', 'a', 'b', '--', 'c']);
    }

    public function testParseSynonyms()
    {
        $this->expectMake('Alberon\Awe\Commands\Build', ['b', 'c']);

        $this->argsParser->parse(['b', 'b', 'c']);
    }

    public function testVersionOption()
    {
        $this->expectMake('Alberon\Awe\Commands\Version', []);

        $this->argsParser->parse(['--version']);
    }

    public function testVersionShorthand()
    {
        $this->expectMake('Alberon\Awe\Commands\Version', []);

        $this->argsParser->parse(['-v']);
    }

    public function testHelpOption()
    {
        $this->expectMake('Alberon\Awe\Commands\Help', []);

        $this->argsParser->parse(['--help']);
    }

    public function testHelpShorthand()
    {
        $this->expectMake('Alberon\Awe\Commands\Help', []);

        $this->argsParser->parse(['-h']);
    }

    public function testHelpAfterCommand()
    {
        $this->expectMake('Alberon\Awe\Commands\Help', ['build']);

        $this->argsParser->parse(['build', '--help']);
    }

    public function testHelpShorthandAfterCommand()
    {
        $this->expectMake('Alberon\Awe\Commands\Help', ['build']);

        $this->argsParser->parse(['build', '-h']);
    }

    public function testNoParametersDisplaysHelp()
    {
        $this->expectMake('Alberon\Awe\Commands\Help', []);

        $this->argsParser->parse([]);
    }

    /**
     * @expectedException Alberon\Awe\InvalidParameterException
     * @expectedExceptionMessage Unknown global parameter '--invalidparameter'
     */
    public function testUnknownParameterException()
    {
        $this->argsParser->parse(['--invalidparameter', 'build']);
    }

    /**
     * @expectedException Alberon\Awe\InvalidParameterException
     * @expectedExceptionMessage Unknown command 'invalidcommand'
     */
    public function testUnknownCommandException()
    {
        $this->argsParser->parse(['invalidcommand']);
    }
}
