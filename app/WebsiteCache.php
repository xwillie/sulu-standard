<?php

/*
 * This file is part of Sulu.
 *
 * (c) MASSIVE ART WebServices GmbH
 *
 * This source file is subject to the MIT license that is bundled
 * with this source code in the file LICENSE.
 */

require_once __DIR__ . '/WebsiteKernel.php';

use Symfony\Component\HttpKernel\HttpKernelInterface;
use Symfony\Component\HttpKernel\HttpCache\Store;
use DTL\Symfony\HttpCacheTagging\Storage\DoctrineCache;
use DTL\Symfony\HttpCacheTagging\TagManager;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpKernel\HttpCache\HttpCache;
use Doctrine\Common\Cache\PhpFileCache;
use DTL\Symfony\HttpCacheTagging\TaggingKernel;
use Symfony\Component\HttpKernel\TerminableInterface;
use Symfony\Component\HttpFoundation\Response;
use Sulu\Component\HttpCache\Handler\TagsHandler;

class WebsiteCache implements HttpKernelInterface, TerminableInterface
{
    private $taggedKernel;
    private $appKernel;

    public function __construct(HttpKernelInterface $kernel)
    {
        $this->appKernel = $kernel;
        $store = new Store(__DIR__ . '/cache/http_cache');
        $httpCache = new HttpCache($kernel, $store);

        // our tag storage strategy
        $tagStorage = new DoctrineCache(new PhpFileCache(__DIR__ . '/cache/http_tags'));
        $tagManager = new TagManager($tagStorage, $store);

        // now you can procss the request
        $this->taggedKernel = new TaggingKernel($httpCache, $tagManager, [
            'tag_encoding' => 'comma-separated',
            'header_invalidate_tags' => TagsHandler::TAGS_HEADER
        ]);
    }

    public function handle(Request $request, $type = HttpKernelInterface::MASTER_REQUEST, $catch = true)
    {
        return $this->taggedKernel->handle($request);
    }

    public function terminate(Request $request, Response $response)
    {
        $this->appKernel->terminate($request, $response);
    }

}
