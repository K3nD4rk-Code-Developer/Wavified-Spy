import Button from "components/Button";
import Container from "components/Container";
import Roact from "@rbxts/roact";
import { withHooksPure } from "@rbxts/roact-hooked";
import { useRootDispatch, useRootSelector } from "hooks/use-root-store";
import { selectNoActors } from "reducers/remote-log";
import { toggleNoActors } from "reducers/remote-log";

function Settings() {
	const dispatch = useRootDispatch();
	const noActors = useRootSelector(selectNoActors);

	const handleToggle = () => {
		dispatch(toggleNoActors());
	};

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
				<uipadding PaddingLeft={new UDim(0, 20)} PaddingRight={new UDim(0, 20)} PaddingTop={new UDim(0, 20)} />
				<uilistlayout
					FillDirection={Enum.FillDirection.Vertical}
					HorizontalAlignment={Enum.HorizontalAlignment.Left}
					Padding={new UDim(0, 16)}
				/>

				{/* Settings Title */}
				<textlabel
					Text="Settings"
					TextSize={24}
					Font="GothamBold"
					TextColor3={new Color3(1, 1, 1)}
					Size={new UDim2(1, 0, 0, 30)}
					BackgroundTransparency={1}
					TextXAlignment="Left"
					TextYAlignment="Top"
				/>

				{/* Actor Detection Setting */}
				<frame Size={new UDim2(1, 0, 0, 70)} BackgroundTransparency={1}>
					<uilistlayout
						FillDirection={Enum.FillDirection.Horizontal}
						VerticalAlignment={Enum.VerticalAlignment.Center}
						Padding={new UDim(0, 12)}
					/>

					{/* Setting Label */}
					<frame Size={new UDim2(1, -70, 1, 0)} BackgroundTransparency={1}>
						<uilistlayout
							FillDirection={Enum.FillDirection.Vertical}
							HorizontalAlignment={Enum.HorizontalAlignment.Left}
							Padding={new UDim(0, 4)}
						/>

						<textlabel
							Text="Ignore Actor Remotes"
							TextSize={16}
							Font="GothamBold"
							TextColor3={new Color3(1, 1, 1)}
							Size={new UDim2(1, 0, 0, 20)}
							BackgroundTransparency={1}
							TextXAlignment="Left"
							TextYAlignment="Center"
						/>

						<textlabel
							Text="When enabled, remote calls from scripts running inside Actors will be ignored and not logged"
							TextSize={12}
							Font="Gotham"
							TextColor3={new Color3(0.7, 0.7, 0.7)}
							Size={new UDim2(1, 0, 0, 36)}
							BackgroundTransparency={1}
							TextXAlignment="Left"
							TextYAlignment="Top"
							TextWrapped={true}
						/>
					</frame>

					{/* Toggle Switch */}
					<Button
						onClick={handleToggle}
						size={new UDim2(0, 50, 0, 28)}
						background={noActors ? new Color3(0.3, 0.7, 0.3) : new Color3(0.3, 0.3, 0.3)}
						transparency={0}
						cornerRadius={new UDim(0, 14)}
					>
						{/* Toggle Thumb */}
						<frame
							Size={new UDim2(0, 22, 0, 22)}
							Position={noActors ? new UDim2(1, -25, 0.5, 0) : new UDim2(0, 3, 0.5, 0)}
							AnchorPoint={new Vector2(0, 0.5)}
							BackgroundColor3={new Color3(1, 1, 1)}
							BorderSizePixel={0}
						>
							<uicorner CornerRadius={new UDim(0, 11)} />
						</frame>
					</Button>
				</frame>
			</scrollingframe>
		</Container>
	);
}

export default withHooksPure(Settings);
