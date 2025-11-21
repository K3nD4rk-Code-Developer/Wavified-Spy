import KeybindListener from "components/KeybindListener";
import MainWindow from "components/MainWindow";
import SettingsPersistence from "components/SettingsPersistence";
import Roact from "@rbxts/roact";

export default function App() {
	return (
		<>
			<KeybindListener />
			<MainWindow />
			<SettingsPersistence />
		</>
	);
}
