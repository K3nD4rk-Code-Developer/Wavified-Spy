import { ScriptData } from "./model";

export function setScript(id: string, scriptData: ScriptData) {
	return {
		type: "SET_SCRIPT",
		id,
		script: scriptData,
	} as const;
}

export function updateScriptContent(id: string, content: string) {
	return {
		type: "UPDATE_SCRIPT_CONTENT",
		id,
		content,
	} as const;
}

export function removeScript(id: string) {
	return {
		type: "REMOVE_SCRIPT",
		id,
	} as const;
}

export type ScriptActions = ReturnType<typeof setScript> | ReturnType<typeof updateScriptContent> | ReturnType<typeof removeScript>;
