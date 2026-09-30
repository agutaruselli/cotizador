import { z } from 'zod';
import { requestStatusSchema } from '../../lib/requestStatus';
import { supabase } from '../../lib/supabase';

const trackedRequestSchema = z.object({
  request_number: z.number(),
  status: requestStatusSchema,
  created_at: z.string(),
  submitted_at: z.string().nullable(),
  quote_due_at: z.string().nullable(),
});

export type TrackedRequest = z.infer<typeof trackedRequestSchema>;

// RF-13: the token travels in the POST body, never in a URL.
export async function fetchRequestByToken(token: string): Promise<TrackedRequest | null> {
  const response: { data: unknown; error: unknown } = await supabase.rpc('get_request_by_token', {
    p_token: token,
  });
  if (response.error) throw new Error('Could not load tracked request');
  const rows = z.array(trackedRequestSchema).parse(response.data);
  return rows[0] ?? null;
}
