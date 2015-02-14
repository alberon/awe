<?php

abstract class TestCase extends PHPUnit_Framework_TestCase {

    protected function tearDown()
    {
        $this->addToAssertionCount(Mockery::getContainer()->mockery_getExpectationCount());

        Mockery::close();
    }

}
