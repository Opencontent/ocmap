<?php


class OCMapsCacheManager
{

  const DIRECTORY_NAME = 'maps';
  const SUBDIRECTORY_NAME = 'data';

  public static function getCacheManager( $hashIdentifier )
  {
    $cacheFile = $hashIdentifier . '.cache';
    $cacheFilePath = eZDir::path(
      array( eZSys::cacheDirectory(), self::DIRECTORY_NAME, self::SUBDIRECTORY_NAME, $cacheFile )
    );

    return eZClusterFileHandler::instance( $cacheFilePath );
  }

  public function clearCache( $hashIdentifier )
  {
    $this->getCacheManager( $hashIdentifier )->purge();
  }

  public function clearAllCache()
  {
    $commonPath = eZDir::path( array( eZSys::cacheDirectory(), self::DIRECTORY_NAME ) );
    $fileHandler = eZClusterFileHandler::instance();
    $commonSuffix = '';
    $fileHandler->fileDeleteByDirList( array( self::SUBDIRECTORY_NAME ), $commonPath, $commonSuffix );
  }

  public static function retrieveCache( $file, $mtime, $hashIdentifier )
  {
    $content = include( $file );
    return $content;
  }

}
