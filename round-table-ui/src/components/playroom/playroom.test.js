import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import Playroom from './playroom';

describe('<Playroom />', () => {
  test('it should mount', () => {
    render(<Playroom />);
    
    const playroom = screen.getByTestId('Playroom');

    expect(playroom).toBeInTheDocument();
  });
});