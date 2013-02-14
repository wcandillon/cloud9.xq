module namespace test = "http://www.28msec.com/cloud9/tests";

import module namespace req = "http://www.28msec.com/modules/http/request";
import module namespace res = "http://www.28msec.com/modules/http/response";

import module namespace fs = "http://www.28msec.com/cloud9/lib/file";
import module namespace d = "http://www.28msec.com/cloud9/lib/fs";

import schema namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare variable $test:serialize-as-text := <output:serialization-parameters><output:method value="text"/></output:serialization-parameters>;

declare function test:d()
{
  db:collection($d:inodes),
  db:collection($d:files)
};

declare %an:sequential function test:list()
{
  test:list("/fs/workspace/")
};

declare %an:sequential function test:list($path as xs:string)
{
  <ul>{
    for $file in fs:list($path)
    let $fullpath := $path || "/" || $file
    return
      if(fs:is-directory($fullpath)) then
        <li>{$file}: {test:list($fullpath)}</li>
      else
        <li>{$file}</li>
  }</ul>
};

declare %an:sequential function test:fs()
{
(:
  fs:delete("/fs/workspace/");
  fs:delete("/fs/workspace2/");
:)  
  if(fs:exists("/fs/workspace/test")) then (); else
  fs:create-directory("/fs/workspace/test");
  
  fs:write("/fs/workspace/test/foo.txt", <foo><bar /></foo>, $test:serialize-as-text);
  
  if(fs:exists("/fs/workspace2/")) then (); else
  fs:create-directory("/fs/workspace2/");
  
  fs:copy("/fs/workspace/test/", "/fs/workspace2/");
  fs:list("/fs/workspace2/", true())
};

declare %an:sequential function test:delete()
{
  variable $path := req:parameter-values("path");
  variable $tokens := tokenize($path, "/");
  variable $parent := string-join(subsequence($tokens, 1, count($tokens) - 1), "/");
  fs:delete($path);
  res:set-redirect("/tests/explorer?path=" || $parent)
};

declare %an:sequential function test:new-file()
{
  variable $path := req:parameter-values("path");
  variable $tokens := tokenize($path, "/");
  variable $parent := string-join(subsequence($tokens, 1, count($tokens) - 1), "/");
  fs:write($path, "Hello World", $test:serialize-as-text);
  res:set-redirect("/tests/explorer?path=" || $parent)
};

declare %an:sequential function test:new-folder()
{
  variable $path := req:parameter-values("path");
  variable $tokens := tokenize($path, "/");
  variable $parent := string-join(subsequence($tokens, 1, count($tokens) - 1), "/");
  fs:create-directory($path);
  res:set-redirect("/tests/explorer?path=" || $parent)
};

declare %an:sequential function test:copy()
{
  variable $src := req:parameter-values("src");
  variable $dest := req:parameter-values("dest");
  if(not(fs:is-directory("/copy/fs/workspace"))) then
    fs:create-directory("/copy/fs/workspace");
  else ();
  fs:copy($src, $dest);
  res:set-redirect("/tests/explorer?path=" || $dest)
};

declare %an:sequential function test:explorer()
{
variable $path := req:parameter-values("path", "/fs/workspace");
variable $tokens := tokenize($path, "/");
variable $parent := string-join(subsequence($tokens, 1, count($tokens) - 1), "/");
res:set-content-type("text/html");
<html>
   <head>
   
   </head>
   <body>
   {
   if(fs:is-file($path)) then
     fs:read-text($path)
   else
   <div>
   <h1>{$path}</h1>
   <hr />
   <ul>
     <li><a href="/tests/new-file?path={$path}/test.txt">New File</a></li>
     <li><a href="/tests/new-folder?path={$path}/test">New Folder</a></li>
   </ul>
   <hr />
   <ul>
     <li><a href="/tests/explorer?path={$parent}">..</a></li>
   {
     for $file in fs:list($path)
     let $fullpath := $path || "/" || $file
     let $dest := "/copy/" || $fullpath
     return
       <li>
         <a href="/tests/explorer?path={$fullpath}">{$file}</a>
         (<a href="/tests/delete?path={$fullpath}">delete</a>,
          <a href="/tests/copy?src={$fullpath}&amp;dest={$dest}">copy</a>)
       </li>
   }
   </ul>
   </div>
   }
   </body>
</html>
};
