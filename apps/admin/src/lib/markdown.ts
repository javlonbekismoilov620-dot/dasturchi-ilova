import DOMPurify from 'dompurify';
import { marked } from 'marked';

/** Renders lesson markdown for preview. Output is sanitised — never trust stored HTML. */
export function renderMarkdown(src: string) {
  const html = marked.parse(src.replace(/^> \[!(NOTE|TIP|WARNING|IMPORTANT)\]\s*$/gim, '> **$1**'), { async: false, gfm: true }) as string;
  return DOMPurify.sanitize(html);
}
