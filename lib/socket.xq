module namespace s = "http://www.28msec.com/cloud9/lib/socket";

import module namespace date = "http://www.zorba-xquery.com/modules/datetime";
import module namespace random = "http://www.zorba-xquery.com/modules/random";
import module namespace base64 = "http://www.zorba-xquery.com/modules/converters/base64";

import module namespace req = "http://www.28msec.com/modules/http/request";
import module namespace res = "http://www.28msec.com/modules/http/response";

import module namespace c = "http://www.28msec.com/cloud9/lib/commands";
import module namespace b = "http://www.28msec.com/cloud9/lib/socket.io/broker";
import module namespace m = "http://www.28msec.com/cloud9/lib/socket.io/message";

declare variable $s:heartbeat-timeout  as xs:integer := 15000;
declare variable $s:connection-timeout as xs:integer := 3000;

declare %private variable $s:handshake               as xs:QName := xs:QName('s:handshake');
declare %private variable $s:transport-not-supported as xs:QName := xs:QName('s:transport-not-supported');

declare %private variable $s:supported-transports as xs:string+ := ("polling");
declare %private variable $s:supported-upgrades   as xs:string* := ();

declare %private variable $s:transport   as xs:string? := ();
declare %private variable $s:session-id  as xs:string? := ();

declare %an:nondeterministic function s:timestamp() as xs:decimal
{
  let $current-dateTime := fn:adjust-dateTime-to-timezone(current-dateTime(), xs:dayTimeDuration('PT0H'))
  let $duration := $current-dateTime - xs:dateTime("1970-01-01T00:00:00Z")
  return fn:round($duration div xs:dayTimeDuration('PT1S'))
};

declare %private %an:sequential function s:handshake()
as xs:string?
{ 
  res:set-content-type("text/plain; charset=UTF-8");
  $s:transport := req:parameter-values("transport");
  $s:session-id := req:parameter-values("sid");
  if($s:transport != $s:supported-transports) then
    error($res:service-unavailable, $s:transport);
  else
    ();
  if(empty($s:session-id)) then {
    s:connect();
    m:handshake($s:session-id, $s:heartbeat-timeout, $s:connection-timeout, $s:supported-upgrades)
  } else {
    ()
  }
};

declare %private function s:messages()
as element(message)*
{
  let $payload := if(req:method-post()) then req:text-content() else ()
  return
    if(exists($payload)) then
      m:parse-messages($payload)
    else ()
};

declare %an:sequential function s:listen()
as xs:string+
{
  variable $result := s:handshake();
  if(exists($result)) then {
    $result
  } else if(req:method-post()) then {
    for $message in s:messages()
    let $type := $message/@type/number()
    let $data := $message/text()
    return
      switch (trace($type, "type"))
        case $m:ping
        return s:pong($data);

        case $m:message
        return s:msg(jn:parse-json($data));
      
      default return ();
      "ok" 
    } else if(req:method-get()) then { 
      variable $messages := b:messages($s:session-id, $s:connection-timeout);
      if(empty($messages)) then
        s:pong()
      else
        m:join-messages($messages)
    } else {
      error($res:bad-request)
    }
};

declare %an:sequential function s:send($message as xs:string)
as empty-sequence()
{
  s:send($message, false())
};

declare %private %an:sequential function s:send($message as xs:string, $broadcast as xs:boolean)
as empty-sequence()
{
  if($broadcast) then
    b:broadcast($message);
  else
    b:send($s:session-id, $message);
};

declare %an:sequential function s:connect()
as empty-sequence()
{
  $s:session-id := b:connect();
  s:send(m:msg({"type":"__ASSIGN-ID__","id": $s:session-id || "-" || s:timestamp() }));
  s:send(m:msg({"type": "attached"}));
};

declare %private %an:sequential function s:disconnect()
{
  b:disconnect($s:session-id)
};

declare %an:sequential function s:pong(){ s:pong(()) };

declare %an:sequential function s:pong($data as xs:string?)
{
  s:send(m:pong($data))
};

declare %an:sequential function s:msg($message as structured-item())
as empty-sequence()
{
  trace($message, "json");
  let $command := $message("command")
  let $responses := switch($command)
  
    case "RunDebugBrk"
    return c:run($message)

    case "Run"
    return c:run($message)

    case "kill"
    return c:kill($message)

    default return ()
  for $resp in $responses
  return s:send(trace($resp, "RESPONSE"))
};

declare %an:sequential function s:event($message as structured-item())
as empty-sequence()
{
  trace($message, "event");
};
