<?php
use Mockery as m;

class ConfigNormaliserTest extends TestCase
{
    protected function setUp()
    {
        parent::setUp();

        $this->normaliser = $this->app->make('Alberon\Awe\ConfigNormaliser');
    }

    /*--------------------------------------
     Success
    --------------------------------------*/

    public function testReturnsAnArrayOfData()
    {
        $data = [
            'ASSETS' => [
                'test' => [
                    'src'  => 'assets/src/',
                    'dest' => 'assets/build/',
                ]
            ]
        ];

        $this->assertInternalType('array', $this->normaliser->normalise($data));
    }

    /*--------------------------------------
     Root error checking
    --------------------------------------*/

    /**
     * @expectedException         Alberon\Awe\ConfigNormaliserExeception
     * @expectedExceptionMessage  Root must be a mapping (actual type is string)
     */
    public function testThrowsAnExceptionWhenTheRootIsNotAMapping()
    {
        $this->normaliser->normalise('Not a mapping');
    }

    /**
     * @expectedException         Alberon\Awe\ConfigNormaliserExeception
     * @expectedExceptionMessage  File is empty
     */
    public function testThrowsAnExceptionWhenTheRootIsAnEmptyMapping()
    {
        $this->normaliser->normalise([]);
    }

    /**
     * @expectedException         Alberon\Awe\ConfigNormaliserExeception
     * @expectedExceptionMessage  File is empty
     */
    public function testThrowsAnExceptionWhenTheRootIsAnEmptyString()
    {
        // This happens when the file is completely empty
        $this->normaliser->normalise('');
    }

    /*--------------------------------------
     Top-level error checking
    --------------------------------------*/

    /**
     * @expectedException         Alberon\Awe\ConfigNormaliserExeception
     * @expectedExceptionMessage  Unknown setting 'unknown'
     */
    public function testThrowsAnExceptionWhenAnUnknownTopLevelSettingIsGiven()
    {
        $this->normaliser->normalise([
            'unknown' => [],
        ]);
    }

    /**
     * @expectedException         Alberon\Awe\ConfigNormaliserExeception
     * @expectedExceptionMessage  Unknown setting 'assets'
     */
    public function testKeyNamesAreCaseSensitive()
    {
        $this->normaliser->normalise([
            'assets' => [],
        ]);
    }

    /*--------------------------------------
     ASSETS.*
    --------------------------------------*/

    /**
     * @expectedException         Alberon\Awe\ConfigNormaliserExeception
     * @expectedExceptionMessage  Setting 'ASSETS.test' must be a mapping (actual type is string)
     */
    public function testThrowsAnExceptionWhenAnAssetGroupIsAString()
    {
        $this->normaliser->normalise([
            'ASSETS' => [
                'test' => 'Not a mapping',
            ],
        ]);
    }

    /**
     * @expectedException         Alberon\Awe\ConfigNormaliserExeception
     * @expectedExceptionMessage  Setting 'ASSETS.test' must be a mapping (actual type is array)
     */
    public function testThrowsAnExceptionWhenAnAssetGroupIsASequence()
    {
        $this->normaliser->normalise([
            'ASSETS' => [
                'test' => ['Not a mapping'],
            ],
        ]);
    }

    /**
     * @expectedException         Alberon\Awe\ConfigNormaliserExeception
     * @expectedExceptionMessage  Invalid group name 'abc#def' in ASSETS (a-z, 0-9 only)
     */
    public function testThrowsAnExceptionIfAnAssetGroupNameIsNotAlphanumeric()
    {
        $this->normaliser->normalise([
            'ASSETS' => [
                'abc#def' => [],
            ],
        ]);
    }

    /**
     * @expectedException         Alberon\Awe\ConfigNormaliserExeception
     * @expectedExceptionMessage  Unknown setting 'unknown' in ASSETS.test
     */
    public function testThrowsAnExceptionIfAnUnknownOptionIsFoundInAnAssetGroup()
    {
        $this->normaliser->normalise([
            'ASSETS' => [
                'test' => [
                    'unknown' => true,
                ],
            ],
        ]);
    }

    /*--------------------------------------
     ASSETS.*.src
    --------------------------------------*/

    /**
     * @expectedException         Alberon\Awe\ConfigNormaliserExeception
     * @expectedExceptionMessage  Missing required setting 'src' in ASSETS.test
     */
    public function testThrowsAnExceptionIfSrcIsMissingInAnAssetGroup()
    {
        $this->normaliser->normalise([
            'ASSETS' => [
                'test' => [
                    'dest' => 'assets/build/',
                ],
            ],
        ]);
    }

    /**
     * @expectedException         Alberon\Awe\ConfigNormaliserExeception
     * @expectedExceptionMessage  Setting 'ASSETS.test.src' must be a string (actual type is boolean)
     */
    public function testThrowsAnExceptionIfAssetGroupSrcIsNotAString()
    {
        $this->normaliser->normalise([
            'ASSETS' => [
                'test' => [
                    'src'  => true,
                    'dest' => 'assets/build/',
                ],
            ],
        ]);
    }

    /*--------------------------------------
     ASSETS.*.dest
    --------------------------------------*/

    /**
     * @expectedException         Alberon\Awe\ConfigNormaliserExeception
     * @expectedExceptionMessage  Missing required setting 'dest' in ASSETS.test
     */
    public function testThrowsAnExceptionIfDestIsMissingInAnAssetGroup()
    {
        $this->normaliser->normalise([
            'ASSETS' => [
                'test' => [
                    'src' => 'assets/src/',
                ],
            ],
        ]);
    }

    /**
     * @expectedException         Alberon\Awe\ConfigNormaliserExeception
     * @expectedExceptionMessage  Setting 'ASSETS.test.dest' must be a string (actual type is boolean)
     */
    public function testThrowsAnExceptionIfAssetGroupDestIsNotAString()
    {
        $this->normaliser->normalise([
            'ASSETS' => [
                'test' => [
                    'src'  => 'assets/src/',
                    'dest' => true,
                ],
            ],
        ]);
    }

    /*--------------------------------------
     ASSETS.*.bower
    --------------------------------------*/

    public function testDisablesBowerByDefault()
    {
        $config = $this->normaliser->normalise([
            'ASSETS' => [
                'test' => [
                    'src'  => 'assets/src/',
                    'dest' => 'assets/build/',
                ],
            ],
        ]);

        $this->assertSame(false, $config['ASSETS']['test']['bower']);
    }

    public function testBowerCanBeSetToAPath()
    {
        $config = $this->normaliser->normalise([
            'ASSETS' => [
                'test' => [
                    'src'   => 'assets/src/',
                    'dest'  => 'assets/build/',
                    'bower' => 'bower_components/',
                ],
            ],
        ]);

        $this->assertSame('bower_components/', $config['ASSETS']['test']['bower']);
    }

    /**
     * @expectedException         Alberon\Awe\ConfigNormaliserExeception
     * @expectedExceptionMessage  Setting 'ASSETS.test.bower' must be a string or false (actual value is true)
     */
    public function testThrowsAnExceptionIfBowerIsTrue()
    {
        $this->normaliser->normalise([
            'ASSETS' => [
                'test' => [
                    'src'   => 'assets/src/',
                    'dest'  => 'assets/build/',
                    'bower' => true,
                ],
            ],
        ]);
    }

    /*--------------------------------------
     ASSETS.*.autoprefixer
    --------------------------------------*/

    public function testDisablesAutoprefixerByDefault()
    {
        $config = $this->normaliser->normalise([
            'ASSETS' => [
                'test' => [
                    'src'  => 'assets/src/',
                    'dest' => 'assets/build/',
                ],
            ],
        ]);

        $this->assertSame(false, $config['ASSETS']['test']['autoprefixer']);
    }

    public function testAutoprefixerCanBeEnabled()
    {
        $config = $this->normaliser->normalise([
            'ASSETS' => [
                'test' => [
                    'src'          => 'assets/src/',
                    'dest'         => 'assets/build/',
                    'autoprefixer' => true,
                ],
            ],
        ]);

        $this->assertSame(true, $config['ASSETS']['test']['autoprefixer']);
    }

    /**
     * @expectedException         Alberon\Awe\ConfigNormaliserExeception
     * @expectedExceptionMessage  Setting 'ASSETS.test.autoprefixer' must be a boolean (actual type is string)
     */
    public function testThrowsAnExceptionIfAutoprefixerIsNotBoolean()
    {
        $this->normaliser->normalise([
            'ASSETS' => [
                'test' => [
                    'src'          => 'assets/src/',
                    'dest'         => 'assets/build/',
                    'autoprefixer' => 'oops',
                ],
            ],
        ]);
    }

    /*--------------------------------------
     ASSETS.*.prettyprint
    --------------------------------------*/

    public function testAlwaysDisablesPrettyPrint()
    {
        $config = $this->normaliser->normalise([
            'ASSETS' => [
                'test' => [
                    'src'  => 'assets/src/',
                    'dest' => 'assets/build/',
                ],
            ],
        ]);

        $this->assertSame(false, $config['ASSETS']['test']['prettyprint']);
    }

    /**
     * @expectedException         Alberon\Awe\ConfigNormaliserExeception
     * @expectedExceptionMessage  Unknown setting 'prettyprint' in ASSETS.test
     */
    public function testPrettyPrintCannotBeEnabled()
    {
        $this->normaliser->normalise([
            'ASSETS' => [
                'test' => [
                    'src'         => 'assets/src/',
                    'dest'        => 'assets/build/',
                    'prettyprint' => true,
                ],
            ],
        ]);
    }

    /*--------------------------------------
     ASSETS.*.sourcemaps
    --------------------------------------*/

    public function testAlwaysEnablesSourceMaps()
    {
        $config = $this->normaliser->normalise([
            'ASSETS' => [
                'test' => [
                    'src'  => 'assets/src/',
                    'dest' => 'assets/build/',
                ],
            ],
        ]);

        $this->assertSame(true, $config['ASSETS']['test']['sourcemaps']);
    }

    /**
     * @expectedException         Alberon\Awe\ConfigNormaliserExeception
     * @expectedExceptionMessage  Unknown setting 'sourcemaps' in ASSETS.test
     */
    public function testSourceMapsCannotBeDisabled()
    {
        $this->normaliser->normalise([
            'ASSETS' => [
                'test' => [
                    'src'        => 'assets/src/',
                    'dest'       => 'assets/build/',
                    'sourcemaps' => false,
                ],
            ],
        ]);
    }

    /*--------------------------------------
     ASSETS.*.warningfile
    --------------------------------------*/

    public function testAlwaysEnablesWarningFile()
    {
        $config = $this->normaliser->normalise([
            'ASSETS' => [
                'test' => [
                    'src'  => 'assets/src/',
                    'dest' => 'assets/build/',
                ],
            ],
        ]);

        $this->assertSame('_DO_NOT_EDIT.txt', $config['ASSETS']['test']['warningfile']);
    }

    /**
     * @expectedException         Alberon\Awe\ConfigNormaliserExeception
     * @expectedExceptionMessage  Unknown setting 'warningfile' in ASSETS.test
     */
    public function testWarningFileCannotBeDisabled()
    {
        $this->normaliser->normalise([
            'ASSETS' => [
                'test' => [
                    'src'         => 'assets/src/',
                    'dest'        => 'assets/build/',
                    'warningfile' => false,
                ],
            ],
        ]);
    }
}
