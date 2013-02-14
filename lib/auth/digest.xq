module namespace auth  = "http://www.28msec.com/cloud9/lib/auth/digest";

import module namespace hash = "http://www.zorba-xquery.com/modules/cryptography/hash";
import module namespace ran = "http://www.zorba-xquery.com/modules/random";

import module namespace req = "http://www.28msec.com/modules/http/request";
import module namespace res = "http://www.28msec.com/modules/http/response";

declare variable $auth:scheme as xs:string := "Digest ";

declare variable $auth:login as xs:string := "test";
declare variable $auth:password as xs:string := "test";

declare variable $auth:algo as xs:string := "MD5";
declare variable $auth:qop as xs:string := "auth";

declare %an:sequential function auth:authorize()
as empty-sequence()
{ 
    try {
      let $params := auth:parse-params()
      return auth:authorize($params)
    } catch res:unauthorized {
      error($res:unauthorized, "Unauthorized", { "WWW-Authenticate": $auth:scheme || auth:www-authenticate-header() })
    }
};

declare %an:sequential function auth:authorize($params as object())
as empty-sequence()
{
    let $params := trace($params, "params")
    let $username := $params("username")
    let $username := trace($username, "username")
    let $realm := $params("realm")
    let $realm := trace($realm, "realm")
    let $nonce := $params("nonce")
    let $nonce := trace($nonce, "nonce")
    let $uri   := $params("uri")(: TODO: req:path() :)
    let $uri := trace($uri, "uri")
    let $nc    := $params("nc")
    let $nc := trace($nc, "nc")
    let $cnonce := $params("cnonce")
    let $cnonce := trace($cnonce, "cnonce")
    let $qop    := $params("qop")
    let $qop    := trace($qop, "qop")
    let $ha1 := auth:md5(string-join(($username, $realm, $auth:password), ":"))
    let $ha1 := trace($ha1, "ha1")
    let $ha2 := auth:md5(string-join((trace(req:method(), "method"), $uri), ":"))
    let $ha2 := trace($ha2, "ha2")
    let $response := auth:md5(trace(string-join(($ha1, $nonce, $nc, $cnonce, $qop, $ha2), ":"), "RESPONSE"))
    return if(trace(lower-case($response), "res1") ne trace($params("response"), "res2")) then error($res:unauthorized) else ()
};

(:~
 : Parse the Authorization header.
 :
 : @error res:unauthorized
 :)
declare function auth:parse-params()
as object()
{
  let $header := req:header-value("Authorization")
  let $header := if(empty($header)) then error($res:unauthorized) else $header
  let $params := substring-after($header, $auth:scheme)
  let $params := auth:parse-params($params)
  return $params
};

declare %an:nondeterministic function auth:www-authenticate-header()
as xs:string
{
  let $params := {
    "realm": req:server-name(),
    "qop": $auth:qop,
    "algorithm": $auth:algo,
    "nonce": auth:nonce(),
    "opaque": auth:opaque()   
  }
  return auth:serialize-params($params)
};

declare function auth:parse-params($params as xs:string)
as object()
{
  {|
    let $params := tokenize($params, ",")
    for $param in $params
    let $split := tokenize($param, "=")
    let $key   := $split[1]
    let $key   := normalize-space($key)
    let $value := $split[2]
    let $value := replace(replace($value,'\s+$',''),'^\s+','')
    let $value := if(starts-with($value, '"')) then substring($value, 2, string-length($value) - 2) else $value
    return { $key: $value }
  |}
};

declare function auth:serialize-params($params as object())
as xs:string
{
  let $values :=
    for $key in jn:keys($params)
    return $key || "=" || '"' || $params($key) || '"'
  return string-join($values, ",")
};

declare function auth:md5($input as xs:string)
as xs:string
{
  lower-case(string(xs:hexBinary(hash:md5($input))))
};

declare %an:nondeterministic function auth:nonce()
as xs:string
{
  ran:uuid()
};

declare %an:nondeterministic function auth:opaque()
as xs:string
{
  ran:uuid()
};
