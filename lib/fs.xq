module namespace fs = "http://www.28msec.com/cloud9/lib/fs";

import module namespace date = "http://www.zorba-xquery.com/modules/datetime";
import module namespace base64 = "http://www.zorba-xquery.com/modules/converters/base64";

import module namespace store = "http://www.28msec.com/modules/store";

import schema namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
import schema namespace f = "http://www.28msec.com/cloud9/schemas/fs"; 

declare namespace file = "http://expath.org/ns/file";

declare collection fs:inodes as schema-element(f:inode);
declare variable $fs:inodes as xs:QName := xs:QName('fs:inodes');

declare %an:automatic %an:value-range index fs:inode-range
  on nodes db:collection(xs:QName('fs:inodes'))
  by string(@uri) as xs:string;
declare variable $fs:inode-range as xs:QName := xs:QName('fs:inode-range');

declare %an:automatic %an:value-equality %an:unique index fs:inode-id
  on nodes db:collection(xs:QName('fs:inodes'))
  by xs:string(@uri || @child) as xs:string;

(: Index folder by parent :)
declare %an:automatic %an:value-equality index fs:inode
  on nodes db:collection(xs:QName('fs:inodes'))
  by xs:string(@uri) as xs:string,
     xs:string(@child) as xs:string;
declare variable $fs:inode as xs:QName := xs:QName('fs:inode');

(: Declare collection of documents :)
declare collection fs:files as schema-element(f:file);
declare variable $fs:files as xs:QName := xs:QName('fs:files');

(: Access a document range :)
declare %an:automatic %an:unique %an:value-equality index fs:file
  on nodes db:collection(xs:QName('fs:files'))
  by xs:string(@path) as xs:string;
declare variable $fs:file as xs:QName := xs:QName('fs:file');

declare variable $fs:path-separator as xs:string := ":";
declare variable $fs:directory-separator as xs:string := "/";

declare %an:sequential function fs:swip()
{
  db:delete-nodes(db:collection($fs:inodes));
  db:delete-nodes(db:collection($fs:files));
};

declare function fs:file($path as xs:string)
as schema-element(f:file)?
{
  let $path := fs:path-to-native($path)
  return
    idx:probe-index-point-value($fs:file, $path)
};

declare function fs:file-must-exists($path as xs:string)
as schema-element(f:file)
{
  fs:file($path)
};

declare function fs:is-directory($path as xs:string)
as xs:boolean
{
  let $path := fs:path-to-native($path)
  return
    if($path = "/") then
      count(idx:probe-index-range-value($fs:inode-range, "/", "/", true(), true(), true(), true())) ge 1
    else
      let $inode := fs:inode($path)
      return $inode/@file = false()
};

declare %an:sequential function fs:delete-file($path as xs:string)
as empty-sequence()
{
  variable $path := fs:path-to-native($path);
  variable $inode := fs:inode-must-exists($path);
  variable $file := idx:probe-index-point-value($fs:file, $path);
  db:delete-nodes($inode);
  db:delete-nodes($file);
  store:flush();
};

declare %an:sequential function fs:append-binary(
  $file as xs:string,
  $content as xs:base64Binary*
) as empty-sequence()
{
  error(xs:QName('fs:NOT_IMPLEMENTED'), "This function is not implemented yet.")
};

declare %an:sequential function fs:append-text(
  $file as xs:string,
  $content as xs:string*
) as empty-sequence()
{
  error(xs:QName('fs:NOT_IMPLEMENTED'), "This function is not implemented yet.")
};

declare %an:sequential function fs:create-directory(
  $dir as xs:string
) as empty-sequence()
{
  let $dir := fs:path-to-native($dir)
  let $segments := tokenize($dir, "/")
  for $segment at $i in $segments
  where $i gt 1
  let $current := string-join(subsequence($segments, 1, $i - 1), "/")
  let $full := $current || "/" || $segment
  let $current := if($current = "") then "/" else $current
  return
    if(not(fs:is-directory($full)) and $segment != "") then {
      db:insert-nodes($fs:inodes, validate { <f:inode uri="{$current}" child="{$segment}" last-modified="{date:current-dateTime()}" file="false" size="0" /> });
      store:flush();
      if($current != "/") then {
        fs:touch-inode($current);
      } else {}
    } else {}
};

declare %an:nondeterministic function fs:is-file(
  $file as xs:string
) as xs:boolean
{
  let $file := fs:path-to-native($file)
  return
    count(idx:probe-index-point-value($fs:file, $file)) = 1
};

declare %an:nondeterministic function fs:read-text(
  $file as xs:string,
  $encoding as xs:string
) as xs:string
{
  base64:decode(fs:read-binary($file), $encoding)
};

declare %an:nondeterministic function fs:read-binary(
  $file as xs:string
) as xs:base64Binary
{
  let $content := fs:file-must-exists($file)/text()
  return if(empty($content)) then
    xs:base64Binary("")
  else $content
};

declare %an:sequential function fs:write-binary(
  $path as xs:string,
  $content as xs:base64Binary
) as empty-sequence()
{
  let $path := fs:path-to-native($path)
  let $parent := fs:dir-name($path)
  let $child := fs:base-name($path)
  let $file := fs:file($path)
  let $size := fs:binary-size($content)
  return if(not(fs:is-directory($parent))) then {
    error(xs:QName("file:FOFL9999"))
  } else if(empty($file)) then {
    fs:touch-inode($parent);
    db:insert-nodes($fs:inodes, validate { <f:inode uri="{$parent}" child="{$child}" last-modified="{date:current-dateTime()}" file="true" size="{$size}" /> } );
    db:insert-nodes($fs:files, validate { <f:file path="{$path}">{$content}</f:file> } );
    store:flush();
  } else if(fs:is-directory($path)) then {
    error(xs:QName("file:FOFL0004"))
  } else {
    fs:touch-inode($parent);
    variable $inode := fs:inode-must-exists($path);
    replace value of node $inode/@last-modified with date:current-dateTime();
    replace value of node $inode/@size with $size;
    replace value of node $file with $content;
  }
};

declare %an:sequential function fs:write-text(
  $file as xs:string,
  $content as xs:string*
) as empty-sequence()
{
  fs:write-binary($file, base64:encode($content))
};

declare %an:nondeterministic function fs:list(
  $dir as xs:string
) as xs:string*
{
  let $dir := fs:path-to-native($dir)
  return
    idx:probe-index-point-value($fs:inode-range, $dir)/@child 
};

declare %an:nondeterministic function fs:last-modified(
  $path as xs:string
) as xs:dateTime 
{
  let $inode := fs:inode-must-exists($path)
  return
    $inode/@last-modified
};

declare function fs:inode($path as xs:string) as schema-element(f:inode)?
{
  let $path := fs:path-to-native($path)
  let $parent := fs:dir-name($path)
  let $child  := fs:base-name($path)
  return idx:probe-index-point-value($fs:inode, $parent, $child)
};

declare function fs:inode-must-exists($path as xs:string) as schema-element(f:inode)
{
  fs:inode($path)
};

declare %an:sequential function fs:touch-inode($path as xs:string)
as empty-sequence()
{
  variable $inode := fs:inode-must-exists($path);
  replace value of node $inode/@last-modified with date:current-dateTime();
};

declare function fs:size(
  $file as xs:string
) as xs:integer
{
  let $inode := fs:inode-must-exists($file)
  return $inode/@size
};

declare function fs:binary-size(
  $base64 as xs:base64Binary
) as xs:integer
{
  let $base64 := string($base64)
  let $body := if(contains($base64, "=")) then substring-before($base64, "=") else $base64
  let $padding := string-length(substring($base64, string-length($body) + 1))
  return xs:integer(string-length($body) * 3 div 4 - 0.25 * $padding) 
};

declare function fs:path-to-native($path as xs:string) 
as xs:string
{
  let $segments := tokenize($path, "/")[. != ""]
  return "/" || string-join($segments, "/")
};

declare function fs:dir-name($path as xs:string) as xs:string
{
  let $path := fs:path-to-native($path)
  let $tokens := tokenize($path, "/")[. != ""]
  return
    "/" || string-join(
      subsequence($tokens, 1, count($tokens) - 1),
      "/"
  )
};

(:~
 : Returns the last component from the <pre>$path</pre>, deleting any
 : trailing directory-separator characters. If <pre>$path</pre> consists
 : entirely directory-separator characters, the empty string is returned. If
 : <pre>$path</pre> is the empty string, the string <pre>"."</pre> is returned,
 : signifying the current directory.
 :
 : No path existence check is made.
 :
 : @param $path A file path/URI.
 : @return The base name of this file.
 :)
declare function fs:base-name($path as xs:string) as xs:string?
{
  let $segments := tokenize($path, "/")[. != ""]
  return $segments[last()]
};
