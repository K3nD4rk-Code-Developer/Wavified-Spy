import Roact from "@rbxts/roact";
import { TabType, deleteTab, selectActiveTab, pushTab, setActiveTab, createTabColumn } from "reducers/tab-group";
import { codifyOutgoingSignal, stringifyRemote } from "./utils";
import { getInstanceFromId, getInstancePath } from "utils/instance-util";
import {
	makeSelectRemoteLog,
	removeOutgoingSignal,
	selectRemoteIdSelected,
	selectSignalSelected,
	togglePaused,
	selectRemoteLogIds,
	setRemoteSelected,
	toggleRemotePaused,
	toggleRemoteBlocked,
	toggleBlockAllRemotes,
} from "reducers/remote-log";
import { removeRemoteLog, selectPaused, selectPausedRemotes, selectBlockedRemotes, selectPathNotation } from "reducers/remote-log";
import { setActionEnabled, setActionCaption } from "reducers/action-bar";
import { useActionEffect } from "hooks/use-action-effect";
import { useEffect, withHooksPure } from "@rbxts/roact-hooked";
import { useRootDispatch, useRootSelector, useRootStore } from "hooks/use-root-store";
import { genScript } from "utils/gen-script";
import { HttpService } from "@rbxts/services";


const selectRemoteLog = makeSelectRemoteLog();

function ActionBarEffects() {
	const store = useRootStore();
	const dispatch = useRootDispatch();

	const currentTab = useRootSelector(selectActiveTab);

	const remoteId = useRootSelector(selectRemoteIdSelected);
	const remote = useRootSelector((state) => (remoteId !== undefined ? selectRemoteLog(state, remoteId) : undefined));

	const signal = useRootSelector(selectSignalSelected);
	const pathNotation = useRootSelector(selectPathNotation);

	useActionEffect("copy", () => {
		if (remote) {
			setclipboard?.(getInstancePath(remote.object));
		} else if (signal) {
			setclipboard?.(codifyOutgoingSignal(signal));
		}
	});

	useActionEffect("copyPath", () => {
		const object = remote?.object ?? (currentTab && getInstanceFromId(currentTab.id));
		if (object) {
			setclipboard?.(getInstancePath(object));
		}
	});

	useActionEffect("save", () => {
		if (remote) {
			const [remoteName] = getInstancePath(remote.object).sub(-66, -1).gsub("[^a-zA-Z0-9]+", "_");

			const fileName = `${remoteName}.txt`;
			const fileContents = stringifyRemote(remote);

			writefile?.(fileName, fileContents);
		} else if (signal) {
			const remote = selectRemoteLog(store.getState(), signal.remoteId)!;
			const signalOrder = remote.outgoing.findIndex((s) => s.id === signal.id);

			const [remoteName] = getInstancePath(remote.object).sub(-66, -1).gsub("[^a-zA-Z0-9]+", "_");

			const fileName = `${remoteName}_Signal${signalOrder + 1}.txt`;
			const fileContents = stringifyRemote(remote, (s) => signal.id === s.id);

			writefile?.(fileName, fileContents);
		}
	});

	useActionEffect("delete", () => {
		if (remote) {
			dispatch(removeRemoteLog(remote.id));
			dispatch(deleteTab(remote.id));
		} else if (signal) {
			dispatch(removeOutgoingSignal(signal.remoteId, signal.id));
		}
	});

	useActionEffect("copyScript", () => {
		// Check if we're viewing a script tab
		if (currentTab?.type === TabType.Script && currentTab.scriptContent) {
			setclipboard?.(currentTab.scriptContent);
		} else if (signal) {
			// Convert Record<number, unknown> to array
			const parameters: unknown[] = [];
			for (const [key, value] of pairs(signal.parameters)) {
				parameters[key as number] = value;
			}
			const scriptText = genScript(signal.remote, parameters, pathNotation);
			setclipboard?.(scriptText);
		}
	});

	useActionEffect("pause", () => {
		dispatch(togglePaused());
	});

	const remoteIds = useRootSelector(selectRemoteLogIds);
	const paused = useRootSelector(selectPaused);
	const pausedRemotes = useRootSelector(selectPausedRemotes);
	const blockedRemotes = useRootSelector(selectBlockedRemotes);

	useActionEffect("navigatePrevious", () => {
		if (remoteId !== undefined) {
			const currentIndex = remoteIds.indexOf(remoteId);
			if (currentIndex > 0) {
				dispatch(setRemoteSelected(remoteIds[currentIndex - 1]));
			}
		} else if (remoteIds.size() > 0) {
			dispatch(setRemoteSelected(remoteIds[remoteIds.size() - 1]));
		}
	});

	useActionEffect("navigateNext", () => {
		if (remoteId !== undefined) {
			const currentIndex = remoteIds.indexOf(remoteId);
			if (currentIndex < remoteIds.size() - 1) {
				dispatch(setRemoteSelected(remoteIds[currentIndex + 1]));
			}
		} else if (remoteIds.size() > 0) {
			dispatch(setRemoteSelected(remoteIds[0]));
		}
	});

	useActionEffect("pauseRemote", () => {
		if (remoteId !== undefined) {
			dispatch(toggleRemotePaused(remoteId));
		}
	});

	useActionEffect("blockRemote", () => {
		if (remoteId !== undefined) {
			dispatch(toggleRemoteBlocked(remoteId));
		}
	});

	useActionEffect("blockAll", () => {
		dispatch(toggleBlockAllRemotes());
	});

	useActionEffect("viewScript", () => {
		if (signal) {
			// Convert Record<number, unknown> to array
			const parameters: unknown[] = [];
			for (const [key, value] of pairs(signal.parameters)) {
				parameters[key as number] = value;
			}
			const scriptText = genScript(signal.remote, parameters, pathNotation);

			// Create a unique ID for the script tab
			const scriptTabId = HttpService.GenerateGUID(false);
			const tab = createTabColumn(scriptTabId, `Script - ${signal.name}`, TabType.Script, true, scriptText);

			dispatch(pushTab(tab));
			dispatch(setActiveTab(scriptTabId));
		}
	});

	// Remote & Signal actions
	useEffect(() => {
		const remoteEnabled = remoteId !== undefined;
		const signalEnabled = signal !== undefined && currentTab?.id === signal.remoteId;
		const isHome = currentTab?.type === TabType.Home;
		const isScriptTab = currentTab?.type === TabType.Script && currentTab?.scriptContent !== undefined;

		dispatch(setActionEnabled("copy", remoteEnabled || signalEnabled));
		dispatch(setActionEnabled("save", remoteEnabled || signalEnabled));
		dispatch(setActionEnabled("delete", remoteEnabled || signalEnabled));

		dispatch(setActionEnabled("traceback", signalEnabled));
		dispatch(setActionEnabled("copyPath", remoteEnabled || !isHome));
		dispatch(setActionEnabled("copyScript", signalEnabled || isScriptTab));

		// Enable navigate buttons when there are remotes
		const hasRemotes = remoteIds.size() > 0;
		dispatch(setActionEnabled("navigatePrevious", hasRemotes));
		dispatch(setActionEnabled("navigateNext", hasRemotes));

		// Enable new remote control buttons
		dispatch(setActionEnabled("pauseRemote", remoteEnabled));
		dispatch(setActionEnabled("blockRemote", remoteEnabled));
		dispatch(setActionEnabled("blockAll", hasRemotes));
		dispatch(setActionEnabled("viewScript", signalEnabled));
	}, [remoteId === undefined, signal, currentTab, remoteIds]);

	// Update pause button caption
	useEffect(() => {
		dispatch(setActionCaption("pause", paused ? "Resume" : "Pause"));
	}, [paused]);

	// Update pauseRemote button caption
	useEffect(() => {
		if (remoteId !== undefined) {
			const isPaused = pausedRemotes.has(remoteId);
			dispatch(setActionCaption("pauseRemote", isPaused ? "Resume Remote" : "Pause Remote"));
		}
	}, [remoteId, pausedRemotes]);

	// Update blockRemote button caption
	useEffect(() => {
		if (remoteId !== undefined) {
			const isBlocked = blockedRemotes.has(remoteId);
			dispatch(setActionCaption("blockRemote", isBlocked ? "Unblock Remote" : "Block Remote"));
		}
	}, [remoteId, blockedRemotes]);

	// Update blockAll button caption
	useEffect(() => {
		const allBlocked = remoteIds.size() > 0 && remoteIds.every((id) => blockedRemotes.has(id));
		dispatch(setActionCaption("blockAll", allBlocked ? "Unblock All" : "Block All"));
	}, [remoteIds, blockedRemotes]);

	return <></>;
}

export default withHooksPure(ActionBarEffects);
