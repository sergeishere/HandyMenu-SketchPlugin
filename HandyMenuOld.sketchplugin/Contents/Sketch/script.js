// Plugin's identifiers
var HANDY_MENU_PLUGIN_ID = 'com.sergeishere.plugins.handymenu';
var MENU_IDENTIFIER = 'com.sergeishere.plugins.handymenu.menuWindow';
var SETUP_MENU_IDENTIFIER = 'com.sergeishere.plugins.handymenu.setupWindow';
var ACTUAL_CONTEXT_IDENTIFIER = 'com.sergeishere.plugins.handymenu.actualContext';

// User Defaults keys
var PANEL_COMMANDS_KEY = 'plugin_sketch_handymenu_my_commands';
var NEEDS_RELOAD_KEY = 'handymenu_needs_reload';
var COMMANDS_COUNT_KEY = 'plugin_sketch_handymenu_my_commands_count';
var PANEL_HEIGHT_KEY = 'plugin_sketch_handymenu_my_commands_panel_height';
var ALL_COMMANDS_STRING = 'plugin_sketch_handymenu_all_commands_string';

// Handy Meny components sizes
var COMMAND_ITEM_HEIGHT = 23;
var MENU_WIDTH = 200;

// Updating plugins list
var onStart = function(context) {
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
    
    //Saving to the user defaults
    var userDefaults = NSUserDefaults.standardUserDefaults();
    userDefaults.setObject_forKey(JSON.stringify(allCommands), ALL_COMMANDS_STRING);
    userDefaults.synchronize();
}

// Opening Handy Menu
var onRun = function(context) {

    var userDefaults = NSUserDefaults.standardUserDefaults();

    var itemsCount = userDefaults.integerForKey(COMMANDS_COUNT_KEY);

    // Opening settings if there are no added commands
    if (itemsCount == 0) {
        context.document.showMessage('Handy Menu is empty.');
        onSetup(context);
        return;
    }

    COScript.currentCOScript().setShouldKeepAround_(true);

    var threadDictionary = NSThread.mainThread().threadDictionary();
    // Updating actual context
    threadDictionary[ACTUAL_CONTEXT_IDENTIFIER] = context;
    // Reusing menu panel instance or creating the new one
    var handyMenuPanel = threadDictionary[MENU_IDENTIFIER] || initHandyMenuPanel();

    // Updating menu size and position
    var totalHeight = userDefaults.integerForKey(PANEL_HEIGHT_KEY) || (COMMAND_ITEM_HEIGHT * itemsCount);

    var mouseLocation = NSEvent.mouseLocation();

    var xPos = mouseLocation.x + 1;
    var yPos = mouseLocation.y - totalHeight + 12;

    if (userDefaults.boolForKey(NEEDS_RELOAD_KEY)) {
        handyMenuPanel.setContentSize(NSMakeSize(MENU_WIDTH, totalHeight + 6));
        handyMenuPanel.setFrameOrigin(NSMakePoint(xPos, yPos));
        handyMenuPanel.contentView().subviews()[0].setFrameSize(NSMakeSize(MENU_WIDTH, totalHeight + 6));
        handyMenuPanel.contentView().subviews()[1].setFrameSize(NSMakeSize(MENU_WIDTH, totalHeight + 3));
        handyMenuPanel.contentView().subviews()[1].reload(nil);

        userDefaults.setObject_forKey(false, NEEDS_RELOAD_KEY);

    } else {
        handyMenuPanel.setFrameOrigin(NSMakePoint(xPos, yPos));
    }

    // Showing menu
    handyMenuPanel.makeKeyAndOrderFront(nil);
}

// Initializing Handy Menu panel
function initHandyMenuPanel() {

    console.log('Initializing handyMenuPanel');

    var threadDictionary = NSThread.mainThread().threadDictionary();
    var userDefaults = NSUserDefaults.standardUserDefaults();

    var actualContext = threadDictionary[ACTUAL_CONTEXT_IDENTIFIER];

    var itemsCount = userDefaults.integerForKey(COMMANDS_COUNT_KEY);
    var totalHeight = userDefaults.integerForKey(PANEL_HEIGHT_KEY) || (COMMAND_ITEM_HEIGHT * itemsCount);

    // Creating a window
    handyMenuPanel = NSPanel.alloc().init();
    handyMenuPanel.setFrame_display(NSMakeRect(0, 0, MENU_WIDTH, totalHeight + 6), true);
    handyMenuPanel.setStyleMask(NSWindowStyleMaskTexturedBackground | NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskFullSizeContentView);
    handyMenuPanel.setBackgroundColor(NSColor.windowBackgroundColor());
    handyMenuPanel.standardWindowButton(NSWindowCloseButton).setHidden(true);
    handyMenuPanel.standardWindowButton(NSWindowMiniaturizeButton).setHidden(true);
    handyMenuPanel.standardWindowButton(NSWindowZoomButton).setHidden(true);
    handyMenuPanel.setTitlebarAppearsTransparent(true);
    handyMenuPanel.setLevel(NSPopUpMenuWindowLevel);
    handyMenuPanel.animationBehavior = NSWindowAnimationBehaviorUtilityWindow;

    // Adding vibrancy effect
    var vibrancy = NSVisualEffectView.alloc().initWithFrame(NSMakeRect(0, 0, MENU_WIDTH, totalHeight+6));
    vibrancy.setAppearance(NSAppearance.appearanceNamed(NSAppearanceNameVibrantLight));
    vibrancy.setBlendingMode(NSVisualEffectBlendingModeBehindWindow);
    handyMenuPanel.contentView().addSubview(vibrancy);

    loadAndRun(actualContext, function() {
        HMHelper.startWatchingTo(handyMenuPanel);
    });

    //Add Web View to window
    var webView = WebView.alloc().initWithFrame(NSMakeRect(0, 0, MENU_WIDTH, totalHeight + 3));
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
                COScript.currentCOScript().setShouldKeepAround_(false);
            }

        })
    });

    webView.setFrameLoadDelegate_(delegate.getClassInstance());
    webView.setMainFrameURL(actualContext.plugin.urlForResourceNamed('handyMenu.html').path());
    userDefaults.setObject_forKey(true, NEEDS_RELOAD_KEY);

    var closeButton = handyMenuPanel.standardWindowButton(NSWindowCloseButton);
    closeButton.setCOSJSTargetFunction(function(sender) {
        handyMenuPanel.orderOut(nil);
        COScript.currentCOScript().setShouldKeepAround_(false);
    });
    closeButton.setAction('callAction:');
    
    threadDictionary[MENU_IDENTIFIER] = handyMenuPanel;
    return handyMenuPanel;
}

// Opening settings window
var onSetup = function(context) {

    var userDefaults = NSUserDefaults.standardUserDefaults();
    var threadDictionary = NSThread.mainThread().threadDictionary();

    // Updating actual context
    threadDictionary[ACTUAL_CONTEXT_IDENTIFIER] = context;  
    // Reusing settings instanceor creating the new one
    var handyMenuSettingsWindow = threadDictionary[SETUP_MENU_IDENTIFIER] || initSettingsWindow();

    COScript.currentCOScript().setShouldKeepAround_(true);

    handyMenuSettingsWindow.contentView().subviews()[0].reload(nil);

    // Showing settings window
    handyMenuSettingsWindow.center();
    handyMenuSettingsWindow.makeKeyAndOrderFront(nil);
}

// Initializing Settings Window
function initSettingsWindow() {

    var threadDictionary = NSThread.mainThread().threadDictionary();
    var userDefaults = NSUserDefaults.standardUserDefaults();

    var actualContext = threadDictionary[ACTUAL_CONTEXT_IDENTIFIER];

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
            var allCommandsString = userDefaults.stringForKey(ALL_COMMANDS_STRING);
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
                var totalHeight = hash.totalHeight;

                userDefaults.setObject_forKey(commandsString, PANEL_COMMANDS_KEY);
                userDefaults.setObject_forKey(commandsCount, COMMANDS_COUNT_KEY);
                userDefaults.setObject_forKey(totalHeight, PANEL_HEIGHT_KEY);
                userDefaults.setObject_forKey(true, NEEDS_RELOAD_KEY);
                userDefaults.synchronize();
                
                handyMenuSettingsWindow.orderOut(nil);
                COScript.currentCOScript().setShouldKeepAround_(false);

            } else if (hash.hasOwnProperty('closeWindow')) {
                handyMenuSettingsWindow.orderOut(nil);
                COScript.currentCOScript().setShouldKeepAround_(false);

            } else if (hash.hasOwnProperty('goto')) {
                var url = hash.url;
                NSWorkspace.sharedWorkspace().openURL(NSURL.URLWithString(url));

            }
        })
    });

    webView.setFrameLoadDelegate_(delegate.getClassInstance());
    webView.setMainFrameURL_(actualContext.plugin.urlForResourceNamed('setupMenu.html').path());
    handyMenuSettingsWindow.contentView().addSubview(webView);

    var closeButton = handyMenuSettingsWindow.standardWindowButton(NSWindowCloseButton);
    closeButton.setCOSJSTargetFunction(function(sender) {
        COScript.currentCOScript().setShouldKeepAround_(false);
        handyMenuSettingsWindow.orderOut(nil);
    });
    closeButton.setAction('callAction:');

    threadDictionary[SETUP_MENU_IDENTIFIER] = handyMenuSettingsWindow;

    return handyMenuSettingsWindow;
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

// Loading framework
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

//
//  MochaJSDelegate.js
//  MochaJSDelegate
//
//  Created by Matt Curtis
//  Copyright (c) 2015. All rights reserved.
//

var MochaJSDelegate = function(selectorHandlerDict){
	var uniqueClassName = "MochaJSDelegate_DynamicClass_" + NSUUID.UUID().UUIDString();

	var delegateClassDesc = MOClassDescription.allocateDescriptionForClassWithName_superclass_(uniqueClassName, NSObject);
	
	delegateClassDesc.registerClass();

	//	Handler storage

	var handlers = {};

	//	Define interface

	this.setHandlerForSelector = function(selectorString, func){
		var handlerHasBeenSet = (selectorString in handlers);
		var selector = NSSelectorFromString(selectorString);

		handlers[selectorString] = func;

		if(!handlerHasBeenSet){
			/*
				For some reason, Mocha acts weird about arguments:
				https://github.com/logancollins/Mocha/issues/28

				We have to basically create a dynamic handler with a likewise dynamic number of predefined arguments.
			*/

			var dynamicHandler = function(){
				var functionToCall = handlers[selectorString];

				if(!functionToCall) return;

				return functionToCall.apply(delegateClassDesc, arguments);
			};

			var args = [], regex = /:/g;
			while(match = regex.exec(selectorString)) args.push("arg"+args.length);
			
			dynamicFunction = eval("(function("+args.join(",")+"){ return dynamicHandler.apply(this, arguments); })");

			delegateClassDesc.addInstanceMethodWithSelector_function_(selector, dynamicFunction);
		}
	};

	this.removeHandlerForSelector = function(selectorString){
		delete handlers[selectorString];
	};

	this.getHandlerForSelector = function(selectorString){
		return handlers[selectorString];
	};

	this.getAllHandlers = function(){
		return handlers;
	};

	this.getClass = function(){
		return NSClassFromString(uniqueClassName);
	};

	this.getClassInstance = function(){
		return NSClassFromString(uniqueClassName).new();
	};

	//	Conveience

	if(typeof selectorHandlerDict == "object"){
		for(var selectorString in selectorHandlerDict){
			this.setHandlerForSelector(selectorString, selectorHandlerDict[selectorString]);
		}
	}
}