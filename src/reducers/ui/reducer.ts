import { UIActions } from "./actions";
import { UIState } from "./model";

const initialState: UIState = {
	visible: true,
	toggleKey: Enum.KeyCode.RightControl,
};

export default function uiReducer(state = initialState, action: UIActions): UIState {
	switch (action.type) {
		case "TOGGLE_UI_VISIBILITY":
			return {
				...state,
				visible: !state.visible,
			};
		case "SET_UI_VISIBILITY":
			return {
				...state,
				visible: action.visible,
			};
		case "SET_TOGGLE_KEY":
			return {
				...state,
				toggleKey: action.key,
			};
		case "LOAD_TOGGLE_KEY": {
			// Convert string back to KeyCode enum
			const keyCode = Enum.KeyCode[action.keyName as keyof typeof Enum.KeyCode];
			// Check if it's a valid KeyCode value (not a function or undefined)
			if (keyCode !== undefined && typeOf(keyCode) === "EnumItem") {
				return {
					...state,
					toggleKey: keyCode as Enum.KeyCode,
				};
			}
			return state;
		}
		default:
			return state;
	}
}
