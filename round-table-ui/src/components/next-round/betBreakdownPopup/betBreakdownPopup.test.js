import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import BetBreakdownPopup from './betBreakdownPopup';

describe('<betBreakdownPopup />', () => {
  test('it should mount', () => {
    render(<BetBreakdownPopup />);
    
    const betBreakdownPopup = screen.getByTestId('betBreakdownPopup');

    expect(betBreakdownPopup).toBeInTheDocument();
  });
});