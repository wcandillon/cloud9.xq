module namespace home = "http://www.28msec.com/cloud9/home";

import module namespace ran = "http://www.zorba-xquery.com/modules/random";

import module namespace cloud9 = "http://www.28msec.com/cloud9/lib/cloud9";

declare namespace html = "http://www.w3.org/1999/xhtml";

declare %an:sequential function home:index()
as element(html:html)
{
  cloud9:get("test", "test", ran:uuid())
};
