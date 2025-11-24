import Button from "components/Button";
import Container from "components/Container";
import Roact from "@rbxts/roact";
import { withHooksPure, useState } from "@rbxts/roact-hooked";
import { useRootSelector } from "hooks/use-root-store";
import { selectMaxInspectionResults } from "reducers/remote-log";

// Declare exploit environment functions
declare const getgc: (() => unknown[]) | undefined;
declare const getupvalues: ((func: Callback) => Map<string, unknown>) | undefined;
declare const getconstants: ((func: Callback) => unknown[]) | undefined;
declare const getinfo: ((func: Callback) => { name?: string; source?: string; short_src?: string; what?: string; nups?: number; linedefined?: number; lastlinedefined?: number }) | undefined;
declare const decompile: ((script: LuaSourceContainer) => string) | undefined;

enum ScannerType {
	None = "none",
	Upvalue = "upvalue",
	Constant = "constant",
	Script = "script",
	Module = "module",
	Closure = "closure",
}

interface ScanResult {
	id: string;
	name: string;
	type: string;
	value?: string;
	details?: string;
	// Raw data for detailed inspection
	rawFunc?: Callback;
	rawScript?: LuaSourceContainer;
	rawUpvalues?: Map<string, unknown>;
	rawConstants?: unknown[];
	rawInfo?: ReturnType<typeof getinfo>;
}

function Inspection() {
	const maxResults = useRootSelector(selectMaxInspectionResults);
	const [selectedScanner, setSelectedScanner] = useState<ScannerType>(ScannerType.None);
	const [scanResults, setScanResults] = useState<ScanResult[]>([]);
	const [isScanning, setIsScanning] = useState(false);
	const [searchQuery, setSearchQuery] = useState("");
	const [selectedResult, setSelectedResult] = useState<ScanResult | undefined>(undefined);

	const handleScan = (scannerType: ScannerType) => {
		setIsScanning(true);
		setSelectedScanner(scannerType);
		setSelectedResult(undefined);
		const results: ScanResult[] = [];

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
		{ type: ScannerType.Upvalue, name: "Upvalue Scanner", icon: "rbxassetid://9887697255", color: new Color3(0.4, 0.6, 1), desc: "Examine function upvalues" },
		{ type: ScannerType.Constant, name: "Constant Scanner", icon: "rbxassetid://9887697099", color: new Color3(0.6, 0.4, 1), desc: "View function constants" },
		{ type: ScannerType.Script, name: "Script Scanner", icon: "rbxassetid://9896665034", color: new Color3(1, 0.6, 0.4), desc: "Find script instances" },
		{ type: ScannerType.Module, name: "Module Scanner", icon: "rbxassetid://9887696628", color: new Color3(0.4, 1, 0.6), desc: "Discover modules" },
		{ type: ScannerType.Closure, name: "Closure Spy", icon: "rbxassetid://9887696242", color: new Color3(1, 0.4, 0.6), desc: "Monitor closures" },
	];

	const renderDetailPanel = () => {
		if (!selectedResult) {
			return (
				<frame Size={new UDim2(1, 0, 1, 0)} BackgroundColor3={new Color3(0.05, 0.05, 0.05)} BorderSizePixel={0}>
					<uicorner CornerRadius={new UDim(0, 10)} />
					<uilistlayout
						FillDirection={Enum.FillDirection.Vertical}
						HorizontalAlignment={Enum.HorizontalAlignment.Center}
						VerticalAlignment={Enum.VerticalAlignment.Center}
						Padding={new UDim(0, 10)}
					/>

					<imagelabel
						Image="rbxassetid://9896633081"
						Size={new UDim2(0, 80, 0, 80)}
						BackgroundTransparency={1}
						ImageColor3={new Color3(0.3, 0.3, 0.3)}
					/>

					<textlabel
						Text="No Selection"
						TextSize={24}
						Font="GothamBold"
						TextColor3={new Color3(0.5, 0.5, 0.5)}
						Size={new UDim2(1, 0, 0, 30)}
						BackgroundTransparency={1}
						TextXAlignment="Center"
						TextYAlignment="Center"
					/>

					<textlabel
						Text="Click on any result to view details"
						TextSize={14}
						Font="Gotham"
						TextColor3={new Color3(0.4, 0.4, 0.4)}
						Size={new UDim2(1, -40, 0, 20)}
						BackgroundTransparency={1}
						TextXAlignment="Center"
						TextYAlignment="Center"
						TextWrapped={true}
					/>
				</frame>
			);
		}

		return (
			<frame Size={new UDim2(1, 0, 1, 0)} BackgroundColor3={new Color3(0.05, 0.05, 0.05)} BorderSizePixel={0}>
				<uicorner CornerRadius={new UDim(0, 10)} />
				<uipadding PaddingLeft={new UDim(0, 20)} PaddingRight={new UDim(0, 20)} PaddingTop={new UDim(0, 20)} PaddingBottom={new UDim(0, 20)} />

				<scrollingframe
					Size={new UDim2(1, 0, 1, 0)}
					BackgroundTransparency={1}
					BorderSizePixel={0}
					ScrollBarThickness={5}
					ScrollBarImageColor3={new Color3(0.3, 0.3, 0.3)}
					CanvasSize={new UDim2(0, 0, 0, 0)}
					AutomaticCanvasSize={Enum.AutomaticSize.Y}
				>
					<uilistlayout
						FillDirection={Enum.FillDirection.Vertical}
						HorizontalAlignment={Enum.HorizontalAlignment.Left}
						Padding={new UDim(0, 16)}
					/>

					{/* Header with close button */}
					<frame Size={new UDim2(1, 0, 0, 36)} BackgroundTransparency={1}>
						<uilistlayout
							FillDirection={Enum.FillDirection.Horizontal}
							VerticalAlignment={Enum.VerticalAlignment.Center}
							HorizontalAlignment={Enum.HorizontalAlignment.Left}
							Padding={new UDim(0, 10)}
						/>

						<textlabel
							Text="Details"
							TextSize={22}
							Font="GothamBold"
							TextColor3={new Color3(1, 1, 1)}
							Size={new UDim2(1, -46, 0, 36)}
							BackgroundTransparency={1}
							TextXAlignment="Left"
							TextYAlignment="Center"
						/>

						<Button
							onClick={() => setSelectedResult(undefined)}
							size={new UDim2(0, 36, 0, 36)}
							background={new Color3(0.15, 0.15, 0.15)}
							transparency={0}
							cornerRadius={new UDim(0, 8)}
						>
							<textlabel
								Text="✕"
								TextSize={18}
								Font="GothamBold"
								TextColor3={new Color3(0.8, 0.3, 0.3)}
								Size={new UDim2(1, 0, 1, 0)}
								BackgroundTransparency={1}
								TextXAlignment="Center"
								TextYAlignment="Center"
							/>
						</Button>
					</frame>

					{/* Basic Info Card */}
					<frame Size={new UDim2(1, 0, 0, 100)} BackgroundColor3={new Color3(0.08, 0.08, 0.08)} BorderSizePixel={0}>
						<uicorner CornerRadius={new UDim(0, 10)} />
						<uipadding PaddingLeft={new UDim(0, 16)} PaddingTop={new UDim(0, 14)} PaddingRight={new UDim(0, 16)} />
						<uilistlayout FillDirection={Enum.FillDirection.Vertical} Padding={new UDim(0, 6)} />

						<textlabel
							Text={selectedResult.name}
							TextSize={18}
							Font="GothamBold"
							TextColor3={new Color3(1, 1, 1)}
							Size={new UDim2(1, 0, 0, 22)}
							BackgroundTransparency={1}
							TextXAlignment="Left"
							TextYAlignment="Center"
							TextTruncate="AtEnd"
						/>

						<textlabel
							Text={`Type: ${selectedResult.type}`}
							TextSize={13}
							Font="Gotham"
							TextColor3={new Color3(0.6, 0.8, 1)}
							Size={new UDim2(1, 0, 0, 16)}
							BackgroundTransparency={1}
							TextXAlignment="Left"
							TextYAlignment="Center"
							TextTruncate="AtEnd"
						/>

						{selectedResult.value !== undefined ? (
							<textlabel
								Text={`Path: ${selectedResult.value}`}
								TextSize={12}
								Font="Code"
								TextColor3={new Color3(0.6, 0.6, 0.6)}
								Size={new UDim2(1, 0, 0, 15)}
								BackgroundTransparency={1}
								TextXAlignment="Left"
								TextYAlignment="Center"
								TextTruncate="AtEnd"
							/>
						) : undefined}

						{selectedResult.details !== undefined ? (
							<textlabel
								Text={selectedResult.details}
								TextSize={11}
								Font="Gotham"
								TextColor3={new Color3(0.5, 0.5, 0.5)}
								Size={new UDim2(1, 0, 0, 14)}
								BackgroundTransparency={1}
								TextXAlignment="Left"
								TextYAlignment="Center"
								TextTruncate="AtEnd"
							/>
						) : undefined}
					</frame>

					{/* Upvalues Section */}
					{selectedResult.rawUpvalues && selectedResult.rawUpvalues.size() > 0 && (
						<frame Size={new UDim2(1, 0, 0, math.min(320, selectedResult.rawUpvalues.size() * 32 + 60))} BackgroundColor3={new Color3(0.08, 0.08, 0.08)} BorderSizePixel={0}>
							<uicorner CornerRadius={new UDim(0, 10)} />
							<uipadding PaddingLeft={new UDim(0, 16)} PaddingTop={new UDim(0, 14)} PaddingRight={new UDim(0, 16)} PaddingBottom={new UDim(0, 14)} />

							<textlabel
								Text={`Upvalues (${selectedResult.rawUpvalues.size()})`}
								TextSize={16}
								Font="GothamBold"
								TextColor3={new Color3(0.4, 0.7, 1)}
								Size={new UDim2(1, 0, 0, 24)}
								BackgroundTransparency={1}
								TextXAlignment="Left"
								TextYAlignment="Center"
							/>

							<scrollingframe
								Size={new UDim2(1, 0, 1, -32)}
								Position={new UDim2(0, 0, 0, 32)}
								BackgroundTransparency={1}
								BorderSizePixel={0}
								ScrollBarThickness={4}
								ScrollBarImageColor3={new Color3(0.25, 0.25, 0.25)}
								CanvasSize={new UDim2(0, 0, 0, selectedResult.rawUpvalues.size() * 32)}
							>
								<uilistlayout FillDirection={Enum.FillDirection.Vertical} Padding={new UDim(0, 4)} />

								{(() => {
									const elements: Roact.Element[] = [];
									selectedResult.rawUpvalues.forEach((value, key) => {
										elements.push(
											<frame
												Key={tostring(key)}
												Size={new UDim2(1, -8, 0, 28)}
												BackgroundColor3={new Color3(0.06, 0.06, 0.06)}
												BorderSizePixel={0}
											>
												<uicorner CornerRadius={new UDim(0, 6)} />
												<uipadding PaddingLeft={new UDim(0, 10)} PaddingRight={new UDim(0, 10)} />

												<textlabel
													Text={`${key}: `}
													TextSize={11}
													Font="GothamBold"
													TextColor3={new Color3(0.7, 0.9, 1)}
													Size={new UDim2(0, 100, 1, 0)}
													BackgroundTransparency={1}
													TextXAlignment="Left"
													TextYAlignment="Center"
													TextTruncate="AtEnd"
												/>

												<textlabel
													Text={`${typeOf(value)} = ${tostring(value).sub(1, 40)}`}
													TextSize={11}
													Font="Code"
													TextColor3={new Color3(0.8, 0.8, 0.8)}
													Size={new UDim2(1, -105, 1, 0)}
													Position={new UDim2(0, 105, 0, 0)}
													BackgroundTransparency={1}
													TextXAlignment="Left"
													TextYAlignment="Center"
													TextTruncate="AtEnd"
												/>
											</frame>
										);
									});
									return elements;
								})()}
							</scrollingframe>
						</frame>
					)}

					{/* Constants Section */}
					{selectedResult.rawConstants && selectedResult.rawConstants.size() > 0 && (
						<frame Size={new UDim2(1, 0, 0, math.min(320, selectedResult.rawConstants.size() * 32 + 60))} BackgroundColor3={new Color3(0.08, 0.08, 0.08)} BorderSizePixel={0}>
							<uicorner CornerRadius={new UDim(0, 10)} />
							<uipadding PaddingLeft={new UDim(0, 16)} PaddingTop={new UDim(0, 14)} PaddingRight={new UDim(0, 16)} PaddingBottom={new UDim(0, 14)} />

							<textlabel
								Text={`Constants (${selectedResult.rawConstants.size()})`}
								TextSize={16}
								Font="GothamBold"
								TextColor3={new Color3(0.7, 0.4, 1)}
								Size={new UDim2(1, 0, 0, 24)}
								BackgroundTransparency={1}
								TextXAlignment="Left"
								TextYAlignment="Center"
							/>

							<scrollingframe
								Size={new UDim2(1, 0, 1, -32)}
								Position={new UDim2(0, 0, 0, 32)}
								BackgroundTransparency={1}
								BorderSizePixel={0}
								ScrollBarThickness={4}
								ScrollBarImageColor3={new Color3(0.25, 0.25, 0.25)}
								CanvasSize={new UDim2(0, 0, 0, selectedResult.rawConstants.size() * 32)}
							>
								<uilistlayout FillDirection={Enum.FillDirection.Vertical} Padding={new UDim(0, 4)} />

								{(() => {
									const elements: Roact.Element[] = [];
									for (let i = 0; i < selectedResult.rawConstants.size(); i++) {
										const value = selectedResult.rawConstants[i];
										elements.push(
											<frame
												Key={`constant_${i}`}
												Size={new UDim2(1, -8, 0, 28)}
												BackgroundColor3={new Color3(0.06, 0.06, 0.06)}
												BorderSizePixel={0}
											>
												<uicorner CornerRadius={new UDim(0, 6)} />
												<uipadding PaddingLeft={new UDim(0, 10)} PaddingRight={new UDim(0, 10)} />

												<textlabel
													Text={`[${i + 1}] `}
													TextSize={11}
													Font="GothamBold"
													TextColor3={new Color3(0.9, 0.7, 1)}
													Size={new UDim2(0, 40, 1, 0)}
													BackgroundTransparency={1}
													TextXAlignment="Left"
													TextYAlignment="Center"
												/>

												<textlabel
													Text={`${typeOf(value)} = ${tostring(value).sub(1, 50)}`}
													TextSize={11}
													Font="Code"
													TextColor3={new Color3(0.8, 0.8, 0.8)}
													Size={new UDim2(1, -45, 1, 0)}
													Position={new UDim2(0, 45, 0, 0)}
													BackgroundTransparency={1}
													TextXAlignment="Left"
													TextYAlignment="Center"
													TextTruncate="AtEnd"
												/>
											</frame>
										);
									}
									return elements;
								})()}
							</scrollingframe>
						</frame>
					)}

					{/* Script Viewer */}
					{selectedResult.rawScript && (
						<frame Size={new UDim2(1, 0, 0, 400)} BackgroundColor3={new Color3(0.08, 0.08, 0.08)} BorderSizePixel={0}>
							<uicorner CornerRadius={new UDim(0, 10)} />
							<uipadding PaddingLeft={new UDim(0, 16)} PaddingTop={new UDim(0, 14)} PaddingRight={new UDim(0, 16)} PaddingBottom={new UDim(0, 14)} />

							<textlabel
								Text="Script Source"
								TextSize={16}
								Font="GothamBold"
								TextColor3={new Color3(1, 0.7, 0.4)}
								Size={new UDim2(1, 0, 0, 24)}
								BackgroundTransparency={1}
								TextXAlignment="Left"
								TextYAlignment="Center"
							/>

							<scrollingframe
								Size={new UDim2(1, 0, 1, -32)}
								Position={new UDim2(0, 0, 0, 32)}
								BackgroundColor3={new Color3(0.04, 0.04, 0.04)}
								BorderSizePixel={0}
								ScrollBarThickness={5}
								ScrollBarImageColor3={new Color3(0.25, 0.25, 0.25)}
								CanvasSize={new UDim2(0, 0, 0, 0)}
								AutomaticCanvasSize={Enum.AutomaticSize.Y}
							>
								<uicorner CornerRadius={new UDim(0, 8)} />
								<uipadding PaddingLeft={new UDim(0, 12)} PaddingTop={new UDim(0, 12)} PaddingRight={new UDim(0, 12)} PaddingBottom={new UDim(0, 12)} />

								<textlabel
									Text={(() => {
										if (decompile) {
											const success = pcall(() => decompile(selectedResult.rawScript!));
											if (success[0]) {
												return success[1] as string;
											} else {
												return `-- Failed to decompile\n-- Error: ${tostring(success[1])}`;
											}
										} else {
											return "-- decompile() function not available\n-- Cannot view source code in this environment";
										}
									})()}
									TextSize={11}
									Font="Code"
									TextColor3={new Color3(0.9, 0.9, 0.9)}
									Size={new UDim2(1, 0, 0, 0)}
									AutomaticSize={Enum.AutomaticSize.Y}
									BackgroundTransparency={1}
									TextXAlignment="Left"
									TextYAlignment="Top"
									TextWrapped={true}
								/>
							</scrollingframe>
						</frame>
					)}
				</scrollingframe>
			</frame>
		);
	};

	return (
		<Container>
			<frame Size={new UDim2(1, 0, 1, 0)} BackgroundTransparency={1}>
				<uilistlayout
					FillDirection={Enum.FillDirection.Horizontal}
					HorizontalAlignment={Enum.HorizontalAlignment.Left}
					Padding={new UDim(0, 16)}
				/>

				{/* Left Side - Scanners and Results */}
				<scrollingframe
					Size={new UDim2(0.5, -8, 1, 0)}
					BackgroundTransparency={1}
					BorderSizePixel={0}
					ScrollBarThickness={5}
					ScrollBarImageColor3={new Color3(0.3, 0.3, 0.3)}
					CanvasSize={new UDim2(0, 0, 0, 0)}
					AutomaticCanvasSize={Enum.AutomaticSize.Y}
				>
					<uipadding PaddingLeft={new UDim(0, 20)} PaddingRight={new UDim(0, 8)} PaddingTop={new UDim(0, 20)} PaddingBottom={new UDim(0, 20)} />
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
							CellSize={new UDim2(0.48, 0, 0, 64)}
							CellPadding={new UDim2(0.02, 0, 0, 12)}
						/>

						{scannerInfo.map((scanner) => (
							<Button
								Key={scanner.type}
								onClick={() => handleScan(scanner.type)}
								size={new UDim2(0.48, 0, 0, 64)}
								background={selectedScanner === scanner.type ? scanner.color : new Color3(0.1, 0.1, 0.1)}
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

								{selectedScanner === scanner.type && (
									<uistroke Color={scanner.color} Thickness={2} Transparency={0} />
								)}
							</Button>
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
									ScrollBarThickness={5}
									ScrollBarImageColor3={new Color3(0.3, 0.3, 0.3)}
									CanvasSize={new UDim2(0, 0, 0, filteredResults.size() * 70)}
								>
									<uicorner CornerRadius={new UDim(0, 10)} />
									<uipadding PaddingLeft={new UDim(0, 10)} PaddingRight={new UDim(0, 10)} PaddingTop={new UDim(0, 10)} />
									<uilistlayout FillDirection={Enum.FillDirection.Vertical} Padding={new UDim(0, 6)} />

									{filteredResults.map((result) => {
										const isSelected = selectedResult?.id === result.id;
										return (
											<Button
												Key={result.id}
												onClick={() => setSelectedResult(result)}
												size={new UDim2(1, -6, 0, 64)}
												background={isSelected ? new Color3(0.12, 0.14, 0.18) : new Color3(0.08, 0.08, 0.08)}
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
													TextColor3={new Color3(0.6, 0.7, 0.9)}
													Size={new UDim2(1, 0, 0, 14)}
													BackgroundTransparency={1}
													TextXAlignment="Left"
													TextYAlignment="Center"
													TextTruncate="AtEnd"
												/>

												{result.details !== undefined ? (
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
												) : undefined}

												{isSelected && (
													<uistroke Color={new Color3(0.4, 0.6, 1)} Thickness={2} Transparency={0} />
												)}
											</Button>
										);
									})}
								</scrollingframe>
							)}
						</frame>
					)}
				</scrollingframe>

				{/* Right Side - Detail Panel */}
				<frame Size={new UDim2(0.5, -8, 1, 0)} BackgroundTransparency={1}>
					<uipadding PaddingLeft={new UDim(0, 8)} PaddingRight={new UDim(0, 20)} PaddingTop={new UDim(0, 20)} PaddingBottom={new UDim(0, 20)} />
					{renderDetailPanel()}
				</frame>
			</frame>
		</Container>
	);
}

export default withHooksPure(Inspection);
