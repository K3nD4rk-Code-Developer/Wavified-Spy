import Container from "components/Container";
import Roact from "@rbxts/roact";
import TitleBar from "../components/TitleBar";
import { useSidePanelContext } from "../use-side-panel-context";
import { useRootSelector } from "hooks/use-root-store";
import { selectInspectionResultSelected } from "reducers/remote-log";
import { withHooksPure } from "@rbxts/roact-hooked";

// Declare decompile function
declare const decompile: ((script: LuaSourceContainer) => string) | undefined;

function InspectionConstants() {
	const { lowerSize, lowerPosition, lowerHidden, setLowerHidden } = useSidePanelContext();
	const selectedResult = useRootSelector(selectInspectionResultSelected);

	// Show constants if available, otherwise show script source
	const showConstants = selectedResult?.rawConstants && selectedResult.rawConstants.size() > 0;
	const showScript = selectedResult?.rawScript && !showConstants;
	const constantCount = selectedResult?.rawConstants?.size() ?? 0;
	const isEmpty = !selectedResult || (!showConstants && !showScript);

	return (
		<Container size={lowerSize} position={lowerPosition} clipChildren={true}>
			<TitleBar
				caption={showScript ? "Script Preview" : showConstants ? `Constants (${constantCount})` : "Constants"}
				hidden={lowerHidden}
				toggleHidden={() => setLowerHidden(!lowerHidden)}
			/>

			{!isEmpty ? (
				<scrollingframe
					Size={new UDim2(1, 0, 1, -30)}
					Position={new UDim2(0, 0, 0, 30)}
					BackgroundTransparency={1}
					BorderSizePixel={0}
					ScrollBarThickness={1}
					ScrollBarImageTransparency={0.6}
					AutomaticCanvasSize="Y"
				>
					<uilistlayout FillDirection="Vertical" Padding={new UDim(0, 2)} VerticalAlignment="Top" SortOrder="LayoutOrder" />
					<uipadding PaddingLeft={new UDim(0, 4)} PaddingRight={new UDim(0, 4)} PaddingTop={new UDim(0, 4)} PaddingBottom={new UDim(0, 4)} />

					{showConstants ? (
						(() => {
							const elements: Roact.Element[] = [];
							for (let i = 0; i < selectedResult!.rawConstants!.size(); i++) {
								const value = selectedResult!.rawConstants![i];
								elements.push(
									<frame
										Key={`constant_${i}`}
										AutomaticSize="Y"
										Size={new UDim2(1, -8, 0, 0)}
										BackgroundColor3={new Color3(1, 1, 1)}
										BackgroundTransparency={0.95}
										BorderSizePixel={0}
										LayoutOrder={i}
									>
										<uilistlayout FillDirection="Vertical" Padding={new UDim(0, 2)} VerticalAlignment="Top" />
										<uipadding PaddingLeft={new UDim(0, 8)} PaddingRight={new UDim(0, 8)} PaddingTop={new UDim(0, 4)} PaddingBottom={new UDim(0, 4)} />

										<textlabel
											AutomaticSize="Y"
											Size={new UDim2(1, -16, 0, 0)}
											Text={`[${i + 1}] ${typeOf(value)}`}
											Font="GothamBold"
											TextColor3={new Color3(0.9, 0.7, 1)}
											TextSize={10}
											TextXAlignment="Left"
											BackgroundTransparency={1}
										/>

										<textlabel
											AutomaticSize="Y"
											Size={new UDim2(1, -16, 0, 0)}
											Text={tostring(value).sub(1, 150)}
											Font="Code"
											TextColor3={new Color3(0.8, 0.8, 0.8)}
											TextSize={9}
											TextXAlignment="Left"
											TextWrapped={true}
											BackgroundTransparency={1}
										/>
									</frame>
								);
							}
							return elements;
						})()
					) : showScript ? (
						<frame
							AutomaticSize="Y"
							Size={new UDim2(1, -8, 0, 0)}
							BackgroundColor3={new Color3(0.05, 0.05, 0.05)}
							BackgroundTransparency={0.3}
							BorderSizePixel={0}
							LayoutOrder={1}
						>
							<uipadding PaddingLeft={new UDim(0, 8)} PaddingRight={new UDim(0, 8)} PaddingTop={new UDim(0, 8)} PaddingBottom={new UDim(0, 8)} />

							<textlabel
								AutomaticSize="Y"
								Size={new UDim2(1, -16, 0, 0)}
								Text={(() => {
									if (decompile) {
										const success = pcall(() => decompile(selectedResult!.rawScript!));
										if (success[0]) {
											const source = success[1] as string;
											// Limit to first 50 lines for preview
											const lines = source.split("\n");
											if (lines.size() > 50) {
												const previewLines: string[] = [];
												for (let i = 0; i < 50; i++) {
													previewLines.push(lines[i]);
												}
												return previewLines.join("\n") + "\n\n-- ... (truncated, use View Script button for full source)";
											}
											return source;
										} else {
											return `-- Failed to decompile\n-- Error: ${tostring(success[1])}`;
										}
									} else {
										return "-- decompile() function not available\n-- Use View Script button to open in viewer";
									}
								})()}
								Font="Code"
								TextColor3={new Color3(0.85, 0.85, 0.85)}
								TextSize={9}
								TextXAlignment="Left"
								TextYAlignment="Top"
								TextWrapped={true}
								BackgroundTransparency={1}
							/>
						</frame>
					) : undefined}
				</scrollingframe>
			) : (
				<frame
					Size={new UDim2(1, 0, 1, -30)}
					Position={new UDim2(0, 0, 0, 30)}
					BackgroundTransparency={1}
					BorderSizePixel={0}
				>
					<textlabel
						AnchorPoint={new Vector2(0.5, 0.5)}
						Position={new UDim2(0.5, 0, 0.5, 0)}
						Size={new UDim2(1, -20, 1, 0)}
						Text="Select a result to view details"
						Font="Gotham"
						TextColor3={new Color3(0.5, 0.5, 0.5)}
						TextSize={12}
						TextWrapped={true}
						BackgroundTransparency={1}
					/>
				</frame>
			)}
		</Container>
	);
}

export default withHooksPure(InspectionConstants);
