@import "MochaJSDelegate.js";

// Plugin's identifiers
const HANDY_MENU_PLUGIN_ID = "com.sergeishere.plugins.handymenu";
const MENU_IDENTIFIER = "com.sergeishere.plugins.handymenu.menuWindow";
const SETUP_MENU_IDENTIFIER = "com.sergeishere.plugins.handymenu.setupWindow";

// User Defaults keys
const PANEL_COMMANDS_KEY = "plugin_sketch_handymenu_my_commands";
const NEEDS_RELOAD_KEY = 'handymenu_needs_reload';
const COMMANDS_COUNT_KEY = "plugin_sketch_handymenu_my_commands_count";

// Handy Meny components sizes
const COMMAND_ITEM_HEIGHT = 23;
const MENU_WIDTH = 200;

// System dictionaries
var userDefaults = NSUserDefaults.standardUserDefaults();
var threadDictionary = NSThread.mainThread().threadDictionary();

var handyMenuPanel = threadDictionary[MENU_IDENTIFIER];


// After loading Sketch
var onStart = function(context) {

    const itemsCount = userDefaults.integerForKey(COMMANDS_COUNT_KEY);
    const MENU_HEIGHT = itemsCount * COMMAND_ITEM_HEIGHT + 6;

    // Creating a window
    handyMenuPanel = NSPanel.alloc().init();

    handyMenuPanel.setFrame_display(NSMakeRect(0, 0, MENU_WIDTH, MENU_HEIGHT), true);
    handyMenuPanel.setStyleMask(NSWindowStyleMaskTexturedBackground | NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskFullSizeContentView);
    handyMenuPanel.setBackgroundColor(NSColor.windowBackgroundColor());
    handyMenuPanel.standardWindowButton(NSWindowCloseButton).setHidden(true);
    handyMenuPanel.standardWindowButton(NSWindowMiniaturizeButton).setHidden(true);
    handyMenuPanel.standardWindowButton(NSWindowZoomButton).setHidden(true);
    handyMenuPanel.setTitlebarAppearsTransparent(true);
    handyMenuPanel.setLevel(NSPopUpMenuWindowLevel);

    //Add Web View to window
    var webView = WebView.alloc().initWithFrame(NSMakeRect(0, 0, MENU_WIDTH, MENU_HEIGHT - 3));
    webView.setAutoresizingMask(NSViewWidthSizable | NSViewHeightSizable);
    webView.setDrawsBackground(false);

    webView.setMainFrameURL(context.plugin.urlForResourceNamed("handyMenu.html").path());
    userDefaults.setObject_forKey(true, NEEDS_RELOAD_KEY);

    handyMenuPanel.contentView().addSubview(webView);

    threadDictionary[MENU_IDENTIFIER] = handyMenuPanel;

}


// Opening Handy Menu
var onRun = function(context) {

    COScript.currentCOScript().setShouldKeepAround(true);

    const itemsCount = userDefaults.integerForKey(COMMANDS_COUNT_KEY);

    if (itemsCount == 0) {
        context.document.showMessage("Handy Menu is empty.");
        onSetup(context);
        return;
    }

    const MENU_HEIGHT = itemsCount * COMMAND_ITEM_HEIGHT + 6;

    log(handyMenuPanel);

    var mouseLocation = NSEvent.mouseLocation();

    var xPos = mouseLocation.x + 1;
    var yPos = mouseLocation.y - MENU_HEIGHT + 6;

    if (handyMenuPanel.frame().size.height != MENU_HEIGHT) {
        handyMenuPanel.setContentSize(NSMakeSize(MENU_WIDTH, MENU_HEIGHT));
        handyMenuPanel.setFrameOrigin(NSMakePoint(xPos, yPos));
        handyMenuPanel.contentView().subviews()[0].setFrameSize(NSMakeSize(MENU_WIDTH, MENU_HEIGHT - 3));
    } else {
        handyMenuPanel.setFrameOrigin(NSMakePoint(xPos, yPos));
    }

    if (userDefaults.boolForKey(NEEDS_RELOAD_KEY)) {
        log('reloaded');
        handyMenuPanel.contentView().subviews()[0].reload(nil);
        userDefaults.setObject_forKey(false, NEEDS_RELOAD_KEY);
    }

    handyMenuPanel.makeKeyAndOrderFront(nil);

    var constWebView = handyMenuPanel.contentView().subviews()[0];
    var windowObject = constWebView.windowScriptObject();
    var myCommandsString = userDefaults.stringForKey(PANEL_COMMANDS_KEY);

    var delegate = new MochaJSDelegate({

        "webView:didFinishLoadForFrame:": (function(webView, webFrame) {

            windowObject.callWebScriptMethod_withArguments('updateCommandsList', [myCommandsString]);

        }),

        "webView:didChangeLocationWithinPageForFrame:": (function(webView, webFrame) {

            var locationHash = windowObject.evaluateWebScript("window.location.hash");

            var hash = parseHash(locationHash);
            log(hash);

            if (hash.hasOwnProperty('executeCommand')) {

                commandID = hash.commandID;
                pluginID = hash.pluginID;

                // Geting commands list
                var pluginManager = AppController.sharedInstance().pluginManager();
                var plugins = pluginManager.plugins();

                for (key in plugins) {
                    var commands = plugins[key].commands();
                    for (command in commands) {
                        if (key == pluginID && commands[command].metadata().identifier == commandID) {

                            handyMenuPanel.orderOut(nil);

                            try {
                                commands[command].run_manager(context, pluginManager);
                            } catch (e) {
                                log('Plugin running error. \n' + e.name + ':' + e.message + '\n' + e.stack);
                            }
                            
                            COScript.currentCOScript().setShouldKeepAround(false);
                            
                            return;
                        }
                    }
                }
            }

        })
    });

    constWebView.setFrameLoadDelegate_(delegate.getClassInstance());

    // Define the close window behaviour on the standard red traffic light button
    var closeButton = handyMenuPanel.standardWindowButton(NSWindowCloseButton);
    closeButton.setCOSJSTargetFunction(function(sender) {
        COScript.currentCOScript().setShouldKeepAround(false);
        handyMenuPanel.orderOut(nil);
    });
    closeButton.setAction("callAction:");
};

// Handy Menu settings window
var onSetup = function(context) {

    var userDefaults = NSUserDefaults.standardUserDefaults();
    var threadDictionary = NSThread.mainThread().threadDictionary();

    if (threadDictionary[SETUP_MENU_IDENTIFIER]) {
        return;
    }

    // Getting commands list
    var pluginManager = AppController.sharedInstance().pluginManager();
    var plugins = pluginManager.plugins();

    var allCommands = [];

    for (key in plugins) {
        if (key != HANDY_MENU_PLUGIN_ID) {
            var commands = plugins[key].commands();
            var record = {
                'pluginName': plugins[key].metadata().name + '',
                'commands': []
            };

            for (command in commands) {

                if (commands[command].hasRunHandler()) {

                    var commandRecord = {
                        name: commands[command].metadata().name + '',
                        pluginID: key + '',
                        commandID: commands[command].identifier() + ''
                    };

                    record.commands.push(commandRecord);
                }

            }

            allCommands.push(record);

        }
    }

    // Configuring a window
    var windowWidth = 640;
    var MENU_HEIGHT = 640;

    var webViewWindow = NSPanel.alloc().init();

    webViewWindow.setFrame_display(NSMakeRect(0, 0, windowWidth, MENU_HEIGHT), false);
    webViewWindow.setStyleMask(NSTitledWindowMask | NSClosableWindowMask);
    webViewWindow.setBackgroundColor(NSColor.colorWithRed_green_blue_alpha(0.13, 0.07, 0.33, 1.0));
    webViewWindow.standardWindowButton(NSWindowMiniaturizeButton).setHidden(true);
    webViewWindow.standardWindowButton(NSWindowZoomButton).setHidden(true);
    webViewWindow.setTitlebarAppearsTransparent(true);
    webViewWindow.setLevel(NSFloatingWindowLevel);

    threadDictionary[SETUP_MENU_IDENTIFIER] = webViewWindow;

    const allCommandsString = JSON.stringify(allCommands);

    COScript.currentCOScript().setShouldKeepAround(true);
    //Add Web View to window
    var webView = WebView.alloc().initWithFrame(NSMakeRect(0, 0, windowWidth, MENU_HEIGHT - 24));
    webView.setAutoresizingMask(NSViewWidthSizable | NSViewHeightSizable);
    var windowObject = webView.windowScriptObject();
    var delegate = new MochaJSDelegate({

        "webView:didFinishLoadForFrame:": (function(webView, webFrame) {

            var myCommandsString = userDefaults.stringForKey(PANEL_COMMANDS_KEY);

            windowObject.callWebScriptMethod_withArguments("loadMyCommandsList", [myCommandsString]);
            windowObject.callWebScriptMethod_withArguments("loadAllCommandsList", [allCommandsString]);

        }),

        "webView:didChangeLocationWithinPageForFrame:": (function(webView, webFrame) {

            var locationHash = windowObject.evaluateWebScript("window.location.hash");
            var hash = parseHash(locationHash);
            log(hash);

            if (hash.hasOwnProperty('saveCommandsList')) {
                var commandsString = hash.commands;
                var commandsCount = hash.commandsCount;

                userDefaults.setObject_forKey(commandsString, PANEL_COMMANDS_KEY);
                userDefaults.setObject_forKey(commandsCount, COMMANDS_COUNT_KEY);
                userDefaults.synchronize();

                threadDictionary.removeObjectForKey(SETUP_MENU_IDENTIFIER);
                webViewWindow.close();

                userDefaults.setObject_forKey(true, NEEDS_RELOAD_KEY);

                COScript.currentCOScript().setShouldKeepAround(false);
            } else if (hash.hasOwnProperty('closeWindow')) {
                webViewWindow.close();
                threadDictionary.removeObjectForKey(SETUP_MENU_IDENTIFIER);
                COScript.currentCOScript().setShouldKeepAround(false);
            }
        })
    });

    webView.setFrameLoadDelegate_(delegate.getClassInstance());
    webView.setMainFrameURL_(context.plugin.urlForResourceNamed("setupMenu.html").path());
    webViewWindow.contentView().addSubview(webView);
    webViewWindow.center();
    webViewWindow.makeKeyAndOrderFront(nil);

    var closeButton = webViewWindow.standardWindowButton(NSWindowCloseButton);
    closeButton.setCOSJSTargetFunction(function(sender) {
        COScript.currentCOScript().setShouldKeepAround(false);
        threadDictionary.removeObjectForKey(SETUP_MENU_IDENTIFIER);
        webViewWindow.close();
    });
    closeButton.setAction("callAction:");
};



// Utility functions


// Getting actual context
function updateContext() {
    var doc = NSDocumentController.sharedDocumentController().currentDocument();

    return {
        document: doc
    }
}


// Getting Hex Color from NSColor

function getHexColor(fromNSColor) {

    var color = MSColor.colorWithNSColor(fromNSColor));
    var sR = (Math.round(color.red() * 255)).toString(16);
    var sG = (Math.round(color.green() * 255)).toString(16);
    var sB = (Math.round(color.blue() * 255)).toString(16);
    return "#" + sR + sG + sB;
}


// Parsing WebView's hash
function parseHash(aURL) {
    aURL = aURL;
    var vars = {};
    var hashes = aURL.slice(aURL.indexOf('#') + 1).split('&');

    for (var i = 0; i < hashes.length; i++) {
        var hash = hashes[i].split('=');

        if (hash.length > 1) {
            vars[hash[0].toString()] = hash[1];
        } else {
            vars[hash[0].toString()] = null;
        }
    }

    return vars;
}