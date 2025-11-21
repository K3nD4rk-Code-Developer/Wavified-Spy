export interface ScriptState {
	scripts: Record<string, ScriptData>;
}

export interface ScriptData {
	id: string;
	name: string;
	content: string;
	signalId?: string; // Optional: ID of the signal this script was generated from
	remoteId?: string; // Optional: ID of the remote this script is for
}
