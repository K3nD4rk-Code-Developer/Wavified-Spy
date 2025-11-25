import Roact from "@rbxts/roact";
import RowCaption from "./RowCaption";
import RowDoubleCaption from "./RowDoubleCaption";
import RowLine from "./RowLine";
import { Signal, OutgoingSignal, stringifySignalTraceback } from "reducers/remote-log";
import { codify } from "utils/codify";
import { describeFunction, stringifyFunctionSignature } from "utils/function-util";
import { formatEscapes } from "utils/format-escapes";
import { getInstancePath } from "utils/instance-util";
import { useMemo, withHooksPure } from "@rbxts/roact-hooked";

interface Props {
	signal: Signal;
}

function stringifyTypesAndValues(list: Record<number, unknown>) {
	const types: string[] = [];
	const values: string[] = [];

	for (const [index, value] of pairs(list)) {
		if ((index as number) > 12) {
			types.push("...");
			values.push("...");
			break;
		}
		if (typeIs(value, "Instance")) {
			types.push(value.ClassName);
		} else {
			types.push(typeOf(value));
		}
		values.push(formatEscapes(codify(value, -1).sub(1, 256)));
	}

	return [types, values] as const;
}

function RowBody({ signal }: Props) {
	const isOutgoing = signal.direction === "outgoing";
	const outgoingSignal = isOutgoing ? (signal as OutgoingSignal & { direction: "outgoing" }) : undefined;

	const description = useMemo(() => {
		if (outgoingSignal?.callback) {
			return describeFunction(outgoingSignal.callback);
		}
		return { source: "N/A (incoming signal)" };
	}, []);

	const tracebackNames = useMemo(() => {
		if (outgoingSignal) {
			return stringifySignalTraceback(outgoingSignal);
		}
		return ["N/A (incoming signal)"];
	}, []);

	const [parameterTypes, parameterValues] = useMemo(() => stringifyTypesAndValues(signal.parameters), []);
	const [returnTypes, returnValues] = useMemo(() => {
		if (outgoingSignal?.returns) {
			return stringifyTypesAndValues(outgoingSignal.returns);
		}
		return [["N/A"], ["N/A"]];
	}, []);

	return (
		<>
			<RowLine />

			<frame
				AutomaticSize="Y"
				Size={new UDim2(1, 0, 0, 0)}
				BackgroundColor3={new Color3(1, 1, 1)}
				BackgroundTransparency={0.98}
				BorderSizePixel={0}
			>
				<RowCaption text="Direction" description={isOutgoing ? "Outgoing (Client → Server)" : "Incoming (Server → Client)"} wrapped />
				<RowCaption text="Remote name" description={formatEscapes(signal.name)} wrapped />
				<RowCaption text="Remote location" description={formatEscapes(signal.path)} wrapped />
				<RowCaption
					text="Remote caller"
					description={signal.caller ? formatEscapes(getInstancePath(signal.caller)) : isOutgoing ? "No script found" : "Server"}
					wrapped
				/>
				<RowCaption
					text="Called from Actor"
					description={signal.isActor ? "Yes" : "No"}
				/>

				<uipadding
					PaddingLeft={new UDim(0, 58)}
					PaddingRight={new UDim(0, 58)}
					PaddingTop={new UDim(0, 6)}
					PaddingBottom={new UDim(0, 6)}
				/>
				<uilistlayout FillDirection="Vertical" Padding={new UDim()} VerticalAlignment="Top" />
			</frame>

			{parameterTypes.size() > 0 && (
				<>
					<RowLine />

					<frame
						AutomaticSize="Y"
						Size={new UDim2(1, 0, 0, 0)}
						BackgroundColor3={new Color3(1, 1, 1)}
						BackgroundTransparency={0.98}
						BorderSizePixel={0}
					>
						<RowDoubleCaption
							text={isOutgoing ? "Parameters" : "Received Data"}
							hint={parameterTypes.join("\n")}
							description={parameterValues.join("\n")}
						/>
						{isOutgoing && outgoingSignal?.returns && (
							<RowDoubleCaption
								text="Returns"
								hint={returnTypes.join("\n")}
								description={returnValues.join("\n")}
							/>
						)}

						<uipadding
							PaddingLeft={new UDim(0, 58)}
							PaddingRight={new UDim(0, 58)}
							PaddingTop={new UDim(0, 6)}
							PaddingBottom={new UDim(0, 6)}
						/>
						<uilistlayout FillDirection="Vertical" Padding={new UDim()} VerticalAlignment="Top" />
					</frame>
				</>
			)}

			{isOutgoing && outgoingSignal && (
				<>
					<RowLine />

					<imagelabel
						AutomaticSize="Y"
						Image={"rbxassetid://9913871236"}
						ImageColor3={new Color3(1, 1, 1)}
						ImageTransparency={0.98}
						ScaleType="Slice"
						SliceCenter={new Rect(4, 4, 4, 4)}
						Size={new UDim2(1, 0, 0, 0)}
						BackgroundTransparency={1}
					>
						<RowCaption text="Signature" description={outgoingSignal.callback ? stringifyFunctionSignature(outgoingSignal.callback) : "N/A"} wrapped />
						<RowCaption text="Source" description={description.source} wrapped />
						<RowCaption text="Traceback" wrapped description={tracebackNames.join("\n")} />

						<uipadding
							PaddingLeft={new UDim(0, 58)}
							PaddingRight={new UDim(0, 58)}
							PaddingTop={new UDim(0, 6)}
							PaddingBottom={new UDim(0, 6)}
						/>
						<uilistlayout FillDirection="Vertical" Padding={new UDim()} VerticalAlignment="Top" />
					</imagelabel>
				</>
			)}
		</>
	);
}

export default withHooksPure(RowBody);
