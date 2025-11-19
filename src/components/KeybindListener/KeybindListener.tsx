import Roact from "@rbxts/roact";
import { UserInputService } from "@rbxts/services";
import { useRootDispatch, useRootSelector } from "hooks/use-root-store";
import { selectToggleKey } from "reducers/ui";
import { toggleUIVisibility } from "reducers/ui";
import { withHooksPure, useEffect } from "@rbxts/roact-hooked";

function KeybindListener() {
	const dispatch = useRootDispatch();
	const toggleKey = useRootSelector(selectToggleKey);

	useEffect(() => {
		const connection = UserInputService.InputBegan.Connect((input, gameProcessed) => {
			// Don't handle input if typing in a text box
			if (gameProcessed) return;

			// Check if the pressed key matches the configured toggle key
			if (input.KeyCode === toggleKey) {
				dispatch(toggleUIVisibility());
			}
		});

		return () => {
			connection.Disconnect();
		};
	}, [toggleKey]);

	// This component doesn't render anything
	return undefined;
}

export default withHooksPure(KeybindListener);
