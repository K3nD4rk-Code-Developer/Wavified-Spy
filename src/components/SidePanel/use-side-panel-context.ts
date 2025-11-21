import Roact from "@rbxts/roact";
import { useContext } from "@rbxts/roact-hooked";

interface SidePanelContextProps {
	upperHidden: boolean;
	upperSize: Roact.Binding<UDim2>;
	setUpperHidden: (hidden: boolean | ((value: boolean) => boolean)) => void;
	setUpperHeight: (height: number) => void;

	middleHidden: boolean;
	middleSize: Roact.Binding<UDim2>;
	middlePosition: Roact.Binding<UDim2>;
	setMiddleHidden: (hidden: boolean | ((value: boolean) => boolean)) => void;
	setMiddleHeight: (height: number) => void;

	lowerHidden: boolean;
	lowerSize: Roact.Binding<UDim2>;
	lowerPosition: Roact.Binding<UDim2>;
	setLowerHidden: (hidden: boolean | ((value: boolean) => boolean)) => void;
	setLowerHeight: (height: number) => void;
}

export const SidePanelContext = Roact.createContext<SidePanelContextProps>(undefined!);

export function useSidePanelContext() {
	return useContext(SidePanelContext);
}
