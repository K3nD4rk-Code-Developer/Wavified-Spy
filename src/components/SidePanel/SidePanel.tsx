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
const DEFAULT_UPPER_HEIGHT = 200;
const DEFAULT_MIDDLE_HEIGHT = 150;
const DEFAULT_LOWER_HEIGHT = 200;

function SidePanel() {
	const [upperHeight, setUpperHeight] = useBinding(DEFAULT_UPPER_HEIGHT);
	const [middleHeight, setMiddleHeight] = useBinding(DEFAULT_MIDDLE_HEIGHT);
	const [lowerHeight, setLowerHeight] = useBinding(DEFAULT_LOWER_HEIGHT);
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
			Roact.joinBindings([middleHeight, middleAnim]).map(([height, n]) => {
				const middleShown = new UDim2(1, 0, 0, height);
				const middleHidden = new UDim2(1, 0, 0, MIN_PANEL_HEIGHT);
				return middleShown.Lerp(middleHidden, n);
			}),
		[],
	);

	const middlePosition = useMemo(
		() =>
			Roact.joinBindings([lowerHeight, middleHeight, middleAnim, lowerAnim]).map(([lHeight, mHeight, mAnim, lAnim]) => {
				const middleHeightActual = mHeight * (1 - mAnim) + MIN_PANEL_HEIGHT * mAnim;
				const lowerHeightActual = lHeight * (1 - lAnim) + MIN_PANEL_HEIGHT * lAnim;
				return new UDim2(0, 0, 1, -lowerHeightActual - middleHeightActual);
			}),
		[],
	);

	const upperSize = useMemo(
		() =>
			Roact.joinBindings([upperHeight, lowerHeight, middleHeight, upperAnim, lowerAnim, middleAnim]).map(
				([uHeight, lHeight, mHeight, uAnim, lAnim, mAnim]) => {
					const middleHeightActual = mHeight * (1 - mAnim) + MIN_PANEL_HEIGHT * mAnim;
					const lowerHeightActual = lHeight * (1 - lAnim) + MIN_PANEL_HEIGHT * lAnim;
					const upperShown = new UDim2(1, 0, 0, uHeight);
					const upperHidden = new UDim2(1, 0, 0, MIN_PANEL_HEIGHT);
					const lowerHidden = new UDim2(1, 0, 1, -MIN_PANEL_HEIGHT - middleHeightActual);
					return upperShown.Lerp(lowerHidden, lAnim).Lerp(upperHidden, uAnim);
				},
			),
		[],
	);

	return (
		<SidePanelContext.Provider
			value={{
				upperHidden,
				upperSize,
				setUpperHidden,
				setUpperHeight,
				middleHidden,
				middleSize,
				middlePosition,
				setMiddleHidden,
				setMiddleHeight,
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
