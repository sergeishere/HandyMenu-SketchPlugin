// window.addEventListener('keydown', function(event) {
// 	if (event.keyCode >= 49 && event.keyCode <= 57) {
// 		var elementIndex = event.keyCode - 49;
// 		var element = document.getElementById("command-list").childNodes[elementIndex];
// 		executeCommand(element.getAttribute('commandid'), element.getAttribute('pluginid'));
// 	}
// }, false);


function updateHash(hash) {
    window.location.hash = hash + '&date=' + new Date().getTime();
    return false
}

function executeCommand(commandID, pluginID) {
    updateHash('executeCommand&commandID=' + commandID + "&pluginID=" + pluginID);
}

function updateCommandsList(commandsString) {
    commands = (JSON.parse(decodeURIComponent(commandsString)));

    var ul = document.getElementById("command-list");
    
    console.log(commands.list);

    commands.list.forEach(function(item, i, arr) {
        var li = document.createElement("li");

        switch (item.type) {
            case 'command':
                li.classList.add('command');
                li.appendChild(document.createTextNode(item.name));
                li.setAttribute("commandid", item.commandID);
                li.setAttribute("pluginid", item.pluginID);

                li.onclick = function() {
                    executeCommand(li.getAttribute('commandid'), li.getAttribute('pluginid'));
                };
                break;
            case 'separator':
                li.classList.add('separator');
                li.appendChild(document.createElement('hr'));
                break;
        }

        ul.appendChild(li);
    });
}