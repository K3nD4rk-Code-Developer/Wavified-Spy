import { RemoteLogActions } from "./actions";
import { PathNotation, RemoteLogState } from "./model";

const initialState: RemoteLogState = {
	logs: [],
	paused: false,
	pausedRemotes: new Set(),
	blockedRemotes: new Set(),
	remotesMultiSelected: new Set(),
	noActors: false,
	noExecutor: false,
	showRemoteEvents: true,
	showRemoteFunctions: true,
	showBindableEvents: false,
	showBindableFunctions: false,
	pathNotation: PathNotation.Dot,
};

export default function remoteLogReducer(state = initialState, action: RemoteLogActions): RemoteLogState {
	switch (action.type) {
		case "PUSH_REMOTE_LOG":
			return {
				...state,
				logs: [...state.logs, action.log],
			};
		case "REMOVE_REMOTE_LOG":
			return {
				...state,
				logs: state.logs.filter((log) => log.id !== action.id),
			};
		case "PUSH_OUTGOING_SIGNAL":
			return {
				...state,
				logs: state.logs.map((log) => {
					if (log.id === action.id) {
						const signalWithTimestamp = {
							...action.signal,
							timestamp: os.clock(),
						};
						const outgoing = [signalWithTimestamp, ...log.outgoing];
						return {
							...log,
							outgoing,
						};
					}
					return log;
				}),
			};
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
		case "TOGGLE_NO_EXECUTOR":
			return {
				...state,
				noExecutor: !state.noExecutor,
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
		case "TOGGLE_REMOTE_MULTI_SELECTED": {
			const remotesMultiSelected = new Set<string>();
			state.remotesMultiSelected.forEach((id) => remotesMultiSelected.add(id));
			if (remotesMultiSelected.has(action.id)) {
				remotesMultiSelected.delete(action.id);
			} else {
				remotesMultiSelected.add(action.id);
			}
			return {
				...state,
				remotesMultiSelected,
			};
		}
		case "CLEAR_MULTI_SELECTION":
			return {
				...state,
				remotesMultiSelected: new Set(),
			};
		case "LOAD_SETTINGS":
			return {
				...state,
				noActors: action.settings.noActors ?? state.noActors,
				noExecutor: action.settings.noExecutor ?? state.noExecutor,
				showRemoteEvents: action.settings.showRemoteEvents ?? state.showRemoteEvents,
				showRemoteFunctions: action.settings.showRemoteFunctions ?? state.showRemoteFunctions,
				showBindableEvents: action.settings.showBindableEvents ?? state.showBindableEvents,
				showBindableFunctions: action.settings.showBindableFunctions ?? state.showBindableFunctions,
				pathNotation: action.settings.pathNotation ?? state.pathNotation,
			};
		default:
			return state;
	}
}
