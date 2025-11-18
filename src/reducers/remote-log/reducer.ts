import { RemoteLogActions } from "./actions";
import { RemoteLogState } from "./model";

const initialState: RemoteLogState = {
	logs: [],
	paused: false,
	pausedRemotes: new Set(),
	blockedRemotes: new Set(),
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
						const outgoing = [action.signal, ...log.outgoing];
						if (outgoing.size() > 50) {
							outgoing.pop();
						}
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
		case "BLOCK_ALL_REMOTES": {
			const blockedRemotes = new Set<string>();
			state.logs.forEach((log) => blockedRemotes.add(log.id));
			return {
				...state,
				blockedRemotes,
			};
		}
		default:
			return state;
	}
}
