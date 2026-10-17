/**
 * The in-page list: plain anchors. On wide screens it sticks beside the page
 * and, where scroll-driven animation exists, lights the section in view (see
 * .toc in learn.css). Without it the list is simply static.
 */
export function SectionList({ items }: { items: { id: string; label: string }[] }) {
  return (
    <nav aria-label="On this page" className="toc">
      <ul className="flex flex-wrap gap-x-5 gap-y-2 text-sm text-text-muted lg:flex-col lg:gap-y-1">
        {items.map((item, i) => (
          <li key={item.id}>
            <a href={`#${item.id}`} data-s={i + 1} className="block py-1 lg:py-1.5">
              {item.label}
            </a>
          </li>
        ))}
      </ul>
    </nav>
  );
}
