import Container from "components/Container";
import FunctionTree from "./FunctionTree";
import Peek from "./Peek";
import Roact from "@rbxts/roact";
import Traceback from "./Traceback";
import { SIDE_PANEL_WIDTH } from "constants";
import { SidePanelContext } from "./use-side-panel-context";
import { useBinding, useMemo, useState, withHooksPure } from "@rbxts/roact-hooked";
import { useSpring } from "@rbxts/roact-hooked-plus";

const MIN_PANEL_HEIGHT = 40;
const MIDDLE_PANEL_HEIGHT = 150;

function SidePanel() {
	const [lowerHeight, setLowerHeight] = useBinding(200);
	const [lowerHidden, setLowerHidden] = useState(false);
	const [middleHidden, setMiddleHidden] = useState(false);
	const [upperHidden, setUpperHidden] = useState(false);

	const lowerAnim = useSpring(lowerHidden ? 1 : 0, { frequency: 8 });
	const middleAnim = useSpring(middleHidden ? 1 : 0, { frequency: 8 });
	const upperAnim = useSpring(upperHidden ? 1 : 0, { frequency: 8 });

	const lowerSize = useMemo(
		() =>
			Roact.joinBindings([lowerHeight, lowerAnim, upperAnim]).map(([height, n, ftn]) => {
				const lowerShown = new UDim2(1, 0, 0, height);
				const lowerHidden = new UDim2(1, 0, 0, MIN_PANEL_HEIGHT);
				const upperHidden = new UDim2(1, 0, 1, -MIN_PANEL_HEIGHT);
				return lowerShown.Lerp(upperHidden, ftn).Lerp(lowerHidden, n);
			}),
		[],
	);

	const lowerPosition = useMemo(
		() =>
			Roact.joinBindings([lowerHeight, lowerAnim, upperAnim]).map(([height, n, ftn]) => {
				const lowerShown = new UDim2(0, 0, 1, -height);
				const lowerHidden = new UDim2(0, 0, 1, -MIN_PANEL_HEIGHT);
				const upperHidden = new UDim2(0, 0, 0, MIN_PANEL_HEIGHT);
				return lowerShown.Lerp(lowerHidden, n).Lerp(upperHidden, ftn);
			}),
		[],
	);

	const middleSize = useMemo(
		() =>
			middleAnim.map((n) => {
				const middleShown = new UDim2(1, 0, 0, MIDDLE_PANEL_HEIGHT);
				const middleHidden = new UDim2(1, 0, 0, MIN_PANEL_HEIGHT);
				return middleShown.Lerp(middleHidden, n);
			}),
		[],
	);

	const middlePosition = useMemo(
		() =>
			Roact.joinBindings([lowerHeight, middleAnim]).map(([lHeight, mAnim]) => {
				const middleHeight = MIDDLE_PANEL_HEIGHT * (1 - mAnim) + MIN_PANEL_HEIGHT * mAnim;
				return new UDim2(0, 0, 1, -lHeight - middleHeight);
			}),
		[],
	);

	const upperSize = useMemo(
		() =>
			Roact.joinBindings([lowerHeight, upperAnim, lowerAnim, middleAnim]).map(([height, n, tn, mAnim]) => {
				const middleHeight = MIDDLE_PANEL_HEIGHT * (1 - mAnim) + MIN_PANEL_HEIGHT * mAnim;
				const upperShown = new UDim2(1, 0, 1, -height - middleHeight);
				const upperHidden = new UDim2(1, 0, 0, MIN_PANEL_HEIGHT);
				const lowerHidden = new UDim2(1, 0, 1, -MIN_PANEL_HEIGHT - middleHeight);
				return upperShown.Lerp(lowerHidden, tn).Lerp(upperHidden, n);
			}),
		[],
	);

	return (
		<SidePanelContext.Provider
			value={{
				upperHidden,
				upperSize,
				setUpperHidden,
				middleHidden,
				middleSize,
				middlePosition,
				setMiddleHidden,
				lowerHidden,
				lowerSize,
				lowerPosition,
				setLowerHidden,
				setLowerHeight,
			}}
		>
			<Container
				anchorPoint={new Vector2(1, 0)}
				size={new UDim2(0, SIDE_PANEL_WIDTH, 1, -84)}
				position={new UDim2(1, 0, 0, 84)}
			>
				<FunctionTree />
				<Peek />
				<Traceback />
			</Container>
		</SidePanelContext.Provider>
	);
}

export default withHooksPure(SidePanel);
