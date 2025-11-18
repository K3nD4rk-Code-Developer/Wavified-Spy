export interface ActionBarState {
	actions: ActionBarStates;
}

export interface ActionBarStates {
	close: ActionState;
	navigatePrevious: ActionState;
	navigateNext: ActionState;
	copy: ActionState;
	save: ActionState;
	delete: ActionState;
	traceback: ActionState;
	copyPath: ActionState;
	copyScript: ActionState;
	pause: ActionState;
	pauseRemote: ActionState;
	blockRemote: ActionState;
	blockAll: ActionState;
	viewScript: ActionState;
	settings: ActionState;
}

export interface ActionState {
	id: string;
	disabled: boolean;
	active: boolean;
	caption?: string;
}
