module namespace l  = "http://www.28msec.com/cloud9/lib/webdav/locks";

import module namespace r = "http://www.zorba-xquery.com/modules/random";
import module namespace date = "http://www.zorba-xquery.com/modules/datetime";
import module namespace store = "http://www.28msec.com/modules/store";

declare namespace d = "DAV:";

declare collection l:locks as element(lock);
declare variable $l:locks as xs:QName := xs:QName('l:locks');

declare %an:automatic %an:value-equality index l:lock
  on nodes db:collection(xs:QName('l:locks'))
  by xs:string(@path) as xs:string;
declare variable $l:lock as xs:QName := xs:QName('l:lock');

declare %an:automatic %an:value-equality index l:lock-by-id
  on nodes db:collection(xs:QName('l:locks'))
  by xs:string(@path) as xs:string,
     xs:string(@id) as xs:string;
declare variable $l:lock-by-id as xs:QName := xs:QName('l:lock-by-id');

declare %an:automatic %an:value-equality index l:infinite-lock
  on nodes db:collection(xs:QName('l:locks'))[@infinite = "true"]
  by xs:string(@path) as xs:string;
declare variable $l:infinite-lock as xs:QName := xs:QName('l:infinite-lock');

declare %an:automatic %an:value-equality index l:infinite-lock-by-id
  on nodes db:collection(xs:QName('l:locks'))[@infinite = "true"]
  by xs:string(@path) as xs:string,
     xs:string(@id) as xs:string;
declare variable $l:infinite-lock-by-id as xs:QName := xs:QName('l:infinite-lock-by-id');

declare variable $l:locked as xs:QName := xs:QName('l:locked');
declare variable $l:unlocked as xs:QName := xs:QName('l:unlocked');
declare variable $l:precondition-failed as xs:QName := xs:QName('l:precondition-failed');

declare variable $l:max-timeout as xs:integer := 1800;

declare function l:is-locked($path as xs:string)
as xs:boolean
{
  (
    let $segments := tokenize($path, "/")
    for $segment at $i in $segments
    where $i gt 1 and $i lt count($segments)
    let $path := string-join(subsequence($segments, 1, $i), "/")
    return count(idx:probe-index-point-value($l:infinite-lock, $path)) gt 0
    ,
    count(idx:probe-index-point-value($l:lock, $path)) gt 0
  ) = true()
};

declare function l:is-locked($path as xs:string, $id as xs:string)
as xs:boolean
{
  (
    let $segments := tokenize($path, "/")
    for $segment at $i in $segments
    where $i gt 1 and $i lt count($segments)
    let $path := string-join(subsequence($segments, 1, $i), "/")
    return count(idx:probe-index-point-value($l:infinite-lock-by-id, $path, $id)) eq 1
    ,
    count(idx:probe-index-point-value($l:lock-by-id, $path, $id)) eq 1
  ) = true()    
};

declare %an:sequential function l:unlock($path as xs:string, $id as xs:string)
as empty-sequence()
{
  variable $lock := idx:probe-index-point-value($l:lock-by-id, $path, $id);
  if(empty($lock)) then
    error($l:unlocked);
  else ();
  db:delete-nodes($lock); 
  store:flush();
};

declare %an:sequential function l:locks($path as xs:string)
as element(lock)*
{
    let $segments := tokenize($path, "/")
    for $segment at $i in $segments
    where $i gt 1 and $i lt count($segments)
    let $path := string-join(subsequence($segments, 1, $i), "/")
    return idx:probe-index-point-value($l:infinite-lock, $path)
    ,
    idx:probe-index-point-value($l:lock, $path)    
};

declare %an:sequential function l:lock($path as xs:string, $timeout as xs:integer, $lockinfo as element(d:lockinfo), $infinite as xs:boolean)
as element(lock)
{
  variable $type := $lockinfo/d:lockscope/*/local-name(.);
  variable $locks := l:locks($path);
  
  for $lock in $locks
  return
    if(xs:dateTime($lock/@expires) lt date:current-dateTime()) then
      db:delete-nodes($lock);
    else if(exists($lock)) then
      (
        let $current-type as xs:string := $lock/d:lockinfo/d:lockscope/*/local-name(.)
        return
          if($current-type eq "exclusive") then
            error($l:locked)
          else if($type eq "exclusive") then
            error($l:locked)
          else ()
      );
    else
      ();
  
  variable $uuid := "urn:uuid:" || r:uuid();
  variable $timeout := if($timeout gt $l:max-timeout) then $l:max-timeout else $timeout;
  variable $new-lock := <lock id="{$uuid}" path="{$path}" expires="{l:expires-in($timeout)}" timeout="{$timeout}" infinite="{$infinite}">{$lockinfo}</lock>;
  db:insert-nodes($l:locks, $new-lock);
  $new-lock
};

declare %an:sequential function l:refresh-lock($path as xs:string, $id as xs:string, $timeout as xs:integer)
as element(lock)
{
   variable $lock :=  (
    let $segments := tokenize($path, "/")
    for $segment at $i in $segments
    where $i gt 1 and $i lt count($segments)
    let $path := string-join(subsequence($segments, 1, $i), "/")
    return idx:probe-index-point-value($l:infinite-lock-by-id, $path, $id)
    ,
    idx:probe-index-point-value($l:lock-by-id, $path, $id)
   )[1];
   if(empty($lock)) then error($l:precondition-failed); else ();
   replace value of node $lock/@timeout with $timeout;
   replace value of node $lock/@expires with l:expires-in($timeout);
   $lock  
};

declare %an:nondeterministic function l:expires-in($timeout as xs:integer)
as xs:dateTime
{
  date:current-dateTime() + $timeout * xs:dayTimeDuration('PT1S')
};
