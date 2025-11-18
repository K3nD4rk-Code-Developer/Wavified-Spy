import { ScriptData } from "./model";

export function setScript(id: string, scriptData: ScriptData) {
	return {
		type: "SET_SCRIPT",
		id,
		script: scriptData,
	} as const;
}

export function removeScript(id: string) {
	return {
		type: "REMOVE_SCRIPT",
		id,
	} as const;
}

export type ScriptActions = ReturnType<typeof setScript> | ReturnType<typeof removeScript>;
