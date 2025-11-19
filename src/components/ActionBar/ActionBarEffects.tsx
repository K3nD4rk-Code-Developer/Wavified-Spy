import Roact from "@rbxts/roact";
import { TabType, deleteTab, pushTab, selectActiveTab, selectTabs, setActiveTab } from "reducers/tab-group";
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
	selectPaused,
	selectPausedRemotes,
	selectBlockedRemotes,
	selectPathNotation,
} from "reducers/remote-log";
import { removeRemoteLog } from "reducers/remote-log";
import { setActionEnabled } from "reducers/action-bar";
import { setScript, removeScript } from "reducers/script";
import { useActionEffect } from "hooks/use-action-effect";
import { useEffect, withHooksPure } from "@rbxts/roact-hooked";
import { useRootDispatch, useRootSelector, useRootStore } from "hooks/use-root-store";
import { genScript } from "utils/gen-script";
import { notify } from "utils/notify";
import { generateUniqueScriptName } from "utils/script-tab-util";
import { createTabColumn } from "reducers/tab-group/utils";
import { HttpService } from "@rbxts/services";
import { setTracebackCallStack } from "reducers/traceback";

declare const decompile: ((script: LuaSourceContainer) => string) | undefined;
declare const loadstring: ((source: string) => LuaTuple<[() => void, undefined] | [undefined, string]>) | undefined;

const selectRemoteLog = makeSelectRemoteLog();

function ActionBarEffects() {
	const store = useRootStore();
	const dispatch = useRootDispatch();

	const currentTab = useRootSelector(selectActiveTab);

	const remoteId = useRootSelector(selectRemoteIdSelected);
	const remote = useRootSelector((state) => (remoteId !== undefined ? selectRemoteLog(state, remoteId) : undefined));

	const signal = useRootSelector(selectSignalSelected);
	const tabs = useRootSelector(selectTabs);
	const pathNotation = useRootSelector(selectPathNotation);

	// Auto-populate traceback when signal changes
	useEffect(() => {
		if (signal) {
			dispatch(setTracebackCallStack(signal.traceback));
		}
	}, [signal]);

	useActionEffect("copy", () => {
		if (remote) {
			setclipboard?.(getInstancePath(remote.object));
			notify("Copied remote path to clipboard");
		} else if (signal) {
			setclipboard?.(codifyOutgoingSignal(signal));
			notify("Copied signal to clipboard");
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
			notify(`Saved to ${fileName}`);
		} else if (signal) {
			const remote = selectRemoteLog(store.getState(), signal.remoteId)!;
			const signalOrder = remote.outgoing.findIndex((s) => s.id === signal.id);

			const [remoteName] = getInstancePath(remote.object).sub(-66, -1).gsub("[^a-zA-Z0-9]+", "_");

			const fileName = `${remoteName}_Signal${signalOrder + 1}.txt`;
			const fileContents = stringifyRemote(remote, (s) => signal.id === s.id);

			writefile?.(fileName, fileContents);
			notify(`Saved to ${fileName}`);
		}
	});

	useActionEffect("delete", () => {
		if (remote) {
			dispatch(removeRemoteLog(remote.id));
			dispatch(deleteTab(remote.id));
			notify("Deleted remote");
		} else if (signal) {
			dispatch(removeOutgoingSignal(signal.remoteId, signal.id));
			notify("Deleted signal");
		} else if (currentTab?.type === TabType.Script) {
			// Deleting a script tab
			dispatch(removeScript(currentTab.id));
			dispatch(deleteTab(currentTab.id));
			notify("Deleted script");
		}
	});

	useActionEffect("copyScript", () => {
		// Check if we're viewing a script tab
		if (currentTab?.type === TabType.Script && currentTab.scriptContent) {
			setclipboard?.(currentTab.scriptContent);
		} else if (signal) {
			// Convert Record<number, unknown> to sequential array
			const paramEntries: [number, unknown][] = [];
			for (const [key, value] of pairs(signal.parameters)) {
				paramEntries.push([key as number, value]);
			}
			// Sort by key and extract values into sequential array
			paramEntries.sort((a, b) => a[0] < b[0]);
			const parameters = paramEntries.map(([_, value]) => value as defined);

			const scriptText = genScript(signal.remote, parameters, pathNotation);
			setclipboard?.(scriptText);

			// Also open the script viewer
			const baseName = signal.name;
			const uniqueName = generateUniqueScriptName(baseName, tabs);
			const scriptId = HttpService.GenerateGUID(false);

			// Create tab
			const tab = createTabColumn(scriptId, uniqueName, TabType.Script, true);
			dispatch(pushTab(tab));
			dispatch(setActiveTab(scriptId));

			// Store script content
			dispatch(
				setScript(scriptId, {
					id: scriptId,
					name: uniqueName,
					content: scriptText,
				}),
			);

			notify("Copied script to clipboard and opened in viewer");
		}
	});

	useActionEffect("viewScript", () => {
		if (signal) {
			// Decompile the script
			let scriptText = "";

			if (signal.caller !== undefined && decompile !== undefined) {
				const caller = signal.caller;
				const success = pcall(() => {
					scriptText = decompile(caller);
				});

				if (!success[0]) {
					scriptText = "-- Failed to decompile script\n-- " + tostring(success[1]);
					notify("Failed to decompile script", 3, true);
				}
			} else if (signal.caller === undefined) {
				scriptText = "-- No caller script found";
			} else {
				scriptText = "-- decompile() function not available";
			}

			// Create unique tab name
			const baseName = signal.caller?.Name ?? "Script";
			const uniqueName = generateUniqueScriptName(baseName, tabs);
			const scriptId = HttpService.GenerateGUID(false);

			// Create tab
			const tab = createTabColumn(scriptId, uniqueName, TabType.Script, true);
			dispatch(pushTab(tab));
			dispatch(setActiveTab(scriptId));

			// Store script content
			dispatch(
				setScript(scriptId, {
					id: scriptId,
					name: uniqueName,
					content: scriptText,
				}),
			);

			notify(`Opened ${uniqueName} in script viewer`);
		}
	});

	useActionEffect("traceback", () => {
		if (signal) {
			dispatch(setTracebackCallStack(signal.traceback));
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
			const isPaused = pausedRemotes.has(remoteId);
			notify(isPaused ? "Unpaused remote" : "Paused remote");
		}
	});

	useActionEffect("blockRemote", () => {
		if (remoteId !== undefined) {
			dispatch(toggleRemoteBlocked(remoteId));
			const isBlocked = blockedRemotes.has(remoteId);
			notify(isBlocked ? "Unblocked remote" : "Blocked remote");
		}
	});

	useActionEffect("blockAll", () => {
		dispatch(toggleBlockAllRemotes());
		notify("Toggled block all remotes");
	});

	useActionEffect("runRemote", () => {
		if (signal) {
			// Convert Record<number, unknown> to sequential array
			const paramEntries: [number, unknown][] = [];
			for (const [key, value] of pairs(signal.parameters)) {
				paramEntries.push([key as number, value]);
			}
			// Sort by key and extract values into sequential array
			paramEntries.sort((a, b) => a[0] < b[0]);
			const parameters = paramEntries.map(([_, value]) => value as defined);

			const scriptText = genScript(signal.remote, parameters, pathNotation);

			// Execute the script
			if (loadstring) {
				const [func, err] = loadstring(scriptText);
				if (func) {
					const [success, result] = pcall(func);
					if (!success) {
						notify("Failed to run remote: " + tostring(result), 3, true);
					} else {
						notify("Executed remote successfully");
					}
				} else {
					notify("Failed to load remote script: " + tostring(err), 3, true);
				}
			} else {
				notify("loadstring function not available", 3, true);
			}
		}
	});

	// Remote & Signal actions
	useEffect(() => {
		const remoteEnabled = remoteId !== undefined;
		const signalEnabled = signal !== undefined && currentTab?.id === signal.remoteId;
		const isHome = currentTab?.type === TabType.Home;
		const isScript = currentTab?.type === TabType.Script;

		dispatch(setActionEnabled("copy", remoteEnabled || signalEnabled));
		dispatch(setActionEnabled("save", remoteEnabled || signalEnabled));
		dispatch(setActionEnabled("delete", remoteEnabled || signalEnabled || isScript));

		dispatch(setActionEnabled("traceback", signalEnabled));
		dispatch(setActionEnabled("copyPath", remoteEnabled || !isHome));
		dispatch(setActionEnabled("copyScript", signalEnabled));
		dispatch(setActionEnabled("viewScript", signalEnabled));

		dispatch(setActionEnabled("pauseRemote", remoteEnabled));
		dispatch(setActionEnabled("blockRemote", remoteEnabled));
		dispatch(setActionEnabled("runRemote", signalEnabled));
	}, [remoteId === undefined, signal, currentTab]);

	return <></>;
}

export default withHooksPure(ActionBarEffects);
