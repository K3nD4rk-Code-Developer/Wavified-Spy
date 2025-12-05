import Container from "components/Container";
import Roact from "@rbxts/roact";
import TitleBar from "../components/TitleBar";
import { useSidePanelContext } from "../use-side-panel-context";
import { useRootSelector } from "hooks/use-root-store";
import { selectInspectionResultSelected } from "reducers/remote-log";
import { withHooksPure } from "@rbxts/roact-hooked";
import { formatEscapes } from "utils/format-escapes";

function InspectionMetadata() {
	const { upperSize, upperHidden, setUpperHidden } = useSidePanelContext();
	const selectedResult = useRootSelector(selectInspectionResultSelected);

	const isEmpty = !selectedResult;

	return (
		<Container size={upperSize}>
			<TitleBar
				caption={`Metadata${selectedResult ? ` - ${selectedResult.name}` : ""}`}
				hidden={upperHidden}
				toggleHidden={() => setUpperHidden(!upperHidden)}
			/>

			{!upperHidden && (!isEmpty ? (
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

					{/* Basic Info Section */}
					<frame
						AutomaticSize="Y"
						Size={new UDim2(1, -8, 0, 0)}
						BackgroundColor3={new Color3(1, 1, 1)}
						BackgroundTransparency={0.95}
						BorderSizePixel={0}
						LayoutOrder={1}
					>
						<uilistlayout FillDirection="Vertical" Padding={new UDim(0, 2)} VerticalAlignment="Top" />
						<uipadding PaddingLeft={new UDim(0, 8)} PaddingRight={new UDim(0, 8)} PaddingTop={new UDim(0, 6)} PaddingBottom={new UDim(0, 6)} />

						<textlabel
							AutomaticSize="Y"
							Size={new UDim2(1, -16, 0, 0)}
							Text="Basic Information"
							Font="GothamBold"
							TextColor3={new Color3(0.9, 0.9, 1)}
							TextSize={11}
							TextXAlignment="Left"
							BackgroundTransparency={1}
						/>

						<textlabel
							AutomaticSize="Y"
							Size={new UDim2(1, -16, 0, 0)}
							Text={`Type: ${selectedResult.type}`}
							Font="Gotham"
							TextColor3={new Color3(0.8, 0.8, 0.8)}
							TextSize={10}
							TextXAlignment="Left"
							TextWrapped={true}
							BackgroundTransparency={1}
						/>

						{selectedResult.value !== undefined && (
							<textlabel
								AutomaticSize="Y"
								Size={new UDim2(1, -16, 0, 0)}
								Text={`Path: ${formatEscapes(selectedResult.value)}`}
								Font="Gotham"
								TextColor3={new Color3(0.75, 0.75, 0.75)}
								TextSize={9}
								TextXAlignment="Left"
								TextWrapped={true}
								BackgroundTransparency={1}
							/>
						)}
					</frame>

					{/* Function Info Section */}
					{selectedResult.rawInfo && (
						<frame
							AutomaticSize="Y"
							Size={new UDim2(1, -8, 0, 0)}
							BackgroundColor3={new Color3(0.2, 0.5, 0.2)}
							BackgroundTransparency={0.9}
							BorderSizePixel={0}
							LayoutOrder={2}
						>
							<uilistlayout FillDirection="Vertical" Padding={new UDim(0, 2)} VerticalAlignment="Top" />
							<uipadding PaddingLeft={new UDim(0, 8)} PaddingRight={new UDim(0, 8)} PaddingTop={new UDim(0, 6)} PaddingBottom={new UDim(0, 6)} />

							<textlabel
								AutomaticSize="Y"
								Size={new UDim2(1, -16, 0, 0)}
								Text="Function Details"
								Font="GothamBold"
								TextColor3={new Color3(0.9, 0.9, 1)}
								TextSize={11}
								TextXAlignment="Left"
								BackgroundTransparency={1}
							/>

							<textlabel
								AutomaticSize="Y"
								Size={new UDim2(1, -16, 0, 0)}
								Text={`Source: ${formatEscapes(selectedResult.rawInfo.short_src ?? selectedResult.rawInfo.source ?? "unknown")}`}
								Font="Gotham"
								TextColor3={new Color3(0.75, 0.75, 0.75)}
								TextSize={9}
								TextXAlignment="Left"
								TextWrapped={true}
								BackgroundTransparency={1}
							/>

							<textlabel
								AutomaticSize="Y"
								Size={new UDim2(1, -16, 0, 0)}
								Text={`Type: ${selectedResult.rawInfo.what ?? "Lua"} | Upvalues: ${selectedResult.rawInfo.nups ?? 0}`}
								Font="Gotham"
								TextColor3={new Color3(0.8, 0.8, 0.8)}
								TextSize={10}
								TextXAlignment="Left"
								BackgroundTransparency={1}
							/>

							{selectedResult.rawInfo.linedefined !== undefined && (
								<textlabel
									AutomaticSize="Y"
									Size={new UDim2(1, -16, 0, 0)}
									Text={`Lines: ${selectedResult.rawInfo.linedefined} - ${selectedResult.rawInfo.lastlinedefined ?? "?"}`}
									Font="Gotham"
									TextColor3={new Color3(0.8, 0.8, 0.8)}
									TextSize={10}
									TextXAlignment="Left"
									BackgroundTransparency={1}
								/>
							)}
						</frame>
					)}

					{/* Script/Module Info Section */}
					{selectedResult.rawScript && (
						<frame
							AutomaticSize="Y"
							Size={new UDim2(1, -8, 0, 0)}
							BackgroundColor3={new Color3(0.15, 0.35, 0.6)}
							BackgroundTransparency={0.9}
							BorderSizePixel={0}
							LayoutOrder={3}
						>
							<uilistlayout FillDirection="Vertical" Padding={new UDim(0, 2)} VerticalAlignment="Top" />
							<uipadding PaddingLeft={new UDim(0, 8)} PaddingRight={new UDim(0, 8)} PaddingTop={new UDim(0, 6)} PaddingBottom={new UDim(0, 6)} />

							<textlabel
								AutomaticSize="Y"
								Size={new UDim2(1, -16, 0, 0)}
								Text="Script Hierarchy"
								Font="GothamBold"
								TextColor3={new Color3(0.9, 0.9, 1)}
								TextSize={11}
								TextXAlignment="Left"
								BackgroundTransparency={1}
							/>

							<textlabel
								AutomaticSize="Y"
								Size={new UDim2(1, -16, 0, 0)}
								Text={`Class: ${selectedResult.rawScript.ClassName}`}
								Font="Gotham"
								TextColor3={new Color3(0.8, 0.8, 0.9)}
								TextSize={10}
								TextXAlignment="Left"
								BackgroundTransparency={1}
							/>

							<textlabel
								AutomaticSize="Y"
								Size={new UDim2(1, -16, 0, 0)}
								Text={`Parent: ${selectedResult.rawScript.Parent?.Name ?? "nil"}${
									selectedResult.rawScript.Parent ? ` (${selectedResult.rawScript.Parent.ClassName})` : ""
								}`}
								Font="Gotham"
								TextColor3={new Color3(0.75, 0.75, 0.75)}
								TextSize={9}
								TextXAlignment="Left"
								TextWrapped={true}
								BackgroundTransparency={1}
							/>
						</frame>
					)}
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
						Text="Select an inspection result to view metadata"
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

export default withHooksPure(InspectionMetadata);
