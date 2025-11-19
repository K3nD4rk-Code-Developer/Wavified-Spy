import Button from "components/Button";
import Container from "components/Container";
import Roact from "@rbxts/roact";
import { withHooksPure } from "@rbxts/roact-hooked";
import { useRootDispatch, useRootSelector } from "hooks/use-root-store";
import {
	selectShowRemoteEvents,
	selectShowRemoteFunctions,
	selectShowBindableEvents,
	selectShowBindableFunctions,
	selectPathNotation,
} from "reducers/remote-log";
import {
	toggleShowRemoteEvents,
	toggleShowRemoteFunctions,
	toggleShowBindableEvents,
	toggleShowBindableFunctions,
	setPathNotation,
} from "reducers/remote-log";
import { PathNotation } from "reducers/remote-log/model";

function Settings() {
	const dispatch = useRootDispatch();
	const showRemoteEvents = useRootSelector(selectShowRemoteEvents);
	const showRemoteFunctions = useRootSelector(selectShowRemoteFunctions);
	const showBindableEvents = useRootSelector(selectShowBindableEvents);
	const showBindableFunctions = useRootSelector(selectShowBindableFunctions);
	const pathNotation = useRootSelector(selectPathNotation);

	const handleToggleRemoteEvents = () => {
		dispatch(toggleShowRemoteEvents());
	};

	const handleToggleRemoteFunctions = () => {
		dispatch(toggleShowRemoteFunctions());
	};

	const handleToggleBindableEvents = () => {
		dispatch(toggleShowBindableEvents());
	};

	const handleToggleBindableFunctions = () => {
		dispatch(toggleShowBindableFunctions());
	};

	const handlePathNotationChange = (notation: PathNotation) => {
		dispatch(setPathNotation(notation));
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

				{/* Filter Options Section */}
				<textlabel
					Text="Filter Options"
					TextSize={18}
					Font="GothamBold"
					TextColor3={new Color3(1, 1, 1)}
					Size={new UDim2(1, 0, 0, 24)}
					BackgroundTransparency={1}
					TextXAlignment="Left"
					TextYAlignment="Top"
				/>

				{/* RemoteEvent Setting */}
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
							Text="Show RemoteEvents"
							TextSize={16}
							Font="GothamBold"
							TextColor3={new Color3(1, 1, 1)}
							Size={new UDim2(1, 0, 0, 20)}
							BackgroundTransparency={1}
							TextXAlignment="Left"
							TextYAlignment="Center"
						/>

						<textlabel
							Text="When enabled, RemoteEvent calls will be logged and displayed"
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
						onClick={handleToggleRemoteEvents}
						size={new UDim2(0, 50, 0, 28)}
						background={showRemoteEvents ? new Color3(0.3, 0.7, 0.3) : new Color3(0.3, 0.3, 0.3)}
						transparency={0}
						cornerRadius={new UDim(0, 14)}
					>
						{/* Toggle Thumb */}
						<frame
							Size={new UDim2(0, 22, 0, 22)}
							Position={showRemoteEvents ? new UDim2(1, -25, 0.5, 0) : new UDim2(0, 3, 0.5, 0)}
							AnchorPoint={new Vector2(0, 0.5)}
							BackgroundColor3={new Color3(1, 1, 1)}
							BorderSizePixel={0}
						>
							<uicorner CornerRadius={new UDim(0, 11)} />
						</frame>
					</Button>
				</frame>

				{/* RemoteFunction Setting */}
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
							Text="Show RemoteFunctions"
							TextSize={16}
							Font="GothamBold"
							TextColor3={new Color3(1, 1, 1)}
							Size={new UDim2(1, 0, 0, 20)}
							BackgroundTransparency={1}
							TextXAlignment="Left"
							TextYAlignment="Center"
						/>

						<textlabel
							Text="When enabled, RemoteFunction calls will be logged and displayed"
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
						onClick={handleToggleRemoteFunctions}
						size={new UDim2(0, 50, 0, 28)}
						background={showRemoteFunctions ? new Color3(0.3, 0.7, 0.3) : new Color3(0.3, 0.3, 0.3)}
						transparency={0}
						cornerRadius={new UDim(0, 14)}
					>
						{/* Toggle Thumb */}
						<frame
							Size={new UDim2(0, 22, 0, 22)}
							Position={showRemoteFunctions ? new UDim2(1, -25, 0.5, 0) : new UDim2(0, 3, 0.5, 0)}
							AnchorPoint={new Vector2(0, 0.5)}
							BackgroundColor3={new Color3(1, 1, 1)}
							BorderSizePixel={0}
						>
							<uicorner CornerRadius={new UDim(0, 11)} />
						</frame>
					</Button>
				</frame>

				{/* BindableEvent Setting */}
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
							Text="Show BindableEvents"
							TextSize={16}
							Font="GothamBold"
							TextColor3={new Color3(1, 1, 1)}
							Size={new UDim2(1, 0, 0, 20)}
							BackgroundTransparency={1}
							TextXAlignment="Left"
							TextYAlignment="Center"
						/>

						<textlabel
							Text="When enabled, BindableEvent calls will be logged and displayed"
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
						onClick={handleToggleBindableEvents}
						size={new UDim2(0, 50, 0, 28)}
						background={showBindableEvents ? new Color3(0.3, 0.7, 0.3) : new Color3(0.3, 0.3, 0.3)}
						transparency={0}
						cornerRadius={new UDim(0, 14)}
					>
						{/* Toggle Thumb */}
						<frame
							Size={new UDim2(0, 22, 0, 22)}
							Position={showBindableEvents ? new UDim2(1, -25, 0.5, 0) : new UDim2(0, 3, 0.5, 0)}
							AnchorPoint={new Vector2(0, 0.5)}
							BackgroundColor3={new Color3(1, 1, 1)}
							BorderSizePixel={0}
						>
							<uicorner CornerRadius={new UDim(0, 11)} />
						</frame>
					</Button>
				</frame>

				{/* BindableFunction Setting */}
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
							Text="Show BindableFunctions"
							TextSize={16}
							Font="GothamBold"
							TextColor3={new Color3(1, 1, 1)}
							Size={new UDim2(1, 0, 0, 20)}
							BackgroundTransparency={1}
							TextXAlignment="Left"
							TextYAlignment="Center"
						/>

						<textlabel
							Text="When enabled, BindableFunction calls will be logged and displayed"
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
						onClick={handleToggleBindableFunctions}
						size={new UDim2(0, 50, 0, 28)}
						background={showBindableFunctions ? new Color3(0.3, 0.7, 0.3) : new Color3(0.3, 0.3, 0.3)}
						transparency={0}
						cornerRadius={new UDim(0, 14)}
					>
						{/* Toggle Thumb */}
						<frame
							Size={new UDim2(0, 22, 0, 22)}
							Position={showBindableFunctions ? new UDim2(1, -25, 0.5, 0) : new UDim2(0, 3, 0.5, 0)}
							AnchorPoint={new Vector2(0, 0.5)}
							BackgroundColor3={new Color3(1, 1, 1)}
							BorderSizePixel={0}
						>
							<uicorner CornerRadius={new UDim(0, 11)} />
						</frame>
					</Button>
				</frame>

				{/* Path Notation Setting */}
				<frame Size={new UDim2(1, 0, 0, 100)} BackgroundTransparency={1}>
					<uilistlayout
						FillDirection={Enum.FillDirection.Vertical}
						HorizontalAlignment={Enum.HorizontalAlignment.Left}
						Padding={new UDim(0, 8)}
					/>

					{/* Setting Label */}
					<frame Size={new UDim2(1, 0, 0, 56)} BackgroundTransparency={1}>
						<uilistlayout
							FillDirection={Enum.FillDirection.Vertical}
							HorizontalAlignment={Enum.HorizontalAlignment.Left}
							Padding={new UDim(0, 4)}
						/>

						<textlabel
							Text="Path Notation Style"
							TextSize={16}
							Font="GothamBold"
							TextColor3={new Color3(1, 1, 1)}
							Size={new UDim2(1, 0, 0, 20)}
							BackgroundTransparency={1}
							TextXAlignment="Left"
							TextYAlignment="Center"
						/>

						<textlabel
							Text="Choose how to access instances in generated scripts (dots, WaitForChild, or FindFirstChild)"
							TextSize={12}
							Font="Gotham"
							TextColor3={new Color3(0.7, 0.7, 0.7)}
							Size={new UDim2(1, 0, 0, 32)}
							BackgroundTransparency={1}
							TextXAlignment="Left"
							TextYAlignment="Top"
							TextWrapped={true}
						/>
					</frame>

					{/* Buttons */}
					<frame Size={new UDim2(1, 0, 0, 36)} BackgroundTransparency={1}>
						<uilistlayout
							FillDirection={Enum.FillDirection.Horizontal}
							HorizontalAlignment={Enum.HorizontalAlignment.Left}
							Padding={new UDim(0, 8)}
						/>

						<Button
							onClick={() => handlePathNotationChange(PathNotation.Dot)}
							size={new UDim2(0, 120, 0, 32)}
							background={pathNotation === PathNotation.Dot ? new Color3(0.3, 0.7, 0.3) : new Color3(0.2, 0.2, 0.2)}
							transparency={0}
							cornerRadius={new UDim(0, 6)}
						>
							<textlabel
								Text="Dot (.)"
								TextSize={14}
								Font="GothamBold"
								TextColor3={new Color3(1, 1, 1)}
								Size={new UDim2(1, 0, 1, 0)}
								BackgroundTransparency={1}
								TextXAlignment="Center"
								TextYAlignment="Center"
							/>
						</Button>

						<Button
							onClick={() => handlePathNotationChange(PathNotation.WaitForChild)}
							size={new UDim2(0, 120, 0, 32)}
							background={pathNotation === PathNotation.WaitForChild ? new Color3(0.3, 0.7, 0.3) : new Color3(0.2, 0.2, 0.2)}
							transparency={0}
							cornerRadius={new UDim(0, 6)}
						>
							<textlabel
								Text="WaitForChild"
								TextSize={14}
								Font="GothamBold"
								TextColor3={new Color3(1, 1, 1)}
								Size={new UDim2(1, 0, 1, 0)}
								BackgroundTransparency={1}
								TextXAlignment="Center"
								TextYAlignment="Center"
							/>
						</Button>

						<Button
							onClick={() => handlePathNotationChange(PathNotation.FindFirstChild)}
							size={new UDim2(0, 120, 0, 32)}
							background={pathNotation === PathNotation.FindFirstChild ? new Color3(0.3, 0.7, 0.3) : new Color3(0.2, 0.2, 0.2)}
							transparency={0}
							cornerRadius={new UDim(0, 6)}
						>
							<textlabel
								Text="FindFirstChild"
								TextSize={14}
								Font="GothamBold"
								TextColor3={new Color3(1, 1, 1)}
								Size={new UDim2(1, 0, 1, 0)}
								BackgroundTransparency={1}
								TextXAlignment="Center"
								TextYAlignment="Center"
							/>
						</Button>
					</frame>
				</frame>
			</scrollingframe>
		</Container>
	);
}

export default withHooksPure(Settings);
