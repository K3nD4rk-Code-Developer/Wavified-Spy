import Rodux from "@rbxts/rodux";
import rootReducer, { RootState } from "reducers";
import { selectPaused, selectPausedRemotes, selectBlockedRemotes } from "reducers/remote-log";

let store: Rodux.Store<RootState, Rodux.Action>;
let isDestructed = false;

function createStore() {
	return new Rodux.Store(rootReducer, undefined);
}

export function configureStore() {
	if (store) return store;
	return (store = createStore());
}

export function destruct() {
	if (isDestructed) return;
	isDestructed = true;
	store.destruct();
}

export function isActive() {
	if (!store || isDestructed) return false;
	const paused = selectPaused(store.getState());
	return !paused;
}

export function isRemoteBlocked(remoteId: string) {
	if (!store || isDestructed) return false;
	const state = store.getState();
	const blockedRemotes = selectBlockedRemotes(state);

	// Only check if remote is blocked (not paused)
	return blockedRemotes.has(remoteId);
}

export function isRemoteAllowed(remoteId: string) {
	if (!store || isDestructed) return false;
	const state = store.getState();
	const paused = selectPaused(state);
	const pausedRemotes = selectPausedRemotes(state);
	const blockedRemotes = selectBlockedRemotes(state);

	// If globally paused, don't allow any remote
	if (paused) return false;

	// If remote is blocked, don't allow it
	if (blockedRemotes.has(remoteId)) return false;

	// If remote is individually paused, don't allow it
	if (pausedRemotes.has(remoteId)) return false;

	return true;
}

export function dispatch(action: Rodux.AnyAction) {
	if (isDestructed) return;
	return configureStore().dispatch(action);
}

export function get<T>(selector: (state: RootState) => T): T;
export function get(): RootState;
export function get(selector?: (state: RootState) => unknown): unknown {
	if (isDestructed) return;
	const store = configureStore();
	return selector ? selector(store.getState()) : store.getState();
}

export function changed<T>(selector: (state: RootState) => T, callback: (state: T) => void) {
	if (isDestructed) return;
	const store = configureStore();

	let lastState = selector(store.getState());
	task.defer(callback, lastState);

	return store.changed.connect((state) => {
		const newState = selector(state);

		if (lastState !== newState) {
			task.spawn(callback, (lastState = newState));
		}
	});
}
