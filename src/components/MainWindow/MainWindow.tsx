import Acrylic from "components/Acrylic";
import ActionBar from "components/ActionBar";
import Pages from "components/Pages";
import Roact from "@rbxts/roact";
import Root from "components/Root";
import SidePanel from "components/SidePanel";
import Tabs from "components/Tabs";
import Window from "components/Window";
import { activateAction } from "reducers/action-bar";
import { useRootDispatch, useRootSelector } from "hooks/use-root-store";
import { selectUIVisible } from "reducers/ui";
import { withHooksPure } from "@rbxts/roact-hooked";

function MainWindow() {
	const dispatch = useRootDispatch();
	const visible = useRootSelector(selectUIVisible);

	return (
		<Root enabled={visible}>
			<Window.Root initialSize={new UDim2(0, 990, 0, 575)} initialPosition={new UDim2(0.5, -540, 0.5, -350)}>
				<Window.DropShadow />
				<Acrylic.Paint />

				<ActionBar />
				<SidePanel />

				<Tabs />
				<Pages />

				<Window.TitleBar
					onClose={() => dispatch(activateAction("close"))}
					caption={`<font color="#FFFFFF">Wavified Spy</font>    <font color="#B2B2B2">${PKG_VERSION}</font>`}
					captionTransparency={0.1}
					icon="rbxassetid://133291240952158"
				/>
				<Window.Resize minSize={new Vector2(650, 450)} />
			</Window.Root>
		</Root>
	);
}

export default withHooksPure(MainWindow);
