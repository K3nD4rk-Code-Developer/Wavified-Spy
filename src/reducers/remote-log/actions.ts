import { IncomingSignal, InspectionResult, OutgoingSignal, PathNotation, RemoteLog } from "./model";
import { PersistedSettings } from "utils/settings-persistence";

export function pushRemoteLog(log: RemoteLog) {
	return { type: "PUSH_REMOTE_LOG", log } as const;
}

export function removeRemoteLog(id: string) {
	return { type: "REMOVE_REMOTE_LOG", id } as const;
}

export function pushOutgoingSignal(id: string, signal: OutgoingSignal) {
	return { type: "PUSH_OUTGOING_SIGNAL", id, signal } as const;
}

export function pushIncomingSignal(id: string, signal: IncomingSignal) {
	return { type: "PUSH_INCOMING_SIGNAL", id, signal } as const;
}

export function removeOutgoingSignal(id: string, signalId: string) {
	return { type: "REMOVE_OUTGOING_SIGNAL", id, signalId } as const;
}

export function clearOutgoingSignals(id: string) {
	return { type: "CLEAR_OUTGOING_SIGNALS", id } as const;
}

export function setRemoteSelected(id?: string) {
	return { type: "SET_REMOTE_SELECTED", id } as const;
}

export function setSignalSelected(remote: string, id?: string) {
	return { type: "SET_SIGNAL_SELECTED", remote, id } as const;
}

export function toggleSignalSelected(remote: string, id: string) {
	return { type: "TOGGLE_SIGNAL_SELECTED", remote, id } as const;
}

export function togglePaused() {
	return { type: "TOGGLE_PAUSED" } as const;
}

export function toggleRemotePaused(id: string) {
	return { type: "TOGGLE_REMOTE_PAUSED", id } as const;
}

export function toggleRemoteBlocked(id: string) {
	return { type: "TOGGLE_REMOTE_BLOCKED", id } as const;
}

export function toggleBlockAllRemotes() {
	return { type: "TOGGLE_BLOCK_ALL_REMOTES" } as const;
}

export function toggleNoActors() {
	return { type: "TOGGLE_NO_ACTORS" } as const;
}

export function toggleNoExecutor() {
	return { type: "TOGGLE_NO_EXECUTOR" } as const;
}

export function toggleShowRemoteEvents() {
	return { type: "TOGGLE_SHOW_REMOTE_EVENTS" } as const;
}

export function toggleShowRemoteFunctions() {
	return { type: "TOGGLE_SHOW_REMOTE_FUNCTIONS" } as const;
}

export function toggleShowBindableEvents() {
	return { type: "TOGGLE_SHOW_BINDABLE_EVENTS" } as const;
}

export function toggleShowBindableFunctions() {
	return { type: "TOGGLE_SHOW_BINDABLE_FUNCTIONS" } as const;
}

export function setPathNotation(notation: PathNotation) {
	return { type: "SET_PATH_NOTATION", notation } as const;
}

export function setMaxInspectionResults(max: number) {
	return { type: "SET_MAX_INSPECTION_RESULTS", max } as const;
}

export function toggleRemoteMultiSelected(id: string) {
	return { type: "TOGGLE_REMOTE_MULTI_SELECTED", id } as const;
}

export function clearMultiSelection() {
	return { type: "CLEAR_MULTI_SELECTION" } as const;
}

export function loadSettings(settings: PersistedSettings) {
	return { type: "LOAD_SETTINGS", settings } as const;
}

export function setInspectionResultSelected(result?: InspectionResult) {
	return { type: "SET_INSPECTION_RESULT_SELECTED", result } as const;
}

export type RemoteLogActions =
	| ReturnType<typeof pushRemoteLog>
	| ReturnType<typeof removeRemoteLog>
	| ReturnType<typeof pushOutgoingSignal>
	| ReturnType<typeof pushIncomingSignal>
	| ReturnType<typeof removeOutgoingSignal>
	| ReturnType<typeof clearOutgoingSignals>
	| ReturnType<typeof setRemoteSelected>
	| ReturnType<typeof setSignalSelected>
	| ReturnType<typeof toggleSignalSelected>
	| ReturnType<typeof togglePaused>
	| ReturnType<typeof toggleRemotePaused>
	| ReturnType<typeof toggleRemoteBlocked>
	| ReturnType<typeof toggleBlockAllRemotes>
	| ReturnType<typeof toggleNoActors>
	| ReturnType<typeof toggleNoExecutor>
	| ReturnType<typeof toggleShowRemoteEvents>
	| ReturnType<typeof toggleShowRemoteFunctions>
	| ReturnType<typeof toggleShowBindableEvents>
	| ReturnType<typeof toggleShowBindableFunctions>
	| ReturnType<typeof setPathNotation>
	| ReturnType<typeof setMaxInspectionResults>
	| ReturnType<typeof toggleRemoteMultiSelected>
	| ReturnType<typeof clearMultiSelection>
	| ReturnType<typeof loadSettings>
	| ReturnType<typeof setInspectionResultSelected>;
