module namespace util = "http://www.28msec.com/cloud9/lib/util";

import module namespace functx = "http://www.functx.com/";

declare function util:espace-quotes($string as xs:string)
as xs:string
{
  replace($string, '"', '\\"')
};

declare function util:unescape-quotes($string as xs:string)
as xs:string
{
  replace($string, '\\"', '"')
};

declare function util:parse($xdm as xs:string)
as node()*
{
  let $string := util:unescape-quotes($xdm)
  return
    parse-xml($string)/node()
};

declare function util:serialize($xdm as item()*)
as xs:string
{
  let $string := serialize($xdm, ())
  return
    util:espace-quotes($string)
};
