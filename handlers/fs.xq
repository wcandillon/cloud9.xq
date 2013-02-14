module namespace fs = "http://www.28msec.com/cloud9/fs";

import module namespace date = "http://www.zorba-xquery.com/modules/datetime";

import module namespace req = "http://www.28msec.com/modules/http/request";
import module namespace res = "http://www.28msec.com/modules/http/response";

import module namespace dav = "http://www.28msec.com/cloud9/lib/webdav";
import module namespace auth  = "http://www.28msec.com/cloud9/lib/auth/digest";

declare %an:sequential function fs:workspace()
{
  dav:handle()
};
