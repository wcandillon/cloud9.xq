xquery version "1.0" encoding "UTF-8";

(: This file was generated on Sat Oct 6, 2012 11:16 (UTC+02) by REx v5.17 which is Copyright (c) 1979-2012 by Gunther Rademacher <grd@gmx.net> :)
(: REx command line: if-header-parser.ebnf -tree -xquery :)

(:~
 : The parser that was generated for the if-header-parser grammar.
 :)
module namespace p = "http://www.28msec.com/cloud9/lib/webdav/if-header-parser";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

(:~
 : The codepoint to charclass mapping for 7 bit codepoints.
 :)
declare variable $p:MAP0 as xs:integer+ :=
(
  21, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 2, 2, 2, 2,
  2, 4, 5, 2, 2, 2, 6, 6, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 6, 2, 9, 2, 10, 2, 2, 8, 8, 8, 8, 8, 8, 6, 6, 6, 6, 6, 6, 6,
  11, 6, 6, 6, 6, 6, 6, 6, 6, 12, 6, 6, 6, 13, 14, 15, 2, 2, 2, 8, 16, 8, 8, 8, 16, 6, 6, 6, 6, 6, 6, 6, 17, 18, 6, 6,
  17, 6, 19, 20, 6, 6, 6, 6, 6, 2, 2, 2, 2, 2
);

(:~
 : The codepoint to charclass mapping for codepoints below the surrogate block.
 :)
declare variable $p:MAP1 as xs:integer+ :=
(
  54, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58,
  58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 90, 122, 153, 184,
  211, 211, 211, 211, 211, 211, 211, 211, 211, 211, 211, 211, 211, 211, 211, 211, 211, 211, 211, 211, 211, 211, 211,
  211, 211, 211, 211, 211, 211, 211, 211, 211, 21, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 2, 2, 2, 2, 2, 4, 5, 2, 2, 2, 6, 6, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 6, 2, 9, 2, 10,
  2, 8, 8, 8, 8, 8, 8, 6, 6, 6, 6, 6, 6, 6, 11, 6, 6, 6, 6, 6, 6, 6, 6, 12, 6, 6, 6, 13, 14, 15, 2, 2, 8, 16, 8, 8, 8,
  16, 6, 6, 6, 6, 6, 6, 6, 17, 18, 6, 6, 17, 6, 19, 20, 6, 6, 6, 6, 6, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
);

(:~
 : The codepoint to charclass mapping for codepoints above the surrogate block.
 :)
declare variable $p:MAP2 as xs:integer+ :=
(
  57344, 65536, 65533, 1114111, 2, 2
);

(:~
 : The token-set-id to DFA-initial-state mapping.
 :)
declare variable $p:INITIAL as xs:integer+ :=
(
  1, 34, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13
);

(:~
 : The DFA transition table.
 :)
declare variable $p:TRANSITION as xs:integer+ :=
(
  174, 174, 174, 174, 88, 91, 174, 174, 174, 168, 174, 174, 170, 111, 172, 174, 99, 107, 174, 174, 174, 205, 174, 174,
  174, 151, 165, 174, 174, 136, 148, 174, 174, 151, 231, 174, 193, 119, 174, 174, 174, 168, 133, 174, 174, 125, 165,
  174, 174, 144, 165, 174, 174, 159, 174, 174, 174, 216, 148, 174, 243, 168, 174, 174, 174, 151, 182, 174, 174, 151,
  148, 174, 174, 151, 190, 174, 174, 151, 201, 174, 174, 151, 213, 174, 224, 239, 174, 174, 0, 162, 162, 162, 162, 162,
  162, 162, 14, 0, 0, 192, 0, 0, 0, 0, 0, 192, 192, 0, 0, 192, 0, 0, 14, 0, 0, 0, 128, 0, 0, 15, 0, 15, 15, 15, 14, 0,
  0, 0, 17, 17, 14, 19, 0, 0, 0, 96, 0, 0, 0, 0, 0, 14, 19, 288, 0, 16, 0, 0, 0, 14, 19, 0, 0, 0, 0, 0, 14, 19, 0, 320,
  0, 0, 320, 320, 14, 0, 0, 19, 0, 0, 0, 0, 0, 14, 0, 0, 0, 0, 0, 0, 0, 0, 0, 14, 19, 0, 22, 23, 24, 14, 20, 0, 19, 0,
  0, 0, 0, 0, 15, 0, 15, 0, 14, 19, 256, 0, 0, 0, 0, 224, 14, 0, 0, 0, 21, 19, 0, 0, 0, 0, 0, 18, 19, 0, 0, 0, 64, 0, 0,
  64, 64, 0, 0, 19, 0, 22, 23, 24, 14, 0, 0, 64, 0, 0, 0, 0, 0, 352, 0, 0, 0
);

(:~
 : The DFA-state to expected-token-set mapping.
 :)
declare variable $p:EXPECTED as xs:integer+ :=
(
  32, 16, 18, 24, 1040, 22, 50, 52, 532, 280, 54, 660, 724, 8, 4, 256, 128, 8, 4, 128, 8, 8, 8, 8
);

(:~
 : The token-string table.
 :)
declare variable $p:TOKEN as xs:string+ :=
(
  "EPSILON",
  "eof",
  "absoluteURI",
  "string",
  "whitespace",
  "'('",
  "')'",
  "'Not'",
  "'W/'",
  "'['",
  "']'"
);

(:~
 : Match next token in input string, starting at given index, using
 : the DFA entry state for the set of tokens that are expected in
 : the current context.
 :
 : @param $input the input string.
 : @param $begin the index where to start in input string.
 : @param $token-set the expected token set id.
 : @return a sequence of three: the token code of the result token,
 : with input string begin and end positions. If there is no valid
 : token, return the negative id of the DFA state that failed, along
 : with begin and end positions of the longest viable prefix.
 :)
declare function p:match($input as xs:string,
                         $begin as xs:integer,
                         $token-set as xs:integer) as xs:integer+
{
  let $result := $p:INITIAL[1 + $token-set]
  return p:transition($input,
                      $begin,
                      $begin,
                      $begin,
                      $result,
                      $result mod 32,
                      0)
};

(:~
 : The DFA state transition function. If we are in a valid DFA state, save
 : it's result annotation, consume one input codepoint, calculate the next
 : state, and use tail recursion to do the same again. Otherwise, return
 : any valid result or a negative DFA state id in case of an error.
 :
 : @param $input the input string.
 : @param $begin the begin index of the current token in the input string.
 : @param $current the index of the current position in the input string.
 : @param $end the end index of the result in the input string.
 : @param $result the result code.
 : @param $current-state the current DFA state.
 : @param $previous-state the  previous DFA state.
 : @return a sequence of three: the token code of the result token,
 : with input string begin and end positions. If there is no valid
 : token, return the negative id of the DFA state that failed, along
 : with begin and end positions of the longest viable prefix.
 :)
declare function p:transition($input as xs:string,
                              $begin as xs:integer,
                              $current as xs:integer,
                              $end as xs:integer,
                              $result as xs:integer,
                              $current-state as xs:integer,
                              $previous-state as xs:integer) as xs:integer+
{
  if ($current-state = 0) then
    let $result := $result idiv 32
    return
      if ($result != 0) then
      (
        $result - 1,
        $begin,
        $end
      )
      else
      (
        - $previous-state,
        $begin,
        $current - 1
      )
  else
    let $c0 := (string-to-codepoints(substring($input, $current, 1)), 0)[1]
    let $c1 :=
      if ($c0 < 128) then
        $p:MAP0[1 + $c0]
      else if ($c0 < 55296) then
        let $c1 := $c0 idiv 32
        let $c2 := $c1 idiv 32
        return $p:MAP1[1 + $c0 mod 32 + $p:MAP1[1 + $c1 mod 32 + $p:MAP1[1 + $c2]]]
      else
        p:map2($c0, 1, 2)
    let $current := $current + 1
    let $i0 := 32 * $c1 + $current-state - 1
    let $i1 := $i0 idiv 8
    let $next-state := $p:TRANSITION[$i0 mod 8 + $p:TRANSITION[$i1 + 1] + 1]
    return
      if ($next-state > 31) then
        p:transition($input, $begin, $current, $current, $next-state, $next-state mod 32, $current-state)
      else
        p:transition($input, $begin, $current, $end, $result, $next-state, $current-state)
};

(:~
 : Recursively translate one 32-bit chunk of an expected token bitset
 : to the corresponding sequence of token strings.
 :
 : @param $result the result of previous recursion levels.
 : @param $chunk the 32-bit chunk of the expected token bitset.
 : @param $base-token-code the token code of bit 0 in the current chunk.
 : @return the set of token strings.
 :)
declare function p:token($result as xs:string*,
                         $chunk as xs:integer,
                         $base-token-code as xs:integer) as xs:string*
{
  if ($chunk = 0) then
    $result
  else
    p:token
    (
      ($result, if ($chunk mod 2 != 0) then $p:TOKEN[$base-token-code] else ()),
      if ($chunk < 0) then $chunk idiv 2 + 2147483648 else $chunk idiv 2,
      $base-token-code + 1
    )
};

(:~
 : Calculate expected token set for a given DFA state as a sequence
 : of strings.
 :
 : @param $state the DFA state.
 : @return the set of token strings
 :)
declare function p:expected-token-set($state as xs:integer) as xs:string*
{
  if ($state > 0) then
    for $t in 0 to 0
    let $i0 := $t * 24 + $state - 1
    return p:token((), $p:EXPECTED[$i0 + 1], $t * 32 + 1)
  else
    ()
};

(:~
 : Classify codepoint by doing a tail recursive binary search for a
 : matching codepoint range entry in MAP2, the codepoint to charclass
 : map for codepoints above the surrogate block.
 :
 : @param $c the codepoint.
 : @param $lo the binary search lower bound map index.
 : @param $hi the binary search upper bound map index.
 : @return the character class.
 :)
declare function p:map2($c as xs:integer, $lo as xs:integer, $hi as xs:integer) as xs:integer
{
  if ($lo > $hi) then
    0
  else
    let $m := ($hi + $lo) idiv 2
    return
      if ($p:MAP2[$m] > $c) then
        p:map2($c, $lo, $m - 1)
      else if ($p:MAP2[2 + $m] < $c) then
        p:map2($c, $m + 1, $hi)
      else
        $p:MAP2[4 + $m]
};

(:~
 : The index of the parser state for accessing the combined
 : (i.e. level > 1) lookahead code.
 :)
declare variable $p:lk := 1;

(:~
 : The index of the parser state for accessing the position in the
 : input string of the begin of the token that has been shifted.
 :)
declare variable $p:b0 := 2;

(:~
 : The index of the parser state for accessing the position in the
 : input string of the end of the token that has been shifted.
 :)
declare variable $p:e0 := 3;

(:~
 : The index of the parser state for accessing the code of the
 : level-1-lookahead token.
 :)
declare variable $p:l1 := 4;

(:~
 : The index of the parser state for accessing the position in the
 : input string of the begin of the level-1-lookahead token.
 :)
declare variable $p:b1 := 5;

(:~
 : The index of the parser state for accessing the position in the
 : input string of the end of the level-1-lookahead token.
 :)
declare variable $p:e1 := 6;

(:~
 : The index of the parser state for accessing the token code that
 : was expected when an error was found.
 :)
declare variable $p:error := 7;

(:~
 : The index of the parser state that points to the first entry
 : used for collecting action results.
 :)
declare variable $p:result := 8;

(:~
 : Create a textual error message from a parsing error.
 :
 : @param $input the input string.
 : @param $error the parsing error descriptor.
 : @return the error message.
 :)
declare function p:error-message($input as xs:string, $error as element(error)) as xs:string
{
  let $begin := xs:integer($error/@b)
  let $context := string-to-codepoints(substring($input, 1, $begin - 1))
  let $linefeeds := index-of($context, 10)
  let $line := count($linefeeds) + 1
  let $column := ($begin - $linefeeds[last()], $begin)[1]
  return
    if ($error/@o) then
      concat
      (
        "syntax error, found ", $p:TOKEN[$error/@o + 1], "&#10;",
        "while expecting ", $p:TOKEN[$error/@x + 1], "&#10;",
        if ($error/@e = $begin) then
          ""
        else
          concat("after successfully scanning ", string($error/@e - $begin), " characters "),
        "at line ", string($line), ", column ", string($column), "&#10;",
        "...", substring($input, $begin, 32), "..."
      )
    else
      let $expected := p:expected-token-set($error/@s)
      return
        concat
        (
          "lexical analysis failed&#10;",
          "while expecting ",
          "["[exists($expected[2])],
          string-join($expected, ", "),
          "]"[exists($expected[2])],
          "&#10;",
          if ($error/@e = $begin) then
            ""
          else
            concat("after successfully scanning ", string($error/@e - $begin), " characters "),
          "at line ", string($line), ", column ", string($column), "&#10;",
          "...", substring($input, $begin, 32), "..."
        )
};

(:~
 : Shift one token, i.e. compare lookahead token 1 with expected
 : token and in case of a match, shift lookahead tokens down such that
 : l1 becomes the current token, and higher lookahead tokens move down.
 : When lookahead token 1 does not match the expected token, raise an
 : error by saving the expected token code in the error field of the
 : parser state.
 :
 : @param $code the expected token.
 : @param $input the input string.
 : @param $state the parser state.
 : @return the updated parser state.
 :)
declare function p:shift($code as xs:integer, $input as xs:string, $state as item()+) as item()+
{
  if ($state[$p:error]) then
    $state
  else if ($state[$p:l1] = $code) then
  (
    subsequence($state, $p:l1, $p:e1 - $p:l1 + 1),
    0,
    $state[$p:e1],
    subsequence($state, $p:e1),
    if ($state[$p:e0] != $state[$p:b1]) then
      text {substring($input, $state[$p:e0], $state[$p:b1] - $state[$p:e0])}
    else
      (),
    let $name := $p:TOKEN[1 + $state[$p:l1]]
    let $content := substring($input, $state[$p:b1], $state[$p:e1] - $state[$p:b1])
    return
      if (starts-with($name, "'")) then
        element TOKEN {$content}
      else
        element {$name} {$content}
  )
  else
  (
    subsequence($state, 1, $p:error - 1),
    element error
    {
      attribute b {$state[$p:b1]},
      attribute e {$state[$p:e1]},
      if ($state[$p:l1] < 0) then
        attribute s {- $state[$p:l1]}
      else
        (attribute o {$state[$p:l1]}, attribute x {$code})
    },
    subsequence($state, $p:error + 1)
  )
};

(:~
 : Use p:match to fetch the next token, but skip any leading
 : whitespace.
 :
 : @param $input the input string.
 : @param $begin the index where to start.
 : @param $token-set the valid token set id.
 : @return a sequence of three values: the token code of the result
 : token, with input string positions of token begin and end.
 :)
declare function p:matchW($input as xs:string,
                          $begin as xs:integer,
                          $token-set as xs:integer) as xs:integer+
{
  let $match := p:match($input, $begin, $token-set)
  return
    if ($match[1] = 4) then                                 (: whitespace^token :)
      p:matchW($input, $match[3], $token-set)
    else
      $match
};

(:~
 : Lookahead one token on level 1 with whitespace skipping.
 :
 : @param $set the code of the DFA entry state for the set of valid tokens.
 : @param $input the input string.
 : @param $state the parser state.
 : @return the updated parser state.
 :)
declare function p:lookahead1W($set as xs:integer, $input as xs:string, $state as item()+) as item()+
{
  if ($state[$p:l1] != 0) then
    $state
  else
    let $match := p:matchW($input, $state[$p:b1], $set)
    return
    (
      $match[1],
      subsequence($state, $p:lk + 1, $p:l1 - $p:lk - 1),
      $match,
      subsequence($state, $p:e1 + 1)
    )
};

(:~
 : Lookahead one token on level 1.
 :
 : @param $set the code of the DFA entry state for the set of valid tokens.
 : @param $input the input string.
 : @param $state the parser state.
 : @return the updated parser state.
 :)
declare function p:lookahead1($set as xs:integer, $input as xs:string, $state as item()+) as item()+
{
  if ($state[$p:l1] != 0) then
    $state
  else
    let $match := p:match($input, $state[$p:b1], $set)
    return
    (
      $match[1],
      subsequence($state, $p:lk + 1, $p:l1 - $p:lk - 1),
      $match,
      subsequence($state, $p:e1 + 1)
    )
};

(:~
 : Reduce the result stack. Pop $count element, wrap them in a
 : new element named $name, and push the new element.
 :
 : @param $state the parser state.
 : @param $name the name of the result node.
 : @param $count the number of child nodes.
 : @return the updated parser state.
 :)
declare function p:reduce($state as item()+, $name as xs:string, $count as xs:integer) as item()+
{
  subsequence($state, 1, $count),
  element {$name}
  {
    subsequence($state, $count + 1)
  }
};

(:~
 : Parse NoTaggedList.
 :
 : @param $input the input string.
 : @param $state the parser state.
 : @return the updated parser state.
 :)
declare function p:parse-NoTaggedList($input as xs:string, $state as item()+) as item()+
{
  let $count := count($state)
  let $state := p:parse-List($input, $state)
  return p:reduce($state, "NoTaggedList", $count)
};

(:~
 : Parse OpaqueTag.
 :
 : @param $input the input string.
 : @param $state the parser state.
 : @return the updated parser state.
 :)
declare function p:parse-OpaqueTag($input as xs:string, $state as item()+) as item()+
{
  let $count := count($state)
  let $state := p:shift(3, $input, $state)                  (: string :)
  return p:reduce($state, "OpaqueTag", $count)
};

(:~
 : Parse Weak.
 :
 : @param $input the input string.
 : @param $state the parser state.
 : @return the updated parser state.
 :)
declare function p:parse-Weak($input as xs:string, $state as item()+) as item()+
{
  let $count := count($state)
  let $state := p:shift(8, $input, $state)                  (: 'W/' :)
  return p:reduce($state, "Weak", $count)
};

(:~
 : Parse EntityTag.
 :
 : @param $input the input string.
 : @param $state the parser state.
 : @return the updated parser state.
 :)
declare function p:parse-EntityTag($input as xs:string, $state as item()+) as item()+
{
  let $count := count($state)
  let $state := p:lookahead1W(9, $input, $state)            (: string | whitespace^token | 'W/' :)
  let $state :=
    if ($state[$p:error]) then
      $state
    else if ($state[$p:l1] = 8) then                        (: 'W/' :)
      let $state := p:parse-Weak($input, $state)
      return $state
    else
      $state
  let $state := p:lookahead1W(3, $input, $state)            (: string | whitespace^token :)
  let $state := p:parse-OpaqueTag($input, $state)
  return p:reduce($state, "EntityTag", $count)
};

(:~
 : Parse StateToken.
 :
 : @param $input the input string.
 : @param $state the parser state.
 : @return the updated parser state.
 :)
declare function p:parse-StateToken($input as xs:string, $state as item()+) as item()+
{
  let $count := count($state)
  let $state := p:parse-CodedURL($input, $state)
  return p:reduce($state, "StateToken", $count)
};

(:~
 : Parse the 1st loop of production List (one or more). Use
 : tail recursion for iteratively updating the parser state.
 :
 : @param $input the input string.
 : @param $state the parser state.
 : @return the updated parser state.
 :)
declare function p:parse-List-1($input as xs:string, $state as item()+) as item()+
{
  if ($state[$p:error]) then
    $state
  else
    let $state := p:lookahead1W(11, $input, $state)         (: absoluteURI | whitespace^token | 'Not' | '[' :)
    let $state :=
      if ($state[$p:error]) then
        $state
      else if ($state[$p:l1] = 7) then                      (: 'Not' :)
        let $state := p:shift(7, $input, $state)            (: 'Not' :)
        return $state
      else
        $state
    let $state := p:lookahead1W(8, $input, $state)          (: absoluteURI | whitespace^token | '[' :)
    let $state :=
      if ($state[$p:l1] = 2) then                           (: absoluteURI :)
        let $state := p:parse-StateToken($input, $state)
        return $state
      else if ($state[$p:error]) then
        $state
      else
        let $state := p:shift(9, $input, $state)            (: '[' :)
        let $state := p:lookahead1W(1, $input, $state)      (: EPSILON | whitespace^token :)
        let $state := p:parse-EntityTag($input, $state)
        let $state := p:lookahead1W(4, $input, $state)      (: whitespace^token | ']' :)
        let $state := p:shift(10, $input, $state)           (: ']' :)
        return $state
    let $state := p:lookahead1W(12, $input, $state)         (: absoluteURI | whitespace^token | ')' | 'Not' | '[' :)
    return
      if ($state[$p:l1] = 6) then                           (: ')' :)
        $state
      else
        p:parse-List-1($input, $state)
};

(:~
 : Parse List.
 :
 : @param $input the input string.
 : @param $state the parser state.
 : @return the updated parser state.
 :)
declare function p:parse-List($input as xs:string, $state as item()+) as item()+
{
  let $count := count($state)
  let $state := p:lookahead1(0, $input, $state)             (: '(' :)
  let $state := p:shift(5, $input, $state)                  (: '(' :)
  let $state := p:lookahead1W(1, $input, $state)            (: EPSILON | whitespace^token :)
  let $state := p:parse-List-1($input, $state)
  let $state := p:shift(6, $input, $state)                  (: ')' :)
  return p:reduce($state, "List", $count)
};

(:~
 : Parse CodedURL.
 :
 : @param $input the input string.
 : @param $state the parser state.
 : @return the updated parser state.
 :)
declare function p:parse-CodedURL($input as xs:string, $state as item()+) as item()+
{
  let $count := count($state)
  let $state := p:shift(2, $input, $state)                  (: absoluteURI :)
  return p:reduce($state, "CodedURL", $count)
};

(:~
 : Parse Resource.
 :
 : @param $input the input string.
 : @param $state the parser state.
 : @return the updated parser state.
 :)
declare function p:parse-Resource($input as xs:string, $state as item()+) as item()+
{
  let $count := count($state)
  let $state := p:parse-CodedURL($input, $state)
  return p:reduce($state, "Resource", $count)
};

(:~
 : Parse the 1st loop of production TaggedList (one or more). Use
 : tail recursion for iteratively updating the parser state.
 :
 : @param $input the input string.
 : @param $state the parser state.
 : @return the updated parser state.
 :)
declare function p:parse-TaggedList-1($input as xs:string, $state as item()+) as item()+
{
  if ($state[$p:error]) then
    $state
  else
    let $state := p:lookahead1W(1, $input, $state)          (: EPSILON | whitespace^token :)
    let $state := p:parse-List($input, $state)
    let $state := p:lookahead1W(10, $input, $state)         (: eof | absoluteURI | whitespace^token | '(' :)
    return
      if ($state[$p:l1] != 5) then                          (: '(' :)
        $state
      else
        p:parse-TaggedList-1($input, $state)
};

(:~
 : Parse TaggedList.
 :
 : @param $input the input string.
 : @param $state the parser state.
 : @return the updated parser state.
 :)
declare function p:parse-TaggedList($input as xs:string, $state as item()+) as item()+
{
  let $count := count($state)
  let $state := p:parse-Resource($input, $state)
  let $state := p:lookahead1W(1, $input, $state)            (: EPSILON | whitespace^token :)
  let $state := p:parse-TaggedList-1($input, $state)
  return p:reduce($state, "TaggedList", $count)
};

(:~
 : Parse the 1st loop of production If (one or more). Use
 : tail recursion for iteratively updating the parser state.
 :
 : @param $input the input string.
 : @param $state the parser state.
 : @return the updated parser state.
 :)
declare function p:parse-If-1($input as xs:string, $state as item()+) as item()+
{
  if ($state[$p:error]) then
    $state
  else
    let $state := p:parse-TaggedList($input, $state)
    let $state := p:lookahead1W(5, $input, $state)          (: eof | absoluteURI | whitespace^token :)
    return
      if ($state[$p:l1] != 2) then                          (: absoluteURI :)
        $state
      else
        p:parse-If-1($input, $state)
};

(:~
 : Parse the 2nd loop of production If (one or more). Use
 : tail recursion for iteratively updating the parser state.
 :
 : @param $input the input string.
 : @param $state the parser state.
 : @return the updated parser state.
 :)
declare function p:parse-If-2($input as xs:string, $state as item()+) as item()+
{
  if ($state[$p:error]) then
    $state
  else
    let $state := p:parse-NoTaggedList($input, $state)
    let $state := p:lookahead1W(6, $input, $state)          (: eof | whitespace^token | '(' :)
    return
      if ($state[$p:l1] != 5) then                          (: '(' :)
        $state
      else
        p:parse-If-2($input, $state)
};

(:~
 : Parse If.
 :
 : @param $input the input string.
 : @param $state the parser state.
 : @return the updated parser state.
 :)
declare function p:parse-If($input as xs:string, $state as item()+) as item()+
{
  let $count := count($state)
  let $state := p:lookahead1W(7, $input, $state)            (: absoluteURI | whitespace^token | '(' :)
  let $state :=
    if ($state[$p:l1] = 2) then                             (: absoluteURI :)
      let $state := p:parse-If-1($input, $state)
      return $state
    else if ($state[$p:error]) then
      $state
    else
      let $state := p:parse-If-2($input, $state)
      return $state
  let $state := p:lookahead1W(2, $input, $state)            (: eof | whitespace^token :)
  let $state := p:shift(1, $input, $state)                  (: eof :)
  return p:reduce($state, "If", $count)
};

(:~
 : Parse start symbol If from given string.
 :
 : @param $s the string to be parsed.
 : @return the result as generated by parser actions.
 :)
declare function p:parse-If($s as xs:string) as item()*
{
  let $state := p:parse-If($s, (0, 1, 1, 0, 1, 0, false()))
  let $error := $state[$p:error]
  return
    if ($error) then
      element ERROR {$error/@*, p:error-message($s, $error)}
    else
      subsequence($state, $p:result)
};

(: End :)
