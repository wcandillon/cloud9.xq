module namespace err = "http://www.28msec.com/cloud9/lib/error";

import module namespace req = "http://www.28msec.com/modules/http/request";
import module namespace resp = "http://www.28msec.com/modules/http/response";
import module namespace diagnostic = "http://www.28msec.com/modules/http/util/diagnostic";
import module namespace cookie="http://www.28msec.com/modules/http/cookie";

declare %an:sequential function err:handle(
  $code as xs:QName,
  $description as xs:string?,
  $value as item()*,
  $stack)
{
  if($code eq $resp:unauthorized and $value instance of object()) then
      let $key := jn:keys($value)
      return resp:set-header($key, $value($key));
  else
      ();
  (: set status code of response :)
  if(resp:valid-status($code))
  then
    resp:set-status($code); 
  else
    (: http:internal-server-error if not a valid http status :)
    resp:set-status($resp:internal-server-error);

  resp:set-content-type("text/html");
  
  (: response body :)
  <html>
      <head>
          <title> { $code } - Oups... An error happened</title>
      </head>
    <body style='font: 100% "Lucida Grande", tahoma, verdana, arial, sans-serif !important; margin: 20px;'>
      <center><h1>Oups... An error happened</h1>
        <table>
          {
            if ( $code eq $resp:not-found ) then (
              <tr height="50"><td colspan="2">The requested URL was not found on this server ({ $code }).</td></tr>,
              <tr><td valign="top"><b>Reason:</b></td><td> { $description }</td></tr>,
              <tr height="50"><td colspan="2">If you were trying to access the project's default handler visit <a href="/default/index">/default/index</a>. If you think this is an error, please contact <a href="mailto:support@28msec.com">support@28msec.com</a>.</td></tr>
            )
            else (
              <tr valign="top" height="50"><td><b>Status:</b></td><td>{ $code }</td></tr>,
              <tr valign="top"><td><b>Message:</b></td><td>{ $description }</td></tr>
            )
          }
        </table>
      </center>
      <p>
        <hr />
        <h2>Stack Trace: </h2>
        {
          for $call in $stack/stack/call
          let $ns    := string($call/@ns)
          let $name  := string($call/@localName)
          let $arity := string($call/@arity)
          return (<code>called from module <b>{$ns}</b> function <b>{$name}#{$arity}</b></code>,<br/>)
        } 
      </p>
    </body>
  </html>
};
