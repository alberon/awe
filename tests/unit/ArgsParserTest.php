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
        $this->app->shouldReceive('make')->with($class, [$args])->once()->andReturn('ok');
    }

    public function testCommandsReturnsAssociativeArrayOfCommandsMappedToClasses()
    {
        $commands = $this->argsParser->commands();

        $this->assertInternalType('array', $commands);
        $this->assertSame($commands['build'], 'Alberon\Awe\Commands\Build');
        $this->assertSame($commands['watch'], 'Alberon\Awe\Commands\Watch');
    }

    public function testSynonymsReturnsAssociativeArrayOfSynonymsMappedToCommands()
    {
        $synonyms = $this->argsParser->synonyms();

        $this->assertInternalType('array', $synonyms);
        $this->assertSame($synonyms['b'], 'build');
        $this->assertSame($synonyms['w'], 'watch');
    }

    public function testParseCommandNameReturnsCommandObject()
    {
        $this->expectMake('Alberon\Awe\Commands\Build', []);

        $this->assertSame('ok', $this->argsParser->parse(['build']));
    }

    public function testParseWithParametersReturnsCommandObjectWithParameters()
    {
        $this->expectMake('Alberon\Awe\Commands\Build', ['-h', 'a', 'b', '--', 'c']);

        $this->assertSame('ok', $this->argsParser->parse(['build', '-h', 'a', 'b', '--', 'c']));
    }

    public function testParseSynonymReturnsCommandObject()
    {
        $this->expectMake('Alberon\Awe\Commands\Build', ['b', 'c']);

        $this->assertSame('ok', $this->argsParser->parse(['b', 'b', 'c']));
    }

    public function testParseVersionOptionReturnsVersionCommand()
    {
        $this->expectMake('Alberon\Awe\Commands\Version', []);

        $this->assertSame('ok', $this->argsParser->parse(['--version']));
    }

    public function testParseShorthandVersionOptionReturnsVersionCommand()
    {
        $this->expectMake('Alberon\Awe\Commands\Version', []);

        $this->assertSame('ok', $this->argsParser->parse(['-v']));
    }

    public function testParseHelpOptionReturnsHelpCommand()
    {
        $this->expectMake('Alberon\Awe\Commands\Help', []);

        $this->assertSame('ok', $this->argsParser->parse(['--help']));
    }

    public function testParseShorthandHelpOptionReturnsHelpCommand()
    {
        $this->expectMake('Alberon\Awe\Commands\Help', []);

        $this->assertSame('ok', $this->argsParser->parse(['-h']));
    }

    public function testParseHelpOptionAfterCommandReturnsHelpCommand()
    {
        $this->expectMake('Alberon\Awe\Commands\Help', ['build']);

        $this->assertSame('ok', $this->argsParser->parse(['build', '--help']));
    }

    public function testParseShorthandHelpOptionAfterCommandReturnsHelpCommand()
    {
        $this->expectMake('Alberon\Awe\Commands\Help', ['build']);

        $this->assertSame('ok', $this->argsParser->parse(['build', '-h']));
    }

    public function testParseWithNoParametersReturnsHelpCommand()
    {
        $this->expectMake('Alberon\Awe\Commands\Help', []);

        $this->assertSame('ok', $this->argsParser->parse([]));
    }

    /**
     * @expectedException Alberon\Awe\InvalidParameterException
     * @expectedExceptionMessage Unknown global parameter '--invalidparameter'
     */
    public function testParseUnknownParameterThrowsException()
    {
        $this->assertSame('ok', $this->argsParser->parse(['--invalidparameter', 'build']));
    }

    /**
     * @expectedException Alberon\Awe\InvalidParameterException
     * @expectedExceptionMessage Unknown command 'invalidcommand'
     */
    public function testParseUnknownCommandThrowsException()
    {
        $this->argsParser->parse(['invalidcommand']);
    }
}
