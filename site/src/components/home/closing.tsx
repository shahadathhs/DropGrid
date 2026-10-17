import { downloadUrl } from "@/lib/links";

/** The last screenful: one primary button. */
export function Closing() {
  return (
    <section className="wrap py-16 lg:py-32" aria-labelledby="closing-title">
      <div className="reveal flex flex-col items-start gap-6">
        <h2 id="closing-title" className="font-display text-3xl lg:text-5xl">
          Free for Android.
        </h2>
        <a
          href={downloadUrl}
          className="btn-primary px-5 py-3 text-sm font-semibold lg:px-6 lg:py-4 lg:text-base"
        >
          Get the latest build
        </a>
      </div>
    </section>
  );
}
