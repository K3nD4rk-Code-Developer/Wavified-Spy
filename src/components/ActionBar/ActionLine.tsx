import Container from "components/Container";
import Roact from "@rbxts/roact";

interface Props {
	order?: number | Roact.Binding<number>;
}

export default function ActionLine({ order }: Props) {
	return (
		<Container size={new UDim2(0, 13, 0, 32)} order={order}>
			<frame
				BackgroundColor3={new Color3(1, 1, 1)}
				BackgroundTransparency={0.92}
				Size={new UDim2(0, 1, 0, 24)}
				Position={new UDim2(0, 6, 0, 4)}
				BorderSizePixel={0}
			/>
		</Container>
	);
}
