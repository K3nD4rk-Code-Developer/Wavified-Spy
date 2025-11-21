import { RemoteLogActions } from "./actions";
import { PathNotation, RemoteLogState } from "./model";
import { loadSettings } from "utils/settings-persistence";

// Load persisted settings if available
const persistedSettings = loadSettings();

const initialState: RemoteLogState = {
	logs: [],
	paused: false,
	pausedRemotes: new Set(),
	blockedRemotes: new Set(),
	noActors: persistedSettings?.noActors ?? false,
	showRemoteEvents: persistedSettings?.showRemoteEvents ?? true,
	showRemoteFunctions: persistedSettings?.showRemoteFunctions ?? true,
	showBindableEvents: persistedSettings?.showBindableEvents ?? false,
	showBindableFunctions: persistedSettings?.showBindableFunctions ?? false,
	pathNotation: persistedSettings?.pathNotation ?? PathNotation.Dot,
};

export default function remoteLogReducer(state = initialState, action: RemoteLogActions): RemoteLogState {
	// Log ALL actions to debug state resets
	// Cast to any to handle Rodux internal actions like @@INIT
	const actionType = (action as any).type as string;
	// Check if action type starts with "@@" using substring
	if (actionType && actionType.substring(0, 2) !== "@@") {
		print("[Reducer] Action:", actionType, "Current logs:", state.logs.size());
		if (state.logs.size() === 0 && state === initialState) {
			warn("[Reducer] WARNING: State is initialState (fresh reducer call)!");
		}
	}

	switch (action.type) {
		case "PUSH_REMOTE_LOG": {
			print("[Reducer] PUSH_REMOTE_LOG - Adding log:", action.log.id, "Total logs:", state.logs.size() + 1);
			const newState = {
				...state,
				logs: [...state.logs, action.log],
			};
			print("[Reducer] New state logs count:", newState.logs.size());
			return newState;
		}
		case "REMOVE_REMOTE_LOG":
			return {
				...state,
				logs: state.logs.filter((log) => log.id !== action.id),
			};
		case "PUSH_OUTGOING_SIGNAL": {
			// Validate that the log exists before trying to add signal
			const logExists = state.logs.some((log) => log.id === action.id);
			if (!logExists) {
				warn(
					"[RemoteLog Reducer] PUSH_OUTGOING_SIGNAL failed: No log found with id:",
					action.id,
					"Signal will be lost!",
				);
				return state; // Don't modify state if log doesn't exist
			}

			print("[Reducer] PUSH_OUTGOING_SIGNAL - Adding signal to log:", action.id);
			const newState = {
				...state,
				logs: state.logs.map((log) => {
					if (log.id === action.id) {
						const outgoing = [action.signal, ...log.outgoing];
						print("[Reducer] Log", action.id, "now has", outgoing.size(), "signals");
						return {
							...log,
							outgoing,
						};
					}
					return log;
				}),
			};
			return newState;
		}
		case "REMOVE_OUTGOING_SIGNAL":
			return {
				...state,
				logs: state.logs.map((log) => {
					if (log.id === action.id) {
						return {
							...log,
							outgoing: log.outgoing.filter((signal) => signal.id !== action.signalId),
						};
					}
					return log;
				}),
			};
		case "CLEAR_OUTGOING_SIGNALS":
			return {
				...state,
				logs: state.logs.map((log) => {
					if (log.id === action.id) {
						return {
							...log,
							outgoing: [],
						};
					}
					return log;
				}),
			};
		case "SET_REMOTE_SELECTED":
			return {
				...state,
				remoteSelected: action.id,
			};
		case "SET_SIGNAL_SELECTED":
			return {
				...state,
				signalSelected: action.id,
				remoteForSignalSelected: action.id !== undefined ? action.remote : undefined,
			};
		case "TOGGLE_SIGNAL_SELECTED": {
			const signalSelected = state.signalSelected === action.id ? undefined : action.id;

			return {
				...state,
				signalSelected,
				remoteForSignalSelected: signalSelected !== undefined ? action.remote : undefined,
			};
		}
		case "TOGGLE_PAUSED":
			return {
				...state,
				paused: !state.paused,
			};
		case "TOGGLE_REMOTE_PAUSED": {
			const pausedRemotes = new Set<string>();
			state.pausedRemotes.forEach((id) => pausedRemotes.add(id));
			if (pausedRemotes.has(action.id)) {
				pausedRemotes.delete(action.id);
			} else {
				pausedRemotes.add(action.id);
			}
			return {
				...state,
				pausedRemotes,
			};
		}
		case "TOGGLE_REMOTE_BLOCKED": {
			const blockedRemotes = new Set<string>();
			state.blockedRemotes.forEach((id) => blockedRemotes.add(id));
			if (blockedRemotes.has(action.id)) {
				blockedRemotes.delete(action.id);
			} else {
				blockedRemotes.add(action.id);
			}
			return {
				...state,
				blockedRemotes,
			};
		}
		case "TOGGLE_BLOCK_ALL_REMOTES": {
			// Check if all remotes are currently blocked
			const allBlocked = state.logs.size() > 0 && state.logs.every((log) => state.blockedRemotes.has(log.id));

			const blockedRemotes = new Set<string>();
			if (!allBlocked) {
				// Block all if not all are blocked
				state.logs.forEach((log) => blockedRemotes.add(log.id));
			}
			// Otherwise leave it empty to unblock all

			return {
				...state,
				blockedRemotes,
			};
		}
		case "TOGGLE_NO_ACTORS":
			return {
				...state,
				noActors: !state.noActors,
			};
		case "TOGGLE_SHOW_REMOTE_EVENTS":
			return {
				...state,
				showRemoteEvents: !state.showRemoteEvents,
			};
		case "TOGGLE_SHOW_REMOTE_FUNCTIONS":
			return {
				...state,
				showRemoteFunctions: !state.showRemoteFunctions,
			};
		case "TOGGLE_SHOW_BINDABLE_EVENTS":
			return {
				...state,
				showBindableEvents: !state.showBindableEvents,
			};
		case "TOGGLE_SHOW_BINDABLE_FUNCTIONS":
			return {
				...state,
				showBindableFunctions: !state.showBindableFunctions,
			};
		case "SET_PATH_NOTATION":
			return {
				...state,
				pathNotation: action.notation,
			};
		default:
			// Log unknown actions that might be resetting state
			// Cast to any to handle actions not in RemoteLogActions type
			const unknownActionType = (action as any).type as string;
			// Check if action type starts with "@@" using substring
			if (unknownActionType && unknownActionType.substring(0, 2) !== "@@") {
				print("[Reducer] Unknown action:", unknownActionType);
			}
			return state;
	}
}
