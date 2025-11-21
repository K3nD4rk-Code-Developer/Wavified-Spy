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
			// Convert string back to KeyCode enum using GetEnumItems
			const allKeyCodes = Enum.KeyCode.GetEnumItems();
			const foundKeyCode = allKeyCodes.find((keyCode) => keyCode.Name === action.keyName);

			if (foundKeyCode) {
				return {
					...state,
					toggleKey: foundKeyCode,
				};
			}
			return state;
		}
		default:
			return state;
	}
}
