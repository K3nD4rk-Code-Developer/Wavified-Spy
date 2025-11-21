import Container from "components/Container";
import Roact from "@rbxts/roact";
import TitleBar from "../components/TitleBar";
import { useSidePanelContext } from "../use-side-panel-context";
import { describeFunction, stringifyFunctionSignature } from "utils/function-util";
import { selectSignalSelected } from "reducers/remote-log";
import { getInstancePath } from "utils/instance-util";
import { useRootSelector } from "hooks/use-root-store";
import { withHooksPure, useEffect, useRef } from "@rbxts/roact-hooked";
import { formatEscapes } from "utils/format-escapes";

interface FunctionNodeProps {
	fn: Callback;
	index: number;
	totalInStack: number;
	remotePath: string;
	remoteName: string;
}

function FunctionNode({ fn, index, totalInStack, remotePath, remoteName }: FunctionNodeProps) {
	const description = describeFunction(fn);
	const signature = stringifyFunctionSignature(fn);
	const isRemoteCaller = index === totalInStack - 1;
	const level = index + 1;

	return (
		<frame
			AutomaticSize="Y"
			Size={new UDim2(1, 0, 0, 0)}
			BackgroundColor3={isRemoteCaller ? new Color3(0.15, 0.4, 0.15) : new Color3(1, 1, 1)}
			BackgroundTransparency={isRemoteCaller ? 0.8 : 0.93}
			BorderSizePixel={0}
			LayoutOrder={index}
		>
			<uilistlayout FillDirection="Vertical" Padding={new UDim(0, 2)} VerticalAlignment="Top" />

			<uipadding
				PaddingLeft={new UDim(0, 12 + index * 8)}
				PaddingRight={new UDim(0, 8)}
				PaddingTop={new UDim(0, 6)}
				PaddingBottom={new UDim(0, 6)}
			/>

			{/* Level indicator */}
			<textlabel
				AutomaticSize="Y"
				Size={new UDim2(1, -16, 0, 0)}
				Text={`${isRemoteCaller ? "└─ " : "├─ "}Level ${level}${isRemoteCaller ? " (Remote Caller)" : ""}`}
				Font="Gotham"
				TextColor3={new Color3(0.6, 0.6, 0.6)}
				TextSize={10}
				TextXAlignment="Left"
				BackgroundTransparency={1}
			/>

			{/* Function signature */}
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
				TextColor3={new Color3(0.75, 0.75, 0.75)}
				TextSize={9}
				TextXAlignment="Left"
				TextWrapped={true}
				BackgroundTransparency={1}
			/>

			{isRemoteCaller && (
				<>
					{/* Divider */}
					<frame
						Size={new UDim2(1, -16, 0, 1)}
						BackgroundColor3={new Color3(0.2, 0.5, 0.2)}
						BackgroundTransparency={0.5}
						BorderSizePixel={0}
					/>

					{/* Remote being called */}
					<textlabel
						AutomaticSize="Y"
						Size={new UDim2(1, -16, 0, 0)}
						Text={`Calls Remote: ${formatEscapes(remoteName)}`}
						Font="Gotham"
						TextColor3={new Color3(0.3, 0.7, 0.3)}
						TextSize={10}
						TextXAlignment="Left"
						TextWrapped={true}
						BackgroundTransparency={1}
					/>

					<textlabel
						AutomaticSize="Y"
						Size={new UDim2(1, -16, 0, 0)}
						Text={`Path: ${formatEscapes(remotePath)}`}
						Font="Gotham"
						TextColor3={new Color3(0.3, 0.7, 0.3)}
						TextSize={9}
						TextXAlignment="Left"
						TextWrapped={true}
						BackgroundTransparency={1}
					/>
				</>
			)}
		</frame>
	);
}

function FunctionTree() {
	const { setUpperHidden, upperHidden, upperSize, setUpperHeight } = useSidePanelContext();
	const signal = useRootSelector(selectSignalSelected);
	const scrollFrameRef = useRef<ScrollingFrame>();

	const isEmpty = !signal || signal.traceback.size() === 0;

	// Auto-resize panel based on content
	useEffect(() => {
		const frame = scrollFrameRef.current;
		if (!frame || isEmpty) return;

		const updateHeight = () => {
			const contentHeight = frame.AbsoluteCanvasSize.Y;
			const titleBarHeight = 30;
			const padding = 20;
			// Cap at 400px max, min 150px
			const desiredHeight = math.clamp(contentHeight + titleBarHeight + padding, 150, 400);
			setUpperHeight(desiredHeight);
		};

		// Initial update
		task.defer(updateHeight);

		// Monitor for changes
		const connection = frame.GetPropertyChangedSignal("AbsoluteCanvasSize").Connect(updateHeight);

		return () => connection.Disconnect();
	}, [isEmpty, signal]);

	return (
		<Container size={upperSize}>
			<TitleBar
				caption={`Function Tree${signal ? ` (${signal.traceback.size()})` : ""}`}
				hidden={upperHidden}
				toggleHidden={() => setUpperHidden(!upperHidden)}
			/>

			{!isEmpty && signal ? (
				<scrollingframe
					Ref={scrollFrameRef}
					Size={new UDim2(1, 0, 1, -30)}
					Position={new UDim2(0, 0, 0, 30)}
					BorderSizePixel={0}
					BackgroundTransparency={1}
					ScrollBarThickness={1}
					ScrollBarImageTransparency={0.6}
					AutomaticCanvasSize="Y"
				>
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

					{signal.traceback.map((fn, index) => (
						<FunctionNode
							fn={fn}
							index={index}
							totalInStack={signal.traceback.size()}
							remotePath={signal.path}
							remoteName={signal.name}
						/>
					))}
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
						Text="Select a signal to view function tree"
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

export default withHooksPure(FunctionTree);
