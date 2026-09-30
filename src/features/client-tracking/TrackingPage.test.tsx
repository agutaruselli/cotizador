import { render, screen } from '@testing-library/react';
import { MemoryRouter, Route, Routes } from 'react-router';
import { es } from '../../i18n/es';
import { fetchRequestByToken } from './api';
import { TrackingPage } from './TrackingPage';

vi.mock('./api', () => ({ fetchRequestByToken: vi.fn() }));
const fetchMock = vi.mocked(fetchRequestByToken);

function renderAt(url: string) {
  render(
    <MemoryRouter initialEntries={[url]}>
      <Routes>
        <Route path="/seguimiento" element={<TrackingPage />} />
      </Routes>
    </MemoryRouter>,
  );
}

describe('TrackingPage (RF-13)', () => {
  beforeEach(() => {
    fetchMock.mockReset();
  });

  it('shows the request status for a valid token taken from the URL fragment', async () => {
    fetchMock.mockResolvedValue({
      request_number: 42,
      status: 'received',
      created_at: '2026-09-30T12:00:00Z',
      submitted_at: '2026-09-30T12:00:00Z',
      quote_due_at: null,
    });
    renderAt('/seguimiento#abc');

    expect(await screen.findByText('42')).toBeInTheDocument();
    expect(screen.getByText(es.requestStatus.received)).toBeInTheDocument();
    expect(fetchMock).toHaveBeenCalledWith('abc');
  });

  it('shows the RF-10 notice next to the tracking information', async () => {
    fetchMock.mockResolvedValue(null);
    renderAt('/seguimiento#abc');
    await screen.findByText(es.tracking.notFoundTitle);
    expect(screen.getByText(es.referentialNotice.body)).toBeInTheDocument();
  });

  it('shows not found without calling the API when there is no token', async () => {
    renderAt('/seguimiento');
    expect(await screen.findByText(es.tracking.notFoundTitle)).toBeInTheDocument();
    expect(fetchMock).not.toHaveBeenCalled();
  });

  it('shows a generic error when the API fails', async () => {
    fetchMock.mockRejectedValue(new Error('network'));
    renderAt('/seguimiento#abc');
    expect(await screen.findByText(es.tracking.errorTitle)).toBeInTheDocument();
  });
});
