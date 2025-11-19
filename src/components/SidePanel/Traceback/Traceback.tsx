import Container from "components/Container";
import Roact from "@rbxts/roact";
import TitleBar from "../components/TitleBar";
import { useSidePanelContext } from "../use-side-panel-context";
import { describeFunction, stringifyFunctionSignature } from "utils/function-util";
import { selectTracebackCallStack } from "reducers/traceback";
import { selectSignalSelected } from "reducers/remote-log";
import { useRootSelector } from "hooks/use-root-store";
import { withHooksPure } from "@rbxts/roact-hooked";
import { formatEscapes } from "utils/format-escapes";

interface TracebackFrameProps {
	fn: Callback;
	index: number;
	isRemoteCaller: boolean;
}

function getRemoteTypeName(remote: Instance): string {
	if (remote.IsA("RemoteEvent")) {
		return "RemoteEvent (FireServer)";
	} else if (remote.IsA("RemoteFunction")) {
		return "RemoteFunction (InvokeServer)";
	} else if (remote.IsA("BindableEvent")) {
		return "BindableEvent (Fire)";
	} else if (remote.IsA("BindableFunction")) {
		return "BindableFunction (Invoke)";
	}
	return "Unknown";
}

function TracebackFrame({ fn, index, isRemoteCaller }: TracebackFrameProps) {
	const description = describeFunction(fn);
	const signature = stringifyFunctionSignature(fn);

	return (
		<frame
			AutomaticSize="Y"
			Size={new UDim2(1, 0, 0, 0)}
			BackgroundColor3={isRemoteCaller ? new Color3(0.2, 0.5, 0.2) : new Color3(1, 1, 1)}
			BackgroundTransparency={isRemoteCaller ? 0.85 : 0.95}
			BorderSizePixel={0}
			LayoutOrder={index}
		>
			<uilistlayout FillDirection="Vertical" Padding={new UDim(0, 2)} VerticalAlignment="Top" />

			<uipadding
				PaddingLeft={new UDim(0, 8)}
				PaddingRight={new UDim(0, 8)}
				PaddingTop={new UDim(0, 4)}
				PaddingBottom={new UDim(0, 4)}
			/>

			{/* Signature */}
			<textlabel
				AutomaticSize="Y"
				Size={new UDim2(1, -16, 0, 0)}
				Text={isRemoteCaller ? `→ ${signature} ←` : signature}
				Font="Gotham"
				TextColor3={new Color3(1, 1, 1)}
				TextSize={11}
				TextXAlignment="Left"
				TextWrapped={true}
				BackgroundTransparency={1}
			/>

			{/* Source file */}
			<textlabel
				AutomaticSize="Y"
				Size={new UDim2(1, -16, 0, 0)}
				Text={formatEscapes(description.source)}
				Font="Gotham"
				TextColor3={new Color3(0.7, 0.7, 0.7)}
				TextSize={9}
				TextXAlignment="Left"
				TextWrapped={true}
				BackgroundTransparency={1}
			/>
		</frame>
	);
}

function Traceback() {
	const { lowerHidden, setLowerHidden, lowerSize, lowerPosition } = useSidePanelContext();
	const callStack = useRootSelector(selectTracebackCallStack);
	const signal = useRootSelector(selectSignalSelected);

	const isEmpty = callStack.size() === 0;

	return (
		<Container size={lowerSize} position={lowerPosition}>
			<TitleBar
				caption={`Traceback (${callStack.size()})`}
				hidden={lowerHidden}
				toggleHidden={() => setLowerHidden(!lowerHidden)}
			/>

			{!isEmpty && signal ? (
				<scrollingframe
					Size={new UDim2(1, 0, 1, -30)}
					Position={new UDim2(0, 0, 0, 30)}
					BorderSizePixel={0}
					BackgroundTransparency={1}
					ScrollBarThickness={8}
					ScrollBarImageTransparency={0.7}
					AutomaticCanvasSize="Y"
				>
					{/* Event Type Header */}
					<frame
						AutomaticSize="Y"
						Size={new UDim2(1, -8, 0, 0)}
						BackgroundColor3={new Color3(0.15, 0.35, 0.6)}
						BackgroundTransparency={0.85}
						BorderSizePixel={0}
						LayoutOrder={-2}
					>
						<uilistlayout FillDirection="Vertical" Padding={new UDim(0, 2)} VerticalAlignment="Top" />

						<uipadding
							PaddingLeft={new UDim(0, 8)}
							PaddingRight={new UDim(0, 8)}
							PaddingTop={new UDim(0, 6)}
							PaddingBottom={new UDim(0, 6)}
						/>

						<textlabel
							AutomaticSize="Y"
							Size={new UDim2(1, -16, 0, 0)}
							Text={`Event Type: ${getRemoteTypeName(signal.remote)}`}
							Font="GothamBold"
							TextColor3={new Color3(0.9, 0.9, 1)}
							TextSize={11}
							TextXAlignment="Left"
							BackgroundTransparency={1}
						/>

						<textlabel
							AutomaticSize="Y"
							Size={new UDim2(1, -16, 0, 0)}
							Text={`Remote: ${formatEscapes(signal.name)}`}
							Font="Gotham"
							TextColor3={new Color3(0.8, 0.8, 0.9)}
							TextSize={10}
							TextXAlignment="Left"
							TextWrapped={true}
							BackgroundTransparency={1}
						/>

						{signal.isActor && (
							<textlabel
								AutomaticSize="Y"
								Size={new UDim2(1, -16, 0, 0)}
								Text="Called from Actor"
								Font="Gotham"
								TextColor3={new Color3(1, 0.8, 0.3)}
								TextSize={9}
								TextXAlignment="Left"
								BackgroundTransparency={1}
							/>
						)}
					</frame>

					<uilistlayout
						FillDirection="Vertical"
						VerticalAlignment="Top"
						SortOrder="LayoutOrder"
						Padding={new UDim(0, 2)}
					/>

					<uipadding
						PaddingLeft={new UDim(0, 4)}
						PaddingRight={new UDim(0, 4)}
						PaddingTop={new UDim(0, 4)}
						PaddingBottom={new UDim(0, 4)}
					/>

					{callStack.map((fn, index) => (
						<TracebackFrame fn={fn} index={index} isRemoteCaller={index === callStack.size() - 1} />
					))}
				</scrollingframe>
			) : (
				<frame
					Size={new UDim2(1, 0, 1, -30)}
					Position={new UDim2(0, 0, 0, 30)}
					BackgroundColor3={new Color3(1, 1, 1)}
					BackgroundTransparency={0.98}
					BorderSizePixel={0}
				>
					<textlabel
						AnchorPoint={new Vector2(0.5, 0.5)}
						Position={new UDim2(0.5, 0, 0.5, 0)}
						Size={new UDim2(1, -20, 1, 0)}
						Text="Select a signal and click Traceback to view details"
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

export default withHooksPure(Traceback);
