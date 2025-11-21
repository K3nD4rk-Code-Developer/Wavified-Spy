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
			// Use pcall to safely get the enum value
			const [success, result] = pcall(() => {
				return (Enum.KeyCode as unknown as Record<string, Enum.KeyCode>)[action.keyName];
			});

			if (success && result !== undefined && typeOf(result) === "EnumItem") {
				return {
					...state,
					toggleKey: result as Enum.KeyCode,
				};
			}
			return state;
		}
		default:
			return state;
	}
}
