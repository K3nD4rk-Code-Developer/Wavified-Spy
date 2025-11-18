import ActionBarEffects from "./ActionBarEffects";
import ActionButton from "./ActionButton";
import ActionLine from "./ActionLine";
import Container from "components/Container";
import Roact from "@rbxts/roact";

export default function ActionBar() {
	return (
		<>
			<frame
				BackgroundColor3={new Color3(1, 1, 1)}
				BackgroundTransparency={0.92}
				Size={new UDim2(1, 0, 0, 1)}
				Position={new UDim2(0, 0, 0, 83)}
				BorderSizePixel={0}
			/>

			<ActionBarEffects />

			<Container size={new UDim2(1, 0, 0, 36)} position={new UDim2(0, 0, 0, 42)}>
				<ActionButton layoutOrder={1} id="navigatePrevious" icon="rbxassetid://9887696242" />
				<ActionButton layoutOrder={2} id="navigateNext" icon="rbxassetid://9887978919" />
				<ActionButton layoutOrder={3} id="pause" icon="rbxassetid://9887697099" caption="Pause" />

				<ActionLine order={4} />

				<ActionButton layoutOrder={5} id="copy" icon="rbxassetid://9887696628" />
				<ActionButton layoutOrder={6} id="save" icon="rbxassetid://9932819855" />
				<ActionButton layoutOrder={7} id="delete" icon="rbxassetid://9887696922" />

				<ActionLine order={8} />

				<ActionButton layoutOrder={9} id="traceback" icon="rbxassetid://9887697255" caption="Traceback" />
				<ActionButton layoutOrder={10} id="copyPath" icon="rbxassetid://9887697099" caption="Copy as path" />
				<ActionButton layoutOrder={11} id="copyScript" icon="rbxassetid://9887697099" caption="Copy Script" />
				<ActionButton layoutOrder={12} id="viewScript" icon="rbxassetid://9887697255" caption="View Script" />

				<uilistlayout
					SortOrder={Enum.SortOrder.LayoutOrder}
					Padding={new UDim(0, 4)}
					FillDirection="Horizontal"
					HorizontalAlignment="Left"
					VerticalAlignment="Center"
				/>

				<uipadding PaddingLeft={new UDim(0, 8)} />
			</Container>

		</>
	);
}
