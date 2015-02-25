<?php

class CLITest extends TestCase
{
    protected function setUp()
    {
        parent::setUp();

        $this->cli = $this->app->make('Alberon\Awe\CLI');
    }

    public function normaliseReturnValueProvider()
    {
        return [
            [0,     0],
            [1,     1],
            [true,  0],
            [false, 1],
            [null,  1],
        ];
    }

    /**
     * @dataProvider normaliseReturnValueProvider
     */
    public function testConvertsReturnValuesToIntegerReturnCodes($input, $output)
    {
        $this->assertSame($output, $this->cli->normaliseReturnValue($input));
    }
}
