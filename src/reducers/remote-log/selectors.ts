import { RootState } from "reducers";
import { createSelector } from "@rbxts/roselect";
import { Signal } from "./model";

export const selectRemoteLogs = (state: RootState) => state.remoteLog.logs;

// Sort logs by most recent signal timestamp (newest first)
export const selectRemoteLogsSorted = createSelector([selectRemoteLogs], (logs) => {
	return [...logs].sort((a, b) => {
		const aOutgoing = a.outgoing[0]?.timestamp ?? -math.huge;
		const aIncoming = (a.incoming ?? [])[0]?.timestamp ?? -math.huge;
		const aTimestamp = math.max(aOutgoing, aIncoming);
		const bOutgoing = b.outgoing[0]?.timestamp ?? -math.huge;
		const bIncoming = (b.incoming ?? [])[0]?.timestamp ?? -math.huge;
		const bTimestamp = math.max(bOutgoing, bIncoming);
		return aTimestamp > bTimestamp; // Descending order (newest first)
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
export const selectNoExecutor = (state: RootState) => state.remoteLog.noExecutor;
export const selectShowRemoteEvents = (state: RootState) => state.remoteLog.showRemoteEvents;
export const selectShowRemoteFunctions = (state: RootState) => state.remoteLog.showRemoteFunctions;
export const selectShowBindableEvents = (state: RootState) => state.remoteLog.showBindableEvents;
export const selectShowBindableFunctions = (state: RootState) => state.remoteLog.showBindableFunctions;
export const selectPathNotation = (state: RootState) => state.remoteLog.pathNotation;
export const selectMaxInspectionResults = (state: RootState) => state.remoteLog.maxInspectionResults;
export const selectInspectionResultSelected = (state: RootState) => state.remoteLog.inspectionResultSelected;

export const makeSelectRemoteLog = () =>
	createSelector([selectRemoteLogsSorted, (_: unknown, id: string) => id], (logs, id) => logs.find((log) => log.id === id));
export const makeSelectRemoteLogOutgoing = () => createSelector([makeSelectRemoteLog()], (log) => log?.outgoing);
export const makeSelectRemoteLogObject = () => createSelector([makeSelectRemoteLog()], (log) => log?.object);
export const makeSelectRemoteLogType = () => createSelector([makeSelectRemoteLog()], (log) => log?.type);

// Combined signals selector (merges outgoing and incoming, sorted by timestamp)
export const makeSelectRemoteLogSignals = () =>
	createSelector([makeSelectRemoteLog()], (log): Signal[] | undefined => {
		if (!log) return undefined;

		const outgoing: Signal[] = log.outgoing.map((s) => ({ ...s, direction: "outgoing" as const }));
		const incoming: Signal[] = (log.incoming ?? []).map((s) => ({ ...s, direction: "incoming" as const }));

		// Combine and sort by timestamp (newest first)
		return [...outgoing, ...incoming].sort((a, b) => b.timestamp > a.timestamp);
	});

const _selectOutgoing = makeSelectRemoteLogOutgoing();
const _selectSignals = makeSelectRemoteLogSignals();
export const selectSignalSelected = createSelector(
	[(state: RootState) => _selectSignals(state, selectSignalIdSelectedRemote(state) ?? ""), selectSignalIdSelected],
	(signals, id) => (signals && id !== undefined ? signals?.find((signal) => signal.id === id) : undefined),
);
