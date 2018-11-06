<?php

class OCMapsRepositoryCache
{
    public static function clearCache()
    {
        $repository = new MapsCacheManager();
        $repository->clearAllCache();
    }
}
