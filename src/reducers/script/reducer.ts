import { ScriptActions } from "./actions";
import { ScriptState } from "./model";

const initialState: ScriptState = {
	scripts: {},
};

export default function scriptReducer(state = initialState, action: ScriptActions): ScriptState {
	switch (action.type) {
		case "SET_SCRIPT":
			return {
				...state,
				scripts: {
					...state.scripts,
					[action.id]: action.script,
				},
			};
		case "UPDATE_SCRIPT_CONTENT": {
			const scriptData = state.scripts[action.id];
			if (!scriptData) return state;
			return {
				...state,
				scripts: {
					...state.scripts,
					[action.id]: {
						...scriptData,
						content: action.content,
					},
				},
			};
		}
		case "REMOVE_SCRIPT": {
			const newScripts = { ...state.scripts };
			delete newScripts[action.id];
			return {
				...state,
				scripts: newScripts,
			};
		}
		default:
			return state;
	}
}
