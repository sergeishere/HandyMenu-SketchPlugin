@import "MochaJSDelegate.js";
@import "quickPanelDefaults.js";

function onRun(context) {
  //Since the webview can talk with Sketch, we have a function to update the context
  //as needed to make sure we have the correct context when we apply changes
  //the updateContext function is in utils.js
  // var doc = updateContext().document;

  var userDefaults = NSUserDefaults.standardUserDefaults();
  var threadDictionary = NSThread.mainThread().threadDictionary();

  if (threadDictionary[setupWindowIdentifier]) {
    return;
  }

  COScript.currentCOScript().setShouldKeepAround(true);

  // Configuring a window
  var windowWidth = 640;
  var windowHeight = 640;

  var webViewWindow = NSPanel.alloc().init();

  webViewWindow.setFrame_display(NSMakeRect(0, 0, windowWidth, windowHeight), false);
  webViewWindow.setStyleMask(NSTitledWindowMask | NSClosableWindowMask);
  webViewWindow.setBackgroundColor(NSColor.colorWithRed_green_blue_alpha(0.13, 0.07, 0.33, 1.0));
  webViewWindow.standardWindowButton(NSWindowMiniaturizeButton).setHidden(true);
  webViewWindow.standardWindowButton(NSWindowZoomButton).setHidden(true);
  // webViewWindow.setTitle("Setup QuickPanel");
  webViewWindow.setTitlebarAppearsTransparent(true);
  webViewWindow.becomeKeyWindow();
  webViewWindow.setLevel(NSFloatingWindowLevel);
  webViewWindow.isMovable = true;

  threadDictionary[setupWindowIdentifier] = webViewWindow;

  // Get commands list
  var pluginManager = AppController.sharedInstance().pluginManager();
  var plugins = pluginManager.plugins();

  var allCommands = [];

  for (key in plugins) {
    var commands = plugins[key].commands();
    for (command in commands) {
      
      var record = {
        name: commands[command].metadata().name + '',
        pluginID: key + '',
        commandID: commands[command].identifier() + ''
      };
      allCommands.push(record);
    }
  }

  const allCommandsString = JSON.stringify(allCommands);

  //Add Web View to window
  var webView = WebView.alloc().initWithFrame(NSMakeRect(0, 0, windowWidth, windowHeight-24));
  webView.setAutoresizingMask(NSViewWidthSizable | NSViewHeightSizable);
  var windowObject = webView.windowScriptObject();
  var delegate = new MochaJSDelegate({

    "webView:didFinishLoadForFrame:": (function(webView, webFrame) {

      var myCommandsString = userDefaults.stringForKey(panelCommandsKey);

      windowObject.callWebScriptMethod_withArguments("loadMyCommandsList", [myCommandsString]);
      windowObject.callWebScriptMethod_withArguments("loadAllCommandsList",[allCommandsString]);
      
    }),

    //To get commands from the webView we observe the location hash: if it changes, we do something
    "webView:didChangeLocationWithinPageForFrame:": (function(webView, webFrame) {

      var locationHash = windowObject.evaluateWebScript("window.location.hash");
      //The hash object exposes commands and parameters
      //In example, if you send updateHash('add','artboardName','Mark')
      //You’ll be able to use hash.artboardName to return 'Mark'
      var hash = parseHash(locationHash);
      log(hash);
      //We parse the location hash and check for the command we are sending from the UI
      //If the command exist we run the following code
      if (hash.hasOwnProperty('saveCommandsList')) {
        //If you are sending arguments from the UI
        //You can simply grab them from the hash object
        var commandsString = hash.commands;
        var commandsCount = hash.commandsCount;

        userDefaults.setObject_forKey(commandsString, panelCommandsKey);
        userDefaults.setObject_forKey(commandsCount, panelCommandsCountKey);
        userDefaults.synchronize();

        threadDictionary.removeObjectForKey(setupWindowIdentifier);
        webViewWindow.close();
        COScript.currentCOScript().setShouldKeepAround(false);
      }else if (hash.hasOwnProperty('closeWindow')){
        webViewWindow.close();
        threadDictionary.removeObjectForKey(setupWindowIdentifier);
        COScript.currentCOScript().setShouldKeepAround(false);
      }
    })
  });

  webView.setFrameLoadDelegate_(delegate.getClassInstance());
  webView.setMainFrameURL_(context.plugin.urlForResourceNamed("setuppanel.html").path());
  webViewWindow.contentView().addSubview(webView);
  webViewWindow.center();
  webViewWindow.makeKeyAndOrderFront(nil);

  // Define the close window behaviour on the standard red traffic light button
  var closeButton = webViewWindow.standardWindowButton(NSWindowCloseButton);
  closeButton.setCOSJSTargetFunction(function(sender) {
    COScript.currentCOScript().setShouldKeepAround(false);
    threadDictionary.removeObjectForKey(setupWindowIdentifier);
    webViewWindow.close();
  });
  closeButton.setAction("callAction:");
};

//Utility functions
function updateContext() {
  var doc = NSDocumentController.sharedDocumentController().currentDocument();

  return {
    document: doc
  }
}

function getHexColor(fromNSColor) {
  var color = MSColor.colorWithNSColor(fromNSColor));
  var sR = (Math.round(color.red() * 255)).toString(16);
  var sG = (Math.round(color.green() * 255)).toString(16);
  var sB = (Math.round(color.blue() * 255)).toString(16);
  return "#" + sR + sG + sB;
}

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