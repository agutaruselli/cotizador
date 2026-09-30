import { parseEnv } from './env';

describe('parseEnv', () => {
  it('accepts a valid configuration', () => {
    const env = parseEnv({
      VITE_SUPABASE_URL: 'https://example.supabase.co',
      VITE_SUPABASE_ANON_KEY: 'public-key',
    });
    expect(env.VITE_SUPABASE_URL).toBe('https://example.supabase.co');
  });

  it('reports missing variable names without leaking values', () => {
    expect(() => parseEnv({ VITE_SUPABASE_URL: 'not-a-url-secret' })).toThrow(
      /VITE_SUPABASE_URL, VITE_SUPABASE_ANON_KEY/,
    );
    expect(() => parseEnv({ VITE_SUPABASE_URL: 'not-a-url-secret' })).not.toThrow(/secret/);
  });
});
