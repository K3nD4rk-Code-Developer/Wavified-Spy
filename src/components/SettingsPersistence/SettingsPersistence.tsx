import Roact from "@rbxts/roact";
import { useEffect, useMutable, withHooksPure } from "@rbxts/roact-hooked";
import { useRootDispatch, useRootSelector } from "hooks/use-root-store";
import {
	selectNoActors,
	selectNoExecutor,
	selectShowRemoteEvents,
	selectShowRemoteFunctions,
	selectShowBindableEvents,
	selectShowBindableFunctions,
	selectPathNotation,
	loadSettings as loadSettingsAction,
} from "reducers/remote-log";
import { selectToggleKey, loadToggleKey } from "reducers/ui";
import { loadSettings, saveSettings, PersistedSettings } from "utils/settings-persistence";

function SettingsPersistence() {
	const dispatch = useRootDispatch();
	const loaded = useMutable(false);

	// Get all settings from state
	const noActors = useRootSelector(selectNoActors);
	const noExecutor = useRootSelector(selectNoExecutor);
	const showRemoteEvents = useRootSelector(selectShowRemoteEvents);
	const showRemoteFunctions = useRootSelector(selectShowRemoteFunctions);
	const showBindableEvents = useRootSelector(selectShowBindableEvents);
	const showBindableFunctions = useRootSelector(selectShowBindableFunctions);
	const pathNotation = useRootSelector(selectPathNotation);
	const toggleKey = useRootSelector(selectToggleKey);

	// Load settings after 1 second on mount
	useEffect(() => {
		const connection = task.delay(1, () => {
			const settings = loadSettings();
			if (settings) {
				dispatch(loadSettingsAction(settings));
				// Load toggle key separately
				if (settings.toggleKey) {
					dispatch(loadToggleKey(settings.toggleKey));
				}
			}
			loaded.current = true;
		});

		return () => {
			if (connection) {
				task.cancel(connection);
			}
		};
	}, []);

	// Save settings whenever they change (but only after initial load)
	useEffect(() => {
		if (!loaded.current) return;

		const settings: PersistedSettings = {
			noActors,
			noExecutor,
			showRemoteEvents,
			showRemoteFunctions,
			showBindableEvents,
			showBindableFunctions,
			pathNotation,
			toggleKey: toggleKey.Name,
		};

		saveSettings(settings);
	}, [noActors, noExecutor, showRemoteEvents, showRemoteFunctions, showBindableEvents, showBindableFunctions, pathNotation, toggleKey]);

	return <></>;
}

export default withHooksPure(SettingsPersistence);
