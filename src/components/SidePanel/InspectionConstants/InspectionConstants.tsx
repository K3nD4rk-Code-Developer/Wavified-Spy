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

	return (
		<Container size={lowerSize} position={lowerPosition}>
			<TitleBar
				caption={showScript ? "Script Source" : "Constants"}
				hidden={lowerHidden}
				toggleHidden={() => setLowerHidden(!lowerHidden)}
			/>

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

				{!selectedResult ? (
					<textlabel
						Text="Select a result to view details"
						TextSize={12}
						Font="Gotham"
						TextColor3={new Color3(0.6, 0.6, 0.6)}
						Size={new UDim2(1, 0, 0, 60)}
						BackgroundTransparency={1}
						TextXAlignment="Center"
						TextYAlignment="Center"
						TextWrapped={true}
					/>
				) : showConstants ? (
					<>
						<textlabel
							Text={`${selectedResult.rawConstants!.size()} Constants`}
							TextSize={11}
							Font="GothamBold"
							TextColor3={new Color3(0.8, 0.8, 0.8)}
							Size={new UDim2(1, 0, 0, 16)}
							BackgroundTransparency={1}
							TextXAlignment="Left"
							TextYAlignment="Center"
						/>

						{(() => {
							const elements: Roact.Element[] = [];
							for (let i = 0; i < selectedResult.rawConstants!.size(); i++) {
								const value = selectedResult.rawConstants![i];
								elements.push(
									<frame
										Key={`constant_${i}`}
										Size={new UDim2(1, 0, 0, 0)}
										BackgroundColor3={new Color3(0.08, 0.08, 0.08)}
										BorderSizePixel={0}
										AutomaticSize={Enum.AutomaticSize.Y}
									>
										<uicorner CornerRadius={new UDim(0, 4)} />
										<uipadding
											PaddingLeft={new UDim(0, 8)}
											PaddingRight={new UDim(0, 8)}
											PaddingTop={new UDim(0, 6)}
											PaddingBottom={new UDim(0, 6)}
										/>
										<uilistlayout FillDirection={Enum.FillDirection.Vertical} Padding={new UDim(0, 2)} />

										<textlabel
											Text={`[${i + 1}]`}
											TextSize={10}
											Font="GothamBold"
											TextColor3={new Color3(0.9, 0.7, 1)}
											Size={new UDim2(1, 0, 0, 12)}
											BackgroundTransparency={1}
											TextXAlignment="Left"
											TextYAlignment="Center"
										/>

										<textlabel
											Text={`${typeOf(value)} = ${tostring(value).sub(1, 100)}`}
											TextSize={9}
											Font="Code"
											TextColor3={new Color3(0.8, 0.8, 0.8)}
											Size={new UDim2(1, 0, 0, 0)}
											AutomaticSize={Enum.AutomaticSize.Y}
											BackgroundTransparency={1}
											TextXAlignment="Left"
											TextYAlignment="Top"
											TextWrapped={true}
										/>
									</frame>
								);
							}
							return elements;
						})()}
					</>
				) : showScript ? (
					<>
						<textlabel
							Text="Decompiled Source"
							TextSize={11}
							Font="GothamBold"
							TextColor3={new Color3(0.8, 0.8, 0.8)}
							Size={new UDim2(1, 0, 0, 16)}
							BackgroundTransparency={1}
							TextXAlignment="Left"
							TextYAlignment="Center"
						/>

						<frame
							Size={new UDim2(1, 0, 0, 0)}
							BackgroundColor3={new Color3(0.05, 0.05, 0.05)}
							BorderSizePixel={0}
							AutomaticSize={Enum.AutomaticSize.Y}
						>
							<uicorner CornerRadius={new UDim(0, 4)} />
							<uipadding
								PaddingLeft={new UDim(0, 8)}
								PaddingRight={new UDim(0, 8)}
								PaddingTop={new UDim(0, 8)}
								PaddingBottom={new UDim(0, 8)}
							/>

							<textlabel
								Text={(() => {
									if (decompile) {
										const success = pcall(() => decompile(selectedResult.rawScript!));
										if (success[0]) {
											return success[1] as string;
										} else {
											return `-- Failed to decompile\n-- Error: ${tostring(success[1])}`;
										}
									} else {
										return "-- decompile() function not available\n-- Cannot view source code in this environment";
									}
								})()}
								TextSize={9}
								Font="Code"
								TextColor3={new Color3(0.9, 0.9, 0.9)}
								Size={new UDim2(1, 0, 0, 0)}
								AutomaticSize={Enum.AutomaticSize.Y}
								BackgroundTransparency={1}
								TextXAlignment="Left"
								TextYAlignment="Top"
								TextWrapped={true}
							/>
						</frame>
					</>
				) : (
					<textlabel
						Text="No constants or script data available"
						TextSize={12}
						Font="Gotham"
						TextColor3={new Color3(0.6, 0.6, 0.6)}
						Size={new UDim2(1, 0, 0, 60)}
						BackgroundTransparency={1}
						TextXAlignment="Center"
						TextYAlignment="Center"
						TextWrapped={true}
					/>
				)}
			</scrollingframe>
		</Container>
	);
}

export default withHooksPure(InspectionConstants);
