import Container from "components/Container";
import Roact from "@rbxts/roact";
import TitleBar from "../components/TitleBar";
import { useSidePanelContext } from "../use-side-panel-context";
import { selectSignalSelected, selectPathNotation } from "reducers/remote-log";
import { useRootSelector } from "hooks/use-root-store";
import { withHooksPure } from "@rbxts/roact-hooked";
import { genScript } from "utils/gen-script";
import { highlightLua } from "utils/syntax-highlight";

function Peek() {
	const { middleHidden, setMiddleHidden, middleSize, middlePosition } = useSidePanelContext();
	const signal = useRootSelector(selectSignalSelected);
	const pathNotation = useRootSelector(selectPathNotation);

	let scriptCode = "";
	let highlightedCode = "";
	if (signal) {
		// Convert parameters to array
		const paramEntries: [number, unknown][] = [];
		for (const [key, value] of pairs(signal.parameters)) {
			paramEntries.push([key as number, value]);
		}
		paramEntries.sort((a, b) => a[0] < b[0]);
		const parameters = paramEntries.map(([_, value]) => value as defined);

		scriptCode = genScript(signal.remote, parameters, pathNotation);
		highlightedCode = highlightLua(scriptCode);
	}

	const isEmpty = !signal || scriptCode === "";

	return (
		<Container size={middleSize} position={middlePosition}>
			<TitleBar
				caption="Peek"
				hidden={middleHidden}
				toggleHidden={() => setMiddleHidden(!middleHidden)}
			/>

			{!middleHidden && (!isEmpty ? (
				<scrollingframe
					Size={new UDim2(1, 0, 1, -30)}
					Position={new UDim2(0, 0, 0, 30)}
					BackgroundColor3={Color3.fromRGB(30, 30, 30)}
					BorderSizePixel={0}
					ScrollBarThickness={4}
					ScrollBarImageColor3={Color3.fromRGB(80, 80, 80)}
					CanvasSize={new UDim2(1, 0, 0, 10000)}
				>
					<uipadding
						PaddingLeft={new UDim(0, 12)}
						PaddingRight={new UDim(0, 12)}
						PaddingTop={new UDim(0, 12)}
						PaddingBottom={new UDim(0, 12)}
					/>

					<textlabel
						Size={new UDim2(1, 0, 1, 0)}
						Text={highlightedCode}
						RichText={true}
						Font={Enum.Font.Code}
						TextSize={11}
						TextColor3={Color3.fromRGB(212, 212, 212)}
						TextXAlignment="Left"
						TextYAlignment="Top"
						TextWrapped={false}
						BackgroundTransparency={1}
					/>
				</scrollingframe>
			) : (
				<frame
					Size={new UDim2(1, 0, 1, -30)}
					Position={new UDim2(0, 0, 0, 30)}
					BackgroundColor3={new Color3(1, 1, 1)}
					BackgroundTransparency={1}
					BorderSizePixel={0}
				>
					<textlabel
						AnchorPoint={new Vector2(0.5, 0.5)}
						Position={new UDim2(0.5, 0, 0.5, 0)}
						Size={new UDim2(1, -20, 1, 0)}
						Text="Select a signal to peek at the generated script"
						Font="Gotham"
						TextColor3={new Color3(0.5, 0.5, 0.5)}
						TextSize={12}
						TextWrapped={true}
						BackgroundTransparency={1}
					/>
				</frame>
			))}
		</Container>
	);
}

export default withHooksPure(Peek);
