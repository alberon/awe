<?php
namespace Alberon\Awe;

class Assets
{
    protected $app;
    protected $config;

    public function __construct(App $app, Config $config)
    {
        $this->app    = $app;
        $this->config = $config;
    }

    public function groups()
    {
        $rootPath = $this->config->rootPath();

        $groups = [];
        foreach ($this->config->get('ASSETS', []) as $groupConfig) {
            $groups[] = $this->app->make('Alberon\Awe\AssetGroup', [$rootPath, $groupConfig]);
        }

        return $groups;
    }
}
