var allCommandList = document.getElementById('all-commands-list');
var myCommandsList = document.getElementById('my-commands-list');


dragula([allCommandList, myCommandsList], {
        direction: 'vertical',
        copy: function(el, source) {
            return source.id == 'all-commands-list';
        },
        invalid: function(el, handle) {
            return el.classList.contains('plugin-header') || el.classList.contains('checked-command');
        },
        accepts: function(el, target, source, sibling) {
            return target.id == 'my-commands-list';
        },
        removeOnSpill: true
    })
    .on('drop', function(el, target, source, sibling) {
        if (el.querySelector('.delete-icon') == null) {
            var deleteIcon = document.createElement('i');
            deleteIcon.className = 'delete-icon';
            deleteIcon.innerHTML = '✕';
            deleteIcon.onclick = function() {
                removeItem(el);
            };
            el.appendChild(deleteIcon);

            if (source.id == 'all-commands-list') {
                source.querySelector('li[commandid="' + el.getAttribute('commandid') + '"]').classList.add('checked-command');
            }
        }
        if (target.id == 'my-commands-list' && target.children.length != 0) {
            target.classList.remove('no-commands');
        }
    })
    .on('drag', function(el, source) {
        document.body.style.cursor = 'grabbing';
    })
    .on('dragend', function(el) {
        document.body.style.cursor = 'default';
    })
    .on('out', function(el, container, source) {
        if (source.id == 'my-commands-list') {
            document.body.style.cursor = 'not-allowed';
        }
    })
    .on('over', function(el, container, source) {
        document.body.style.cursor = 'grabbing';
    })
    .on('remove', function(el, container, source) {
        allCommandList.querySelector('li[commandid="' + el.getAttribute('commandid') + '"]').classList.remove('checked-command');
        if (myCommandsList.children.length == 0) {
            myCommandsList.classList.add('no-commands');
        }
    });

function saveCommands() {

    var commands = {
        'list': []
    };

    var totalHeight = 0;

    var commandsListItems = document.getElementById('my-commands-list').getElementsByTagName('li');

    for (var i = 0; i < commandsListItems.length; i++) {
        commands.list.push({
            name: commandsListItems[i].getAttribute('commandname') || '',
            commandID: commandsListItems[i].getAttribute('commandid') || '',
            pluginID: commandsListItems[i].getAttribute('pluginid') || '',
            type: commandsListItems[i].getAttribute('itemtype')
        });
        totalHeight += (commandsListItems[i].getAttribute('itemtype') == 'command') ? 23 : 10;
    }

    console.log(totalHeight);

    var commandsString = encodeURIComponent(JSON.stringify(commands));

    updateHash('saveCommandsList&commands=' + commandsString + '&commandsCount=' + commands.list.length + '&totalHeight=' + totalHeight);
}

function loadAllCommandsList(commandsString) {

    var plugins = JSON.parse(commandsString);
    // var plugins = [];

    if (plugins.length > 0) {
        document.body.querySelector('.no-plugins').style.display = 'none';
        document.body.querySelector('.left').style.display = 'block';
        document.body.querySelector('.right').style.display = 'block';

        plugins.forEach(function(plugin, i, arr) {

            var li = document.createElement('li');
            li.appendChild(document.createTextNode(plugin.pluginName));
            li.className = 'plugin-header';
            allCommandList.appendChild(li);

            plugin.commands.forEach(function(command, i, arr) {
                var li = document.createElement('li');
                li.className = 'command';
                li.appendChild(document.createTextNode(command.name));
                li.setAttribute('commandid', command.commandID);
                li.setAttribute('pluginid', command.pluginID);
                li.setAttribute('commandName', command.name);
                li.setAttribute('itemtype', 'command');
                allCommandList.appendChild(li);
            });


        });
    } else {
        document.body.querySelector('.no-plugins').style.display = 'block';
        document.body.querySelector('.left').style.display = 'none';
        document.body.querySelector('.right').style.display = 'none';
    }
}

function loadMyCommandsList(commandsString) {

    var commands = (JSON.parse(decodeURIComponent(commandsString)));

    if (commands.list.length > 0) {
        myCommandsList.classList.remove('no-commands');
    }
    
    commands.list.forEach(function(item, i, arr) {
        var li = document.createElement('li');

        li.setAttribute('itemtype', item.type);

        var deleteIcon = document.createElement('i');
        deleteIcon.className = 'delete-icon';
        deleteIcon.innerHTML = '✕';

        switch (item.type) {
            
            case 'separator':
                li.className = 'command separator';
                deleteIcon.onclick = function() {
                    li.parentNode.removeChild(li);
                };
                break;
            default:
                li.className = 'command';

                li.appendChild(document.createTextNode(item.name));

                li.setAttribute('commandid', item.commandID);
                li.setAttribute('pluginid', item.pluginID);
                li.setAttribute('commandname', item.name);
                li.setAttribute('itemtype', 'command');

                deleteIcon.onclick = function() {
                    removeItem(li, item.commandID);
                };

                allCommandList.querySelector('li[commandid="' + item.commandID + '"]').classList.add('checked-command');
                break;
        }

        li.appendChild(deleteIcon);
        myCommandsList.appendChild(li);

    });
}

function removeItem(listItem, commandid) {
    allCommandList.querySelector('li[commandid="' + listItem.getAttribute('commandid') + '"]').classList.remove('checked-command');
    listItem.parentNode.removeChild(listItem);
    if (myCommandsList.children.length == 0) {
        myCommandsList.classList.add('no-commands');
    }
}

function addSeparator() {
    var separator = document.createElement('li');
    separator.classList.add('command');
    separator.classList.add('separator');
    separator.setAttribute('itemtype', 'separator');

    var deleteIcon = document.createElement('i');
    deleteIcon.className = 'delete-icon';
    deleteIcon.innerHTML = '✕';
    deleteIcon.onclick = function() {
        separator.parentNode.removeChild(separator);
    };

    separator.appendChild(deleteIcon);

    myCommandsList.appendChild(separator);
}

function closeWindow() {
    updateHash('closeWindow');
}

function updateHash(hash) {
    window.location.hash = hash + '&date=' + new Date().getTime();
    return false
}