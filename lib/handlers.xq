module namespace s = "http://www.28msec.com/cloud9/lib/handlers";

import module namespace reflection = "http://www.zorba-xquery.com/modules/reflection";
import module namespace json = "http://www.zorba-xquery.com/modules/converters/json";

import module namespace req = "http://www.28msec.com/modules/http/request";
import module namespace res = "http://www.28msec.com/modules/http/response";

import module namespace cloud9 = "http://www.28msec.com/cloud9/lib/cloud9";

import module namespace file = "http://www.28msec.com/cloud9/lib/file";

declare namespace j = "http://john.snelson.org.uk/parsing-json-into-xquery";

declare %an:sequential function s:message($message as xs:string)
as xs:string*
{
  variable $json := json:parse($message);
  variable $command as xs:string? := string($json/j:pair[@name="command"]/text());
  if(exists(trace($command, "COMMAND"))) then
    switch($command)
    case "settings" return s:settings($json)
    
    case "kill" return s:kill($json)
    
    case "Run" return trace(s:run($json), "RUN")
    
    case "RunDebugBrk" return trace(s:run($json), "DEBUG")
    default return ()
  else ()
};

declare %an:sequential function s:settings($message as element(j:json))
as xs:string*
{
  variable $action := $message/j:pair[@name = "action"]/text();
  if($action = "set") then {
    variable $settings := $message/j:pair[@name = "settings"]/text();
    cloud9:save-settings($settings);
  } else {}
};

declare %an:sequential function s:run($json as element(j:json))
as xs:string*
{
  if($json/j:pair[@name = "command"]/text() = "Run" or $json/j:pair[@name = "command"]/text() = "RunDebugBrk") then {
    variable $filename := trace(concat("/fs/workspace/", $json/j:pair[@name="file"]/text()), "filename");
    variable $content := file:read-text(trace($filename, "filename"));
    variable $result := try {
      serialize(reflection:eval-s($content), ())
    } catch * {
      $filename || ":" || $err:line-number || ":" || $err:column-number || ": " || $err:description
    };
    ('3:::{"type":"node-start","pid":42694}',
     '3:::{"type":"node-data","pid":42694,"stream":"stdout","data":"' || trace(replace($result, '"', '\\"'), "RESULT") || '"}',
     '3:::{"type":"state","pythonProcessRunning":false,"workspaceDir":"/Users/wcandillon/28msec/cloud9"}',
     '3:::{"type":"node-exit","pid":42694,"code":1}')
  } else {}
};

declare %an:sequential function s:kill($json as element(j:json))
as xs:string
{
  '3:::{"type":"node-exit","pid":null,"code":1}'
};
