import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import NextRoundPlayroom from './nextroundPlayroom';

describe('<NextRoundPlayroom />', () => {
  test('it should mount', () => {
    render(<NextRoundPlayroom />);
    
    const nextroundPlayroom = screen.getByTestId('NextRoundPlayroom');

    expect(nextroundPlayroom).toBeInTheDocument();
  });
});