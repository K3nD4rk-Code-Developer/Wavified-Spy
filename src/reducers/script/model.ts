export interface ScriptState {
	scripts: Record<string, ScriptData>;
}

export interface ScriptData {
	id: string;
	name: string;
	content: string;
}
