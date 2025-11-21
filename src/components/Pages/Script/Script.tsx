import Container from "components/Container";
import Roact from "@rbxts/roact";
import { withHooksPure } from "@rbxts/roact-hooked";
import { useRootSelector } from "hooks/use-root-store";
import { selectActiveTab } from "reducers/tab-group";
import { selectScriptContent } from "reducers/script";

function Script() {
	const currentTab = useRootSelector(selectActiveTab);
	const scriptContent = useRootSelector((state) =>
		currentTab ? selectScriptContent(state, currentTab.id) : undefined,
	);

	return (
		<Container>
			<scrollingframe
				Size={new UDim2(1, 0, 1, 0)}
				BackgroundColor3={Color3.fromRGB(20, 20, 20)}
				BorderSizePixel={0}
				ScrollBarThickness={6}
				ScrollBarImageColor3={Color3.fromRGB(100, 100, 100)}
				CanvasSize={new UDim2(0, 0, 0, 0)}
				AutomaticCanvasSize={Enum.AutomaticSize.Y}
			>
				<textlabel
					Text={scriptContent ?? "No script content"}
					TextSize={14}
					Font={Enum.Font.Code}
					TextColor3={new Color3(1, 1, 1)}
					Size={new UDim2(1, -20, 0, 0)}
					Position={new UDim2(0, 10, 0, 10)}
					BackgroundTransparency={1}
					TextXAlignment={Enum.TextXAlignment.Left}
					TextYAlignment={Enum.TextYAlignment.Top}
					TextWrapped={true}
					AutomaticSize={Enum.AutomaticSize.Y}
				/>
			</scrollingframe>
		</Container>
	);
}

export default withHooksPure(Script);
