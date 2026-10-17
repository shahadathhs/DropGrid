import { Closing } from "@/components/home/closing";
import { Facts } from "@/components/home/facts";
import { Grounds } from "@/components/home/grounds";
import { Hero } from "@/components/home/hero";
import { ModesGlance } from "@/components/home/modes-glance";
import { ScreenTour } from "@/components/home/screen-tour";
import { PageShell } from "@/components/page-shell";

export default function Home() {
  return (
    <PageShell current="/">
      <Hero />
      <ScreenTour />
      <Grounds />
      <ModesGlance />
      <Facts />
      <Closing />
    </PageShell>
  );
}
