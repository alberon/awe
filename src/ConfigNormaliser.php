<?php
namespace Alberon\Awe;

use Exception;
use LogicException;

class ConfigNormaliser
{
    public function normalise($config)
    {
        $this->parseRoot(null, $config);

        return $config;
    }

    /*--------------------------------------
     Parsers
    --------------------------------------*/

    protected function parseRoot($setting, &$config)
    {
        $type = $this->typeOf($config);

        if (!$config && ($type === 'mapping' || $type === 'string'))
            throw new ConfigNormaliserExeception('File is empty');

        $this->checkSettingType($setting, $config, null, 'mapping');

        // Setting groups
        $this->checkAllowedKeys($setting, $config, ['ASSETS']);

        if ($this->optionalSetting($setting, $config, 'ASSETS', ['mapping']))
            $this->parseAssets('ASSETS', $config['ASSETS']);
    }

    protected function parseAssets($setting, &$config)
    {
        foreach ($config as $key => &$value) {
            // Validate the name
            if (!ctype_alnum($key))
                throw new ConfigNormaliserExeception("Invalid group name '{$key}' in {$setting} (a-z, 0-9 only)");

            // Validate the type
            $this->checkSettingType($setting, $config, $key, 'mapping');

            // Check the group config
            $this->parseAssetGroup("{$setting}.{$key}", $value);
        }
    }

    protected function parseAssetGroup($setting, &$config)
    {
        $this->checkAllowedKeys($setting, $config, ['src', 'dest', 'autoprefixer', 'bower']);

        $this->requireSetting($setting, $config, 'src', 'string');
        $this->requireSetting($setting, $config, 'dest', 'string');

        $this->optionalSetting($setting, $config, 'autoprefixer', 'boolean', false);
        $this->optionalSetting($setting, $config, 'bower', ['string', false], false);

        // Forced settings - may be made editable in the future, but for now
        // they are only used to speed up unit testing
        $config['prettyprint'] = false;
        $config['sourcemaps']  = true;
        $config['warningfile'] = '_DO_NOT_EDIT.txt';
    }

    /*--------------------------------------
     Helpers
    --------------------------------------*/

    protected function requireSetting($setting, $config, $key, $allowedTypes = null)
    {
        if (isset($config[$key]))
            $this->checkSettingType($setting, $config, $key, $allowedTypes);
        else
            throw new ConfigNormaliserExeception("Missing required setting '{$key}' in {$setting}");
    }

    protected function optionalSetting($setting, &$config, $key, $allowedTypes = null, $defaultValue = null)
    {
        if (isset($config[$key])) {
            $this->checkSettingType($setting, $config, $key, $allowedTypes);
            return true;
        } else {
            $config[$key] = $defaultValue;
            return false;
        }
    }

    protected function typeOf($value)
    {
        $type = gettype($value);

        // Special case to distinguish YAML mappings (assoc arrays) from sequences
        if ($type === 'array' && array_keys($value) !== range(0, count($value) - 1))
            $type = 'mapping';

        return $type;
    }

    protected function typesToString($types)
    {
        if (count($types) > 1) {
            $last       = array_pop($types);
            $secondLast = array_pop($types);
            $types[] = "$secondLast or $last";
        }

        return implode(', ', $types);
    }

    protected function settingName($setting, $key)
    {
        if ($setting) {
            if ($key)
                return "Setting '$setting.$key'";
            else
                return "Setting '$setting'";
        } else {
            if ($key)
                return "Setting '$key'";
            else
                return 'Root';
        }
    }

    protected function checkSettingType($setting, $config, $key, $allowedTypes = null)
    {
        // Skip if no valid types were specified (meaning anything is allowed)
        // if ($allowedTypes === null)
        //     return;

        // Find the setting's value
        $value = ($key ? $config[$key] : $config);

        // Work out the type
        $type = $this->typeOf($value);

        // If it fails, we're going to need to list the types that were valid
        // in a human-readable format, so we'll prepare that at the same time
        $typesForError = [];

        // Accept a single accepted type or an array
        $allowedTypes = (array) $allowedTypes;

        // Check each type
        foreach ($allowedTypes as $allowedType) {
            // Types
            if ($allowedType === 'boolean' || $allowedType === 'mapping' || $allowedType === 'string') {
                if ($type === $allowedType)
                    return;

                $typesForError[] = "a $allowedType";

            } elseif ($allowedType === 'array') {
                if ($type === $allowedType)
                    return;

                $typesForError[] = "an $allowedType";

            // Specific values
            } elseif ($allowedType === true || $allowedType === false) {
                if ($value === $allowedType)
                    return;

                $typesForError[] = $allowedType ? 'true' : 'false';

            // This shouldn't happen!
            } else {
                throw new LogicException("BUG: Unknown type '{$allowedType}' in checkSettingType()");
            }
        }

        // No valid types found
        $settingName = $this->settingName($setting, $key);
        $typesString = $this->typesToString($typesForError);

        // Avoid confusing message "must be string or false (actual type is boolean)"
        if ($type === 'boolean' && (in_array(false, $allowedTypes, true) || in_array(true, $allowedTypes, true)))
            $actual = "value is " . ($value ? 'true' : 'false');
        else
            $actual = "type is {$type}";

        throw new ConfigNormaliserExeception("{$settingName} must be {$typesString} (actual $actual)");
    }

    public function checkAllowedKeys($setting, $config, $keys)
    {
        foreach ($config as $key => $value) {
            if (!in_array($key, $keys, true)) {
                if ($setting)
                    throw new ConfigNormaliserExeception("Unknown setting '{$key}' in {$setting}");
                else
                    throw new ConfigNormaliserExeception("Unknown setting '{$key}' in (root)");
            }
        }
    }
}

class ConfigNormaliserExeception extends Exception {}
