export function toggleUIVisibility() {
	return { type: "TOGGLE_UI_VISIBILITY" } as const;
}

export function setUIVisibility(visible: boolean) {
	return { type: "SET_UI_VISIBILITY", visible } as const;
}

export function setToggleKey(key: Enum.KeyCode) {
	return { type: "SET_TOGGLE_KEY", key } as const;
}

export function loadToggleKey(keyName: string) {
	return { type: "LOAD_TOGGLE_KEY", keyName } as const;
}

export type UIActions =
	| ReturnType<typeof toggleUIVisibility>
	| ReturnType<typeof setUIVisibility>
	| ReturnType<typeof setToggleKey>
	| ReturnType<typeof loadToggleKey>;
