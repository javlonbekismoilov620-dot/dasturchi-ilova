import { getSupabase } from './supabase';

export interface ChatMessage {
  role: 'user' | 'assistant';
  content: string;
}

/**
 * Sends the conversation to the `assistant` edge function, which holds the provider key
 * server-side (never in the app) and grounds answers in the current lesson's content.
 */
export async function askAssistant(messages: ChatMessage[], lessonId?: string): Promise<string> {
  const { data, error } = await getSupabase().functions.invoke<{ reply: string }>('assistant', {
    body: { messages: messages.slice(-12), lessonId: lessonId ?? null },
  });
  if (error || !data?.reply) throw new Error(error?.message ?? 'assistant_unavailable');
  return data.reply;
}
