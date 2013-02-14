module namespace f = 'http://www.28msec.com/cloud9/lib/callback';

import module namespace r = "http://www.zorba-xquery.com/modules/reflection";

declare %an:sequential function f:callback($name as xs:QName, $message as xs:string)
as xs:string*
{
  let $query :=
        'import module namespace m = "' || namespace-uri-from-QName($name) || '";'
    ||  'm:' || local-name-from-QName($name)
    ||  '('
    ||  "'" || $message || "'"
    ||  ')'
  return
      r:eval-s($query)
};