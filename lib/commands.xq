module namespace c = "http://www.28msec.com/cloud9/lib/commands";

import module namespace reflection = "http://www.zorba-xquery.com/modules/reflection";

import module namespace file = "http://www.28msec.com/cloud9/lib/file";

import module namespace m = "http://www.28msec.com/cloud9/lib/socket.io/message";

declare %an:sequential function c:run($cmd as object())
as xs:string*
{
  let $base := "/fs/workspace/"
  let $file := $base || $cmd("file")
  let $content := file:read-text($file)
  let $result :=  try {
      let $result := serialize(reflection:eval-s($content), ())
      return { "stream": "stdout", "data": $result }
    } catch * {
      let $result := $file || ":" || $err:line-number || ":" || $err:column-number || ": " || $err:description
      return { "stream": "stderr", "data": $result }
    }
  return
  (
    m:msg({"type":"node-start","pid":42}),
    m:msg({"type":"node-data","stream":"stdout","data":"","extra":null,"pid":42}),
    m:msg({"type":"node-data","pid":42,"stream": $result("stream"),"data": $result("data") }),
    m:msg({"type":"state","node":42,"processRunning":"42","workspaceDir":"/Users/wcandillon/28msec/editor/c9"}),
    m:msg({"type":"node-exit","pid":42,"code":0})
  )
};

declare function c:kill($cmd as object())
as xs:string
{
    m:msg({"type": "node-exit", "pid": 42, "code": 0 })
};
