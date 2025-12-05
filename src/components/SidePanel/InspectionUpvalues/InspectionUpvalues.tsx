import Container from "components/Container";
import Roact from "@rbxts/roact";
import TitleBar from "../components/TitleBar";
import { useSidePanelContext } from "../use-side-panel-context";
import { useRootSelector } from "hooks/use-root-store";
import { selectInspectionResultSelected } from "reducers/remote-log";
import { withHooksPure } from "@rbxts/roact-hooked";

function InspectionUpvalues() {
	const { middleSize, middlePosition, middleHidden, setMiddleHidden } = useSidePanelContext();
	const selectedResult = useRootSelector(selectInspectionResultSelected);

	const isEmpty = !selectedResult || !selectedResult.rawUpvalues || selectedResult.rawUpvalues.size() === 0;
	const upvalueCount = selectedResult?.rawUpvalues?.size() ?? 0;

	return (
		<Container size={middleSize} position={middlePosition} clipChildren={true}>
			<TitleBar
				caption={`Upvalues${upvalueCount > 0 ? ` (${upvalueCount})` : ""}`}
				hidden={middleHidden}
				toggleHidden={() => setMiddleHidden(!middleHidden)}
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

					{(() => {
						const elements: Roact.Element[] = [];
						let index = 0;
						selectedResult!.rawUpvalues!.forEach((value, key) => {
							elements.push(
								<frame
									Key={tostring(key)}
									AutomaticSize="Y"
									Size={new UDim2(1, -8, 0, 0)}
									BackgroundColor3={new Color3(1, 1, 1)}
									BackgroundTransparency={0.95}
									BorderSizePixel={0}
									LayoutOrder={index}
								>
									<uilistlayout FillDirection="Vertical" Padding={new UDim(0, 2)} VerticalAlignment="Top" />
									<uipadding PaddingLeft={new UDim(0, 8)} PaddingRight={new UDim(0, 8)} PaddingTop={new UDim(0, 4)} PaddingBottom={new UDim(0, 4)} />

									<textlabel
										AutomaticSize="Y"
										Size={new UDim2(1, -16, 0, 0)}
										Text={tostring(key)}
										Font="GothamBold"
										TextColor3={new Color3(0.7, 0.9, 1)}
										TextSize={10}
										TextXAlignment="Left"
										BackgroundTransparency={1}
									/>

									<textlabel
										AutomaticSize="Y"
										Size={new UDim2(1, -16, 0, 0)}
										Text={`${typeOf(value)}: ${tostring(value).sub(1, 150)}`}
										Font="Gotham"
										TextColor3={new Color3(0.8, 0.8, 0.8)}
										TextSize={9}
										TextXAlignment="Left"
										TextWrapped={true}
										BackgroundTransparency={1}
									/>
								</frame>
							);
							index++;
						});
						return elements;
					})()}
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
						Text={!selectedResult ? "Select a function to view upvalues" : "No upvalues found"}
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

export default withHooksPure(InspectionUpvalues);
