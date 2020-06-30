import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import DayPlayroom from './DayPlayroom';

describe('<DayPlayroom />', () => {
  test('it should mount', () => {
    render(<DayPlayroom />);
    
    const DayPlayroom = screen.getByTestId('DayPlayroom');

    expect(DayPlayroom).toBeInTheDocument();
  });
});