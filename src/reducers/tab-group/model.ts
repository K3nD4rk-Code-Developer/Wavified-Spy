export interface TabGroupState {
	tabs: TabGroupColumn[];
	activeTab: string;
}

export interface TabGroupColumn {
	id: string;
	caption: string;
	type: TabType;
	canClose: boolean;
	scriptContent?: string;
}

export enum TabType {
	Home = "home",
	Event = "event",
	Function = "function",
	BindableEvent = "bindable-event",
	BindableFunction = "bindable-function",
	Script = "script",
	Settings = "settings",
}
