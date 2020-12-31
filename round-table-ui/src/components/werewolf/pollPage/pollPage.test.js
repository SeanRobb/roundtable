import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import PollPage from './pollPage';

describe('<PollPage />', () => {
  test('it should mount', () => {
    render(<PollPage />);
    
    const PollPage = screen.getByTestId('PollPage');

    expect(PollPage).toBeInTheDocument();
  });
});