module namespace dav = "http://www.28msec.com/cloud9/lib/webdav";

import module namespace req = "http://www.28msec.com/modules/http/request";
import module namespace res = "http://www.28msec.com/modules/http/response";

import module namespace util = "http://www.28msec.com/cloud9/lib/webdav/util";
import module namespace file = "http://www.28msec.com/cloud9/lib/file";
import module namespace l  = "http://www.28msec.com/cloud9/lib/webdav/locks";
import module namespace if-parser = "http://www.28msec.com/cloud9/lib/webdav/if-header-parser";
import module namespace mimetypes = "http://www.28msec.com/cloud9/lib/mimetypes";

import schema namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare namespace a = "http://ajax.org/2005/aml";
declare namespace b = "urn:uuid:C2F41010-65B3-11d1-A29F-00AA00C14882/";
declare namespace d = "DAV:";

declare %private variable $dav:serialize-as-text := <output:serialization-parameters><output:method value="text"/></output:serialization-parameters>;

declare %private variable $dav:default-properties as xs:string+ := ("resourcetype", "getlastmodified", "getcontenttype", "getcontentlength");
declare %private variable $dav:properties as xs:string+ := ( $dav:default-properties, "supportedlock", "lockdiscovery" );

declare function dav:path()
as xs:string
{
  let $path := req:path()
  let $path := file:path-to-native($path)
  return $path
};

declare %an:sequential function dav:handle()
{
  variable $method := upper-case(req:method());
  switch($method)
    case "REPORT" return dav:report()
    case "PROPFIND" return dav:propfind()
    case "GET" return dav:get()
    case "PUT" return dav:put()
    case "MOVE" return dav:move()
    case "COPY" return dav:copy()
    case "DELETE" return dav:delete()
    case "MKCOL" return dav:mkcol()
    case "HEAD" return dav:head()
    case "OPTIONS" return dav:options()
    case "PROPPATCH" return dav:proppatch()
    case "UNLOCK" return dav:unlock()
    case "LOCK" return dav:lock()
    default
      return
        error(xs:QName('dav:UNKNOWN_METHOD'))
};

declare %an:sequential function dav:lock()
{
  variable $path := dav:path();
 
  if(not(file:exists($path))) then {
    try {
      file:write($path, (), ()); 
    } catch * {
      error($res:conflict);
    }
  } else {}
 
  variable $if as xs:string? := req:header-value("If");
  variable $timeout := xs:integer(substring-after(req:header-value("Timeout"), "Second-"));
  variable $lock := ();
  
  (: If the If header is present, we try to refresh the lock according to the If conditions :)
  if(exists($if)) then {
    variable $conditions := dav:if-conditions($if);
    for $condition in $conditions
    let $not := $condition/@not/exists(.)
    let $path := $condition/@path/string()
    for $state in $condition/state/text()
    let $locked := l:is-locked($path, $state)
    return
      if($not and $locked) then
        error($res:precondition-failed);
      else if(not($not) and not($locked)) then
        error($res:precondition-failed);
      else
        $lock := try { l:refresh-lock($path, $state, $timeout) } catch l:precondition-failed { error($res:precondition-failed) } ;
  } else {
    variable $lockinfo as element(d:lockinfo) := parse-xml(req:text-content())/d:lockinfo;
    variable $infinite as xs:boolean := let $depth := req:header-value("Depth") return if(empty($depth)) then false() else $depth eq "infinity";
    $lock := try {
      l:lock($path, $timeout, $lockinfo, $infinite)
    } catch l:locked {
      error($res:locked)
    };
    res:set-header("Lock-Token", $lock/@id);
  }
  
  let $lockinfo as element(d:lockinfo) := $lock/d:lockinfo
  return
  <d:prop> 
    <d:lockdiscovery> 
      <d:activelock> 
        {$lockinfo/d:lockscope, $lockinfo/d:locktype, $lockinfo/d:owner}
        <d:depth>{if($lock/@infinity="true") then "infinity" else "0"}</d:depth> 
        <d:timeout>Second-{$lock/@timeout/string()}</d:timeout> 
        <d:locktoken> 
          <d:href>{$lock/@id/string()}</d:href>
        </d:locktoken> 
        <d:lockroot> 
          <d:href>{$path}</d:href>
        </d:lockroot> 
      </d:activelock> 
    </d:lockdiscovery> 
  </d:prop> 
};

declare %an:sequential function dav:unlock()
{
  res:set-status-code(200);
  variable $path := dav:path();
  let $id := req:header-value("Lock-Token")
  let $id := if(empty($id)) then error($res:bad-request) else $id
  let $id := util:absolute-uri($id)
  return
    try {
      l:unlock($path, $id)
    } catch l:unlocked {
      error($res:conflict)
    }
};

declare %an:sequential function dav:options()
{
  res:set-status-code(200);
  res:set-header("DAV", "1,2");
};

declare %an:sequential function dav:mkcol()
as empty-sequence()
{
  variable $path := dav:path();
  try {
    {
      variable $content := if(req:content-length() gt 0) then req:text-content() else "";
      res:set-status-code(201);
      if(not(file:is-directory(file:dir-name($path)))) then
        res:set-status-code(409);
      else if(file:is-file($path)) then
        res:set-status-code(405);
      else
        file:create-directory($path);
    }
  } catch file:FOFL0002 {
    res:set-status-code(405);
  } catch req:no-text-content {
    res:set-status-code(415);
  } catch req:invalid-encoding {
    res:set-status-code(415);
  }
};

declare %an:sequential function dav:head()
as empty-sequence()
{
  dav:get(); (: ; because we don't return anything' :)
};



declare %an:sequential function dav:get()
{
  res:set-content-type(mimetypes:type-by-filename(dav:path()));
  try {
    {
      res:set-status-code(200);  
      res:set-decode-binary(true());    
      file:read-binary(dav:path())
    }
  } catch file:FOFL0001 {
    {
    res:set-status-code(404);
    <d:error>
      <a:exception>File Not Found</a:exception>
      <a:message>File at location {dav:path()} not found</a:message>
    </d:error>
    }
  }
};

declare %an:sequential function dav:delete()
{
  try {
    let $path := dav:path()
    return
      if(l:is-locked($path)) then
        error($res:locked)
      else
        file:delete($path) 
  } catch file:FOFL0001 {
    {
    res:set-status-code(404);
    <d:error>
      <a:exception>File Not Found</a:exception>
      <a:message>File at location {dav:path()} not found</a:message>
    </d:error>
    }
  }
};


declare %an:sequential function dav:copy()
{
  variable $source := dav:path();
  variable $destination := dav:destination();
  variable $overwrite := req:header-value("overwrite");
  $overwrite := if($overwrite eq "T" or empty($overwrite)) then true() else false();
  if(not($overwrite) and file:exists($destination)) then
    error($res:precondition-failed);
  else if(not(file:exists($source))) then
    error($res:conflict);
  else
    ();
   try {
     {
        if(file:exists($destination)) then {
          file:delete($destination);
          res:set-status-code(204);
        } else {
          res:set-status-code(201);
        }
        
        dav:is-allowed($destination);
        file:copy($source, $destination);
      }
    } catch file:FOFL0003 {
      {
        res:set-status-code(409);
      }
    }
};

declare %an:sequential function dav:move()
{
  variable $source := dav:path();
  variable $destination := dav:destination();
  variable $overwrite := req:header-value("overwrite");
  $overwrite := if($overwrite eq "T" or empty($overwrite)) then true() else false();
  if(not($overwrite) and file:exists($destination)) then
    error($res:precondition-failed);
  else if(not(file:exists($source))) then
    error($res:conflict);
  else
    ();
  try {
    {
      if(file:exists($destination)) then {
        file:delete($destination);
        res:set-status-code(204);
      } else {
        res:set-status-code(201);
      }
     
      dav:is-allowed();
      dav:is-allowed($destination);
      file:move($source, $destination);
      
}
    } catch file:FOFL0003 {
      {      
        res:set-status-code(409);
      }
    }
};


declare %an:sequential function dav:put()
{
  dav:is-allowed();
  try {
    res:set-status-code(201);
    file:write-binary(dav:path(), req:binary-content());
  } catch file:FOFL0004 {
    res:set-status-code(409);
  }
};

declare %an:sequential function dav:report()
{
  res:set-status-code(207);
  res:set-content-type("text/xml");
  for $file in file:list(req:path(), true())
  let $x := $file
  return "./" || $file || "
"
};

declare %an:sequential function dav:proppatch()
{
  variable $doc := try { parse-xml(req:text-content()) } catch * { error($res:bad-request) };
  variable $response := ();
  if(exists($doc/d:propertyupdate)) then {
    res:set-status-code(403);
  } else {
    res:set-status-code(207);
    $response := <d:multistatus>
      <d:response>
        <d:href>{dav:path()}</d:href>
        {
          for $prop in $doc//d:prop
          return
            <d:propstat>
              {$prop}
              <d:status>HTTP/1.1 403</d:status>
            </d:propstat>
        }
       </d:response>
     </d:multistatus>;
  }
  $response
};

declare %an:sequential function dav:propfind()
{
  try {
    {
      variable $depth as xs:string := let $depth := req:header-value("Depth")
                         let $depth := if(empty($depth)) then "infinity" else lower-case($depth)
                         let $depth := if($depth = "") then "infinity" else $depth
                         return if($depth = "0" or $depth = "1" or "infinity") then $depth else error($res:bad-request);
     
     variable $properties as element(d:propfind)? := try { parse-xml(req:text-content())/d:propfind } catch * { error($res:bad-request) };
      
      
  res:set-status-code(207);
  
  let $base := req:path()
  let $base := if(file:exists($base)) then $base else error($res:not-found)
  let $base1 := if (not(ends-with($base, "/"))) then ($base || "/") else $base
  let $list := ($base, if(file:is-directory($base) and $depth = "1") then
                 for $resource in file:list($base) return $base1 || $resource
               else if(file:is-directory($base) and $depth = "infinity") then
                 for $resource in file:list($base, true()) return $base1 || $resource
               else ())
  return
    <d:multistatus>
      {
        for $href in $list
        (:
         : Its is a WebDAV recommendation to add a trailing slash to collectionnames.
         : Apple's iCal also requires a trailing slash for principals (rfc 3744).
         : Therefore we add a trailing / for any non-file. This might need adjustments
         :  if we find there are other edge cases.
         :)
        let $href := if(file:is-directory($href) and not(ends-with($href, "/"))) then $href || "/" else $href
        return <d:response>
          <d:href>{$href}</d:href>
           <d:propstat>
            <d:prop>
            {
              let $props as xs:string* := if(empty($properties) or exists($properties/d:allprop)) then
                              $dav:default-properties
                            else
                              $properties/d:prop/d:*/local-name(.)
              (:let $props as xs:string* := if() then else:)
              for $prop in $props
              return dav:property($href, $prop)
            }
            </d:prop>
            <d:status>HTTP/1.1 200 OK</d:status>
        </d:propstat>
        </d:response>
      }
    </d:multistatus>
  }
} catch res:not-found {
  {
    res:set-status-code(404);
    <d:error>
      <a:exception>File Not Found</a:exception>
      <a:message>File at location {req:path()} not found</a:message>
    </d:error>
  }
} catch file:FOFL0001 {
  {
    res:set-status-code(404);
    <d:error>
      <a:exception>File Not Found</a:exception>
      <a:message>File at location {req:path()} not found</a:message>
    </d:error>
  }
}
};

declare %private %an:nondeterministic function dav:property($resource as xs:string, $property as xs:string)
as element()?
{
  switch($property)
  case "getlastmodified"
  return <d:getlastmodified b:dt="dateTime.rfc1123">{util:dateTime-rfc1123(file:last-modified($resource))}</d:getlastmodified>
  
  case "getcontentlength"
  return if(file:is-file($resource)) then <d:getcontentlength>{file:size($resource)}</d:getcontentlength> else ()
  
  case "getcontenttype"
  return  if(file:is-file($resource)) then <d:getcontenttype>{ mimetypes:type-by-filename($resource) }</d:getcontenttype> else ()
      
  case "resourcetype"
  return
    if(file:is-directory($resource)) then
      <d:resourcetype><d:collection/></d:resourcetype>
    else ()
                    
  default return ()
};

declare %private function dav:destination()
as xs:string
{
  variable $destination := req:header-value("destination");
  
  if(empty($destination)) then
    error($res:bad-request)
  else
    dav:destination($destination)
};

declare %private function dav:destination($destination)
as xs:string
{
  let $regexp := "[[:alpha:]]+://[^/[:space:]]+[[:alnum:]]"
  return
    if(matches($destination, $regexp)) then
      replace($destination, $regexp, "")
    else
      $destination
};

declare  function dav:if-conditions()
as element(condition)*
{
  let $if := req:header-value("If")
  return
    if(exists($if)) then
      dav:if-conditions($if)
    else ()
};

(:~
 : @see http://msdn.microsoft.com/en-us/library/exchange/aa142886(v=exchg.65).aspx
 :)
declare function dav:if-conditions($if as xs:string)
as element(condition)+
{
  let $if := if-parser:parse-If($if)
  for $rootList in $if/*[local-name(.) eq "NoTaggedList" or local-name(.) eq "TaggedList"]
  let $path := if($rootList instance of element(TaggedList)) then dav:destination(util:absolute-uri($rootList/Resource/CodedURL/absoluteURI/text())) else dav:path()
  for $list in $rootList/List
  return <condition path="{$path}">
  {
    if(exists($list/TOKEN[text() = "Not"])) then
      attribute not { "true" }
    else (),
    for $uri in $list//absoluteURI/text()
    let $uri := util:absolute-uri($uri)
    return <state>{$uri}</state>
  }
  </condition>
};


declare %an:sequential function dav:is-allowed()
as empty-sequence()
{
  dav:is-allowed(dav:path())
};

declare %an:sequential function dav:is-allowed($path as xs:string)
as empty-sequence()
{
  let $conditions := dav:if-conditions()
  let $conditions := if(empty($conditions) and l:is-locked($path)) then error($res:locked) else $conditions
  for $condition in $conditions
  let $path := $condition/@path/string()
  let $not  := $condition/@not/exists(.)
  for $state in $condition/state
  let $id := $state/text()
  let $locked := l:is-locked($path, $state)
  return if($not and $locked) then
        error($res:precondition-failed)
      else if(not($not) and not($locked)) then
          error($res:precondition-failed)
      else ()
};
