import { UIActions } from "./actions";
import { UIState } from "./model";
import { loadSettings } from "utils/settings-persistence";

// Load persisted settings if available
const persistedSettings = loadSettings();

// Convert KeyCode name string back to Enum.KeyCode
const getInitialToggleKey = (): Enum.KeyCode => {
	if (persistedSettings?.toggleKey) {
		// Iterate through KeyCode enum items to find matching name
		for (const keyCode of Enum.KeyCode.GetEnumItems()) {
			if (keyCode.Name === persistedSettings.toggleKey) {
				return keyCode;
			}
		}
	}
	return Enum.KeyCode.RightControl;
};

const initialState: UIState = {
	visible: true,
	toggleKey: getInitialToggleKey(),
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
		default:
			return state;
	}
}
