/**
 * PHP linter worker.
 *
 * @copyright 2011, Ajax.org B.V.
 * @license GPLv3 <http://www.gnu.org/licenses/gpl.txt>
 */
define("ext/xquery/linereport", ["require", "exports", "module"], function(require, exports, module) {
    
var baseLanguageHandler = require("ext/linereport/linereport_base");
var handler = module.exports = Object.create(baseLanguageHandler);

handler.disabled = false;

handler.handlesLanguage = function(language) {
    return language === 'xquery';
};

handler.init = function(callback) {
    callback();
};

handler.analyze = function(doc, fullAst, callback) {
    if (handler.disabled)
        return callback();
    handler.invokeReporter("php -f " + handler.workspaceDir, this.$postProcess, callback);
};

handler.$postProcess = function(line) {
    return line;
};

});