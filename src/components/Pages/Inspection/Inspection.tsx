import Button from "components/Button";
import Container from "components/Container";
import Roact from "@rbxts/roact";
import { withHooksPure, useState } from "@rbxts/roact-hooked";

// Declare exploit environment functions
declare const getgc: (() => unknown[]) | undefined;
declare const getupvalues: ((func: Callback) => Map<string, unknown>) | undefined;
declare const getconstants: ((func: Callback) => unknown[]) | undefined;
declare const getinfo: ((func: Callback) => { name?: string; source?: string; short_src?: string; what?: string; nups?: number }) | undefined;
declare const debug: {
	getupvalue?: (func: Callback, index: number) => LuaTuple<[string, unknown]>;
	getconstant?: (func: Callback, index: number) => unknown;
	getinfo?: (func: Callback) => { name?: string; source?: string; short_src?: string; what?: string; nups?: number };
} | undefined;

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
}

function Inspection() {
	const [selectedScanner, setSelectedScanner] = useState<ScannerType>(ScannerType.None);
	const [scanResults, setScanResults] = useState<ScanResult[]>([]);
	const [isScanning, setIsScanning] = useState(false);
	const [searchQuery, setSearchQuery] = useState("");

	const handleScan = (scannerType: ScannerType) => {
		setIsScanning(true);
		setSelectedScanner(scannerType);
		const results: ScanResult[] = [];

		try {
			switch (scannerType) {
				case ScannerType.Upvalue: {
					// Scan for functions with upvalues
					if (getgc) {
						const gc = getgc();
						let count = 0;
						for (const item of gc) {
							if (typeOf(item) === "function") {
								const func = item as Callback;
								const upvalues = getupvalues?.(func);
								if (upvalues && upvalues.size() > 0) {
									let upvalueList = "";
									upvalues.forEach((value, key) => {
										upvalueList += `${key}: ${typeOf(value)}, `;
									});
									results.push({
										id: `upvalue_${count}`,
										name: getinfo?.(func)?.name ?? `Function_${count}`,
										type: "Function with Upvalues",
										value: `${upvalues.size()} upvalues`,
										details: upvalueList,
									});
									count++;
									if (count >= 100) break; // Limit results
								}
							}
						}
					}
					break;
				}
				case ScannerType.Constant: {
					// Scan for functions with constants
					if (getgc) {
						const gc = getgc();
						let count = 0;
						for (const item of gc) {
							if (typeOf(item) === "function") {
								const func = item as Callback;
								const constants = getconstants?.(func);
								if (constants && constants.size() > 0) {
									let constantList = "";
									for (const value of constants) {
										constantList += `${tostring(value)}, `;
									}
									results.push({
										id: `constant_${count}`,
										name: getinfo?.(func)?.name ?? `Function_${count}`,
										type: "Function with Constants",
										value: `${constants.size()} constants`,
										details: constantList.sub(1, math.min(100, constantList.size())),
									});
									count++;
									if (count >= 100) break; // Limit results
								}
							}
						}
					}
					break;
				}
				case ScannerType.Script: {
					// Scan for LuaSourceContainer instances
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
									});
									count++;
									if (count >= 100) break;
								}
							}
						}
					}
					break;
				}
				case ScannerType.Module: {
					// Scan for ModuleScripts
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
									});
									count++;
									if (count >= 100) break;
								}
							}
						}
					}
					break;
				}
				case ScannerType.Closure: {
					// Scan for closures in garbage collector
					if (getgc) {
						const gc = getgc();
						let count = 0;
						for (const item of gc) {
							if (typeOf(item) === "function") {
								const func = item as Callback;
								const info = getinfo?.(func);
								if (info) {
									results.push({
										id: `closure_${count}`,
										name: info.name ?? `Closure_${count}`,
										type: info.what ?? "Lua",
										value: info.short_src ?? "unknown",
										details: `Upvalues: ${info.nups ?? 0}`,
									});
									count++;
									if (count >= 100) break;
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
				<uipadding PaddingLeft={new UDim(0, 20)} PaddingRight={new UDim(0, 20)} PaddingTop={new UDim(0, 20)} />
				<uilistlayout
					FillDirection={Enum.FillDirection.Vertical}
					HorizontalAlignment={Enum.HorizontalAlignment.Left}
					Padding={new UDim(0, 16)}
				/>

				{/* Title */}
				<textlabel
					Text="Inspection Tools"
					TextSize={24}
					Font="GothamBold"
					TextColor3={new Color3(1, 1, 1)}
					Size={new UDim2(1, 0, 0, 30)}
					BackgroundTransparency={1}
					TextXAlignment="Left"
					TextYAlignment="Top"
				/>

				{/* Description */}
				<textlabel
					Text="Advanced runtime introspection tools for analyzing Lua closures, upvalues, constants, scripts, and modules"
					TextSize={12}
					Font="Gotham"
					TextColor3={new Color3(0.7, 0.7, 0.7)}
					Size={new UDim2(1, 0, 0, 32)}
					BackgroundTransparency={1}
					TextXAlignment="Left"
					TextYAlignment="Top"
					TextWrapped={true}
				/>

				{/* Scanner Buttons */}
				<frame Size={new UDim2(1, 0, 0, 120)} BackgroundTransparency={1}>
					<uilistlayout
						FillDirection={Enum.FillDirection.Vertical}
						HorizontalAlignment={Enum.HorizontalAlignment.Left}
						Padding={new UDim(0, 8)}
					/>

					<textlabel
						Text="Scanners"
						TextSize={18}
						Font="GothamBold"
						TextColor3={new Color3(1, 1, 1)}
						Size={new UDim2(1, 0, 0, 24)}
						BackgroundTransparency={1}
						TextXAlignment="Left"
						TextYAlignment="Top"
					/>

					<frame Size={new UDim2(1, 0, 0, 80)} BackgroundTransparency={1}>
						<uigridlayout
							CellSize={new UDim2(0, 150, 0, 36)}
							CellPadding={new UDim2(0, 8, 0, 8)}
						/>

						<Button
							onClick={() => handleScan(ScannerType.Upvalue)}
							size={new UDim2(0, 150, 0, 36)}
							background={selectedScanner === ScannerType.Upvalue ? new Color3(0.3, 0.7, 0.3) : new Color3(0.2, 0.5, 0.8)}
							transparency={0}
							cornerRadius={new UDim(0, 6)}
						>
							<textlabel
								Text="Upvalue Scanner"
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
							onClick={() => handleScan(ScannerType.Constant)}
							size={new UDim2(0, 150, 0, 36)}
							background={selectedScanner === ScannerType.Constant ? new Color3(0.3, 0.7, 0.3) : new Color3(0.2, 0.5, 0.8)}
							transparency={0}
							cornerRadius={new UDim(0, 6)}
						>
							<textlabel
								Text="Constant Scanner"
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
							onClick={() => handleScan(ScannerType.Script)}
							size={new UDim2(0, 150, 0, 36)}
							background={selectedScanner === ScannerType.Script ? new Color3(0.3, 0.7, 0.3) : new Color3(0.2, 0.5, 0.8)}
							transparency={0}
							cornerRadius={new UDim(0, 6)}
						>
							<textlabel
								Text="Script Scanner"
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
							onClick={() => handleScan(ScannerType.Module)}
							size={new UDim2(0, 150, 0, 36)}
							background={selectedScanner === ScannerType.Module ? new Color3(0.3, 0.7, 0.3) : new Color3(0.2, 0.5, 0.8)}
							transparency={0}
							cornerRadius={new UDim(0, 6)}
						>
							<textlabel
								Text="Module Scanner"
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
							onClick={() => handleScan(ScannerType.Closure)}
							size={new UDim2(0, 150, 0, 36)}
							background={selectedScanner === ScannerType.Closure ? new Color3(0.3, 0.7, 0.3) : new Color3(0.2, 0.5, 0.8)}
							transparency={0}
							cornerRadius={new UDim(0, 6)}
						>
							<textlabel
								Text="Closure Spy"
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

				{/* Search Bar */}
				{selectedScanner !== ScannerType.None && (
					<frame Size={new UDim2(1, 0, 0, 60)} BackgroundTransparency={1}>
						<uilistlayout
							FillDirection={Enum.FillDirection.Vertical}
							HorizontalAlignment={Enum.HorizontalAlignment.Left}
							Padding={new UDim(0, 8)}
						/>

						<textlabel
							Text="Search Results"
							TextSize={16}
							Font="GothamBold"
							TextColor3={new Color3(1, 1, 1)}
							Size={new UDim2(1, 0, 0, 20)}
							BackgroundTransparency={1}
							TextXAlignment="Left"
							TextYAlignment="Top"
						/>

						<textbox
							Size={new UDim2(1, 0, 0, 32)}
							PlaceholderText="Search..."
							Text={searchQuery}
							TextSize={14}
							Font="Gotham"
							TextColor3={new Color3(1, 1, 1)}
							BackgroundColor3={new Color3(0.15, 0.15, 0.15)}
							BorderSizePixel={0}
							TextXAlignment="Left"
							ClearTextOnFocus={false}
							Change={{
								Text: (rbx) => setSearchQuery(rbx.Text),
							}}
						>
							<uicorner CornerRadius={new UDim(0, 6)} />
							<uipadding PaddingLeft={new UDim(0, 10)} PaddingRight={new UDim(0, 10)} />
						</textbox>
					</frame>
				)}

				{/* Results */}
				{isScanning && (
					<textlabel
						Text="Scanning..."
						TextSize={16}
						Font="Gotham"
						TextColor3={new Color3(0.7, 0.7, 0.7)}
						Size={new UDim2(1, 0, 0, 40)}
						BackgroundTransparency={1}
						TextXAlignment="Center"
						TextYAlignment="Center"
					/>
				)}

				{!isScanning && selectedScanner !== ScannerType.None && filteredResults.size() === 0 && (
					<textlabel
						Text="No results found"
						TextSize={16}
						Font="Gotham"
						TextColor3={new Color3(0.7, 0.7, 0.7)}
						Size={new UDim2(1, 0, 0, 40)}
						BackgroundTransparency={1}
						TextXAlignment="Center"
						TextYAlignment="Center"
					/>
				)}

				{!isScanning && filteredResults.size() > 0 && (
					<frame Size={new UDim2(1, 0, 0, math.min(400, filteredResults.size() * 80))} BackgroundTransparency={1}>
						<uilistlayout
							FillDirection={Enum.FillDirection.Vertical}
							HorizontalAlignment={Enum.HorizontalAlignment.Left}
							Padding={new UDim(0, 4)}
						/>

						<textlabel
							Text={`Found ${filteredResults.size()} results`}
							TextSize={14}
							Font="GothamBold"
							TextColor3={new Color3(0.8, 0.8, 0.8)}
							Size={new UDim2(1, 0, 0, 20)}
							BackgroundTransparency={1}
							TextXAlignment="Left"
							TextYAlignment="Top"
						/>

						<scrollingframe
							Size={new UDim2(1, 0, 0, math.min(380, filteredResults.size() * 80))}
							BackgroundTransparency={0.95}
							BackgroundColor3={new Color3(0.1, 0.1, 0.1)}
							BorderSizePixel={0}
							ScrollBarThickness={4}
							CanvasSize={new UDim2(0, 0, 0, filteredResults.size() * 76)}
						>
							<uicorner CornerRadius={new UDim(0, 8)} />
							<uipadding PaddingLeft={new UDim(0, 12)} PaddingRight={new UDim(0, 12)} PaddingTop={new UDim(0, 8)} />
							<uilistlayout
								FillDirection={Enum.FillDirection.Vertical}
								HorizontalAlignment={Enum.HorizontalAlignment.Left}
								Padding={new UDim(0, 4)}
							/>

							{filteredResults.map((result) => (
								<frame
									Size={new UDim2(1, -8, 0, 68)}
									BackgroundColor3={new Color3(0.18, 0.18, 0.18)}
									BorderSizePixel={0}
									Key={result.id}
								>
									<uicorner CornerRadius={new UDim(0, 6)} />
									<uipadding PaddingLeft={new UDim(0, 10)} PaddingTop={new UDim(0, 8)} />

									<uilistlayout
										FillDirection={Enum.FillDirection.Vertical}
										HorizontalAlignment={Enum.HorizontalAlignment.Left}
										Padding={new UDim(0, 4)}
									/>

									<textlabel
										Text={result.name}
										TextSize={14}
										Font="GothamBold"
										TextColor3={new Color3(1, 1, 1)}
										Size={new UDim2(1, -10, 0, 16)}
										BackgroundTransparency={1}
										TextXAlignment="Left"
										TextYAlignment="Top"
										TextTruncate="AtEnd"
									/>

									<textlabel
										Text={`Type: ${result.type}`}
										TextSize={12}
										Font="Gotham"
										TextColor3={new Color3(0.7, 0.8, 1)}
										Size={new UDim2(1, -10, 0, 14)}
										BackgroundTransparency={1}
										TextXAlignment="Left"
										TextYAlignment="Top"
										TextTruncate="AtEnd"
									/>

									{result.value !== undefined ? (
										<textlabel
											Text={`Value: ${result.value}`}
											TextSize={11}
											Font="Gotham"
											TextColor3={new Color3(0.6, 0.6, 0.6)}
											Size={new UDim2(1, -10, 0, 12)}
											BackgroundTransparency={1}
											TextXAlignment="Left"
											TextYAlignment="Top"
											TextTruncate="AtEnd"
										/>
									) : undefined}

									{result.details !== undefined ? (
										<textlabel
											Text={result.details}
											TextSize={10}
											Font="Gotham"
											TextColor3={new Color3(0.5, 0.5, 0.5)}
											Size={new UDim2(1, -10, 0, 12)}
											BackgroundTransparency={1}
											TextXAlignment="Left"
											TextYAlignment="Top"
											TextTruncate="AtEnd"
										/>
									) : undefined}
								</frame>
							))}
						</scrollingframe>
					</frame>
				)}
			</scrollingframe>
		</Container>
	);
}

export default withHooksPure(Inspection);
