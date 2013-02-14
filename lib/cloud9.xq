module namespace c9 = "http://www.28msec.com/cloud9/lib/cloud9";

import module namespace req = "http://www.28msec.com/modules/http/request";
import module namespace res = "http://www.28msec.com/modules/http/response";

import module namespace util = "http://www.28msec.com/cloud9/lib/util";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace html = "http://www.w3.org/1999/xhtml";

declare namespace o = "http://www.w3.org/2010/xslt-xquery-serialization";

declare variable $c9:html5-output := <o:serialization-parameters>
  <o:method value="html"/>
  <o:doctype-system value="about:legacy-compat"/>
</o:serialization-parameters>;

declare variable $c9:version as xs:string := "0.4";

declare variable $c9:cdns as object() := {
  "dev":  "http://d37ioxark28zqr.cloudfront.net/",
  "prod": "http://d2oc5zgq8m08jw.cloudfront.net/",
  "local": "/"
};

declare variable $c9:cdn as xs:string := $c9:cdns("local") || $c9:version;

declare variable $c9:port as xs:int := req:server-port();

declare %an:sequential function c9:get($path as xs:string, $project-id as xs:string, $id as xs:string)
{
  res:set-content-type("text/html", $c9:html5-output);
  variable $packed as xs:string := "";
  variable $local  as xs:string := "";
  variable $staticUrl := $c9:cdn || "/static";
  variable $loadedDetectionScript := (
  
  );
  variable $script := (
    <script type="text/javascript" data-ace-worker-path="/{$c9:version}/static/js/worker" src="{$staticUrl}/ace/build/ace.js"></script>
  );
  <html xmlns="http://www.w3.org/1999/xhtml" xmlns:a="http://ajax.org/2005/aml" skipParse="{$packed}">
      <head profile="http://www.w3.org/2005/10/profile">
          <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
          <title>{$project-id} - Cloud9</title>
          <meta name="description" content=""/>
          <meta name="keywords" content=""/>
          <script type="text/javascript">
          var local = "{$local}";
          //<![CDATA[
              if (local)
                  document.title += " Local";
          //]]>
          </script>
          <link rel="icon" type="image/gif" href="{$staticUrl}/favicon.ico" />
  
          <link rel="stylesheet" type="text/css" href="{$staticUrl}/ext/main/style/style.css" />
  
          {$loadedDetectionScript}
          <script type="text/javascript" src="{$staticUrl}/require.js"></script>
          {$script}
          <script type="text/javascript">
          var path = "{$path}";
          var id = "{$id}";
          var project = "{$project-id}";
          var version = "{$c9:version}";
          var smithIoPort = "{req:server-port()}";
          var settings = "";
          var staticUrl = "{$staticUrl}";
          //<![CDATA[
          var requirejsConfig = {"baseUrl": staticUrl,"paths":{"ace": staticUrl + "/ace/lib/ace","apf": staticUrl + "/apf","treehugger": staticUrl + "/treehugger/lib/treehugger","debug": staticUrl + "/v8debug/lib/v8debug","v8debug": staticUrl + "/v8debug/lib/v8debug","core": staticUrl + "/core","ext": staticUrl + "/ext"},"packages":[{"name":"engine.io","location":"engine.io","main":"engine.io-dev.js"},{"name":"smith.io","location":"smith.io","main":"client.js"},{"name":"smith","location":"smith","main":"smith.js"},{"name":"msgpack-js","location":"msgpack-js","main":"msgpack.js"}]};
  
              window.cloud9config = {
                  startdate: new Date(),
                  davPrefix: "/fs/workspace",
                  workspaceDir: path,
                  debug: "",
                  sessionId: id,
                  workspaceId: project,
                  runners: ["node"],
                  name: "",
                  uid: id,
                  pid: 42,
                  readonly: "",
                  projectName: project,
                  version: "",
                  workerUrl: "/" + version + "/static",
                  staticUrl: "/" + version + "/static",
                  smithIo: "{\"port\":" + smithIoPort + ",\"prefix\":\"/socket/server\"}",
                  hosted: false,
                  local: "",
                  env: "local",
                  settings: settings,
                  packed: "",
                  packedName: ""
              };
  
              // prevent console messages from crashing our app!
              if (typeof window["console"] == "undefined") {
                  var K = function() {};
                  window.console = {log:K,debug:K,dir:K,trace:K,error:K,warn:K,profileStart:K,profileEnd:K};
              }
  
              if (!cloud9config.packed) {
                  var RELEASE = "release";
                  var DEBUG   = "debug";
                  var FILES   = "files";
  
                  var VERSION = window.cloud9config.debug ? DEBUG : RELEASE;
  
                  var apfLoc = staticUrl + "/apf-packaged/apf_" + VERSION + ".js";
              }
              else {
                 var apfLoc = "";
              }
              
              var config = requirejsConfig; 
  
              function createSplash() {
                  var loadingMsgs = [
                    "A for and let clause walk into a bar...",
                    "Don't forget to send FLWORs to your significant other.",
                    "Angle brackets and braces are warming up.",
                    "Our mechanical turks are on strike today, this might take a while...",
                    "In the meantime you can familiarize yourself with section 2.5.5 of the XQuery 3.0 specification."
                  ];
                  var loadingIde = document.createElement('div');
                  loadingIde.setAttribute("id", "loadingide");
                  var msg = loadingMsgs[Math.floor(Math.random() * loadingMsgs.length)];
  
                  msg = msg.replace(/"/g, "&quot;").replace(/'/g, "&#8217;").replace(/</g, "&lt;");
                  loadingIde.innerHTML = '<div class="loader-content"><div class="spinner"></div>' + msg + '</div>';
                  document.body.appendChild(loadingIde);
              }
  
              require(config, [apfLoc], function(){
                  if (!window.localStorage || !localStorage.lastLoadTime ||
                      parseInt(localStorage.lastLoadTime, 10) > 4000)
                      setTimeout(createSplash);
  
                  if (!cloud9config.packed) {
                      var list = ["core/ide", "core/ext", "core/util", 
                      "core/settings", "ext/main/main", "ext/editors/editors",
                      "ace/editor"];
                  }
                  else {
                      var list = [staticUrl + "/" + (cloud9config.packedName.length > 0 ? cloud9config.packedName : "packed.js")];
                  }
                  
                  require(list, function(ide, ext, util){
                      if (!cloud9config.packed) {
                          var plugins = ["ext/filesystem/filesystem","ext/settings/settings","ext/editors/editors","ext/themes/themes","ext/themes_default/themes_default","ext/panels/panels","ext/dockpanel/dockpanel","ext/openfiles/openfiles","ext/tree/tree","ext/save/save","ext/recentfiles/recentfiles","ext/gotofile/gotofile","ext/newresource/newresource","ext/undo/undo","ext/clipboard/clipboard","ext/searchinfiles/searchinfiles","ext/searchreplace/searchreplace","ext/quickwatch/quickwatch","ext/gotoline/gotoline","ext/preview/preview","ext/log/log","ext/help/help","ext/linereport/linereport","ext/code/code","ext/statusbar/statusbar","ext/imgview/imgview","ext/extmgr/extmgr","ext/runpanel/runpanel","ext/debugger/debugger","ext/dbg-node/dbg-node","ext/noderunner/noderunner","ext/console/console","ext/consolehints/consolehints","ext/tabbehaviors/tabbehaviors","ext/tabsessions/tabsessions","ext/keybindings_default/keybindings_default","ext/watcher/watcher","ext/dragdrop/dragdrop","ext/menus/menus","ext/tooltip/tooltip","ext/sidebar/sidebar","ext/filelist/filelist","ext/beautify/beautify","ext/offline/offline","ext/stripws/stripws","ext/testpanel/testpanel","ext/nodeunit/nodeunit","ext/zen/zen","ext/codecomplete/codecomplete","ext/vim/vim","ext/anims/anims","ext/guidedtour/guidedtour","ext/quickstart/quickstart","ext/jslanguage/jslanguage","ext/closeconfirmation/closeconfirmation","ext/codetools/codetools","ext/colorpicker/colorpicker","ext/gitblame/gitblame","ext/autosave/autosave","ext/revisions/revisions","ext/quicksearch/quicksearch","ext/language/liveinspect"];
                      }
  
                      // if you pass `force=true` into the querystring, then
                      // we bypass the browser check
                      if (window.cloud9config.hosted && !window.location.search.match(/\bforce\=true\b/)) {
                          // otherwise, ask apf
                          if (apf.isIE) {
                              // redirect to the notsupported page
                              var ref = encodeURIComponent(window.location.pathname + window.location.search);
                              window.location.href = "/site/notsupported.html?ref=" + ref;
                          }
                      }
  
                      var aceConfig = require("ace/config");
  
                      aceConfig.set("packaged", true);
                      aceConfig.set("workerPath", "/" + version + "/static/ace/worker");
                      aceConfig.set("modePath", staticUrl + "/ace/mode");
                      aceConfig.set("themePath", staticUrl + "/ace/theme");
                      
                      //Load extensions
                      if (!cloud9config.packed) {
                          apf.addEventListener("load", function(){
                              require(plugins, function() {
                                  loadAndBegin(ide, plugins);
                              });
                          });
                      }
                      else {
                          apf.addEventListener("load", function() {
                              var ide = require("core/ide");
                              window.ide = ide;
                              loadAndBegin(ide, list);
                          });
                      }
  
                  });
                  preloaderImgs();
              });
  
              function loadAndBegin(ide, plugins) {
                  ide.dispatchEvent("extload", {modules: plugins});
  
                  cloud9config.totalTime = new Date() - cloud9config.startdate;
                  console.log("Total Load Time " 
                      + (cloud9config.totalTime) + "ms");
                  if (window.localStorage)
                      localStorage.lastLoadTime = cloud9config.totalTime;
  
                  var loadingDiv = document.getElementById("loadingide");
                  if (loadingDiv)
                      document.body.removeChild(loadingDiv);
  
                  ide.addEventListener("$event.extload", function(cb){
                      cb();
                  });
              }
  
              function preloaderImgs() {
                  var preloadImgs = [
                     staticUrl + "/ext/main/style/images/bg-overlay.png",
                     staticUrl + "/ext/main/style/images/cover-heaeder.png",
                     staticUrl + "/ext/main/style/images/cover-logo.png",
                     staticUrl + "/ext/main/style/images/panelBg.png",
                     staticUrl + "/ext/main/style/images/editor_tab.png",
                     staticUrl + "/ext/main/style/images/cloud9logo_transparent.png",
                     staticUrl + "/ext/main/style/images/loading-your-editor.png",
                     staticUrl + "/ext/main/style/images/loaderide.gif"
                  ];
                  if (document.images) {
                      var img;
                      for(var i = 0; i < preloadImgs.length; i++) {
                          img = new Image();
                          img.src = preloadImgs[i];
                      }
                  }
              }
          //]]>
          </script>
      </head>
      <body>
      </body>
  </html>
};

declare %an:sequential function c9:settings()
as xs:string
{
  variable $session := ();

  if(empty($session/settings)) then
    insert node <settings /> into $session;
  else
    ();
  
  util:serialize($session/settings)
};

declare %an:sequential function c9:save-settings($settings as xs:string)
as empty-sequence()
{
  variable $settings := util:parse($settings);
  variable $session := <session />;
  replace node $session/settings with $settings;
};
