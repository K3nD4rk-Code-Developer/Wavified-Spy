import Container from "components/Container";
import Roact from "@rbxts/roact";
import { withHooksPure } from "@rbxts/roact-hooked";
import { useRootDispatch, useRootSelector } from "hooks/use-root-store";
import { selectActiveTab } from "reducers/tab-group";
import { selectScript, updateScriptContent } from "reducers/script";
import { highlightLua } from "utils/syntax-highlight";

function Script() {
	const dispatch = useRootDispatch();
	const currentTab = useRootSelector(selectActiveTab);
	const scriptData = useRootSelector((state) =>
		currentTab ? selectScript(state, currentTab.id) : undefined,
	);

	const scriptContent = scriptData?.content ?? "No script content";
	const isEditable = scriptData?.signalId !== undefined;
	const highlightedContent = highlightLua(scriptContent);

	const handleTextChange = (rbx: TextBox) => {
		if (currentTab && isEditable) {
			dispatch(updateScriptContent(currentTab.id, rbx.Text));
		}
	};

	return (
		<Container>
			<scrollingframe
				Size={new UDim2(1, 0, 1, 0)}
				BackgroundColor3={Color3.fromRGB(245, 245, 245)}
				BackgroundTransparency={0.96}
				BorderSizePixel={0}
				ScrollBarThickness={1}
				ScrollBarImageTransparency={0.6}
				ScrollBarImageColor3={Color3.fromRGB(100, 100, 100)}
				CanvasSize={new UDim2(1, 0, 0, 10020)}
			>
				<uipadding
					PaddingLeft={new UDim(0, 10)}
					PaddingRight={new UDim(0, 10)}
					PaddingTop={new UDim(0, 10)}
					PaddingBottom={new UDim(0, 10)}
				/>

				{isEditable ? (
					<textbox
						Text={scriptContent}
						TextSize={14}
						Font={Enum.Font.Code}
						TextColor3={new Color3(1, 1, 1)}
						Size={new UDim2(1, 0, 1, 0)}
						BackgroundTransparency={1}
						TextXAlignment={Enum.TextXAlignment.Left}
						TextYAlignment={Enum.TextYAlignment.Top}
						TextWrapped={true}
						MultiLine={true}
						ClearTextOnFocus={false}
						Change={{
							Text: handleTextChange,
						}}
					/>
				) : (
					<textlabel
						Text={highlightedContent}
						RichText={true}
						TextSize={14}
						Font={Enum.Font.Code}
						TextColor3={Color3.fromRGB(212, 212, 212)}
						Size={new UDim2(1, 0, 1, 0)}
						BackgroundTransparency={1}
						TextXAlignment={Enum.TextXAlignment.Left}
						TextYAlignment={Enum.TextYAlignment.Top}
						TextWrapped={false}
					/>
				)}
			</scrollingframe>
		</Container>
	);
}

export default withHooksPure(Script);
