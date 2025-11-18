import Container from "components/Container";
import Roact from "@rbxts/roact";
import { withHooksPure } from "@rbxts/roact-hooked";
import { useRootSelector } from "hooks/use-root-store";
import { selectActiveTab } from "reducers/tab-group";

function Script() {
	const activeTab = useRootSelector(selectActiveTab);
	const scriptContent = activeTab?.scriptContent ?? "No script content available";

	return (
		<Container>
			<scrollingframe
				Size={new UDim2(1, 0, 1, 0)}
				BackgroundTransparency={1}
				BorderSizePixel={0}
				ScrollBarThickness={6}
				CanvasSize={new UDim2(0, 0, 0, 0)}
				AutomaticCanvasSize={Enum.AutomaticSize.Y}
			>
				<textlabel
					Text={scriptContent}
					TextSize={14}
					Font="Code"
					TextColor3={new Color3(1, 1, 1)}
					Size={new UDim2(1, -20, 0, 0)}
					Position={new UDim2(0, 10, 0, 10)}
					BackgroundTransparency={1}
					TextXAlignment="Left"
					TextYAlignment="Top"
					AutomaticSize={Enum.AutomaticSize.Y}
					TextWrapped={true}
				/>
			</scrollingframe>
		</Container>
	);
}

export default withHooksPure(Script);
