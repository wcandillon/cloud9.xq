module namespace m = "http://www.28msec.com/cloud9/lib/socket.io/message";

declare variable $m:open    := 0;
declare variable $m:close   := 1;
declare variable $m:ping    := 2;
declare variable $m:pong    := 3;
declare variable $m:message := 4;
declare variable $m:upgrade := 5;
declare variable $m:noop    := 6;

declare function m:parse-messages($payload as xs:string)
as element(message)+
{
  m:parse-messages($payload, ())
};

declare function m:parse-messages($payload as xs:string, $messages as element(message)*)
as element(message)+
{
  if($payload = "") then
    $messages
  else
    let $tokens  := tokenize($payload, ":")
    let $size    := number($tokens[1])
    let $body    := string-join(subsequence($tokens, 2), ":")
    let $message := substring($body, 1, $size)
    let $message := m:parse-message($message)
    let $messages := ($messages, $message)
    let $remains := substring($body, $size + 1)
    return
      m:parse-messages($remains, $messages)
};

declare function m:parse-message($payload as xs:string)
as element(message)+
{
  let $chars := string-to-codepoints($payload)
  let $type := number(codepoints-to-string($chars[1]))
  let $data := codepoints-to-string(subsequence($chars, 2))
  return <message type="{$type}">{$data}</message>
};

declare function m:join-messages($messages as xs:string+)
as xs:string
{
  let $payload :=
    for $message in $messages
    return string-length($message) || ":" || $message
  return string-join($payload, "")
};

declare function m:serialize-message($message as object())
as xs:string
{
  let $type := $message("type")
  let $data := $message("data")
  return
    $type || $data
};

declare function m:pong($data as xs:string?)
as xs:string
{
  string($m:pong) || $data
};

declare function m:msg($data as item())
as xs:string
{
  let $data := if($data instance of xs:string) then
                 $data
               else
                 serialize($data, ())
  return $m:message || $data
};

declare function m:event($event-name as xs:string, $data as structured-item())
as xs:string
{
  "5:::" || '{"name":' || ' "' || $event-name || '", "args": [' || serialize($data, ()) || "]}"
};

declare function m:noop()
as xs:string
{
  "8:::"
};

declare function m:handshake($id as xs:string, $heartbeat-timeout as xs:integer, $connection-timeout as xs:integer, $supported-transports as xs:string+)
as xs:string
{
  let $handshake := {"sid": $id, "upgrades": [], "pingInterval": $heartbeat-timeout, "pingTimeout": $connection-timeout, "allowUpgrades": false}
  let $handshake := serialize($handshake, ())
  return
    string-length($handshake) + 1 || ":0" || $handshake
};

