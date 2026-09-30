import { render, screen } from '@testing-library/react';
import { es } from '../i18n/es';
import { ReferentialNotice } from './ReferentialNotice';

describe('ReferentialNotice (RF-10)', () => {
  it('shows the referential quote notice as a labelled region', () => {
    render(<ReferentialNotice />);
    expect(
      screen.getByRole('complementary', { name: es.referentialNotice.title }),
    ).toBeInTheDocument();
    expect(screen.getByText(es.referentialNotice.body)).toBeInTheDocument();
  });
});
