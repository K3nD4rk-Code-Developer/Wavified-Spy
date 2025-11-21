import { RootState } from "reducers";
import { createSelector } from "@rbxts/roselect";

export const selectRemoteLogs = (state: RootState) => {
	const logs = state.remoteLog.logs;
	print("[Selector] selectRemoteLogs called, returning", logs.size(), "logs");
	return logs;
};

export const selectRemoteLogIds = createSelector([selectRemoteLogs], (logs) => {
	const ids = logs.map((log) => log.id);
	print("[Selector] selectRemoteLogIds computed, returning", ids.size(), "IDs");
	return ids;
});
export const selectRemoteLogsOutgoing = (state: RootState) => state.remoteLog.logs.map((log) => log.outgoing);

export const selectRemoteIdSelected = (state: RootState) => state.remoteLog.remoteSelected;
export const selectSignalIdSelected = (state: RootState) => state.remoteLog.signalSelected;
export const selectSignalIdSelectedRemote = (state: RootState) => state.remoteLog.remoteForSignalSelected;
export const selectPaused = (state: RootState) => state.remoteLog.paused;
export const selectPausedRemotes = (state: RootState) => state.remoteLog.pausedRemotes;
export const selectBlockedRemotes = (state: RootState) => state.remoteLog.blockedRemotes;
export const selectNoActors = (state: RootState) => state.remoteLog.noActors;
export const selectShowRemoteEvents = (state: RootState) => state.remoteLog.showRemoteEvents;
export const selectShowRemoteFunctions = (state: RootState) => state.remoteLog.showRemoteFunctions;
export const selectShowBindableEvents = (state: RootState) => state.remoteLog.showBindableEvents;
export const selectShowBindableFunctions = (state: RootState) => state.remoteLog.showBindableFunctions;
export const selectPathNotation = (state: RootState) => state.remoteLog.pathNotation;

export const makeSelectRemoteLog = () =>
	createSelector([selectRemoteLogs, (_: unknown, id: string) => id], (logs, id) => logs.find((log) => log.id === id));

// Fix: Properly pass id parameter through the selector chain
export const makeSelectRemoteLogOutgoing = () =>
	createSelector([selectRemoteLogs, (_: unknown, id: string) => id], (logs, id) => {
		const log = logs.find((log) => log.id === id);
		print("[Selector] makeSelectRemoteLogOutgoing computed for id:", id, "outgoing count:", log?.outgoing.size() ?? 0);
		return log?.outgoing;
	});

export const makeSelectRemoteLogObject = () =>
	createSelector([selectRemoteLogs, (_: unknown, id: string) => id], (logs, id) => {
		const log = logs.find((log) => log.id === id);
		return log?.object;
	});

export const makeSelectRemoteLogType = () =>
	createSelector([selectRemoteLogs, (_: unknown, id: string) => id], (logs, id) => {
		const log = logs.find((log) => log.id === id);
		return log?.type;
	});

const _selectOutgoing = makeSelectRemoteLogOutgoing();
export const selectSignalSelected = createSelector(
	[(state: RootState) => _selectOutgoing(state, selectSignalIdSelectedRemote(state) ?? ""), selectSignalIdSelected],
	(outgoing, id) => (outgoing && id !== undefined ? outgoing?.find((signal) => signal.id === id) : undefined),
);
