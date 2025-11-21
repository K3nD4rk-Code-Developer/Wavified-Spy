import Roact from "@rbxts/roact";
import Row from "./Row";
import Selection from "components/Selection";
import { arrayToMap } from "@rbxts/roact-hooked-plus";
import { selectRemoteIdSelected, selectRemoteLogIds } from "reducers/remote-log";
import { setRemoteSelected } from "reducers/remote-log";
import { useEffect, useState, withHooksPure } from "@rbxts/roact-hooked";
import { useRootDispatch, useRootSelector, useRootStore } from "hooks/use-root-store";

interface Props {
	pageSelected: boolean;
}

function Home({ pageSelected }: Props) {
	const dispatch = useRootDispatch();
	const store = useRootStore();
	const [forceUpdate, setForceUpdate] = useState(0);

	// Force component to update when store changes
	useEffect(() => {
		print("[Home] Setting up store.changed subscription");
		const connection = store.changed.connect(() => {
			print("[Home] Store changed, forcing re-render");
			setForceUpdate((prev) => prev + 1);
		});

		return () => {
			print("[Home] Cleaning up store.changed subscription");
			connection.disconnect();
		};
	}, []);

	const remoteLogIds = useRootSelector(selectRemoteLogIds);
	const selection = useRootSelector(selectRemoteIdSelected);

	print("[Home] useRootSelector returned remoteLogIds:", remoteLogIds, "type:", typeOf(remoteLogIds), "size:", remoteLogIds.size());
	print("[Home] Rendering with", remoteLogIds.size(), "remote IDs, forceUpdate:", forceUpdate);

	// Deselect the remote if the page is deselected.
	useEffect(() => {
		if (!pageSelected && selection) {
			dispatch(setRemoteSelected(undefined));
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
					onClick={() =>
						selection !== id ? dispatch(setRemoteSelected(id)) : dispatch(setRemoteSelected(undefined))
					}
				/>,
			])}
		</scrollingframe>
	);
}

export default withHooksPure(Home);
