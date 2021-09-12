const { app, BrowserWindow } = require('electron');
const path = require('path');
const fs = require('fs');

// Handle creating/removing shortcuts on Windows when installing/uninstalling.
if (require('electron-squirrel-startup')) { // eslint-disable-line global-require
	app.quit();
}

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let mainWindow;

const createWindow = () => {
	// Create the browser window.
	//mainWindow = new BrowserWindow({width: 800, height: 600});
	mainWindow = new BrowserWindow();

	//PowerShell/Pode/Pode.Web Related Config
	var webserver_json_path = path.join(__dirname, 'webserver.json');
	let webserver_config = JSON.parse(fs.readFileSync(webserver_json_path)); //read webserver.json and parse it to use for configuration later

	var powershell_exec = webserver_config.powershell_exec;
	var pode_script_filename = webserver_config.pode_script_filename;

	var podeProtocol = webserver_config.protocol;
	var podeAddress = webserver_config.address;
	var podePort = webserver_config.port;

	//Pode.Web Process Creation
	var child_process = require('child_process');
	var powershell_file_path = path.join(__dirname, pode_script_filename);
	child = child_process.spawn(powershell_exec, ['-NoProfile', "-File", powershell_file_path]);

	mainWindow.webContents.on('did-fail-load',
		function (event, errorCode, errorDescription) {
			console.log('Page failed to load (' + errorCode + '). The server is probably not yet running. Trying again in 100ms.');
			setTimeout(function () {
				mainWindow.webContents.reload();
			}, 100);
		}
	);

	setTimeout(function () {
		// and load the index.html of the app.
		//mainWindow.loadURL('http://127.0.0.1:' + podePort)
		mainWindow.loadURL(podeProtocol + '://' + podeAddress + ':' + podePort)
	}, 1000
	);

	// Emitted when the window is closed.
	mainWindow.on('closed', () => {
		child.kill()
		mainWindow = null;
	});
};

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.on('ready', createWindow);

// Quit when all windows are closed.
app.on('window-all-closed', () => {
	// On OS X it is common for applications and their menu bar
	// to stay active until the user quits explicitly with Cmd + Q
	if (process.platform !== 'darwin') {
		app.quit();
	};
});

app.on('activate', () => {
	// On OS X it's common to re-create a window in the app when the
	// dock icon is clicked and there are no other windows open.
	if (mainWindow === null) {
		createWindow();
	};
});

// In this file you can include the rest of your app's specific main process
// code. You can also put them in separate files and import them here.
