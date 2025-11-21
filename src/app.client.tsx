import Roact from "@rbxts/roact";
import { StoreProvider } from "@rbxts/roact-rodux-hooked";

import App from "components/App";
import { IS_LOADED } from "constants";
import { changed, configureStore } from "store";
import { getGlobal, setGlobal } from "utils/global-util";
import { selectIsClosing } from "reducers/action-bar";

if (getGlobal(IS_LOADED) === true) {
	throw `The global ${IS_LOADED} is already defined.`;
}

const store = configureStore();

const tree = Roact.mount(
	<StoreProvider store={store}>
		<App />
	</StoreProvider>,
);

// CRITICAL FIX: Manually force StoreProvider to update when Rodux store changes
// roact-rodux-hooked doesn't automatically subscribe to store.changed
let updateCount = 0;
let isUpdating = false;

store.changed.connect((state) => {
	// Prevent infinite loop - don't update if we're already updating
	if (isUpdating) {
		print("[App] Skipping update - already updating");
		return;
	}

	// Only update if remoteLog state actually changed
	const logCount = state.remoteLog.logs.size();
	print("[App] Store changed with", logCount, "logs - triggering UI update");

	updateCount++;
	isUpdating = true;

	// Use task.defer to break the synchronous call chain
	task.defer(() => {
		try {
			// Force re-render by updating the tree
			Roact.update(
				tree,
				<StoreProvider store={store}>
					<App Key={"app-" + updateCount} />
				</StoreProvider>,
			);
			print("[App] Update #" + updateCount + " completed");
		} finally {
			isUpdating = false;
		}
	});
});

changed(selectIsClosing, (active) => {
	if (active) {
		Roact.unmount(tree);
		setGlobal(IS_LOADED, false);
		task.defer(() => store.destruct());
	}
});

setGlobal(IS_LOADED, true);
