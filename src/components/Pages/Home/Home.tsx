import Roact from "@rbxts/roact";
import Row from "./Row";
import Selection from "components/Selection";
import { arrayToMap } from "@rbxts/roact-hooked-plus";
import { selectRemoteIdSelected, selectRemoteLogIds, selectRemotesMultiSelected } from "reducers/remote-log";
import { setRemoteSelected, toggleRemoteMultiSelected, clearMultiSelection } from "reducers/remote-log";
import { useEffect, withHooksPure } from "@rbxts/roact-hooked";
import { useRootDispatch, useRootSelector } from "hooks/use-root-store";
import { UserInputService } from "@rbxts/services";

interface Props {
	pageSelected: boolean;
}

function Home({ pageSelected }: Props) {
	const dispatch = useRootDispatch();
	const remoteLogIds = useRootSelector(selectRemoteLogIds);
	const selection = useRootSelector(selectRemoteIdSelected);
	const multiSelected = useRootSelector(selectRemotesMultiSelected);

	// Deselect the remote if the page is deselected.
	useEffect(() => {
		if (!pageSelected && selection) {
			dispatch(setRemoteSelected(undefined));
		}
		if (!pageSelected && multiSelected.size() > 0) {
			dispatch(clearMultiSelection());
		}
	}, [pageSelected]);

	// Deselect the remote if it is no longer in the list.
	useEffect(() => {
		if (selection !== undefined && !remoteLogIds.includes(selection)) {
			dispatch(setRemoteSelected(undefined));
		}
	}, [remoteLogIds]);

	const selectionOrder = selection !== undefined ? remoteLogIds.indexOf(selection) : -1;

	return (
		<scrollingframe
			ScrollBarThickness={0}
			ScrollBarImageTransparency={1}
			CanvasSize={new UDim2(0, 0, 0, (remoteLogIds.size() + 1) * (64 + 4))}
			Size={new UDim2(1, 0, 1, 0)}
			BorderSizePixel={0}
			BackgroundTransparency={1}
		>
			<uipadding PaddingLeft={new UDim(0, 12)} PaddingRight={new UDim(0, 12)} PaddingTop={new UDim(0, 12)} />

			<Selection
				height={64}
				offset={selectionOrder !== -1 ? selectionOrder * (64 + 4) : undefined}
				hasSelection={selection !== undefined}
			/>

			{arrayToMap(remoteLogIds, (id, order) => [
				id,
				<Row
					id={id}
					order={order}
					selected={selection === id}
					multiSelected={multiSelected.has(id)}
					onClick={() => {
						const isCtrlHeld = UserInputService.IsKeyDown(Enum.KeyCode.LeftControl) || UserInputService.IsKeyDown(Enum.KeyCode.RightControl);

						if (isCtrlHeld) {
							// Multi-select mode
							dispatch(toggleRemoteMultiSelected(id));
						} else {
							// Normal single selection
							selection !== id ? dispatch(setRemoteSelected(id)) : dispatch(setRemoteSelected(undefined));
							// Clear multi-selection when not holding Ctrl
							if (multiSelected.size() > 0) {
								dispatch(clearMultiSelection());
							}
						}
					}}
				/>,
			])}
		</scrollingframe>
	);
}

export default withHooksPure(Home);
