import type { MetadataRoute } from "next";
import { siteUrl } from "@/lib/links";
import { sitemapRoutes } from "@/lib/nav";

export const dynamic = "force-static";

export default function sitemap(): MetadataRoute.Sitemap {
  return sitemapRoutes.map((route) => ({
    url: route === "/" ? siteUrl : `${siteUrl}${route}`,
  }));
}
