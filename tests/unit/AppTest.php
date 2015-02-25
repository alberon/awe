<?php
use Mockery as m;

class AppTest extends TestCase
{
    public function testGetInstanceReturnsTheSameInstance()
    {
        $this->assertSame(Alberon\Awe\App::getInstance(), $this->app);
    }

    public function testMakeReturnsTheSameInstance()
    {
        $this->assertSame($this->app->make('Alberon\Awe\App'), $this->app);
    }
}
