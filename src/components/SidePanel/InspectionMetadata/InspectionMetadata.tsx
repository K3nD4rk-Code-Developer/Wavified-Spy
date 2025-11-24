import Container from "components/Container";
import Roact from "@rbxts/roact";
import TitleBar from "../components/TitleBar";
import { useSidePanelContext } from "../use-side-panel-context";
import { useRootSelector } from "hooks/use-root-store";
import { selectInspectionResultSelected } from "reducers/remote-log";
import { withHooksPure } from "@rbxts/roact-hooked";

function InspectionMetadata() {
	const { upperSize, upperHidden, setUpperHidden } = useSidePanelContext();
	const selectedResult = useRootSelector(selectInspectionResultSelected);

	return (
		<Container size={upperSize}>
			<TitleBar caption="Metadata" hidden={upperHidden} toggleHidden={() => setUpperHidden(!upperHidden)} />

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
						Text="Select an inspection result to view metadata"
						TextSize={12}
						Font="Gotham"
						TextColor3={new Color3(0.6, 0.6, 0.6)}
						Size={new UDim2(1, 0, 0, 60)}
						BackgroundTransparency={1}
						TextXAlignment="Center"
						TextYAlignment="Center"
						TextWrapped={true}
					/>
				) : (
					<>
						{/* Basic Info */}
						<frame Size={new UDim2(1, 0, 0, 0)} BackgroundTransparency={1} AutomaticSize={Enum.AutomaticSize.Y}>
							<uilistlayout FillDirection={Enum.FillDirection.Vertical} Padding={new UDim(0, 6)} />

							<textlabel
								Text="Basic Information"
								TextSize={11}
								Font="GothamBold"
								TextColor3={new Color3(0.8, 0.8, 0.8)}
								Size={new UDim2(1, 0, 0, 16)}
								BackgroundTransparency={1}
								TextXAlignment="Left"
								TextYAlignment="Center"
							/>

							<textlabel
								Text={`Name: ${selectedResult.name}`}
								TextSize={10}
								Font="Code"
								TextColor3={new Color3(0.9, 0.9, 0.9)}
								Size={new UDim2(1, 0, 0, 14)}
								BackgroundTransparency={1}
								TextXAlignment="Left"
								TextYAlignment="Center"
								TextWrapped={true}
							/>

							<textlabel
								Text={`Type: ${selectedResult.type}`}
								TextSize={10}
								Font="Code"
								TextColor3={new Color3(0.9, 0.9, 0.9)}
								Size={new UDim2(1, 0, 0, 14)}
								BackgroundTransparency={1}
								TextXAlignment="Left"
								TextYAlignment="Center"
								TextWrapped={true}
							/>

							{selectedResult.value !== undefined && (
								<textlabel
									Text={`Path: ${selectedResult.value}`}
									TextSize={10}
									Font="Code"
									TextColor3={new Color3(0.9, 0.9, 0.9)}
									Size={new UDim2(1, 0, 0, 0)}
									AutomaticSize={Enum.AutomaticSize.Y}
									BackgroundTransparency={1}
									TextXAlignment="Left"
									TextYAlignment="Top"
									TextWrapped={true}
								/>
							)}
						</frame>

						{/* Function Info */}
						{selectedResult.rawInfo && (
							<frame Size={new UDim2(1, 0, 0, 0)} BackgroundTransparency={1} AutomaticSize={Enum.AutomaticSize.Y}>
								<uilistlayout FillDirection={Enum.FillDirection.Vertical} Padding={new UDim(0, 6)} />

								<textlabel
									Text="Function Information"
									TextSize={11}
									Font="GothamBold"
									TextColor3={new Color3(0.8, 0.8, 0.8)}
									Size={new UDim2(1, 0, 0, 16)}
									BackgroundTransparency={1}
									TextXAlignment="Left"
									TextYAlignment="Center"
								/>

								<textlabel
									Text={`Source: ${selectedResult.rawInfo.short_src ?? selectedResult.rawInfo.source ?? "unknown"}`}
									TextSize={10}
									Font="Code"
									TextColor3={new Color3(0.9, 0.9, 0.9)}
									Size={new UDim2(1, 0, 0, 0)}
									AutomaticSize={Enum.AutomaticSize.Y}
									BackgroundTransparency={1}
									TextXAlignment="Left"
									TextYAlignment="Top"
									TextWrapped={true}
								/>

								<textlabel
									Text={`Function Type: ${selectedResult.rawInfo.what ?? "Lua"}`}
									TextSize={10}
									Font="Code"
									TextColor3={new Color3(0.9, 0.9, 0.9)}
									Size={new UDim2(1, 0, 0, 14)}
									BackgroundTransparency={1}
									TextXAlignment="Left"
									TextYAlignment="Center"
								/>

								{selectedResult.rawInfo.linedefined !== undefined && (
									<textlabel
										Text={`Lines: ${selectedResult.rawInfo.linedefined} - ${selectedResult.rawInfo.lastlinedefined ?? "?"}`}
										TextSize={10}
										Font="Code"
										TextColor3={new Color3(0.9, 0.9, 0.9)}
										Size={new UDim2(1, 0, 0, 14)}
										BackgroundTransparency={1}
										TextXAlignment="Left"
										TextYAlignment="Center"
									/>
								)}

								<textlabel
									Text={`Upvalue Count: ${selectedResult.rawInfo.nups ?? 0}`}
									TextSize={10}
									Font="Code"
									TextColor3={new Color3(0.9, 0.9, 0.9)}
									Size={new UDim2(1, 0, 0, 14)}
									BackgroundTransparency={1}
									TextXAlignment="Left"
									TextYAlignment="Center"
								/>
							</frame>
						)}

						{/* Script/Module Info */}
						{selectedResult.rawScript && (
							<frame Size={new UDim2(1, 0, 0, 0)} BackgroundTransparency={1} AutomaticSize={Enum.AutomaticSize.Y}>
								<uilistlayout FillDirection={Enum.FillDirection.Vertical} Padding={new UDim(0, 6)} />

								<textlabel
									Text="Object Hierarchy"
									TextSize={11}
									Font="GothamBold"
									TextColor3={new Color3(0.8, 0.8, 0.8)}
									Size={new UDim2(1, 0, 0, 16)}
									BackgroundTransparency={1}
									TextXAlignment="Left"
									TextYAlignment="Center"
								/>

								<textlabel
									Text={`Class: ${selectedResult.rawScript.ClassName}`}
									TextSize={10}
									Font="Code"
									TextColor3={new Color3(0.9, 0.9, 0.9)}
									Size={new UDim2(1, 0, 0, 14)}
									BackgroundTransparency={1}
									TextXAlignment="Left"
									TextYAlignment="Center"
								/>

								<textlabel
									Text={`Parent: ${selectedResult.rawScript.Parent?.Name ?? "nil"}`}
									TextSize={10}
									Font="Code"
									TextColor3={new Color3(0.9, 0.9, 0.9)}
									Size={new UDim2(1, 0, 0, 14)}
									BackgroundTransparency={1}
									TextXAlignment="Left"
									TextYAlignment="Center"
								/>

								{selectedResult.rawScript.Parent !== undefined && (
									<textlabel
										Text={`Parent Class: ${selectedResult.rawScript.Parent?.ClassName ?? "nil"}`}
										TextSize={10}
										Font="Code"
										TextColor3={new Color3(0.9, 0.9, 0.9)}
										Size={new UDim2(1, 0, 0, 14)}
										BackgroundTransparency={1}
										TextXAlignment="Left"
										TextYAlignment="Center"
									/>
								)}
							</frame>
						)}
					</>
				)}
			</scrollingframe>
		</Container>
	);
}

export default withHooksPure(InspectionMetadata);
