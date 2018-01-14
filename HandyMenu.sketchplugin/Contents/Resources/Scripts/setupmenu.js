const myCommandsList = new Sortable(document.getElementById('my-command-list'), {
	group: {
		name: 'commandsGroup',
		pull: false,
		put: true
	},
	filter: '.delete-icon',
	ghostClass: 'ghost',
	dragClass: 'drag',
	chosenClass: 'chosen',
	onFilter: function(event){
		event.item.parentNode.removeChild(event.item);
	},
	onAdd: function(event) {
		var deleteIcon = document.createElement('i');
		deleteIcon.className = 'delete-icon';
		deleteIcon.innerHTML = '✖';

		event.item.appendChild(deleteIcon);
	}
});

const allCommandsList = new Sortable(document.getElementById('all-command-list'), {
	group: {
		name: 'commandsGroup',
		pull: 'clone',
		put: false
	},
	sort: false,
	ghostClass: 'ghost',
	dragClass: 'drag',
	chosenClass: 'chosen'
});

function saveCommands() {

	var commands = {
		'list': []
	};

	var commandsListItems = document.getElementById('my-command-list').getElementsByTagName('li');

	for (var i = 0; i < commandsListItems.length; i++) {
		commands.list.push({
			name: commandsListItems[i].getAttribute('commandname'),
			commandID: commandsListItems[i].getAttribute('commandid'),
			pluginID: commandsListItems[i].getAttribute('pluginid')
		});
	}

	var commandsString = encodeURIComponent(JSON.stringify(commands));

	updateHash('saveCommandsList&commands=' + commandsString + '&commandsCount=' + commands.list.length);
}

function loadAllCommandsList(commandsString) {

	commands = JSON.parse(commandsString);
	var ul = document.getElementById('all-command-list');

	commands.forEach(function(item, i, arr) {
		var li = document.createElement('li');
		li.appendChild(document.createTextNode(item.name));
		li.setAttribute('commandid', item.commandID);
		li.setAttribute('pluginid', item.pluginID);
		li.setAttribute('commandName', item.name);
		ul.appendChild(li);
	});
}

function loadMyCommandsList(commandsString) {
	commands = (JSON.parse(decodeURIComponent(commandsString)));

	var ul = document.getElementById('my-command-list');
	commands.list.forEach(function(item, i, arr) {
		var li = document.createElement('li');
		li.appendChild(document.createTextNode(item.name));

		var deleteIcon = document.createElement('i');
		deleteIcon.className = 'delete-icon';
		deleteIcon.innerHTML = '✖';

		li.appendChild(deleteIcon);
		li.setAttribute('commandid', item.commandID);
		li.setAttribute('pluginid', item.pluginID);
		li.setAttribute('commandname', item.name);
		ul.appendChild(li);
	});
}

function closeWindow() {
	updateHash('closeWindow');
}

function updateHash(hash) {
	window.location.hash = hash + '&date=' + new Date().getTime();
	return false
}