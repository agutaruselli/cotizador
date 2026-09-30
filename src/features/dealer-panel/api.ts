import type { Session } from '@supabase/supabase-js';
import { z } from 'zod';
import { requestStatusSchema } from '../../lib/requestStatus';
import { supabase } from '../../lib/supabase';

export type SignInResult = 'ok' | 'invalid-credentials';

export async function signIn(email: string, password: string): Promise<SignInResult> {
  const { error } = await supabase.auth.signInWithPassword({ email, password });
  if (!error) return 'ok';
  if (error.code === 'invalid_credentials') return 'invalid-credentials';
  throw new Error('Sign in failed');
}

export async function signOut(): Promise<void> {
  await supabase.auth.signOut();
}

export async function getSession(): Promise<Session | null> {
  const { data } = await supabase.auth.getSession();
  return data.session;
}

export function onSessionChange(callback: (session: Session | null) => void): () => void {
  const { data } = supabase.auth.onAuthStateChange((_event, session) => {
    callback(session);
  });
  return () => {
    data.subscription.unsubscribe();
  };
}

// RF-32: staff are users with a profile. Email OTP clients have none.
export async function fetchIsStaff(userId: string): Promise<boolean> {
  const { data, error } = await supabase.from('profiles').select('id').eq('id', userId).maybeSingle();
  if (error) throw new Error('Could not load profile');
  return data !== null;
}

const panelRequestSchema = z.object({
  id: z.string(),
  request_number: z.number(),
  status: requestStatusSchema,
  submitted_at: z.string().nullable(),
});

export type PanelRequest = z.infer<typeof panelRequestSchema>;

// Preview of the RF-33 inbox; RLS limits rows to the user's dealer.
export async function fetchRequests(): Promise<PanelRequest[]> {
  const { data, error } = await supabase
    .from('requests')
    .select('id, request_number, status, submitted_at')
    .order('submitted_at', { ascending: false })
    .limit(50);
  if (error) throw new Error('Could not load requests');
  return z.array(panelRequestSchema).parse(data);
}
