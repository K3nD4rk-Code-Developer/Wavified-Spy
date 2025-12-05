import Button from "components/Button";
import Roact from "@rbxts/roact";
import { Instant, Spring } from "@rbxts/flipper";
import { TabType, createTabColumn, pushTab, selectTab, setActiveTab } from "reducers/tab-group";
import { formatEscapes } from "utils/format-escapes";
import { getInstancePath } from "utils/instance-util";
import { makeSelectRemoteLogObject, makeSelectRemoteLogOutgoing, makeSelectRemoteLogType } from "reducers/remote-log";
import { multiply } from "utils/number-util";
import { useCallback, useMemo, useMutable, withHooksPure } from "@rbxts/roact-hooked";
import { useGroupMotor, useSpring } from "@rbxts/roact-hooked-plus";
import { useRootSelector, useRootStore } from "hooks/use-root-store";

interface Props {
	id: string;
	order: number;
	selected: boolean;
	multiSelected: boolean;
	onClick: () => void;
}

const ROW_DEFAULT = [new Spring(1, { frequency: 6 }), new Spring(0, { frequency: 6 })];
const ROW_HOVERED = [new Spring(0.95, { frequency: 6 }), new Spring(0, { frequency: 6 })];
const ROW_PRESSED = [new Instant(0.97), new Instant(0.2)];

function Row({ onClick, id, order, selected, multiSelected }: Props) {
	const store = useRootStore();

	const selectType = useMemo(makeSelectRemoteLogType, []);
	const remoteType = useRootSelector((state) => selectType(state, id));

	const selectObject = useMemo(makeSelectRemoteLogObject, []);
	const remoteObject = useRootSelector((state) => selectObject(state, id));

	const selectOutgoing = useMemo(makeSelectRemoteLogOutgoing, []);
	const outgoing = useRootSelector((state) => selectOutgoing(state, id));

	const [transparency, setGoal] = useGroupMotor([1, 0]);
	const backgroundTransparency = transparency.map((t) => t[0]);
	const foregroundTransparency = transparency.map((t) => t[1]);

	const highlight = useSpring(selected ? 0.95 : 1, { frequency: 6 });
	const yOffset = useSpring(order * (64 + 4), { frequency: 6 });

	const lastClickTime = useMutable(0);
	const openOnDoubleClick = useCallback(() => {
		if (!remoteObject) return;

		const now = tick();

		if (now - lastClickTime.current > 0.3) {
			lastClickTime.current = now;
			return false;
		}

		lastClickTime.current = now;

		if (selectTab(store.getState(), id) === undefined) {
			const tab = createTabColumn(id, remoteObject.Name, remoteType!);
			store.dispatch(pushTab(tab));
		}

		store.dispatch(setActiveTab(id));
		return true;
	}, [id]);

	if (!remoteObject) {
		return <></>;
	}

	return (
		<Button
			onClick={() => {
				setGoal(ROW_HOVERED);
				(!openOnDoubleClick() || selected) && onClick();
			}}
			onPress={() => setGoal(ROW_PRESSED)}
			onHover={() => setGoal(ROW_HOVERED)}
			onHoverEnd={() => setGoal(ROW_DEFAULT)}
			size={new UDim2(1, 0, 0, 64)}
			position={yOffset.map((y) => new UDim2(0, 0, 0, y))}
			transparency={1}
			cornerRadius={new UDim(0, 4)}
			layoutOrder={order}
		>
			{/* Order number - outside the box */}
			<textlabel
				Text={`${order + 1}.`}
				Font="GothamBold"
				TextColor3={new Color3(1, 1, 1)}
				TextTransparency={foregroundTransparency.map((t) => multiply(t, 0.4))}
				TextSize={15}
				TextXAlignment="Right"
				TextYAlignment="Center"
				Size={new UDim2(0, 32, 1, 0)}
				Position={new UDim2(0, 0, 0, 0)}
				BackgroundTransparency={1}
			/>

			{/* Transparent background box - offset to not cover number */}
			<frame
				Size={new UDim2(1, -40, 1, 0)}
				Position={new UDim2(0, 40, 0, 0)}
				BackgroundColor3={new Color3(1, 1, 1)}
				BackgroundTransparency={0.92}
				BorderSizePixel={0}
			>
				<uicorner CornerRadius={new UDim(0, 6)} />
			</frame>

			{/* Hover highlight */}
			<frame
				Size={new UDim2(1, -40, 1, 0)}
				Position={new UDim2(0, 40, 0, 0)}
				BackgroundColor3={new Color3(1, 1, 1)}
				BackgroundTransparency={backgroundTransparency}
				BorderSizePixel={0}
			>
				<uicorner CornerRadius={new UDim(0, 6)} />
			</frame>

			{/* Selection highlight */}
			<frame
				Size={new UDim2(1, -40, 1, 0)}
				Position={new UDim2(0, 40, 0, 0)}
				BackgroundColor3={new Color3(1, 1, 1)}
				BackgroundTransparency={highlight}
			>
				<uicorner CornerRadius={new UDim(0, 6)} />
			</frame>

			{/* Multi-select indicator (blue border) */}
			{multiSelected && (
				<frame
					Size={new UDim2(1, -40, 1, 0)}
					Position={new UDim2(0, 40, 0, 0)}
					BackgroundTransparency={1}
					BorderSizePixel={0}
				>
					<uicorner CornerRadius={new UDim(0, 6)} />
					<uistroke Color={Color3.fromRGB(0, 170, 255)} Thickness={2} />
				</frame>
			)}

			{/* Icon */}
			<imagelabel
				Image={
					remoteType === TabType.Event
						? "rbxassetid://111467142036224"
						: remoteType === TabType.Function
							? "rbxassetid://104664672211257"
							: remoteType === TabType.BindableEvent
								? "rbxassetid://76270109328460"
								: remoteType === TabType.BindableFunction
									? "rbxassetid://87985191222737"
									: ""
				}
				ImageTransparency={foregroundTransparency}
				Size={new UDim2(0, 24, 0, 24)}
				Position={new UDim2(0, 52, 0, 20)}
				BackgroundTransparency={1}
			/>

			{/* Name */}
			<textlabel
				Text={formatEscapes(
					outgoing && outgoing.size() > 0 ? `${remoteObject.Name} • ${outgoing.size()}` : remoteObject.Name,
				)}
				Font="Gotham"
				TextColor3={new Color3(1, 1, 1)}
				TextTransparency={foregroundTransparency}
				TextSize={13}
				TextXAlignment="Left"
				TextYAlignment="Bottom"
				Size={new UDim2(1, -120, 0, 12)}
				Position={new UDim2(0, 86, 0, 18)}
				BackgroundTransparency={1}
			>
				<uigradient
					Transparency={
						new NumberSequence([
							new NumberSequenceKeypoint(0, 0),
							new NumberSequenceKeypoint(0.9, 0),
							new NumberSequenceKeypoint(1, 1),
						])
					}
				/>
			</textlabel>

			{/* Path */}
			<textlabel
				Text={formatEscapes(getInstancePath(remoteObject))}
				Font="Gotham"
				TextColor3={new Color3(1, 1, 1)}
				TextTransparency={foregroundTransparency.map((t) => multiply(t, 0.2))}
				TextSize={11}
				TextXAlignment="Left"
				TextYAlignment="Top"
				Size={new UDim2(1, -120, 0, 12)}
				Position={new UDim2(0, 86, 0, 39)}
				BackgroundTransparency={1}
			>
				<uigradient
					Transparency={
						new NumberSequence([
							new NumberSequenceKeypoint(0, 0),
							new NumberSequenceKeypoint(0.9, 0),
							new NumberSequenceKeypoint(1, 1),
						])
					}
				/>
			</textlabel>

			{/* Right chevron */}
			<imagelabel
				Image="rbxassetid://9913448173"
				ImageTransparency={foregroundTransparency}
				AnchorPoint={new Vector2(1, 0)}
				Size={new UDim2(0, 16, 0, 16)}
				Position={new UDim2(1, -18, 0, 24)}
				BackgroundTransparency={1}
			/>
		</Button>
	);
}

export default withHooksPure(Row);
