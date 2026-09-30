import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import type { Session } from '@supabase/supabase-js';
import { MemoryRouter, Route, Routes } from 'react-router';
import { es } from '../../i18n/es';
import { fetchIsStaff, fetchRequests, getSession, signIn } from './api';
import { LoginPage } from './LoginPage';
import { PanelHomePage } from './PanelHomePage';
import { RequireStaff } from './RequireStaff';

vi.mock('./api', () => ({
  signIn: vi.fn(),
  signOut: vi.fn(),
  getSession: vi.fn(),
  onSessionChange: vi.fn(() => () => undefined),
  fetchIsStaff: vi.fn(),
  fetchRequests: vi.fn(),
}));

const session = { user: { id: 'user-1' } } as Session;

function renderPanel(url: string) {
  render(
    <MemoryRouter initialEntries={[url]}>
      <Routes>
        <Route path="/panel/ingresar" element={<LoginPage />} />
        <Route path="/panel" element={<RequireStaff />}>
          <Route index element={<PanelHomePage />} />
        </Route>
      </Routes>
    </MemoryRouter>,
  );
}

describe('dealer panel access (RF-32)', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('redirects to the login page without a session', async () => {
    vi.mocked(getSession).mockResolvedValue(null);
    renderPanel('/panel');
    expect(await screen.findByRole('heading', { name: es.panel.loginTitle })).toBeInTheDocument();
  });

  it('denies access to signed-in users without a staff profile', async () => {
    vi.mocked(getSession).mockResolvedValue(session);
    vi.mocked(fetchIsStaff).mockResolvedValue(false);
    renderPanel('/panel');
    expect(await screen.findByText(es.panel.notStaff)).toBeInTheDocument();
    expect(fetchRequests).not.toHaveBeenCalled();
  });

  it('shows the requests of a staff user', async () => {
    vi.mocked(getSession).mockResolvedValue(session);
    vi.mocked(fetchIsStaff).mockResolvedValue(true);
    vi.mocked(fetchRequests).mockResolvedValue([
      { id: 'r1', request_number: 7, status: 'received', submitted_at: '2026-09-30T12:00:00Z' },
    ]);
    renderPanel('/panel');
    expect(await screen.findByText('7')).toBeInTheDocument();
    expect(screen.getByText(es.requestStatus.received)).toBeInTheDocument();
  });

  it('shows an error for invalid credentials', async () => {
    vi.mocked(getSession).mockResolvedValue(null);
    vi.mocked(signIn).mockResolvedValue('invalid-credentials');
    renderPanel('/panel/ingresar');

    await userEvent.type(await screen.findByLabelText(es.panel.email), 'dealer@example.com');
    await userEvent.type(screen.getByLabelText(es.panel.password), 'wrong-password');
    await userEvent.click(screen.getByRole('button', { name: es.panel.signIn }));

    expect(await screen.findByText(es.panel.invalidCredentials)).toBeInTheDocument();
  });
});
