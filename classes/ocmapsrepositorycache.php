<?php

class OCMapsRepositoryCache
{
    public static function clearCache()
    {
        $repository = new OCMapsCacheManager();
        $repository->clearAllCache();
    }
}
