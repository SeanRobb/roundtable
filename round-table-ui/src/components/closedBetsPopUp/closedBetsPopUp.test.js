import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import ClosedBetsPopup from './closedBetsPopUp';

describe('<ClosedBetsPopUp />', () => {
  test('it should mount', () => {
    render(<ClosedBetsPopUp />);
    
    const closedBetsPopup = screen.getByTestId('ClosedBetsPopUp');

    expect(closedBetsPopup).toBeInTheDocument();
  });
});