import { TabType } from "reducers/tab-group";

export enum PathNotation {
	Dot = "dot",
	WaitForChild = "waitforchild",
	FindFirstChild = "findfirstchild",
}

export interface RemoteLogState {
	logs: RemoteLog[];
	remoteSelected?: string;
	signalSelected?: string;
	remoteForSignalSelected?: string;
	paused: boolean;
	pausedRemotes: Set<string>;
	blockedRemotes: Set<string>;
	noActors: boolean;
	showRemoteEvents: boolean;
	showRemoteFunctions: boolean;
	showBindableEvents: boolean;
	showBindableFunctions: boolean;
	pathNotation: PathNotation;
}

export interface RemoteLog {
	id: string;
	object: RemoteEvent | RemoteFunction | BindableEvent | BindableFunction;
	type: TabType.Event | TabType.Function | TabType.BindableEvent | TabType.BindableFunction;
	outgoing: OutgoingSignal[];
}

export interface OutgoingSignal {
	id: string;
	remote: RemoteEvent | RemoteFunction | BindableEvent | BindableFunction;
	remoteId: string;
	name: string;
	path: string;
	pathFmt: string;
	parameters: Record<number, unknown>;
	returns?: Record<number, unknown>;
	caller?: LocalScript | ModuleScript;
	callback: Callback;
	traceback: Callback[];
	isActor?: boolean;
}
