import { HAS_FILE_ACCESS } from "constants";
import { PathNotation } from "reducers/remote-log/model";

const SETTINGS_FILE = "wavified_spy_settings.json";

export interface PersistedSettings {
	noActors?: boolean;
	showRemoteEvents?: boolean;
	showRemoteFunctions?: boolean;
	showBindableEvents?: boolean;
	showBindableFunctions?: boolean;
	pathNotation?: PathNotation;
	toggleKey?: string; // KeyCode name as string
}

export function loadSettings(): PersistedSettings | undefined {
	if (!HAS_FILE_ACCESS) {
		return undefined;
	}

	try {
		if (!isfile(SETTINGS_FILE)) {
			return undefined;
		}

		const content = readfile(SETTINGS_FILE);
		const settings = game.GetService("HttpService").JSONDecode(content) as PersistedSettings;
		return settings;
	} catch (error) {
		warn(`[Wavified Spy] Failed to load settings: ${error}`);
		return undefined;
	}
}

export function saveSettings(settings: PersistedSettings): void {
	if (!HAS_FILE_ACCESS) {
		return;
	}

	try {
		const content = game.GetService("HttpService").JSONEncode(settings);
		writefile(SETTINGS_FILE, content);
	} catch (error) {
		warn(`[Wavified Spy] Failed to save settings: ${error}`);
	}
}
