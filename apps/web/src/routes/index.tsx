import { createFileRoute } from "@tanstack/react-router";
import { StartScreen } from "../components/screens/StartScreen";

export const Route = createFileRoute("/")({ component: StartScreen });
