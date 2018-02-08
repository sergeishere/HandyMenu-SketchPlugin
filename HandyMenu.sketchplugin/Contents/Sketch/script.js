COScript.currentCOScript().setShouldKeepAround(true);

@import 'MochaJSDelegate.js';

// Plugin's identifiers
var HANDY_MENU_PLUGIN_ID = 'com.sergeishere.plugins.handymenu';
var MENU_IDENTIFIER = 'com.sergeishere.plugins.handymenu.menuWindow';
var SETUP_MENU_IDENTIFIER = 'com.sergeishere.plugins.handymenu.setupWindow';

// User Defaults keys
var PANEL_COMMANDS_KEY = 'plugin_sketch_handymenu_my_commands';
var NEEDS_RELOAD_KEY = 'handymenu_needs_reload';
var COMMANDS_COUNT_KEY = 'plugin_sketch_handymenu_my_commands_count';

// Handy Meny components sizes
var COMMAND_ITEM_HEIGHT = 23;
var MENU_WIDTH = 200;

// System dictionaries
var userDefaults = NSUserDefaults.standardUserDefaults();

// Windows
var handyMenuPanel, handyMenuSettingsWindow;

// Shared variables
var actualContext, allCommandsString;


// Opening Handy Menu
var onRun = function(context) {

    actualContext = context;

    if (!handyMenuPanel) {
        log('Initializing Handy Menu Panel');
        initHandyMenuPanel();
    }

    log('Handy Menu panel is initialized');

    var itemsCount = userDefaults.integerForKey(COMMANDS_COUNT_KEY);

    if (itemsCount == 0) {
        context.document.showMessage('Handy Menu is empty.');
        onSetup(context);
        return;
    }

    // Updating menu size and position

    var menuHeight = itemsCount * COMMAND_ITEM_HEIGHT + 6;
    var mouseLocation = NSEvent.mouseLocation();

    var xPos = mouseLocation.x + 1;
    var yPos = mouseLocation.y - menuHeight + 6;

    if (userDefaults.boolForKey(NEEDS_RELOAD_KEY)) {
        handyMenuPanel.setContentSize(NSMakeSize(MENU_WIDTH, menuHeight));
        handyMenuPanel.setFrameOrigin(NSMakePoint(xPos, yPos));
        handyMenuPanel.contentView().subviews()[0].setFrameSize(NSMakeSize(MENU_WIDTH, menuHeight - 3));
        handyMenuPanel.contentView().subviews()[0].reload(nil);

        userDefaults.setObject_forKey(false, NEEDS_RELOAD_KEY);

    } else {
        handyMenuPanel.setFrameOrigin(NSMakePoint(xPos, yPos));
    }

    // Showing menu
    handyMenuPanel.makeKeyAndOrderFront(nil);

};

// Handy Menu settings window
var onSetup = function(context) {

    actualContext = context;

    if (!handyMenuSettingsWindow) {
        log('Initializing settings window');
        initSettingsWindow();
    }

    log('Settings window is initialized');

    handyMenuSettingsWindow.contentView().subviews()[0].reload(nil);

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

    allCommandsString = JSON.stringify(allCommands);

    // Showing settings window
    handyMenuSettingsWindow.center();
    handyMenuSettingsWindow.makeKeyAndOrderFront(nil);
};



// Utility functions
function initHandyMenuPanel() {

    var itemsCount = userDefaults.integerForKey(COMMANDS_COUNT_KEY);
    var menuHeight = itemsCount * COMMAND_ITEM_HEIGHT + 6;

    // Creating a window
    handyMenuPanel = NSPanel.alloc().init();

    handyMenuPanel.setFrame_display(NSMakeRect(0, 0, MENU_WIDTH, menuHeight), true);
    handyMenuPanel.setStyleMask(NSWindowStyleMaskTexturedBackground | NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskFullSizeContentView);
    handyMenuPanel.setBackgroundColor(NSColor.windowBackgroundColor());
    handyMenuPanel.standardWindowButton(NSWindowCloseButton).setHidden(true);
    handyMenuPanel.standardWindowButton(NSWindowMiniaturizeButton).setHidden(true);
    handyMenuPanel.standardWindowButton(NSWindowZoomButton).setHidden(true);
    handyMenuPanel.setTitlebarAppearsTransparent(true);
    handyMenuPanel.setLevel(NSPopUpMenuWindowLevel);

    //Add Web View to window
    var webView = WebView.alloc().initWithFrame(NSMakeRect(0, 0, MENU_WIDTH, menuHeight - 3));
    webView.setAutoresizingMask(NSViewWidthSizable | NSViewHeightSizable);
    webView.setDrawsBackground(false);
    handyMenuPanel.contentView().addSubview(webView);

    var windowObject = webView.windowScriptObject();
    var delegate = new MochaJSDelegate({

        'webView:didFinishLoadForFrame:': (function(webView, webFrame) {
            var myCommandsString = userDefaults.stringForKey(PANEL_COMMANDS_KEY);
            windowObject.callWebScriptMethod_withArguments('updateCommandsList', [myCommandsString]);

        }),

        'webView:didChangeLocationWithinPageForFrame:': (function(webView, webFrame) {

            var locationHash = windowObject.evaluateWebScript('window.location.hash');

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

                    if (key == pluginID) {
                        handyMenuPanel.orderOut(nil);

                        try {
                            NSApp.delegate().runPluginCommandWithIdentifier_fromBundleAtURL_context_(
                                commandID,
                                plugins[key].url(),
                                actualContext);
                        } catch (e) {
                            log('Plugin running error. \n' + e.name + ':' + e.message + '\n' + e.stack);
                        }
                        return;
                    }
                }
            }

        })
    });

    webView.setFrameLoadDelegate_(delegate.getClassInstance());
    webView.setMainFrameURL(actualContext.plugin.urlForResourceNamed('handyMenu.html').path());
    userDefaults.setObject_forKey(true, NEEDS_RELOAD_KEY);

    // Define the close window behaviour on the standard red traffic light button
    var closeButton = handyMenuPanel.standardWindowButton(NSWindowCloseButton);
    closeButton.setCOSJSTargetFunction(function(sender) {
        handyMenuPanel.orderOut(nil);
    });
    closeButton.setAction('callAction:');
}

// Initializing Settings Window

function initSettingsWindow() {
    // Configuring a window
    var windowWidth = 760;
    var menuHeight = 640;

    handyMenuSettingsWindow = NSPanel.alloc().init();

    handyMenuSettingsWindow.setFrame_display(NSMakeRect(0, 0, windowWidth, menuHeight), false);
    handyMenuSettingsWindow.setStyleMask(NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskTexturedBackground);
    handyMenuSettingsWindow.setBackgroundColor(NSColor.windowBackgroundColor());
    handyMenuSettingsWindow.standardWindowButton(NSWindowMiniaturizeButton).setHidden(true);
    handyMenuSettingsWindow.standardWindowButton(NSWindowZoomButton).setHidden(true);
    handyMenuSettingsWindow.setTitle('Handy Menu Settings');
    handyMenuSettingsWindow.setLevel(NSFloatingWindowLevel);

    //Add Web View to window
    var webView = WebView.alloc().initWithFrame(NSMakeRect(0, 0, windowWidth, menuHeight - 20));
    webView.setAutoresizingMask(NSViewWidthSizable | NSViewHeightSizable);
    var windowObject = webView.windowScriptObject();
    var delegate = new MochaJSDelegate({

        'webView:didFinishLoadForFrame:': (function(webView, webFrame) {

            var myCommandsString = userDefaults.stringForKey(PANEL_COMMANDS_KEY);

            windowObject.callWebScriptMethod_withArguments('loadAllCommandsList', [allCommandsString]);
            windowObject.callWebScriptMethod_withArguments('loadMyCommandsList', [myCommandsString]);

        }),

        'webView:didChangeLocationWithinPageForFrame:': (function(webView, webFrame) {

            var locationHash = windowObject.evaluateWebScript('window.location.hash');
            var hash = parseHash(locationHash);
            log(hash);

            if (hash.hasOwnProperty('saveCommandsList')) {
                var commandsString = hash.commands;
                var commandsCount = hash.commandsCount;

                userDefaults.setObject_forKey(commandsString, PANEL_COMMANDS_KEY);
                userDefaults.setObject_forKey(commandsCount, COMMANDS_COUNT_KEY);
                userDefaults.synchronize();

                handyMenuSettingsWindow.orderOut(nil);

                userDefaults.setObject_forKey(true, NEEDS_RELOAD_KEY);

            } else if (hash.hasOwnProperty('closeWindow')) {
                handyMenuSettingsWindow.orderOut(nil);
            }
        })
    });

    webView.setFrameLoadDelegate_(delegate.getClassInstance());
    webView.setMainFrameURL_(actualContext.plugin.urlForResourceNamed('setupMenu.html').path());
    handyMenuSettingsWindow.contentView().addSubview(webView);

    var closeButton = handyMenuSettingsWindow.standardWindowButton(NSWindowCloseButton);
    closeButton.setCOSJSTargetFunction(function(sender) {
        handyMenuSettingsWindow.orderOut(nil);
    });
    closeButton.setAction('callAction:');
}

// Getting Hex Color from NSColor

function getHexColor(fromNSColor) {

    var color = MSColor.colorWithNSColor(fromNSColor);
    var sR = (Math.round(color.red() * 255)).toString(16);
    var sG = (Math.round(color.green() * 255)).toString(16);
    var sB = (Math.round(color.blue() * 255)).toString(16);
    return '#' + sR + sG + sB;
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