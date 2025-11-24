import Container from "components/Container";
import Roact from "@rbxts/roact";
import TitleBar from "../components/TitleBar";
import { useSidePanelContext } from "../use-side-panel-context";
import { withHooksPure } from "@rbxts/roact-hooked";

function InspectionUpvalues() {
	const { middleSize, middlePosition, middleHidden, setMiddleHidden } = useSidePanelContext();

	return (
		<Container size={middleSize} position={middlePosition}>
			<TitleBar caption="Upvalues" hidden={middleHidden} toggleHidden={() => setMiddleHidden(!middleHidden)} />

			<scrollingframe
				Size={new UDim2(1, 0, 1, -40)}
				Position={new UDim2(0, 0, 0, 40)}
				BackgroundTransparency={1}
				BorderSizePixel={0}
				ScrollBarThickness={4}
				ScrollBarImageColor3={new Color3(0.3, 0.3, 0.3)}
				CanvasSize={new UDim2(0, 0, 0, 0)}
				AutomaticCanvasSize={Enum.AutomaticSize.Y}
			>
				<uilistlayout
					FillDirection={Enum.FillDirection.Vertical}
					Padding={new UDim(0, 4)}
					HorizontalAlignment={Enum.HorizontalAlignment.Left}
				/>
				<uipadding PaddingLeft={new UDim(0, 12)} PaddingRight={new UDim(0, 12)} PaddingTop={new UDim(0, 8)} />

				<textlabel
					Text="Select a function to view upvalues"
					TextSize={12}
					Font="Gotham"
					TextColor3={new Color3(0.6, 0.6, 0.6)}
					Size={new UDim2(1, 0, 0, 60)}
					BackgroundTransparency={1}
					TextXAlignment="Center"
					TextYAlignment="Center"
					TextWrapped={true}
				/>
			</scrollingframe>
		</Container>
	);
}

export default withHooksPure(InspectionUpvalues);
