import { z } from 'zod';

// RF-34. Must match the public.request_status enum in supabase/migrations.
export const requestStatusSchema = z.enum([
  'draft',
  'received',
  'info_requested',
  'quoted',
  'client_interested',
  'visit_scheduled',
  'inspection_done',
  'closed_purchased',
  'closed_no_deal',
  'expired',
]);

export type RequestStatus = z.infer<typeof requestStatusSchema>;
