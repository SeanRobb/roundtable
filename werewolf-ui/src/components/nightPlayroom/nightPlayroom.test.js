import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import NightPlayroom from './nightPlayroom';

describe('<NightPlayroom />', () => {
  test('it should mount', () => {
    render(<NightPlayroom />);
    
    const NightPlayroom = screen.getByTestId('NightPlayroom');

    expect(NightPlayroom).toBeInTheDocument();
  });
});