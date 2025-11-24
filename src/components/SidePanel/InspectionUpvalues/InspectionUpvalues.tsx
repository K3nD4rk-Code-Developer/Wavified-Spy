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

				{!selectedResult || !selectedResult.rawUpvalues || selectedResult.rawUpvalues.size() === 0 ? (
					<textlabel
						Text={!selectedResult ? "Select a function to view upvalues" : "No upvalues found"}
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
						<textlabel
							Text={`${selectedResult.rawUpvalues.size()} Upvalues`}
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
							selectedResult.rawUpvalues.forEach((value, key) => {
								elements.push(
									<frame
										Key={tostring(key)}
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
											Text={tostring(key)}
											TextSize={10}
											Font="GothamBold"
											TextColor3={new Color3(0.7, 0.9, 1)}
											Size={new UDim2(1, 0, 0, 12)}
											BackgroundTransparency={1}
											TextXAlignment="Left"
											TextYAlignment="Center"
											TextTruncate="AtEnd"
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
							});
							return elements;
						})()}
					</>
				)}
			</scrollingframe>
		</Container>
	);
}

export default withHooksPure(InspectionUpvalues);
