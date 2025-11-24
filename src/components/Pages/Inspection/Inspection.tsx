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
	const maxResults = useRootSelector(selectMaxInspectionResults);
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
									if (count >= maxResults) break;
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
									if (count >= maxResults) break;
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
									if (count >= maxResults) break;
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
									if (count >= maxResults) break;
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
		{ type: ScannerType.Upvalue, name: "Upvalue Scanner", icon: "🔍", color: new Color3(0.4, 0.6, 1), desc: "Examine function upvalues" },
		{ type: ScannerType.Constant, name: "Constant Scanner", icon: "📊", color: new Color3(0.6, 0.4, 1), desc: "View function constants" },
		{ type: ScannerType.Script, name: "Script Scanner", icon: "📜", color: new Color3(1, 0.6, 0.4), desc: "Find script instances" },
		{ type: ScannerType.Module, name: "Module Scanner", icon: "📦", color: new Color3(0.4, 1, 0.6), desc: "Discover modules" },
		{ type: ScannerType.Closure, name: "Closure Spy", icon: "🕵️", color: new Color3(1, 0.4, 0.6), desc: "Monitor closures" },
	];

	return (
		<Container>
			<scrollingframe
				Size={new UDim2(1, 0, 1, 0)}
				BackgroundTransparency={1}
				BorderSizePixel={0}
				ScrollBarThickness={4}
				ScrollBarImageTransparency={0.5}
				CanvasSize={new UDim2(0, 0, 0, 0)}
				AutomaticCanvasSize={Enum.AutomaticSize.Y}
			>
				<uipadding PaddingLeft={new UDim(0, 24)} PaddingRight={new UDim(0, 24)} PaddingTop={new UDim(0, 24)} />
				<uilistlayout
					FillDirection={Enum.FillDirection.Vertical}
					HorizontalAlignment={Enum.HorizontalAlignment.Left}
					Padding={new UDim(0, 20)}
				/>

				{/* Header */}
				<frame Size={new UDim2(1, 0, 0, 90)} BackgroundTransparency={1}>
					<uilistlayout
						FillDirection={Enum.FillDirection.Vertical}
						HorizontalAlignment={Enum.HorizontalAlignment.Left}
						Padding={new UDim(0, 8)}
					/>

					<textlabel
						Text="🔬 Inspection Tools"
						TextSize={28}
						Font="GothamBold"
						TextColor3={new Color3(1, 1, 1)}
						Size={new UDim2(1, 0, 0, 36)}
						BackgroundTransparency={1}
						TextXAlignment="Left"
						TextYAlignment="Center"
					/>

					<textlabel
						Text="Advanced runtime introspection for analyzing Lua closures, upvalues, constants, scripts, and modules"
						TextSize={14}
						Font="Gotham"
						TextColor3={new Color3(0.7, 0.7, 0.7)}
						Size={new UDim2(1, 0, 0, 40)}
						BackgroundTransparency={1}
						TextXAlignment="Left"
						TextYAlignment="Top"
						TextWrapped={true}
					/>
				</frame>

				{/* Scanner Buttons Grid */}
				<frame Size={new UDim2(1, 0, 0, 170)} BackgroundTransparency={1}>
					<uilistlayout
						FillDirection={Enum.FillDirection.Vertical}
						HorizontalAlignment={Enum.HorizontalAlignment.Left}
						Padding={new UDim(0, 12)}
					/>

					<textlabel
						Text="Select Scanner"
						TextSize={20}
						Font="GothamBold"
						TextColor3={new Color3(1, 1, 1)}
						Size={new UDim2(1, 0, 0, 28)}
						BackgroundTransparency={1}
						TextXAlignment="Left"
						TextYAlignment="Center"
					/>

					<frame Size={new UDim2(1, 0, 0, 130)} BackgroundTransparency={1}>
						<uigridlayout
							CellSize={new UDim2(0, 190, 0, 60)}
							CellPadding={new UDim2(0, 12, 0, 12)}
						/>

						{scannerInfo.map((scanner) => (
							<Button
								key={scanner.type}
								onClick={() => handleScan(scanner.type)}
								size={new UDim2(0, 190, 0, 60)}
								background={selectedScanner === scanner.type ? scanner.color : new Color3(0.12, 0.12, 0.12)}
								transparency={0}
								cornerRadius={new UDim(0, 10)}
							>
								<frame
									Size={new UDim2(1, 0, 1, 0)}
									BackgroundTransparency={1}
								>
									<uilistlayout
										FillDirection={Enum.FillDirection.Horizontal}
										VerticalAlignment={Enum.VerticalAlignment.Center}
										Padding={new UDim(0, 8)}
									/>
									<uipadding PaddingLeft={new UDim(0, 12)} />

									<textlabel
										Text={scanner.icon}
										TextSize={24}
										Font="Gotham"
										TextColor3={new Color3(1, 1, 1)}
										Size={new UDim2(0, 30, 1, 0)}
										BackgroundTransparency={1}
										TextXAlignment="Center"
										TextYAlignment="Center"
									/>

									<frame Size={new UDim2(1, -42, 1, 0)} BackgroundTransparency={1}>
										<uilistlayout
											FillDirection={Enum.FillDirection.Vertical}
											HorizontalAlignment={Enum.HorizontalAlignment.Left}
											VerticalAlignment={Enum.VerticalAlignment.Center}
											Padding={new UDim(0, 2)}
										/>

										<textlabel
											Text={scanner.name}
											TextSize={14}
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
											TextSize={11}
											Font="Gotham"
											TextColor3={new Color3(0.7, 0.7, 0.7)}
											Size={new UDim2(1, 0, 0, 14)}
											BackgroundTransparency={1}
											TextXAlignment="Left"
											TextYAlignment="Center"
											TextTruncate="AtEnd"
										/>
									</frame>
								</frame>

								{/* Glow effect for selected */}
								{selectedScanner === scanner.type && (
									<uistroke
										Color={scanner.color}
										Thickness={2}
										Transparency={0.3}
									/>
								)}
							</Button>
						))}
					</frame>
				</frame>

				{/* Search Bar */}
				{selectedScanner !== ScannerType.None && (
					<frame Size={new UDim2(1, 0, 0, 80)} BackgroundTransparency={1}>
						<uilistlayout
							FillDirection={Enum.FillDirection.Vertical}
							HorizontalAlignment={Enum.HorizontalAlignment.Left}
							Padding={new UDim(0, 10)}
						/>

						<frame Size={new UDim2(1, 0, 0, 32)} BackgroundTransparency={1}>
							<uilistlayout
								FillDirection={Enum.FillDirection.Horizontal}
								VerticalAlignment={Enum.VerticalAlignment.Center}
								Padding={new UDim(0, 10)}
							/>

							<textlabel
								Text="🔎 Search Results"
								TextSize={18}
								Font="GothamBold"
								TextColor3={new Color3(1, 1, 1)}
								Size={new UDim2(0, 180, 0, 32)}
								BackgroundTransparency={1}
								TextXAlignment="Left"
								TextYAlignment="Center"
							/>

							<textlabel
								Text={`Found: ${filteredResults.size()} / ${scanResults.size()}`}
								TextSize={14}
								Font="GothamBold"
								TextColor3={new Color3(0.4, 0.8, 1)}
								Size={new UDim2(1, -190, 0, 32)}
								BackgroundTransparency={1}
								TextXAlignment="Left"
								TextYAlignment="Center"
							/>
						</frame>

						<textbox
							Size={new UDim2(1, 0, 0, 38)}
							PlaceholderText="🔍 Type to search..."
							Text={searchQuery}
							TextSize={14}
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
							<uipadding PaddingLeft={new UDim(0, 14)} PaddingRight={new UDim(0, 14)} />
							<uistroke Color={new Color3(0.2, 0.2, 0.2)} Thickness={1} />
						</textbox>
					</frame>
				)}

				{/* Status Messages */}
				{isScanning && (
					<frame Size={new UDim2(1, 0, 0, 60)} BackgroundColor3={new Color3(0.1, 0.1, 0.1)} BorderSizePixel={0}>
						<uicorner CornerRadius={new UDim(0, 10)} />
						<textlabel
							Text="⏳ Scanning..."
							TextSize={16}
							Font="GothamBold"
							TextColor3={new Color3(0.4, 0.8, 1)}
							Size={new UDim2(1, 0, 1, 0)}
							BackgroundTransparency={1}
							TextXAlignment="Center"
							TextYAlignment="Center"
						/>
					</frame>
				)}

				{!isScanning && selectedScanner !== ScannerType.None && filteredResults.size() === 0 && (
					<frame Size={new UDim2(1, 0, 0, 80)} BackgroundColor3={new Color3(0.1, 0.1, 0.1)} BorderSizePixel={0}>
						<uicorner CornerRadius={new UDim(0, 10)} />
						<uilistlayout
							FillDirection={Enum.FillDirection.Vertical}
							HorizontalAlignment={Enum.HorizontalAlignment.Center}
							VerticalAlignment={Enum.VerticalAlignment.Center}
							Padding={new UDim(0, 4)}
						/>
						<textlabel
							Text="❌ No Results Found"
							TextSize={18}
							Font="GothamBold"
							TextColor3={new Color3(1, 0.4, 0.4)}
							Size={new UDim2(1, 0, 0, 24)}
							BackgroundTransparency={1}
							TextXAlignment="Center"
							TextYAlignment="Center"
						/>
						<textlabel
							Text="Try a different scanner or adjust your search"
							TextSize={12}
							Font="Gotham"
							TextColor3={new Color3(0.6, 0.6, 0.6)}
							Size={new UDim2(1, 0, 0, 16)}
							BackgroundTransparency={1}
							TextXAlignment="Center"
							TextYAlignment="Center"
						/>
					</frame>
				)}

				{/* Results */}
				{!isScanning && filteredResults.size() > 0 && (
					<frame Size={new UDim2(1, 0, 0, math.min(600, filteredResults.size() * 84 + 40))} BackgroundTransparency={1}>
						<uilistlayout
							FillDirection={Enum.FillDirection.Vertical}
							HorizontalAlignment={Enum.HorizontalAlignment.Left}
							Padding={new UDim(0, 8)}
						/>

						<frame Size={new UDim2(1, 0, 0, 28)} BackgroundTransparency={1}>
							<uilistlayout
								FillDirection={Enum.FillDirection.Horizontal}
								VerticalAlignment={Enum.VerticalAlignment.Center}
								Padding={new UDim(0, 8)}
							/>

							<textlabel
								Text={`✨ Results (${filteredResults.size()})`}
								TextSize={18}
								Font="GothamBold"
								TextColor3={new Color3(1, 1, 1)}
								Size={new UDim2(0.5, 0, 0, 28)}
								BackgroundTransparency={1}
								TextXAlignment="Left"
								TextYAlignment="Center"
							/>

							<textlabel
								Text={`Max: ${maxResults}`}
								TextSize={12}
								Font="Gotham"
								TextColor3={new Color3(0.5, 0.5, 0.5)}
								Size={new UDim2(0.5, 0, 0, 28)}
								BackgroundTransparency={1}
								TextXAlignment="Right"
								TextYAlignment="Center"
							/>
						</frame>

						<scrollingframe
							Size={new UDim2(1, 0, 0, math.min(560, filteredResults.size() * 84))}
							BackgroundColor3={new Color3(0.06, 0.06, 0.06)}
							BorderSizePixel={0}
							ScrollBarThickness={6}
							ScrollBarImageColor3={new Color3(0.3, 0.3, 0.3)}
							CanvasSize={new UDim2(0, 0, 0, filteredResults.size() * 84)}
						>
							<uicorner CornerRadius={new UDim(0, 10)} />
							<uipadding PaddingLeft={new UDim(0, 12)} PaddingRight={new UDim(0, 12)} PaddingTop={new UDim(0, 12)} />
							<uilistlayout
								FillDirection={Enum.FillDirection.Vertical}
								HorizontalAlignment={Enum.HorizontalAlignment.Left}
								Padding={new UDim(0, 8)}
							/>

							{filteredResults.map((result) => (
								<frame
									Size={new UDim2(1, -8, 0, 76)}
									BackgroundColor3={new Color3(0.11, 0.11, 0.11)}
									BorderSizePixel={0}
									Key={result.id}
								>
									<uicorner CornerRadius={new UDim(0, 8)} />
									<uipadding PaddingLeft={new UDim(0, 14)} PaddingTop={new UDim(0, 10)} PaddingRight={new UDim(0, 14)} />
									<uistroke Color={new Color3(0.2, 0.2, 0.2)} Thickness={1} />

									<uilistlayout
										FillDirection={Enum.FillDirection.Vertical}
										HorizontalAlignment={Enum.HorizontalAlignment.Left}
										Padding={new UDim(0, 5)}
									/>

									<textlabel
										Text={`📌 ${result.name}`}
										TextSize={15}
										Font="GothamBold"
										TextColor3={new Color3(1, 1, 1)}
										Size={new UDim2(1, -10, 0, 18)}
										BackgroundTransparency={1}
										TextXAlignment="Left"
										TextYAlignment="Center"
										TextTruncate="AtEnd"
									/>

									<textlabel
										Text={`Type: ${result.type}`}
										TextSize={12}
										Font="Gotham"
										TextColor3={new Color3(0.5, 0.7, 1)}
										Size={new UDim2(1, -10, 0, 15)}
										BackgroundTransparency={1}
										TextXAlignment="Left"
										TextYAlignment="Center"
										TextTruncate="AtEnd"
									/>

									{result.value !== undefined ? (
										<textlabel
											Text={`Value: ${result.value}`}
											TextSize={11}
											Font="Gotham"
											TextColor3={new Color3(0.7, 0.7, 0.7)}
											Size={new UDim2(1, -10, 0, 13)}
											BackgroundTransparency={1}
											TextXAlignment="Left"
											TextYAlignment="Center"
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
											TextYAlignment="Center"
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
