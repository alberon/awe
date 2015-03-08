<?php
namespace Alberon\Awe;

use FilesystemIterator;
use Illuminate\Filesystem\Filesystem as BaseFilesystem;

class Filesystem extends BaseFilesystem
{
    /**
     * Recursively delete a directory.
     *
     * DJM: Modified to account for symlinks
     * https://github.com/laravel/framework/pull/7655
     *
     * The directory itself may be optionally preserved.
     *
     * @param  string  $directory
     * @param  bool    $preserve
     * @return bool
     */
    public function deleteDirectory($directory, $preserve = false)
    {
        if ( ! $this->isDirectory($directory)) return false;

        $items = new FilesystemIterator($directory);

        foreach ($items as $item)
        {
            // If the item is a directory, we can just recurse into the function and
            // delete that sub-directory otherwise we'll just delete the file and
            // keep iterating through each file until the directory is cleaned.
            if ($item->isDir() && ! $item->isLink())
            {
                $this->deleteDirectory($item->getPathname());
            }

            // If the item is just a file, we can go ahead and delete it since we're
            // just looping through and waxing all of the files in this directory
            // and calling directories recursively, so we delete the real path.
            else
            {
                $this->delete($item->getPathname());
            }
        }

        if ( ! $preserve) @rmdir($directory);

        return true;
    }

    /**
     * Determine if the given path is a symlink.
     *
     * @param  string  $link
     * @return bool
     */
    public function isLink($link)
    {
        return is_link($link);
    }
}
