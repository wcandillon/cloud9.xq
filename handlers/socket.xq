module namespace s = "http://www.28msec.com/cloud9/socket";

import module namespace socket = "http://www.28msec.com/cloud9/lib/socket";


declare %an:sequential function s:server()
{
  socket:listen()
};

