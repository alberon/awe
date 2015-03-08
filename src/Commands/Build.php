<?php
namespace Alberon\Awe\Commands;

class Build extends BaseCommand
{
    public function run()
    {
        // Load config data
        $this->app->make('Alberon\Awe\Config')->load(getcwd());

        // Create AssetGroup objects
        $groups = $this->app->make('Alberon\Awe\Assets')->groups();

        // Build assets
        $output = $this->app->make('Alberon\Awe\BuildOutput');

        $output->building();
        foreach ($groups as $group) {
            $group->build();
        }

        // Finished
        $output->finished();
    }
}
