var onStart = function(context) {
    loadAndRun(context,function(){
        HandyMenu.initializePlugin();
    })
}

var onShowMenu = function(context) {
    loadAndRun(context, function(){
        HandyMenu.showMenu();
    })
};

var onSetup = function(context) {
    loadAndRun(context, function(){
        HandyMenu.showSettings();
    })
};


function loadAndRun(context, callback) {
    var FRAMEWORK_NAME = "HandyMenuFramework";
    try {
        callback();
    } catch (e) {
        var pluginBundle = NSBundle.bundleWithURL(context.plugin.url()),
            mocha = Mocha.sharedRuntime();
        if (mocha.loadFrameworkWithName_inDirectory(FRAMEWORK_NAME, pluginBundle.resourceURL().path())) {
            callback();
        } else {
            print("Error while loading framework '" + FRAMEWORK_NAME + "`");
        }
    }
}