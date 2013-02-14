module namespace s = "http://www.28msec.com/cloud9/lib/socket.io/broker";

import module namespace random = "http://www.zorba-xquery.com/modules/random";
import module namespace date   = "http://www.zorba-xquery.com/modules/datetime";

import module namespace sleep = "http://www.28msec.com/modules/sleep";
import module namespace store = "http://www.28msec.com/modules/store";

declare collection s:clients as element(client);
declare variable $s:clients as xs:QName := xs:QName('s:clients');

declare %an:automatic %an:value-equality %an:unique index s:client
on nodes db:collection(xs:QName('s:clients'))
by xs:string(@id) as xs:string;  
declare variable $s:client as xs:QName := xs:QName('s:client');

declare %an:automatic %an:value-range index s:last-seen
on nodes db:collection(xs:QName('s:clients'))
by xs:dateTime(@last-seen) as xs:dateTime;
declare variable $s:last-seen as xs:QName := xs:QName('s:last-seen');

declare collection s:messages as element(message);
declare variable $s:messages as xs:QName := xs:QName('s:messages');

declare %an:automatic %an:value-equality index s:message
on nodes db:collection(xs:QName('s:messages'))
by xs:string(@session-id) as xs:string;
declare variable $s:message as xs:QName := xs:QName('s:message');


declare %an:sequential function s:connect()
as xs:string
{
  variable $id := random:uuid();
  db:insert-nodes($s:clients, <client id="{$id}" last-seen="{date:current-dateTime()}" />);
  $id
};

declare %an:sequential function s:disconnect($id as xs:string)
as empty-sequence()
{
  db:delete-nodes(
    idx:probe-index-point-value($s:client, $id)
  );

  db:delete-nodes(
    idx:probe-index-point-value($s:messages, $id)
  );
};


declare %an:sequential function s:disconnect-clients-not-seen-since($dateTime as xs:dateTime)
as empty-sequence()
{
  let $clients := s:clients-not-seen-since($dateTime)
  for $client in $clients
  return s:disconnect($client);
};

declare function s:clients-not-seen-since($dateTime as xs:dateTime)
as xs:string*
{
  idx:probe-index-point-value($s:last-seen, (), $dateTime, false(), true(), false(), true())/@id/string()
};

declare %an:sequential function s:broadcast($message as xs:string)
as empty-sequence()
{
  (: TODO: use index keys instead :)
  for $client in db:collection($s:clients)
  return s:send($client/@id, $message);
};

declare %an:sequential function s:send($id as xs:string, $message as xs:string)
as empty-sequence()
{
  variable $message := <message datetime="{date:current-dateTime()}" session-id="{$id}">{$message}</message>;
  db:insert-nodes($s:messages, $message);
};

declare %an:sequential function s:heartbeat($id as xs:string)
as empty-sequence()
{
  replace value of node idx:probe-index-point-value($s:client, $id)/@last-seen with date:current-dateTime();
};

declare %an:sequential function s:messages($id as xs:string)
as xs:string*
{
  variable $messages := idx:probe-index-point-value($s:message, $id);
  db:delete-nodes($messages);
  $messages/text()
};

declare %an:sequential function s:messages($id as xs:string, $connection-timeout as xs:integer)
as xs:string*
{
  variable $timeout := 0;
  variable $messages := s:messages($id);
  while(empty($messages) and $timeout lt ($connection-timeout * 3 div 4)) {
    sleep:millis(50);
    $messages := s:messages($id);
    $timeout := $timeout + 0.05;
  }
  $messages
};
