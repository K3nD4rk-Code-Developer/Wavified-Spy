import Button from "components/Button";
import Container from "components/Container";
import Roact from "@rbxts/roact";
import { withHooksPure, useState, useEffect } from "@rbxts/roact-hooked";
import { useRootDispatch, useRootSelector } from "hooks/use-root-store";
import { selectInspectionResultSelected, selectMaxInspectionResults } from "reducers/remote-log";
import { InspectionResult } from "reducers/remote-log/model";
import { setInspectionResultSelected } from "reducers/remote-log/actions";
import { useSingleMotor } from "@rbxts/roact-hooked-plus";
import { Spring, Instant } from "@rbxts/flipper";

// Declare exploit environment functions
declare const getgc: (() => unknown[]) | undefined;
declare const getupvalues: ((func: Callback) => Map<string, unknown>) | undefined;
declare const getconstants: ((func: Callback) => unknown[]) | undefined;
declare const getinfo: ((func: Callback) => { name?: string; source?: string; short_src?: string; what?: string; nups?: number; linedefined?: number; lastlinedefined?: number }) | undefined;

enum ScannerType {
	None = "none",
	Upvalue = "upvalue",
	Constant = "constant",
	Script = "script",
	Module = "module",
	Closure = "closure",
}

interface ScannerButtonProps {
	scanner: { type: ScannerType; name: string; icon: string; desc: string };
	isSelected: boolean;
	onClick: () => void;
}

const SCANNER_DEFAULT = new Spring(0, { frequency: 6 });
const SCANNER_HOVERED = new Spring(0.05, { frequency: 6 });
const SCANNER_PRESSED = new Instant(0.08);
const SCANNER_SELECTED = new Spring(0.12, { frequency: 6 });

function ScannerButton({ scanner, isSelected, onClick }: ScannerButtonProps) {
	const [background, setBackground] = useSingleMotor(isSelected ? 0.12 : 0);

	useEffect(() => {
		if (isSelected) {
			setBackground(SCANNER_SELECTED);
		} else {
			setBackground(SCANNER_DEFAULT);
		}
	}, [isSelected]);

	return (
		<Button
			Key={scanner.type}
			onClick={onClick}
			onPress={() => setBackground(SCANNER_PRESSED)}
			onHover={() => !isSelected && setBackground(SCANNER_HOVERED)}
			onHoverEnd={() => !isSelected && setBackground(SCANNER_DEFAULT)}
			size={new UDim2(0.32, 0, 0, 64)}
			background={background.map((value) => new Color3(value, value, value))}
			transparency={0}
			cornerRadius={new UDim(0, 10)}
		>
			<uipadding PaddingLeft={new UDim(0, 12)} PaddingRight={new UDim(0, 12)} />
			<uilistlayout
				FillDirection={Enum.FillDirection.Horizontal}
				VerticalAlignment={Enum.VerticalAlignment.Center}
				Padding={new UDim(0, 10)}
			/>

			<imagelabel
				Image={scanner.icon}
				Size={new UDim2(0, 32, 0, 32)}
				BackgroundTransparency={1}
				ImageColor3={new Color3(1, 1, 1)}
			/>

			<frame Size={new UDim2(1, -42, 1, 0)} BackgroundTransparency={1}>
				<uilistlayout
					FillDirection={Enum.FillDirection.Vertical}
					VerticalAlignment={Enum.VerticalAlignment.Center}
					Padding={new UDim(0, 3)}
				/>

				<textlabel
					Text={scanner.name}
					TextSize={13}
					Font="GothamBold"
					TextColor3={new Color3(1, 1, 1)}
					Size={new UDim2(1, 0, 0, 16)}
					BackgroundTransparency={1}
					TextXAlignment="Left"
					TextYAlignment="Center"
					TextTruncate="AtEnd"
				/>

				<textlabel
					Text={scanner.desc}
					TextSize={10}
					Font="Gotham"
					TextColor3={new Color3(0.7, 0.7, 0.7)}
					Size={new UDim2(1, 0, 0, 13)}
					BackgroundTransparency={1}
					TextXAlignment="Left"
					TextYAlignment="Center"
					TextTruncate="AtEnd"
				/>
			</frame>

			{isSelected && <uistroke Color={new Color3(0.5, 0.7, 1)} Thickness={2} Transparency={0} />}
		</Button>
	);
}

interface ResultItemProps {
	result: InspectionResult;
	isSelected: boolean;
	onClick: () => void;
}

const RESULT_DEFAULT = new Spring(0.08, { frequency: 6 });
const RESULT_HOVERED = new Spring(0.10, { frequency: 6 });
const RESULT_PRESSED = new Instant(0.12);
const RESULT_SELECTED = new Spring(0.14, { frequency: 6 });

function ResultItem({ result, isSelected, onClick }: ResultItemProps) {
	const [background, setBackground] = useSingleMotor(isSelected ? 0.14 : 0.08);

	useEffect(() => {
		if (isSelected) {
			setBackground(RESULT_SELECTED);
		} else {
			setBackground(RESULT_DEFAULT);
		}
	}, [isSelected]);

	return (
		<Button
			Key={result.id}
			onClick={onClick}
			onPress={() => setBackground(RESULT_PRESSED)}
			onHover={() => !isSelected && setBackground(RESULT_HOVERED)}
			onHoverEnd={() => !isSelected && setBackground(RESULT_DEFAULT)}
			size={new UDim2(1, -6, 0, 64)}
			background={background.map((value) => new Color3(value, value, value))}
			transparency={0}
			cornerRadius={new UDim(0, 8)}
		>
			<uipadding PaddingLeft={new UDim(0, 12)} PaddingTop={new UDim(0, 8)} PaddingRight={new UDim(0, 12)} />
			<uilistlayout FillDirection={Enum.FillDirection.Vertical} Padding={new UDim(0, 4)} />

			<textlabel
				Text={result.name}
				TextSize={14}
				Font="GothamBold"
				TextColor3={new Color3(1, 1, 1)}
				Size={new UDim2(1, 0, 0, 17)}
				BackgroundTransparency={1}
				TextXAlignment="Left"
				TextYAlignment="Center"
				TextTruncate="AtEnd"
			/>

			<textlabel
				Text={`${result.type} • ${result.value ?? "no path"}`}
				TextSize={11}
				Font="Gotham"
				TextColor3={new Color3(0.7, 0.75, 0.8)}
				Size={new UDim2(1, 0, 0, 14)}
				BackgroundTransparency={1}
				TextXAlignment="Left"
				TextYAlignment="Center"
				TextTruncate="AtEnd"
			/>

			{result.details !== undefined && (
				<textlabel
					Text={result.details}
					TextSize={10}
					Font="Code"
					TextColor3={new Color3(0.5, 0.5, 0.5)}
					Size={new UDim2(1, 0, 0, 13)}
					BackgroundTransparency={1}
					TextXAlignment="Left"
					TextYAlignment="Center"
					TextTruncate="AtEnd"
				/>
			)}

			{isSelected && <uistroke Color={new Color3(0.5, 0.7, 1)} Thickness={2} Transparency={0} />}
		</Button>
	);
}

function Inspection() {
	const dispatch = useRootDispatch();
	const maxResults = useRootSelector(selectMaxInspectionResults);
	const selectedResult = useRootSelector(selectInspectionResultSelected);
	const [selectedScanner, setSelectedScanner] = useState<ScannerType>(ScannerType.None);
	const [scanResults, setScanResults] = useState<InspectionResult[]>([]);
	const [isScanning, setIsScanning] = useState(false);
	const [searchQuery, setSearchQuery] = useState("");

	const handleScan = (scannerType: ScannerType) => {
		setIsScanning(true);
		setSelectedScanner(scannerType);
		dispatch(setInspectionResultSelected(undefined));
		const results: InspectionResult[] = [];

		try {
			switch (scannerType) {
				case ScannerType.Upvalue: {
					if (getgc && getupvalues) {
						const gc = getgc();
						let count = 0;
						for (const item of gc) {
							if (typeOf(item) === "function") {
								const func = item as Callback;
								const upvalues = getupvalues(func);
								if (upvalues && upvalues.size() > 0) {
									const info = getinfo?.(func);
									let upvalueList = "";
									upvalues.forEach((value, key) => {
										upvalueList += `${key}: ${typeOf(value)}, `;
									});
									results.push({
										id: `upvalue_${count}`,
										name: info?.name ?? `Function_${count}`,
										type: "Function with Upvalues",
										value: `${upvalues.size()} upvalues`,
										details: upvalueList,
										rawFunc: func,
										rawUpvalues: upvalues,
										rawInfo: info,
									});
									count++;
									if (count >= maxResults) break;
								}
							}
						}
					}
					break;
				}
				case ScannerType.Constant: {
					if (getgc && getconstants) {
						const gc = getgc();
						let count = 0;
						for (const item of gc) {
							if (typeOf(item) === "function") {
								const func = item as Callback;
								const constants = getconstants(func);
								if (constants && constants.size() > 0) {
									const info = getinfo?.(func);
									let constantList = "";
									for (const value of constants) {
										constantList += `${tostring(value)}, `;
									}
									results.push({
										id: `constant_${count}`,
										name: info?.name ?? `Function_${count}`,
										type: "Function with Constants",
										value: `${constants.size()} constants`,
										details: constantList.sub(1, math.min(100, constantList.size())),
										rawFunc: func,
										rawConstants: constants,
										rawInfo: info,
									});
									count++;
									if (count >= maxResults) break;
								}
							}
						}
					}
					break;
				}
				case ScannerType.Script: {
					if (getgc) {
						const gc = getgc();
						let count = 0;
						for (const item of gc) {
							if (typeIs(item, "Instance")) {
								const inst = item as Instance;
								if (inst.IsA("LuaSourceContainer")) {
									results.push({
										id: `script_${count}`,
										name: inst.Name,
										type: inst.ClassName,
										value: inst.GetFullName(),
										details: `Parent: ${inst.Parent?.Name ?? "nil"}`,
										rawScript: inst,
									});
									count++;
									if (count >= maxResults) break;
								}
							}
						}
					}
					break;
				}
				case ScannerType.Module: {
					if (getgc) {
						const gc = getgc();
						let count = 0;
						for (const item of gc) {
							if (typeIs(item, "Instance")) {
								const inst = item as Instance;
								if (inst.IsA("ModuleScript")) {
									results.push({
										id: `module_${count}`,
										name: inst.Name,
										type: "ModuleScript",
										value: inst.GetFullName(),
										details: `Parent: ${inst.Parent?.Name ?? "nil"}`,
										rawScript: inst,
									});
									count++;
									if (count >= maxResults) break;
								}
							}
						}
					}
					break;
				}
				case ScannerType.Closure: {
					if (getgc && getinfo) {
						const gc = getgc();
						let count = 0;
						for (const item of gc) {
							if (typeOf(item) === "function") {
								const func = item as Callback;
								const info = getinfo(func);
								if (info) {
									const upvalues = getupvalues?.(func);
									const constants = getconstants?.(func);
									results.push({
										id: `closure_${count}`,
										name: info.name ?? `Closure_${count}`,
										type: info.what ?? "Lua",
										value: info.short_src ?? "unknown",
										details: `Upvalues: ${info.nups ?? 0}, Lines: ${info.linedefined ?? "?"}-${info.lastlinedefined ?? "?"}`,
										rawFunc: func,
										rawInfo: info,
										rawUpvalues: upvalues,
										rawConstants: constants,
									});
									count++;
									if (count >= maxResults) break;
								}
							}
						}
					}
					break;
				}
			}
		} catch (error) {
			results.push({
				id: "error",
				name: "Error",
				type: "Error",
				value: tostring(error),
				details: "Failed to scan",
			});
		}

		setScanResults(results);
		setIsScanning(false);
	};

	const filteredResults = scanResults.filter((result) => {
		if (searchQuery === "") return true;
		const query = searchQuery.lower();
		const nameMatch = result.name.lower().find(query)[0] !== undefined;
		const typeMatch = result.type.lower().find(query)[0] !== undefined;
		const valueMatch = result.value !== undefined && result.value.lower().find(query)[0] !== undefined;
		return nameMatch || typeMatch || valueMatch;
	});

	const scannerInfo = [
		{ type: ScannerType.Upvalue, name: "Upvalue Scanner", icon: "rbxassetid://119937429331234", desc: "Examine function upvalues" },
		{ type: ScannerType.Constant, name: "Constant Scanner", icon: "rbxassetid://86206500190741", desc: "View function constants" },
		{ type: ScannerType.Script, name: "Script Scanner", icon: "rbxassetid://132151602895952", desc: "Find script instances" },
		{ type: ScannerType.Module, name: "Module Scanner", icon: "rbxassetid://95437669844684", desc: "Discover modules" },
		{ type: ScannerType.Closure, name: "Closure Spy", icon: "rbxassetid://107082546858208", desc: "Monitor closures" },
	];
	
	return (
		<Container>
			<scrollingframe
				Size={new UDim2(1, 0, 1, 0)}
				BackgroundTransparency={1}
				BorderSizePixel={0}
				ScrollBarThickness={1}
				ScrollBarImageTransparency={0.6}
				CanvasSize={new UDim2(0, 0, 0, 0)}
				AutomaticCanvasSize={Enum.AutomaticSize.Y}
			>
				<uipadding PaddingLeft={new UDim(0, 20)} PaddingRight={new UDim(0, 20)} PaddingTop={new UDim(0, 20)} PaddingBottom={new UDim(0, 20)} />
				<uilistlayout
					FillDirection={Enum.FillDirection.Vertical}
					HorizontalAlignment={Enum.HorizontalAlignment.Left}
					Padding={new UDim(0, 18)}
				/>

				{/* Header */}
				<frame Size={new UDim2(1, 0, 0, 70)} BackgroundTransparency={1}>
					<uilistlayout FillDirection={Enum.FillDirection.Vertical} Padding={new UDim(0, 6)} />

					<textlabel
						Text="Runtime Inspection"
						TextSize={26}
						Font="GothamBold"
						TextColor3={new Color3(1, 1, 1)}
						Size={new UDim2(1, 0, 0, 32)}
						BackgroundTransparency={1}
						TextXAlignment="Left"
						TextYAlignment="Center"
					/>

					<textlabel
						Text="Select a scanner to begin analyzing runtime data"
						TextSize={13}
						Font="Gotham"
						TextColor3={new Color3(0.6, 0.6, 0.6)}
						Size={new UDim2(1, 0, 0, 32)}
						BackgroundTransparency={1}
						TextXAlignment="Left"
						TextYAlignment="Top"
						TextWrapped={true}
					/>
				</frame>

				{/* Scanner Grid */}
				<frame Size={new UDim2(1, 0, 0, 140)} BackgroundTransparency={1}>
					<uigridlayout
						CellSize={new UDim2(0.32, 0, 0, 64)}
						CellPadding={new UDim2(0.01, 0, 0, 12)}
					/>

					{scannerInfo.map((scanner) => (
						<ScannerButton
							Key={scanner.type}
							scanner={scanner}
							isSelected={selectedScanner === scanner.type}
							onClick={() => handleScan(scanner.type)}
						/>
					))}
				</frame>

				{/* Search and Results */}
				{selectedScanner !== ScannerType.None && (
					<frame Size={new UDim2(1, 0, 0, 0)} BackgroundTransparency={1} AutomaticSize={Enum.AutomaticSize.Y}>
						<uilistlayout FillDirection={Enum.FillDirection.Vertical} Padding={new UDim(0, 12)} />

						{/* Search Bar */}
						<frame Size={new UDim2(1, 0, 0, 66)} BackgroundTransparency={1}>
							<uilistlayout FillDirection={Enum.FillDirection.Vertical} Padding={new UDim(0, 8)} />

							<frame Size={new UDim2(1, 0, 0, 24)} BackgroundTransparency={1}>
								<uilistlayout
									FillDirection={Enum.FillDirection.Horizontal}
									VerticalAlignment={Enum.VerticalAlignment.Center}
									Padding={new UDim(0, 8)}
								/>

								<textlabel
									Text={`Results: ${filteredResults.size()}/${scanResults.size()}`}
									TextSize={16}
									Font="GothamBold"
									TextColor3={new Color3(1, 1, 1)}
									Size={new UDim2(0.5, 0, 0, 24)}
									BackgroundTransparency={1}
									TextXAlignment="Left"
									TextYAlignment="Center"
								/>

								<textlabel
									Text={`Max: ${maxResults}`}
									TextSize={11}
									Font="Gotham"
									TextColor3={new Color3(0.5, 0.5, 0.5)}
									Size={new UDim2(0.5, 0, 0, 24)}
									BackgroundTransparency={1}
									TextXAlignment="Right"
									TextYAlignment="Center"
								/>
							</frame>

							<textbox
								Size={new UDim2(1, 0, 0, 34)}
								PlaceholderText="Search results..."
								Text={searchQuery}
								TextSize={13}
								Font="Gotham"
								TextColor3={new Color3(1, 1, 1)}
								BackgroundColor3={new Color3(0.08, 0.08, 0.08)}
								BorderSizePixel={0}
								TextXAlignment="Left"
								ClearTextOnFocus={false}
								Change={{
									Text: (rbx) => setSearchQuery(rbx.Text),
								}}
							>
								<uicorner CornerRadius={new UDim(0, 8)} />
								<uipadding PaddingLeft={new UDim(0, 12)} PaddingRight={new UDim(0, 12)} />
								<uistroke Color={new Color3(0.15, 0.15, 0.15)} Thickness={1} />
							</textbox>
						</frame>

						{/* Status or Results */}
						{isScanning ? (
							<frame Size={new UDim2(1, 0, 0, 80)} BackgroundColor3={new Color3(0.08, 0.08, 0.08)} BorderSizePixel={0}>
								<uicorner CornerRadius={new UDim(0, 10)} />
								<textlabel
									Text="Scanning garbage collector..."
									TextSize={15}
									Font="GothamBold"
									TextColor3={new Color3(0.5, 0.7, 1)}
									Size={new UDim2(1, 0, 1, 0)}
									BackgroundTransparency={1}
									TextXAlignment="Center"
									TextYAlignment="Center"
								/>
							</frame>
						) : filteredResults.size() === 0 ? (
							<frame Size={new UDim2(1, 0, 0, 100)} BackgroundColor3={new Color3(0.08, 0.08, 0.08)} BorderSizePixel={0}>
								<uicorner CornerRadius={new UDim(0, 10)} />
								<uilistlayout
									FillDirection={Enum.FillDirection.Vertical}
									HorizontalAlignment={Enum.HorizontalAlignment.Center}
									VerticalAlignment={Enum.VerticalAlignment.Center}
									Padding={new UDim(0, 6)}
								/>
								<textlabel
									Text="No Results"
									TextSize={17}
									Font="GothamBold"
									TextColor3={new Color3(0.8, 0.4, 0.4)}
									Size={new UDim2(1, 0, 0, 22)}
									BackgroundTransparency={1}
									TextXAlignment="Center"
									TextYAlignment="Center"
								/>
								<textlabel
									Text="Try a different scanner or search term"
									TextSize={12}
									Font="Gotham"
									TextColor3={new Color3(0.5, 0.5, 0.5)}
									Size={new UDim2(1, 0, 0, 16)}
									BackgroundTransparency={1}
									TextXAlignment="Center"
									TextYAlignment="Center"
								/>
							</frame>
						) : (
							<scrollingframe
								Size={new UDim2(1, 0, 0, math.min(500, filteredResults.size() * 70))}
								BackgroundColor3={new Color3(0.05, 0.05, 0.05)}
								BorderSizePixel={0}
								ScrollBarThickness={1}
								ScrollBarImageTransparency={0.6}
								CanvasSize={new UDim2(0, 0, 0, filteredResults.size() * 70)}
							>
								<uicorner CornerRadius={new UDim(0, 10)} />
								<uipadding PaddingLeft={new UDim(0, 10)} PaddingRight={new UDim(0, 10)} PaddingTop={new UDim(0, 10)} />
								<uilistlayout FillDirection={Enum.FillDirection.Vertical} Padding={new UDim(0, 6)} />

								{filteredResults.map((result) => (
									<ResultItem
										Key={result.id}
										result={result}
										isSelected={selectedResult?.id === result.id}
										onClick={() => dispatch(setInspectionResultSelected(result))}
									/>
								))}
							</scrollingframe>
						)}
					</frame>
				)}
			</scrollingframe>
		</Container>
	);
}

export default withHooksPure(Inspection);
