function onStart(context) {
    loadAndRun(context, function() {
        HandyMenuPlugin.shared().configure();
    });
}

function onSetup(context) {
    loadAndRun(context, function() {
        HandyMenuPlugin.shared().showSettings();
    });
}

function onExport(context) {
    loadAndRun(context, function() {
        HandyMenuPlugin.shared().exportSettings();
    });
}

function onImport(context) {
    loadAndRun(context, function() {
        HandyMenuPlugin.shared().importSettings();
    });
}

function loadAndRun(context, callback) {

    var osVersionString = NSProcessInfo.processInfo().operatingSystemVersionString();
    var doesOsSupportModern = /11.[0-9]/.test(osVersionString) || /10.15.[0-9]/.test(osVersionString);

    var FRAMEWORK_NAME = doesOsSupportModern ? 'HandyMenuModern' : 'HandyMenuFramework';

    try {
        callback();
    } catch (e) {
        var path = context.plugin
            .urlForResourceNamed(FRAMEWORK_NAME + '.framework')
            .path()
            .stringByDeletingLastPathComponent();
        if (Mocha.sharedRuntime().loadFrameworkWithName_inDirectory(FRAMEWORK_NAME, path)) {
            callback();
        } else {
            print("Error while loading framework '" + FRAMEWORK_NAME + '`');
        }
    }
}
