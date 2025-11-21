import { RootState } from "reducers";
import { createSelector } from "@rbxts/roselect";

export const selectRemoteLogs = (state: RootState) => state.remoteLog.logs;

// Sort logs by most recent signal timestamp (newest first)
export const selectRemoteLogsSorted = createSelector([selectRemoteLogs], (logs) => {
	return [...logs].sort((a, b) => {
		const aTimestamp = a.outgoing[0]?.timestamp ?? -math.huge;
		const bTimestamp = b.outgoing[0]?.timestamp ?? -math.huge;
		return bTimestamp > aTimestamp; // Descending order (newest first)
	});
});

export const selectRemoteLogIds = createSelector([selectRemoteLogsSorted], (logs) => logs.map((log) => log.id));
export const selectRemoteLogsOutgoing = (state: RootState) => state.remoteLog.logs.map((log) => log.outgoing);

export const selectRemoteIdSelected = (state: RootState) => state.remoteLog.remoteSelected;
export const selectSignalIdSelected = (state: RootState) => state.remoteLog.signalSelected;
export const selectSignalIdSelectedRemote = (state: RootState) => state.remoteLog.remoteForSignalSelected;
export const selectRemotesMultiSelected = (state: RootState) => state.remoteLog.remotesMultiSelected;
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
	createSelector([selectRemoteLogsSorted, (_: unknown, id: string) => id], (logs, id) => logs.find((log) => log.id === id));
export const makeSelectRemoteLogOutgoing = () => createSelector([makeSelectRemoteLog()], (log) => log?.outgoing);
export const makeSelectRemoteLogObject = () => createSelector([makeSelectRemoteLog()], (log) => log?.object);
export const makeSelectRemoteLogType = () => createSelector([makeSelectRemoteLog()], (log) => log?.type);

const _selectOutgoing = makeSelectRemoteLogOutgoing();
export const selectSignalSelected = createSelector(
	[(state: RootState) => _selectOutgoing(state, selectSignalIdSelectedRemote(state) ?? ""), selectSignalIdSelected],
	(outgoing, id) => (outgoing && id !== undefined ? outgoing?.find((signal) => signal.id === id) : undefined),
);
