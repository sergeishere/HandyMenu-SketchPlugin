@import "MochaJSDelegate.js";
@import "quickPanelDefaults.js";

function onRun(context) {
  //Since the webview can talk with Sketch, we have a function to update the context
  //as needed to make sure we have the correct context when we apply changes
  //the updateContext function is in utils.js
  // var doc = updateContext().document;

  var userDefaults = NSUserDefaults.standardUserDefaults();

  // Create a window
  var threadDictionary = NSThread.mainThread().threadDictionary();

  if (threadDictionary[panelIdentifier]) {
    return;
  }

  var itemsCount = userDefaults.integerForKey(panelCommandsCountKey);
  const commandItemHeight = 23;

  const windowWidth = 200;
  const windowHeight = itemsCount * commandItemHeight + 30;

  var mouseLocation = NSEvent.mouseLocation();

  var xPos = mouseLocation.x;
  var yPos = mouseLocation.y - windowHeight + 27;

  var webViewWindow = NSPanel.alloc().init();
  webViewWindow.setFrame_display(NSMakeRect(xPos, yPos, windowWidth, windowHeight), false);
  webViewWindow.setStyleMask(NSTexturedBackgroundWindowMask | NSTitledWindowMask | NSClosableWindowMask | NSFullSizeContentViewWindowMask);

  //Uncomment the following line to define the app bar color with an NSColor
  webViewWindow.setBackgroundColor(NSColor.windowBackgroundColor());
  webViewWindow.standardWindowButton(NSWindowCloseButton).setHidden(true);
  webViewWindow.standardWindowButton(NSWindowMiniaturizeButton).setHidden(true);
  webViewWindow.standardWindowButton(NSWindowZoomButton).setHidden(true);
  webViewWindow.setTitle("");
  webViewWindow.setTitlebarAppearsTransparent(true);
  webViewWindow.becomeKeyWindow();
  webViewWindow.setLevel(NSPopUpMenuWindowLevel);

  threadDictionary[panelIdentifier] = webViewWindow;

  COScript.currentCOScript().setShouldKeepAround(true);

  //Add Web View to window
  var webView = WebView.alloc().initWithFrame(NSMakeRect(0, 0, windowWidth, windowHeight - 26));
  webView.setAutoresizingMask(NSViewWidthSizable | NSViewHeightSizable);
  webView.setDrawsBackground(false);
  var windowObject = webView.windowScriptObject();
  var delegate = new MochaJSDelegate({

    "webView:didFinishLoadForFrame:": (function(webView, webFrame) {

      var myCommandsString = userDefaults.stringForKey(panelCommandsKey);
      windowObject.callWebScriptMethod_withArguments('updateCommandsList', [myCommandsString]);

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
      if (hash.hasOwnProperty('executeCommand')) {
        //If you are sending arguments from the UI
        //You can simply grab them from the hash object

        commandID = hash.commandID;
        pluginID = hash.pluginID;

        // Geting commands list
        var pluginManager = AppController.sharedInstance().pluginManager();
        var plugins = pluginManager.plugins();

        for (key in plugins) {
          var commands = plugins[key].commands();
          for (command in commands) {
            if (key == pluginID && commands[command].metadata().identifier == commandID) {
              webViewWindow.close();
              threadDictionary.removeObjectForKey(panelIdentifier);
              commands[command].run_manager(context, pluginManager);
              COScript.currentCOScript().setShouldKeepAround(false);
              return
            }
          }
        }
      }

    })
  });

  webView.setFrameLoadDelegate_(delegate.getClassInstance());
  webView.setMainFrameURL_(context.plugin.urlForResourceNamed("quickpanel.html").path());
  webViewWindow.contentView().addSubview(webView);

  webViewWindow.makeKeyAndOrderFront(nil);

  // Define the close window behaviour on the standard red traffic light button
  var closeButton = webViewWindow.standardWindowButton(NSWindowCloseButton);
  closeButton.setCOSJSTargetFunction(function(sender) {
    COScript.currentCOScript().setShouldKeepAround(false);
    threadDictionary.removeObjectForKey(panelIdentifier);
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