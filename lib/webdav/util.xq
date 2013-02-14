module namespace util = "http://www.28msec.com/cloud9/lib/webdav/util";

import module namespace functx = "http://www.functx.com/";

declare function util:dateTime-rfc1123($datetime as xs:dateTime)
as xs:string
{
  substring(functx:day-of-week-abbrev-en($datetime), 1, 3) ||
  ", " ||
  functx:pad-integer-to-length(day-from-dateTime($datetime), 2) ||
  " " ||
  functx:month-abbrev-en($datetime) ||
  " " ||
  year-from-dateTime($datetime) ||
  " " ||
  functx:pad-integer-to-length(hours-from-dateTime($datetime), 2) ||
  ":" ||
  functx:pad-integer-to-length(minutes-from-dateTime($datetime), 2) ||
  ":" ||
  functx:pad-integer-to-length(round(seconds-from-dateTime($datetime)), 2) ||
  " " || (
    let $timezone := timezone-from-dateTime($datetime)
    let $timezone := functx:timezone-from-duration($timezone)
    let $timezone := replace($timezone, "Z", "+0000")
    let $timezone := replace($timezone, ":", "")
    return
      $timezone
  )
};

(: Convert an absoluteURI in <URI> form to URI :)
declare function util:absolute-uri($uri as xs:string)
as xs:string
{
  substring-before(substring-after($uri, "&lt;"), "&gt;")  
};