<?php

abstract class TestCase extends PHPUnit_Framework_TestCase {

    protected function setUp()
    {
        $this->app = new Alberon\Awe\App;

        $this->fixtures = __DIR__ . '/fixtures';
    }

    protected function tearDown()
    {
        $this->addToAssertionCount(Mockery::getContainer()->mockery_getExpectationCount());

        Mockery::close();
    }

}
