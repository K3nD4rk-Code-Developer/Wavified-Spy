import { PathNotation } from "reducers/remote-log";

declare const readfile: ((path: string) => string) | undefined;
declare const writefile: ((path: string, content: string) => void) | undefined;

const SETTINGS_FILE = "wavified_spy_settings.json";

export interface PersistedSettings {
	noActors?: boolean;
	noExecutor?: boolean;
	showRemoteEvents?: boolean;
	showRemoteFunctions?: boolean;
	showBindableEvents?: boolean;
	showBindableFunctions?: boolean;
	pathNotation?: PathNotation;
	toggleKey?: string; // KeyCode name stored as string
}

export function saveSettings(settings: PersistedSettings): void {
	if (!writefile) return;

	try {
		const json = game.GetService("HttpService").JSONEncode(settings);
		writefile(SETTINGS_FILE, json);
	} catch (err) {
		warn("Failed to save settings:", err);
	}
}

export function loadSettings(): PersistedSettings | undefined {
	if (!readfile) return undefined;

	try {
		const content = readfile(SETTINGS_FILE);
		const settings = game.GetService("HttpService").JSONDecode(content) as PersistedSettings;
		return settings;
	} catch (err) {
		// File doesn't exist or is invalid - return undefined
		return undefined;
	}
}
